import 'dart:async';

import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RankProgressionRepository {
  RankProgressionRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Map<String, String> _lastSyncedFingerprintByUser = <String, String>{};

  Stream<CompetitiveRankSnapshot?> watchCurrentSnapshot() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(null);
    }

    return _progressionDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;
      return CompetitiveRankSnapshot.fromFirestore(data);
    });
  }

  Future<void> syncSnapshot(Player player) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final snapshotRef = _progressionDoc(uid);
    final previousDoc = await snapshotRef.get();
    final previousSnapshot = previousDoc.exists && previousDoc.data() != null
        ? CompetitiveRankSnapshot.fromFirestore(previousDoc.data()!)
        : null;

    final nextSnapshot = evaluateCompetitiveRank(
      player: player,
      previousSnapshot: previousSnapshot,
    );

    final fingerprint = _fingerprintFor(nextSnapshot);
    if (_lastSyncedFingerprintByUser[uid] == fingerprint) {
      return;
    }

    await snapshotRef.set(nextSnapshot.toFirestore(), SetOptions(merge: true));
    _lastSyncedFingerprintByUser[uid] = fingerprint;
  }

  DocumentReference<Map<String, dynamic>> _progressionDoc(String uid) {
    return _firestore.collection('users').doc(uid).collection('progression').doc('current');
  }

  String _fingerprintFor(CompetitiveRankSnapshot snapshot) {
    return [
      snapshot.currentRank,
      snapshot.weekKey,
      snapshot.activeDays,
      snapshot.requiredActiveDays,
      snapshot.requiresBossClear,
      snapshot.bossCompleted,
      snapshot.status.name,
      snapshot.demotionStrikes,
      snapshot.promotionReady,
      snapshot.promotionTargetRank ?? '',
    ].join('|');
  }
}
