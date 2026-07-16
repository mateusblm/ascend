import 'package:ascend/features/auth/data/active_session_repository.dart';
import 'package:ascend/features/profile/data/backend_route_selector.dart';
import 'package:ascend/features/profile/data/java_backend_client.dart';
import 'package:ascend/features/profile/data/player_profile_repository.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool shouldUploadQuestCacheWhenRemoteMissing(List<Quest> quests) {
  return quests.isNotEmpty;
}

/// O inventario do cliente nao edita ocorrencias recorrentes: elas pertencem ao
/// backend e sao materializadas no dia devido. Reenviar essas ocorrencias faria
/// o app competir com a fonte autoritativa e pode invalidar o payload.
List<Map<String, dynamic>> questSourcesForInventorySync(
  Iterable<Quest> quests,
) => quests
    .where((quest) => quest.recurrenceId == null)
    .map(_questSourceFor)
    .toList(growable: false);

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
    journeyId: data['journeyId'] as String?,
    recurrenceId: data['recurrenceId'] as String?,
    mode: _questModeFrom(data['mode']),
    activityCategoryId: data['activityCategoryId'] as String?,
    activityModalityId: data['activityModalityId'] as String?,
    activityId: data['activityId'] as String?,
    executionType: data['executionType'] as String?,
    activitySchemaVersion:
        (data['activitySchemaVersion'] as num?)?.toInt() ?? 0,
    rewardAttribute: _attributeFrom(data['rewardAttribute']),
    xpReward: ((data['xpReward'] as num?)?.toInt() ?? personalQuestDefaultXp)
        .clamp(personalQuestMinXp, 1000000),
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
    plannedFor: _dateFrom(data['plannedFor']),
    occursOn: _dateFrom(data['occursOn']),
    isCompleted: data['isCompleted'] as bool? ?? false,
    isArchived: data['isArchived'] as bool? ?? false,
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
  QuestSyncRepository({
    FirebaseAuth? auth,
    JavaBackendClient? javaBackendClient,
    required ActiveSessionRepository sessionRepository,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _javaBackendClient = BackendRouteSelector.javaClient(javaBackendClient),
       _sessionRepository = sessionRepository;

  final FirebaseAuth _auth;
  final JavaBackendClient? _javaBackendClient;
  final ActiveSessionRepository _sessionRepository;

  Future<bool> hasInitializedSnapshot(String uid) async {
    return (await _buscarQuests(uid)).isNotEmpty;
  }

  Future<Map<String, dynamic>> registerActivityExecution({
    required Quest quest,
    required String executionId,
    required Map<String, Object?> metrics,
    String? observation,
  }) async {
    final activityId = quest.activityId;
    final executionType = quest.executionType;
    if (!quest.isGuided || activityId == null || executionType == null) {
      throw StateError('Esta missão não possui uma atividade guiada válida.');
    }
    await _sessionRepository.registerActiveSession();
    final client = _javaBackendClientObrigatorio(
      'registrar execução de atividade',
    );
    final idToken = await _idTokenObrigatorio(
      'registrar execução de atividade',
    );
    try {
      return await client.completeActivityExecution(
        idToken: idToken,
        deviceSessionId: await _sessionRepository.deviceSessionId(),
        executionId: executionId,
        questId: quest.id,
        activityId: activityId,
        executionType: executionType,
        schemaVersion: quest.activitySchemaVersion,
        metrics: metrics,
        observation: observation,
      );
    } on JavaBackendException catch (error) {
      if (error.isActiveSessionConflict) {
        throw const ActiveSessionConflictException();
      }
      rethrow;
    }
  }

  Stream<List<Quest>> watchQuests(String uid) {
    return Stream.fromFuture(_buscarQuests(uid));
  }

  Future<void> replaceQuests({
    required String uid,
    required List<Quest> quests,
  }) async {
    try {
      await _sessionRepository.registerActiveSession();
      final deviceSessionId = await _sessionRepository.deviceSessionId();
      final sourceQuests = questSourcesForInventorySync(quests);
      final javaBackendClient = _javaBackendClientObrigatorio(
        'sincronizar inventario de quests',
      );
      final idToken = await _idTokenObrigatorio(
        'sincronizar inventario de quests',
      );

      try {
        await javaBackendClient.syncQuestInventory(
          idToken: idToken,
          deviceSessionId: deviceSessionId,
          quests: sourceQuests,
        );
      } on JavaBackendException catch (error) {
        if (error.isActiveSessionConflict) {
          throw const ActiveSessionConflictException();
        }
        rethrow;
      }
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
    try {
      await _sessionRepository.registerActiveSession();
      final deviceSessionId = await _sessionRepository.deviceSessionId();
      final questSource = _questSourceFor(quest);
      final javaBackendClient = _javaBackendClientObrigatorio(
        'concluir quest pessoal',
      );
      final idToken = await _idTokenObrigatorio('concluir quest pessoal');

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
        rethrow;
      }
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
    try {
      await _sessionRepository.registerActiveSession();
      final deviceSessionId = await _sessionRepository.deviceSessionId();
      final javaBackendClient = _javaBackendClientObrigatorio(
        'revogar conclusao de quest pessoal',
      );
      final idToken = await _idTokenObrigatorio(
        'revogar conclusao de quest pessoal',
      );

      try {
        final response = await javaBackendClient.revokePersonalQuestCompletion(
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
        rethrow;
      }
    } catch (error) {
      if (isActiveSessionConflictError(error)) {
        throw const ActiveSessionConflictException();
      }
      rethrow;
    }
  }

  Future<Quest> archivePersonalQuest({
    required String uid,
    required Quest quest,
  }) => _mutateLifecycle(uid: uid, quest: quest, action: 'arquivar');

  Future<Quest> reschedulePersonalQuest({
    required String uid,
    required Quest quest,
    required DateTime plannedFor,
  }) => _mutateLifecycle(
    uid: uid,
    quest: quest,
    action: 'reagendar',
    plannedFor: plannedFor,
  );

  Future<void> createRecurringQuest({
    required String title,
    required AttributeType attribute,
    required List<int> weekdays,
    String? journeyId,
  }) async {
    await _sessionRepository.registerActiveSession();
    final client = _javaBackendClientObrigatorio('criar rotina semanal');
    final token = await _idTokenObrigatorio('criar rotina semanal');
    await client.createRecurringQuest(
      idToken: token,
      deviceSessionId: await _sessionRepository.deviceSessionId(),
      title: title,
      rewardAttribute: attribute.name,
      weekdays: weekdays,
      journeyId: journeyId,
    );
  }

  Future<void> pauseRecurringQuest(String recurrenceId) async {
    await _sessionRepository.registerActiveSession();
    await _javaBackendClientObrigatorio(
      'pausar rotina semanal',
    ).pauseRecurringQuest(
      idToken: await _idTokenObrigatorio('pausar rotina semanal'),
      deviceSessionId: await _sessionRepository.deviceSessionId(),
      recurrenceId: recurrenceId,
    );
  }

  Future<Quest> _mutateLifecycle({
    required String uid,
    required Quest quest,
    required String action,
    DateTime? plannedFor,
  }) async {
    await _sessionRepository.registerActiveSession();
    final client = _javaBackendClientObrigatorio('$action quest pessoal');
    final token = await _idTokenObrigatorio('$action quest pessoal');
    final sessionId = await _sessionRepository.deviceSessionId();
    final response = action == 'arquivar'
        ? await client.archivePersonalQuest(
            idToken: token,
            deviceSessionId: sessionId,
            questId: quest.id,
          )
        : await client.reschedulePersonalQuest(
            idToken: token,
            deviceSessionId: sessionId,
            questId: quest.id,
            plannedFor: plannedFor!,
          );
    return parseQuestSyncData(response, uid: uid, questId: quest.id);
  }

  Future<List<Quest>> _buscarQuests(String uid) async {
    final token = await _auth.currentUser?.getIdToken();
    if (token == null || token.isEmpty) return const <Quest>[];
    final estado = await _javaBackendClientObrigatorio(
      'carregar quests',
    ).fetchGameState(idToken: token);
    final resposta = estado['quests'];
    if (resposta is! List) return const <Quest>[];
    final quests = resposta
        .whereType<Map>()
        .map((quest) {
          final dados = Map<String, dynamic>.from(
            quest.cast<Object?, Object?>(),
          );
          return parseQuestSyncData(
            dados,
            uid: uid,
            questId: dados['id'] as String? ?? '',
          );
        })
        .toList(growable: false);
    quests.sort(_compareQuestOrder);
    return quests;
  }

  JavaBackendClient _javaBackendClientObrigatorio(String acao) {
    final javaBackendClient = _javaBackendClient;
    if (javaBackendClient == null) {
      throw StateError('Backend Java nao configurado para $acao.');
    }
    return javaBackendClient;
  }

  Future<String> _idTokenObrigatorio(String acao) async {
    final idToken = await _auth.currentUser?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Token Firebase ausente para $acao.');
    }
    return idToken;
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
    'journeyId': quest.journeyId,
    'recurrenceId': quest.recurrenceId,
    'mode': quest.mode.name,
    'activityCategoryId': quest.activityCategoryId,
    'activityModalityId': quest.activityModalityId,
    'activityId': quest.activityId,
    'executionType': quest.executionType,
    'activitySchemaVersion': quest.activitySchemaVersion,
    'rewardAttribute': quest.rewardAttribute.name,
    'xpReward': quest.xpReward,
    'category': 'personal',
    'templateType': quest.templateType.name,
    'verificationMode': quest.verificationMode.name,
    'verificationStatus': quest.verificationStatus.name,
    'targetDurationMinutes': quest.targetDurationMinutes,
    'reflectionPrompt': quest.reflectionPrompt,
    'reflectionAnswer': quest.reflectionAnswer,
    'verificationStartedAt': _timestampOrNull(quest.verificationStartedAt),
    'completedAt': _timestampOrNull(quest.completedAt),
    'verifiedAt': _timestampOrNull(quest.verifiedAt),
    'plannedFor': _timestampOrNull(quest.plannedFor),
    'occursOn': _timestampOrNull(quest.occursOn),
    'isCompleted': quest.isCompleted,
    'isArchived': quest.isArchived,
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
  // O contrato Java valida datas com Instant.parse, que exige offset/fuso.
  return value.toUtc().toIso8601String();
}

DateTime? _dateFrom(Object? value) {
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value);
  }
  if (value is Map) {
    final seconds = value['seconds'] ?? value['_seconds'];
    final nanoseconds = value['nanos'] ?? value['_nanoseconds'] ?? 0;
    if (seconds is num && nanoseconds is num) {
      final milliseconds =
          seconds * Duration.millisecondsPerSecond +
          nanoseconds / Duration.microsecondsPerMillisecond / 1000;
      return DateTime.fromMillisecondsSinceEpoch(
        milliseconds.round(),
        isUtc: true,
      ).toLocal();
    }
  }
  return null;
}

int _compareQuestOrder(Quest left, Quest right) {
  final leftCompleted = left.isCompleted ? 1 : 0;
  final rightCompleted = right.isCompleted ? 1 : 0;
  if (leftCompleted != rightCompleted) {
    return leftCompleted.compareTo(rightCompleted);
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

QuestMode _questModeFrom(Object? value) => value is String
    ? QuestMode.values.where((entry) => entry.name == value).firstOrNull ??
          QuestMode.quick
    : QuestMode.quick;
