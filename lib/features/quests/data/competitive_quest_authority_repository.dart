import 'dart:async';

import 'package:ascend/core/crash/crash_reporting_service.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
  });

  final CompetitiveQuestVerificationStatusResult status;
  final DateTime completedAt;
}

class CompetitiveQuestAuthorityRepository {
  CompetitiveQuestAuthorityRepository({
    FirebaseFunctions? functions,
    AppCrashReporter? crashReporter,
  }) : _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'southamerica-east1'),
       _crashReporter = crashReporter ?? const NoopAppCrashReporter();

  static const Duration _rpcTimeout = Duration(seconds: 6);

  final FirebaseFunctions _functions;
  final AppCrashReporter _crashReporter;

  Future<CompetitiveQuestSessionStartResult> startQuestSession({
    required Quest quest,
  }) async {
    try {
      final callable = _functions.httpsCallable('startCompetitiveQuestSession');
      final response = await callable
          .call(_questPayload(quest))
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
    String? reflectionAnswer,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        'verifyCompetitiveQuestCompletion',
      );
      final response = await callable
          .call(<String, dynamic>{
            ..._questPayload(quest),
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

      return CompetitiveQuestVerificationResult(
        status: status,
        completedAt: completedAt,
      );
    } catch (error, stackTrace) {
      _reportRecoverable(
        error,
        stackTrace,
        stage: 'verify_competitive_quest_completion',
      );
      rethrow;
    }
  }

  Map<String, dynamic> _questPayload(Quest quest) {
    return <String, dynamic>{
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
