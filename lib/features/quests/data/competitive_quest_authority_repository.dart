import 'dart:async';

import 'package:ascend/features/auth/data/active_session_repository.dart';
import 'package:ascend/features/profile/data/player_profile_repository.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/quests/data/quest_sync_repository.dart';
import 'package:ascend/core/crash/crash_reporting_service.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

enum CompetitiveQuestSessionStartStatus {
  started,
  alreadyStarted,
}

class CompetitiveQuestSessionStartResult {
  const CompetitiveQuestSessionStartResult({
    required this.status,
    required this.startedAt,
  });

  final CompetitiveQuestSessionStartStatus status;
  final DateTime startedAt;
}

enum CompetitiveQuestVerificationStatusResult {
  verified,
  alreadyVerified,
}

class CompetitiveQuestVerificationResult {
  const CompetitiveQuestVerificationResult({
    required this.status,
    required this.completedAt,
    required this.player,
    required this.quest,
  });

  final CompetitiveQuestVerificationStatusResult status;
  final DateTime completedAt;
  final Player player;
  final Quest quest;
}

class CompetitiveQuestAuthorityRepository {
  CompetitiveQuestAuthorityRepository({
    FirebaseFunctions? functions,
    ActiveSessionRepository? sessionRepository,
    AppCrashReporter? crashReporter,
  }) : _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'southamerica-east1'),
       _sessionRepository = sessionRepository ?? ActiveSessionRepository(),
       _crashReporter = crashReporter ?? const NoopAppCrashReporter();

  static const Duration _rpcTimeout = Duration(seconds: 6);

  final FirebaseFunctions _functions;
  final ActiveSessionRepository _sessionRepository;
  final AppCrashReporter _crashReporter;

  Future<CompetitiveQuestSessionStartResult> startQuestSession({
    required Quest quest,
  }) async {
    try {
      final callable = _functions.httpsCallable('startCompetitiveQuestSession');
      final response = await callable
          .call(await _questPayload(quest))
          .timeout(_rpcTimeout);
      final data = response.data;
      if (data is! Map) {
        throw StateError('Resposta invalida ao iniciar sessao competitiva.');
      }

      final startedAtRaw = data['startedAt'];
      final startedAt = _dateTimeFromPayload(startedAtRaw);
      final status = data['status'] == 'already_started'
          ? CompetitiveQuestSessionStartStatus.alreadyStarted
          : CompetitiveQuestSessionStartStatus.started;

      return CompetitiveQuestSessionStartResult(
        status: status,
        startedAt: startedAt,
      );
    } catch (error, stackTrace) {
      if (isActiveSessionConflictError(error)) {
        throw const ActiveSessionConflictException();
      }
      _reportRecoverable(
        error,
        stackTrace,
        stage: 'start_competitive_quest_session',
      );
      rethrow;
    }
  }

  Future<CompetitiveQuestVerificationResult> verifyQuestCompletion({
    required Quest quest,
    required String uid,
    required String fallbackName,
    String? reflectionAnswer,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        'verifyCompetitiveQuestCompletion',
      );
      final response = await callable
          .call(<String, dynamic>{
            ...await _questPayload(quest),
            if (reflectionAnswer != null) 'reflectionAnswer': reflectionAnswer,
          })
          .timeout(_rpcTimeout);
      final data = response.data;
      if (data is! Map) {
        throw StateError('Resposta invalida ao validar quest competitiva.');
      }

      final completedAt = _dateTimeFromPayload(data['completedAt']);
      final status = data['status'] == 'already_verified'
          ? CompetitiveQuestVerificationStatusResult.alreadyVerified
          : CompetitiveQuestVerificationStatusResult.verified;
      final profile = data['profile'];
      final remoteQuest = data['quest'];
      final questId = data['questId'] as String? ?? quest.id;
      if (profile is! Map || remoteQuest is! Map) {
        throw StateError('Payload remoto incompleto para quest competitiva.');
      }

      return CompetitiveQuestVerificationResult(
        status: status,
        completedAt: completedAt,
        player: parsePlayerProfileData(
          Map<String, dynamic>.from(profile.cast<Object?, Object?>()),
          uid: uid,
          fallbackName: fallbackName,
        ),
        quest: parseQuestSyncData(
          Map<String, dynamic>.from(remoteQuest.cast<Object?, Object?>()),
          uid: uid,
          questId: questId,
        ),
      );
    } catch (error, stackTrace) {
      if (isActiveSessionConflictError(error)) {
        throw const ActiveSessionConflictException();
      }
      _reportRecoverable(
        error,
        stackTrace,
        stage: 'verify_competitive_quest_completion',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _questPayload(Quest quest) async {
    return <String, dynamic>{
      'deviceSessionId': await _sessionRepository.deviceSessionId(),
      'deviceLabel': defaultTargetPlatform.name,
      'questId': quest.id,
      'title': quest.title,
      'templateType': quest.templateType.name,
      'verificationMode': quest.verificationMode.name,
      'targetDurationMinutes': quest.targetDurationMinutes,
      'xpReward': quest.xpReward,
      'rewardAttribute': quest.rewardAttribute.name,
      if (quest.verificationStartedAt != null)
        'verificationStartedAt': quest.verificationStartedAt!.toIso8601String(),
    };
  }

  DateTime _dateTimeFromPayload(Object? raw) {
    if (raw is String) {
      return DateTime.parse(raw).toLocal();
    }
    throw StateError('Timestamp remoto invalido.');
  }

  void _reportRecoverable(
    Object error,
    StackTrace stackTrace, {
    required String stage,
  }) {
    unawaited(
      _crashReporter.recordError(
        error,
        stackTrace,
        reason: 'competitive_quest_authority:$stage',
        fatal: false,
      ),
    );
  }
}
