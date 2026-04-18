import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  }) : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

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
        return ClaimWeeklyBossRemoteResult.claimed;
      }
      if (status == 'already_completed') {
        return ClaimWeeklyBossRemoteResult.alreadyCompleted;
      }

      throw StateError('Status desconhecido retornado pela callable: $status');
    } on FirebaseFunctionsException catch (error) {
      if (!_shouldFallbackToClientWrite(error)) {
        rethrow;
      }
      if (kDebugMode) {
        debugPrint(
          '[WeeklyBossRepository] Callable indisponivel (${error.code}). Usando fallback cliente.',
        );
      }
      return _claimWeeklyBossFromClient(
        bossId: bossId,
        displayName: displayName,
        photoUrl: photoUrl,
        rankAtCompletion: rankAtCompletion,
      );
    }
  }

  bool _isWithinActiveWindow(DateTime now, RemoteWeeklyBoss boss) {
    return !boss.startsAt.isAfter(now) && boss.endsAt.isAfter(now);
  }

  String _normalizeRank(String rank) => rank.trim().toUpperCase();

  bool _shouldFallbackToClientWrite(FirebaseFunctionsException error) {
    const fallbackCodes = <String>{
      'not-found',
      'unimplemented',
      'unavailable',
    };
    return fallbackCodes.contains(error.code);
  }

  Future<ClaimWeeklyBossRemoteResult> _claimWeeklyBossFromClient({
    required String bossId,
    required String displayName,
    required String photoUrl,
    required String rankAtCompletion,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Usuario nao autenticado para fallback de claim.');
    }

    final bossRef = _firestore.collection('weekly_bosses').doc(bossId);
    final completionRef = bossRef.collection('completions').doc(uid);

    return _firestore.runTransaction((transaction) async {
      final completionSnapshot = await transaction.get(completionRef);
      if (completionSnapshot.exists) {
        return ClaimWeeklyBossRemoteResult.alreadyCompleted;
      }

      transaction.set(completionRef, {
        'uid': uid,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'rankAtCompletion': rankAtCompletion,
        'completedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(bossRef, {
        'completedCount': FieldValue.increment(1),
      });

      return ClaimWeeklyBossRemoteResult.claimed;
    });
  }
}
