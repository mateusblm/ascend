import 'package:ascend/features/auth/data/active_session_repository.dart';
import 'package:ascend/features/profile/data/backend_route_selector.dart';
import 'package:ascend/features/profile/data/java_backend_client.dart';
import 'package:ascend/features/profile/data/player_profile_repository.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool shouldUploadQuestCacheWhenRemoteMissing(List<Quest> quests) {
  return quests.isNotEmpty;
}

enum PersonalQuestMutationStatus {
  completed,
  alreadyCompleted,
  revoked,
  alreadyPending,
}

class PersonalQuestMutationResult {
  const PersonalQuestMutationResult({
    required this.status,
    required this.player,
    required this.quest,
  });

  final PersonalQuestMutationStatus status;
  final Player player;
  final Quest quest;
}

Quest parseQuestSyncData(
  Map<String, dynamic> data, {
  required String uid,
  required String questId,
}) {
  return Quest(
    ownerUid: uid,
    id: questId,
    title: (data['title'] as String?)?.trim().isNotEmpty == true
        ? (data['title'] as String).trim()
        : 'Quest',
    rewardAttribute: _attributeFrom(data['rewardAttribute']),
    xpReward: ((data['xpReward'] as num?)?.toInt() ?? personalQuestDefaultXp)
        .clamp(personalQuestMinXp, 1000000),
    category: _categoryFrom(data['category']),
    templateType: _templateTypeFrom(data['templateType']),
    verificationMode: _verificationModeFrom(data['verificationMode']),
    verificationStatus: _verificationStatusFrom(data['verificationStatus']),
    targetDurationMinutes:
        ((data['targetDurationMinutes'] as num?)?.toInt() ?? 0).clamp(0, 1440),
    reflectionPrompt: data['reflectionPrompt'] as String?,
    reflectionAnswer: data['reflectionAnswer'] as String?,
    verificationStartedAt: _dateFrom(data['verificationStartedAt']),
    completedAt: _dateFrom(data['completedAt']),
    verifiedAt: _dateFrom(data['verifiedAt']),
    isCompleted: data['isCompleted'] as bool? ?? false,
    preRewardLevel: (data['preRewardLevel'] as num?)?.toInt(),
    preRewardXp: (data['preRewardXp'] as num?)?.toInt(),
    preRewardMaxXp: (data['preRewardMaxXp'] as num?)?.toInt(),
    preRewardStatPoints: (data['preRewardStatPoints'] as num?)?.toInt(),
    preRewardStrength: (data['preRewardStrength'] as num?)?.toInt(),
    preRewardIntelligence: (data['preRewardIntelligence'] as num?)?.toInt(),
    preRewardVitality: (data['preRewardVitality'] as num?)?.toInt(),
    preRewardAgility: (data['preRewardAgility'] as num?)?.toInt(),
  );
}

class QuestSyncRepository {
  QuestSyncRepository(
    this._firestore, {
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
    JavaBackendClient? javaBackendClient,
    required ActiveSessionRepository sessionRepository,
  }) : _functions =
           functions ??
           FirebaseFunctions.instanceFor(region: 'southamerica-east1'),
       _auth = auth ?? FirebaseAuth.instance,
       _javaBackendClient = BackendRouteSelector.javaClient(javaBackendClient),
       _sessionRepository = sessionRepository;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;
  final JavaBackendClient? _javaBackendClient;
  final ActiveSessionRepository _sessionRepository;

  Future<bool> hasInitializedSnapshot(String uid) async {
    final snapshot = await _metaDoc(uid).get();
    return snapshot.data()?['initialized'] as bool? ?? false;
  }

  Stream<List<Quest>> watchQuests(String uid) {
    return _questsCollection(uid).snapshots().map((snapshot) {
      final quests = snapshot.docs
          .map(
            (doc) => parseQuestSyncData(doc.data(), uid: uid, questId: doc.id),
          )
          .toList(growable: false);
      quests.sort(_compareQuestOrder);
      return quests;
    });
  }

