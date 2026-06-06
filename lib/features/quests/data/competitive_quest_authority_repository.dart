import 'dart:async';

import 'package:ascend/core/config/java_backend_config.dart';
import 'package:ascend/features/auth/data/active_session_repository.dart';
import 'package:ascend/features/profile/data/player_profile_repository.dart';
import 'package:ascend/features/profile/data/java_backend_client.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/quests/data/quest_sync_repository.dart';
import 'package:ascend/core/crash/crash_reporting_service.dart';
import 'package:ascend/features/quests/domain/competitive_quest_evidence.dart';
import 'package:ascend/features/quests/domain/competitive_quest_template.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum CompetitiveQuestSessionStartStatus { started, alreadyStarted }

class CompetitiveQuestSessionStartResult {
  const CompetitiveQuestSessionStartResult({
    required this.status,
    required this.startedAt,
  });

  final CompetitiveQuestSessionStartStatus status;
  final DateTime startedAt;
}

enum CompetitiveQuestVerificationStatusResult { verified, alreadyVerified }

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

class ReadingQuizAttempt {
  const ReadingQuizAttempt({
    required this.quizId,
    required this.questId,
    required this.topic,
    required this.minimumScore,
    required this.generator,
    required this.expiresAt,
    required this.questions,
  });

  final String quizId;
  final String questId;
  final String topic;
  final int minimumScore;
  final String generator;
  final DateTime expiresAt;
  final List<ReadingQuizQuestion> questions;
}

class ReadingQuizQuestion {
  const ReadingQuizQuestion({required this.id, required this.prompt});

  final String id;
  final String prompt;
}

class CompetitiveQuestAuthorityRepository {
  CompetitiveQuestAuthorityRepository({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
    JavaBackendClient? javaBackendClient,
    ActiveSessionRepository? sessionRepository,
    AppCrashReporter? crashReporter,
  }) : _functions =
           functions ??
           FirebaseFunctions.instanceFor(region: 'southamerica-east1'),
       _auth = auth ?? FirebaseAuth.instance,
       _javaBackendClient =
           javaBackendClient ??
           (JavaBackendConfig.isEnabled
               ? JavaBackendClient(baseUrl: JavaBackendConfig.baseUrl)
               : null),
       _sessionRepository = sessionRepository ?? ActiveSessionRepository(),
       _crashReporter = crashReporter ?? const NoopAppCrashReporter();

  static const Duration _rpcTimeout = Duration(seconds: 6);

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;
  final JavaBackendClient? _javaBackendClient;
  final ActiveSessionRepository _sessionRepository;
  final AppCrashReporter _crashReporter;

