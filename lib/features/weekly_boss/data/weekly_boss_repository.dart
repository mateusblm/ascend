import 'dart:async';

import 'package:ascend/core/analytics/analytics_service.dart';
import 'package:ascend/core/crash/crash_reporting_service.dart';
import 'package:ascend/features/auth/data/active_session_repository.dart';
import 'package:ascend/features/profile/data/backend_route_selector.dart';
import 'package:ascend/features/profile/data/java_backend_client.dart';
import 'package:ascend/features/profile/data/player_profile_repository.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum ClaimWeeklyBossRemoteResult { claimed, alreadyCompleted }

class ClaimWeeklyBossCommandResult {
  const ClaimWeeklyBossCommandResult({
    required this.status,
    required this.player,
  });

  final ClaimWeeklyBossRemoteResult status;
  final Player player;
}

class WeeklyBossRepository {
  WeeklyBossRepository(
    this._firestore, {
    FirebaseAuth? auth,
    JavaBackendClient? javaBackendClient,
    ActiveSessionRepository? sessionRepository,
    AppAnalytics? analytics,
    AppCrashReporter? crashReporter,
  }) : _sessionRepository = sessionRepository ?? ActiveSessionRepository(),
       _auth = auth ?? FirebaseAuth.instance,
       _javaBackendClient = BackendRouteSelector.javaClient(javaBackendClient),
       _analytics = analytics ?? const NoopAppAnalytics(),
       _crashReporter = crashReporter ?? const NoopAppCrashReporter();

  final FirebaseFirestore _firestore;
  final ActiveSessionRepository _sessionRepository;
  final FirebaseAuth _auth;
  final JavaBackendClient? _javaBackendClient;
  final AppAnalytics _analytics;
  final AppCrashReporter _crashReporter;

  Stream<RemoteWeeklyBoss?> watchActiveBossForRank(String rank) {
    final normalizedRank = _normalizeRank(rank);
    return _firestore.collection('weekly_bosses').limit(50).snapshots().map((
      snapshot,
    ) {
      final now = DateTime.now();
      final bosses =
          snapshot.docs
              .map(RemoteWeeklyBoss.fromFirestore)
              .where((boss) => _normalizeRank(boss.rank) == normalizedRank)
              .where(
                (boss) => boss.isActive && _isWithinActiveWindow(now, boss),
              )
              .toList()
            ..sort((a, b) => a.endsAt.compareTo(b.endsAt));

      if (kDebugMode) {
        debugPrint(
          '[WeeklyBossRepository] rank=$normalizedRank activeNow=${bosses.length} ids=${bosses.map((boss) => boss.id).join(',')}',
        );
      }

      if (bosses.isEmpty) return null;
      return bosses.first;
    });
  }

  Stream<List<WeeklyBossCompletion>> watchTopCompletions(
    String bossId, {
    int limit = 5,
  }) {
    return _firestore
        .collection('weekly_bosses')
        .doc(bossId)
        .collection('completions')
        .orderBy('completedAt')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(WeeklyBossCompletion.fromFirestore).toList();
        });
  }

  Future<ClaimWeeklyBossCommandResult> claimWeeklyBoss({
    required String bossId,
    required String uid,
    required String fallbackName,
    required String displayName,
    required String photoUrl,
    required String rankAtCompletion,
  }) async {
    await _sessionRepository.registerActiveSession();
    final deviceSessionId = await _sessionRepository.deviceSessionId();
    final javaClient = _javaBackendClientObrigatorio('resgatar boss semanal');
    final idToken = await _idTokenObrigatorio('resgatar boss semanal');

    try {
      final payload = await javaClient.claimWeeklyBoss(
        idToken: idToken,
        deviceSessionId: deviceSessionId,
        bossId: bossId,
        displayName: displayName,
        photoUrl: photoUrl,
        rankAtCompletion: rankAtCompletion,
      );
      return _parseClaimPayload(
        payload,
        bossId: bossId,
        uid: uid,
        fallbackName: fallbackName,
        rankAtCompletion: rankAtCompletion,
        source: 'java',
      );
    } on JavaBackendException catch (error, stackTrace) {
      _reportRecoverable(error, stackTrace, stage: 'claim_weekly_boss_java');
      if (error.isActiveSessionConflict) {
        throw const ActiveSessionConflictException();
      }
      rethrow;
    }
  }

  ClaimWeeklyBossCommandResult _parseClaimPayload(
    Object? payload, {
    required String bossId,
    required String uid,
    required String fallbackName,
    required String rankAtCompletion,
    required String source,
  }) {
    if (payload is! Map) {
      throw StateError('Resposta invalida do claimWeeklyBoss ($source).');
    }

    final status = payload['status'] as String?;
    final profile = payload['profile'];
    if (profile is! Map) {
      throw StateError('Perfil remoto ausente no claim do boss semanal.');
    }
    final player = parsePlayerProfileData(
      Map<String, dynamic>.from(profile.cast<Object?, Object?>()),
      uid: uid,
      fallbackName: fallbackName,
    );
    if (status == 'claimed') {
      unawaited(
        _analytics.logWeeklyBossClaimed(
          bossId: bossId,
          rank: rankAtCompletion,
          status: status!,
        ),
      );
      return ClaimWeeklyBossCommandResult(
        status: ClaimWeeklyBossRemoteResult.claimed,
        player: player,
      );
    }
    if (status == 'already_completed') {
      unawaited(
        _analytics.logWeeklyBossClaimed(
          bossId: bossId,
          rank: rankAtCompletion,
          status: status!,
        ),
      );
      return ClaimWeeklyBossCommandResult(
        status: ClaimWeeklyBossRemoteResult.alreadyCompleted,
        player: player,
      );
    }

    throw StateError(
      'Status desconhecido retornado pelo claimWeeklyBoss: $status',
    );
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
        reason: 'weekly_boss_remote:$stage',
        fatal: false,
      ),
    );
  }

  bool _isWithinActiveWindow(DateTime now, RemoteWeeklyBoss boss) {
    return !boss.startsAt.isAfter(now) && boss.endsAt.isAfter(now);
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

  String _normalizeRank(String rank) => rank.trim().toUpperCase();
}