  Future<void> replaceQuests({
    required String uid,
    required List<Quest> quests,
  }) async {
    final callable = _functions.httpsCallable('syncQuestInventoryFromSource');
    try {
      await _sessionRepository.registerActiveSession();
      final deviceSessionId = await _sessionRepository.deviceSessionId();
      final sourceQuests = quests.map(_questSourceFor).toList(growable: false);
      final javaBackendClient = _javaBackendClient;
      final idToken = await _auth.currentUser?.getIdToken();
      if (javaBackendClient != null && idToken != null) {
        try {
          await javaBackendClient.syncQuestInventory(
            idToken: idToken,
            deviceSessionId: deviceSessionId,
            quests: sourceQuests,
          );
          return;
        } on JavaBackendException catch (error) {
          if (error.isActiveSessionConflict) {
            throw const ActiveSessionConflictException();
          }
          if (!BackendRouteSelector.shouldFallbackToFirebase(error)) {
            rethrow;
          }
        }
      }

      await callable.call(<String, dynamic>{
        'deviceSessionId': deviceSessionId,
        'source': <String, dynamic>{'quests': sourceQuests},
      });
    } catch (error) {
      if (isActiveSessionConflictError(error)) {
        throw const ActiveSessionConflictException();
      }
      rethrow;
    }
  }

  Future<PersonalQuestMutationResult> completePersonalQuest({
    required String uid,
    required String fallbackName,
    required Quest quest,
  }) async {
    final callable = _functions.httpsCallable('completePersonalQuest');
    try {
      await _sessionRepository.registerActiveSession();
      final deviceSessionId = await _sessionRepository.deviceSessionId();
      final questSource = _questSourceFor(quest);
      final javaBackendClient = _javaBackendClient;
      final idToken = await _auth.currentUser?.getIdToken();
      if (javaBackendClient != null && idToken != null) {
        try {
          final response = await javaBackendClient.completePersonalQuest(
            idToken: idToken,
            deviceSessionId: deviceSessionId,
            questId: quest.id,
            quest: questSource,
          );
          return _personalQuestMutationFromResponse(
            response,
            uid: uid,
            fallbackName: fallbackName,
            fallbackQuestId: quest.id,
          );
        } on JavaBackendException catch (error) {
          if (error.isActiveSessionConflict) {
            throw const ActiveSessionConflictException();
          }
          if (!BackendRouteSelector.shouldFallbackToFirebase(error)) {
            rethrow;
          }
        }
      }

      final response = await callable.call(<String, dynamic>{
        'deviceSessionId': deviceSessionId,
        'questId': quest.id,
        'quest': questSource,
      });
      return _personalQuestMutationFromResponse(
        response.data,
        uid: uid,
        fallbackName: fallbackName,
        fallbackQuestId: quest.id,
      );
    } catch (error) {
      if (isActiveSessionConflictError(error)) {
        throw const ActiveSessionConflictException();
      }
      rethrow;
    }
  }

  Future<PersonalQuestMutationResult> revokePersonalQuestCompletion({
    required String uid,
    required String fallbackName,
    required Quest quest,
  }) async {
    final callable = _functions.httpsCallable('revokePersonalQuestCompletion');
    try {
      await _sessionRepository.registerActiveSession();
      final deviceSessionId = await _sessionRepository.deviceSessionId();
      final javaBackendClient = _javaBackendClient;
      final idToken = await _auth.currentUser?.getIdToken();
      if (javaBackendClient != null && idToken != null) {
        try {
          final response = await javaBackendClient
              .revokePersonalQuestCompletion(
                idToken: idToken,
                deviceSessionId: deviceSessionId,
                questId: quest.id,
              );
          return _personalQuestMutationFromResponse(
            response,
            uid: uid,
            fallbackName: fallbackName,
            fallbackQuestId: quest.id,
          );
        } on JavaBackendException catch (error) {
          if (error.isActiveSessionConflict) {
            throw const ActiveSessionConflictException();
          }
          if (!BackendRouteSelector.shouldFallbackToFirebase(error)) {
            rethrow;
          }
        }
      }

      final response = await callable.call(<String, dynamic>{
        'deviceSessionId': deviceSessionId,
        'questId': quest.id,
      });
      return _personalQuestMutationFromResponse(
        response.data,
        uid: uid,
        fallbackName: fallbackName,
        fallbackQuestId: quest.id,
      );
    } catch (error) {
      if (isActiveSessionConflictError(error)) {
        throw const ActiveSessionConflictException();
      }
      rethrow;
    }
  }

  CollectionReference<Map<String, dynamic>> _questsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('quests');
  }

  DocumentReference<Map<String, dynamic>> _metaDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('quests_meta')
        .doc('current');
  }
}