  Future<CompetitiveQuestSessionStartResult> startQuestSession({
    required Quest quest,
  }) async {
    try {
      await _sessionRepository.registerActiveSession();
      final javaBackendClient = _javaBackendClient;
      final idToken = await _currentIdToken();
      if (javaBackendClient != null && idToken != null) {
        try {
          final response = await javaBackendClient.startCompetitiveQuestSession(
            idToken: idToken,
            deviceSessionId: await _sessionRepository.deviceSessionId(),
            quest: await _questPayload(
              quest,
              includeVerificationStartedAt: false,
            ),
          );
          return CompetitiveQuestSessionStartResult(
            status: response['status'] == 'already_started'
                ? CompetitiveQuestSessionStartStatus.alreadyStarted
                : CompetitiveQuestSessionStartStatus.started,
            startedAt: _dateTimeFromPayload(response['startedAt']),
          );
        } on JavaBackendException catch (error) {
          if (error.isActiveSessionConflict) {
            throw const ActiveSessionConflictException();
          }
          // Keep Cloud Functions as fallback while the competitive flow is migrating.
        }
      }

      final callable = _functions.httpsCallable('startCompetitiveQuestSession');
      final response = await callable
          .call(await _questPayload(quest, includeVerificationStartedAt: false))
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
    required QuestEvidence evidence,
    String? reflectionAnswer,
  }) async {
    try {
      await _sessionRepository.registerActiveSession();
      final javaBackendClient = _javaBackendClient;
      final idToken = await _currentIdToken();
      final usesBackendReadingQuiz =
          evidence.type == CompetitiveEvidenceType.readingComprehension &&
          evidence.quizId != null &&
          evidence.quizScore == null;
      if (javaBackendClient != null &&
          idToken != null &&
          !usesBackendReadingQuiz) {
        try {
          final response = await javaBackendClient
              .verifyCompetitiveQuestCompletion(
                idToken: idToken,
                deviceSessionId: await _sessionRepository.deviceSessionId(),
                quest: await _questPayload(
                  quest,
                  includeVerificationStartedAt: true,
                ),
                evidence: evidence.toPayload(),
                reflectionAnswer: reflectionAnswer,
              );
          return _verificationResultFromResponse(
            response,
            uid: uid,
            fallbackName: fallbackName,
            fallbackQuestId: quest.id,
          );
        } on JavaBackendException catch (error) {
          if (error.isActiveSessionConflict) {
            throw const ActiveSessionConflictException();
          }
          // Non-session failures fall back to the legacy callable during Phase 9.
        }
      }

      final callable = _functions.httpsCallable(
        'verifyCompetitiveQuestCompletion',
      );
      final response = await callable
          .call(<String, dynamic>{
            ...await _questPayload(quest, includeVerificationStartedAt: true),
            'evidence': evidence.toPayload(),
            if (reflectionAnswer != null) 'reflectionAnswer': reflectionAnswer,
          })
          .timeout(_rpcTimeout);
      final data = response.data;
      if (data is! Map) {
        throw StateError('Resposta invalida ao validar quest competitiva.');
      }

      return _verificationResultFromResponse(
        Map<String, dynamic>.from(data.cast<Object?, Object?>()),
        uid: uid,
        fallbackName: fallbackName,
        fallbackQuestId: quest.id,
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

  CompetitiveQuestVerificationResult _verificationResultFromResponse(
    Map<String, dynamic> data, {
    required String uid,
    required String fallbackName,
    required String fallbackQuestId,
  }) {
    final completedAt = _dateTimeFromPayload(data['completedAt']);
    final status = data['status'] == 'already_verified'
        ? CompetitiveQuestVerificationStatusResult.alreadyVerified
        : CompetitiveQuestVerificationStatusResult.verified;
    final profile = data['profile'];
    final remoteQuest = data['quest'];
    final questId = data['questId'] as String? ?? fallbackQuestId;
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
  }

  Future<ReadingQuizAttempt> startReadingQuizAttempt({
    required Quest quest,
    required String topic,
  }) async {
    try {
      final callable = _functions.httpsCallable('startReadingQuizAttempt');
      await _sessionRepository.registerActiveSession();
      final template = officialTemplateForQuest(quest);
      final response = await callable
          .call(<String, dynamic>{
            'deviceSessionId': await _sessionRepository.deviceSessionId(),
            'deviceLabel': defaultTargetPlatform.name,
            'questId': quest.id,
            if (template != null) 'templateCatalogId': template.id,
            'topic': topic,
          })
          .timeout(_rpcTimeout);
      final data = response.data;
      if (data is! Map) {
        throw StateError('Resposta invalida ao iniciar quiz de leitura.');
      }

      final questionsRaw = data['questions'];
      if (questionsRaw is! List) {
        throw StateError('Payload de quiz de leitura incompleto.');
      }

      return ReadingQuizAttempt(
        quizId: data['quizId'] as String,
        questId: data['questId'] as String,
        topic: data['topic'] as String,
        minimumScore: data['minimumScore'] as int,
        generator: data['generator'] as String? ?? 'unknown',
        expiresAt: _dateTimeFromPayload(data['expiresAt']),
        questions: questionsRaw
            .whereType<Map>()
            .map(
              (question) => ReadingQuizQuestion(
                id: question['id'] as String,
                prompt: question['prompt'] as String,
              ),
            )
            .toList(growable: false),
      );
    } catch (error, stackTrace) {
      if (isActiveSessionConflictError(error)) {
        throw const ActiveSessionConflictException();
      }
      _reportRecoverable(
        error,
        stackTrace,
        stage: 'start_reading_quiz_attempt',
      );
      rethrow;
    }
  }

  Future<String?> _currentIdToken() async {
    return _auth.currentUser?.getIdToken();
  }

  Future<Map<String, dynamic>> _questPayload(
    Quest quest, {
    required bool includeVerificationStartedAt,
  }) async {
    final template = officialTemplateForQuest(quest);
    return <String, dynamic>{
      'deviceSessionId': await _sessionRepository.deviceSessionId(),
      'deviceLabel': defaultTargetPlatform.name,
      'questId': quest.id,
      if (template != null) 'templateCatalogId': template.id,
      'title': quest.title,
      'templateType': quest.templateType.name,
      'verificationMode': quest.verificationMode.name,
      'targetDurationMinutes': quest.targetDurationMinutes,
      'xpReward': quest.xpReward,
      'rewardAttribute': quest.rewardAttribute.name,
      if (includeVerificationStartedAt && quest.verificationStartedAt != null)
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
