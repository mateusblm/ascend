import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

bool shouldUploadQuestCacheWhenRemoteMissing(List<Quest> quests) {
  return quests.isNotEmpty;
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
  QuestSyncRepository(this._firestore);

  final FirebaseFirestore _firestore;

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
    final collection = _questsCollection(uid);
    final metaDoc = _metaDoc(uid);
    final previousDocs = await collection.get();
    final nextIds = quests.map((quest) => quest.id).toSet();
    final batch = _firestore.batch();

    for (final doc in previousDocs.docs) {
      if (!nextIds.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }

    for (var index = 0; index < quests.length; index++) {
      final quest = quests[index];
      batch.set(collection.doc(quest.id), _toFirestore(quest, index: index));
    }

    batch.set(metaDoc, <String, dynamic>{
      'initialized': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
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

Map<String, dynamic> _toFirestore(Quest quest, {required int index}) {
  return <String, dynamic>{
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
    'orderIndex': index,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

Timestamp? _timestampOrNull(DateTime? value) {
  if (value == null) return null;
  return Timestamp.fromDate(value);
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
