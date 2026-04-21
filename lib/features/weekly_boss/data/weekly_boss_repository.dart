import 'dart:async';

import 'package:ascend/core/analytics/analytics_service.dart';
import 'package:ascend/core/crash/crash_reporting_service.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

enum ClaimWeeklyBossRemoteResult {
  claimed,
  alreadyCompleted,
}

class WeeklyBossRepository {
  WeeklyBossRepository(
    this._firestore, {
    FirebaseFunctions? functions,
    AppAnalytics? analytics,
    AppCrashReporter? crashReporter,
  }) : _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'southamerica-east1'),
       _analytics = analytics ?? const NoopAppAnalytics(),
       _crashReporter = crashReporter ?? const NoopAppCrashReporter();

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final AppAnalytics _analytics;
  final AppCrashReporter _crashReporter;

  Stream<RemoteWeeklyBoss?> watchActiveBossForRank(String rank) {
    final normalizedRank = _normalizeRank(rank);
    return _firestore
        .collection('weekly_bosses')
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final bosses = snapshot.docs
              .map(RemoteWeeklyBoss.fromFirestore)
              .where((boss) => _normalizeRank(boss.rank) == normalizedRank)
              .where((boss) => boss.isActive && _isWithinActiveWindow(now, boss))
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

  Stream<List<WeeklyBossCompletion>> watchTopCompletions(String bossId, {int limit = 5}) {
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

  Future<ClaimWeeklyBossRemoteResult> claimWeeklyBoss({
    required String bossId,
    required String displayName,
    required String photoUrl,
    required String rankAtCompletion,
  }) async {
    try {
      final callable = _functions.httpsCallable('claimWeeklyBoss');
      final response = await callable.call(<String, dynamic>{
        'bossId': bossId,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'rankAtCompletion': rankAtCompletion,
      });

      final payload = response.data;
      if (payload is! Map) {
        throw StateError('Resposta invalida da callable claimWeeklyBoss.');
      }

      final status = payload['status'] as String?;
      if (status == 'claimed') {
        unawaited(
          _analytics.logWeeklyBossClaimed(
            bossId: bossId,
            rank: rankAtCompletion,
            status: status!,
          ),
        );
        return ClaimWeeklyBossRemoteResult.claimed;
      }
      if (status == 'already_completed') {
        unawaited(
          _analytics.logWeeklyBossClaimed(
            bossId: bossId,
            rank: rankAtCompletion,
            status: status!,
          ),
        );
        return ClaimWeeklyBossRemoteResult.alreadyCompleted;
      }

      throw StateError('Status desconhecido retornado pela callable: $status');
    } on FirebaseFunctionsException catch (error, stackTrace) {
      _reportRecoverable(error, stackTrace, stage: 'claim_weekly_boss');
      rethrow;
    }
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

  String _normalizeRank(String rank) => rank.trim().toUpperCase();
}
