import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class WeeklyBossRepository {
  WeeklyBossRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<RemoteWeeklyBoss?> watchActiveBossForRank(String rank) {
    return _firestore
        .collection('weekly_bosses')
        .snapshots()
        .map((snapshot) {
          final bosses = snapshot.docs.map(RemoteWeeklyBoss.fromFirestore).toList();
          final matchingBosses = bosses.where((boss) => boss.rank == rank).toList();
          final activeBosses = matchingBosses.where((boss) => boss.isActive).toList();

          debugPrint(
            '[WeeklyBossRepository] rank=$rank allDocs=${bosses.length} matching=${matchingBosses.length} active=${activeBosses.length} ids=${bosses.map((boss) => boss.id).join(',')}',
          );

          if (activeBosses.isEmpty) return null;
          return activeBosses.first;
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

  Future<bool> submitCompletion({
    required String bossId,
    required String uid,
    required String displayName,
    required String photoUrl,
    required String rankAtCompletion,
  }) async {
    final bossRef = _firestore.collection('weekly_bosses').doc(bossId);
    final completionRef = bossRef.collection('completions').doc(uid);

    return _firestore.runTransaction((transaction) async {
      final completionSnapshot = await transaction.get(completionRef);
      if (completionSnapshot.exists) {
        return false;
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

      return true;
    });
  }
}