PersonalQuestMutationResult _personalQuestMutationFromResponse(
  Object? payload, {
  required String uid,
  required String fallbackName,
  required String fallbackQuestId,
}) {
  if (payload is! Map) {
    throw StateError('Resposta invalida da mutacao de quest pessoal.');
  }
  final profile = payload['profile'];
  final quest = payload['quest'];
  final questId = payload['questId'] as String? ?? fallbackQuestId;
  if (profile is! Map || quest is! Map) {
    throw StateError('Payload remoto incompleto para quest pessoal.');
  }

  final rawStatus = payload['status'] as String?;
  return PersonalQuestMutationResult(
    status: switch (rawStatus) {
      'already_completed' => PersonalQuestMutationStatus.alreadyCompleted,
      'revoked' => PersonalQuestMutationStatus.revoked,
      'already_pending' => PersonalQuestMutationStatus.alreadyPending,
      _ => PersonalQuestMutationStatus.completed,
    },
    player: parsePlayerProfileData(
      Map<String, dynamic>.from(profile.cast<Object?, Object?>()),
      uid: uid,
      fallbackName: fallbackName,
    ),
    quest: parseQuestSyncData(
      Map<String, dynamic>.from(quest.cast<Object?, Object?>()),
      uid: uid,
      questId: questId,
    ),
  );
}

Map<String, dynamic> _questSourceFor(Quest quest) {
  return <String, dynamic>{
    'id': quest.id,
    'title': quest.title,
    'rewardAttribute': quest.rewardAttribute.name,
    'xpReward': quest.xpReward,
    'category': quest.category.name,
    'templateType': quest.templateType.name,
    'verificationMode': quest.verificationMode.name,
    'verificationStatus': quest.verificationStatus.name,
    'targetDurationMinutes': quest.targetDurationMinutes,
    'reflectionPrompt': quest.reflectionPrompt,
    'reflectionAnswer': quest.reflectionAnswer,
    'verificationStartedAt': _timestampOrNull(quest.verificationStartedAt),
    'completedAt': _timestampOrNull(quest.completedAt),
    'verifiedAt': _timestampOrNull(quest.verifiedAt),
    'isCompleted': quest.isCompleted,
    'preRewardLevel': quest.preRewardLevel,
    'preRewardXp': quest.preRewardXp,
    'preRewardMaxXp': quest.preRewardMaxXp,
    'preRewardStatPoints': quest.preRewardStatPoints,
    'preRewardStrength': quest.preRewardStrength,
    'preRewardIntelligence': quest.preRewardIntelligence,
    'preRewardVitality': quest.preRewardVitality,
    'preRewardAgility': quest.preRewardAgility,
  };
}

String? _timestampOrNull(DateTime? value) {
  if (value == null) return null;
  return value.toIso8601String();
}

DateTime? _dateFrom(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

int _compareQuestOrder(Quest left, Quest right) {
  final leftCompleted = left.isCompleted ? 1 : 0;
  final rightCompleted = right.isCompleted ? 1 : 0;
  if (leftCompleted != rightCompleted) {
    return leftCompleted.compareTo(rightCompleted);
  }

  final categoryOrder = left.category.index.compareTo(right.category.index);
  if (categoryOrder != 0) {
    return categoryOrder;
  }

  return left.title.toLowerCase().compareTo(right.title.toLowerCase());
}

AttributeType _attributeFrom(Object? value) {
  if (value is! String) return AttributeType.vitality;

  return AttributeType.values
          .where((entry) => entry.name == value)
          .firstOrNull ??
      AttributeType.vitality;
}

QuestCategory _categoryFrom(Object? value) {
  if (value is! String) return QuestCategory.personal;

  return QuestCategory.values
          .where((entry) => entry.name == value)
          .firstOrNull ??
      QuestCategory.personal;
}

QuestTemplateType _templateTypeFrom(Object? value) {
  if (value is! String) return QuestTemplateType.custom;

  return QuestTemplateType.values
          .where((entry) => entry.name == value)
          .firstOrNull ??
      QuestTemplateType.custom;
}

QuestVerificationMode _verificationModeFrom(Object? value) {
  if (value is! String) return QuestVerificationMode.manual;

  return QuestVerificationMode.values
          .where((entry) => entry.name == value)
          .firstOrNull ??
      QuestVerificationMode.manual;
}

QuestVerificationStatus _verificationStatusFrom(Object? value) {
  if (value is! String) return QuestVerificationStatus.none;

  return QuestVerificationStatus.values
          .where((entry) => entry.name == value)
          .firstOrNull ??
      QuestVerificationStatus.none;
}
