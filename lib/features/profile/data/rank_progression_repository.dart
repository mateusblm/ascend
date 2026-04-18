import 'dart:async';

import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/promotion_exam.dart';
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

  Stream<List<CompetitiveRankSnapshot>> watchRecentHistory({int limit = 6}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(const <CompetitiveRankSnapshot>[]);
    }

    return _historyCollection(uid)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CompetitiveRankSnapshot.fromFirestore(doc.data()))
              .toList();
        });
  }

  Stream<PromotionExam?> watchCurrentPromotionExam() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(null);
    }

    return _promotionExamDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;
      return PromotionExam.fromFirestore(data);
    });
  }

  Future<CompetitiveRankSnapshot?> syncSnapshot(Player player) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

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
      return nextSnapshot;
    }

    final historyRef = _historyCollection(uid).doc(nextSnapshot.weekKey);
    final batch = _firestore.batch();
    batch.set(snapshotRef, nextSnapshot.toFirestore(), SetOptions(merge: true));
    batch.set(historyRef, nextSnapshot.toFirestore(), SetOptions(merge: true));
    await batch.commit();
    _lastSyncedFingerprintByUser[uid] = fingerprint;
    return nextSnapshot;
  }

  Future<void> syncPromotionExam(CompetitiveRankSnapshot snapshot) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final examRef = _promotionExamDoc(uid);
    final examDoc = await examRef.get();
    if (!examDoc.exists || examDoc.data() == null) return;

    final exam = PromotionExam.fromFirestore(examDoc.data()!);
    if (exam.status != PromotionExamStatus.inProgress) return;

    final now = DateTime.now();
    if (snapshot.weekKey != exam.sourceWeekKey || now.isAfter(exam.expiresAt)) {
      await examRef.set(
        exam.copyWith(status: PromotionExamStatus.failed, resolvedAt: now).toFirestore(),
        SetOptions(merge: true),
      );
      return;
    }

    final passed = snapshot.activeDays >= exam.targetActiveDays &&
        (!exam.bossRequired || snapshot.bossCompleted);
    if (!passed) return;

    await examRef.set(
      exam.copyWith(status: PromotionExamStatus.passed, resolvedAt: now).toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<bool> startPromotionExam(CompetitiveRankSnapshot snapshot) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    if (!snapshot.promotionReady || snapshot.promotionTargetRank == null) return false;

    final examRef = _promotionExamDoc(uid);
    final existing = await examRef.get();
    if (existing.exists && existing.data() != null) {
      final currentExam = PromotionExam.fromFirestore(existing.data()!);
      if (currentExam.status == PromotionExamStatus.inProgress) {
        return false;
      }
    }

    final nextRule = rankRuleFor(snapshot.promotionTargetRank!);
    final now = DateTime.now();
    final exam = PromotionExam(
      sourceRank: snapshot.currentRank,
      targetRank: snapshot.promotionTargetRank!,
      sourceWeekKey: snapshot.weekKey,
      status: PromotionExamStatus.inProgress,
      baselineActiveDays: snapshot.activeDays,
      requiredExtraActiveDays: 1,
      bossRequired: nextRule.requiresBossClear,
      startedAt: now,
      expiresAt: now.add(const Duration(days: 3)),
    );

    await examRef.set(exam.toFirestore(), SetOptions(merge: true));
    return true;
  }

  Future<bool> promoteIfExamPassed(CompetitiveRankSnapshot snapshot) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final examRef = _promotionExamDoc(uid);
    final examDoc = await examRef.get();
    if (!examDoc.exists || examDoc.data() == null) return false;

    final exam = PromotionExam.fromFirestore(examDoc.data()!);
    if (exam.status != PromotionExamStatus.passed) return false;

    final promotedRank = exam.targetRank;
    final promotedRule = rankRuleFor(promotedRank);
    final now = DateTime.now();
    final promotedSnapshot = CompetitiveRankSnapshot(
      currentRank: promotedRank,
      weekKey: snapshot.weekKey,
      activeDays: snapshot.activeDays,
      requiredActiveDays: promotedRule.requiredActiveDays,
      requiresBossClear: promotedRule.requiresBossClear,
      bossCompleted: snapshot.bossCompleted,
      status: RankMaintenanceStatus.secure,
      demotionStrikes: 0,
      promotionReady: false,
      promotionTargetRank: rankAfter(promotedRank),
      summary: 'Promovido para o rank $promotedRank.',
      detail: 'O exame foi concluido e sua promocao agora faz parte do historico competitivo.',
      updatedAt: now,
    );

    final batch = _firestore.batch();
    batch.set(_progressionDoc(uid), promotedSnapshot.toFirestore(), SetOptions(merge: true));
    batch.set(
      _historyCollection(uid).doc(promotedSnapshot.weekKey),
      promotedSnapshot.toFirestore(),
      SetOptions(merge: true),
    );
    batch.set(
      examRef,
      exam.copyWith(status: PromotionExamStatus.promoted, resolvedAt: now).toFirestore(),
      SetOptions(merge: true),
    );
    await batch.commit();
    _lastSyncedFingerprintByUser[uid] = _fingerprintFor(promotedSnapshot);
    return true;
  }

  Future<bool> debugForcePromotionReady(Player player) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final snapshotRef = _progressionDoc(uid);
    final snapshotDoc = await snapshotRef.get();
    final baseSnapshot = snapshotDoc.exists && snapshotDoc.data() != null
        ? CompetitiveRankSnapshot.fromFirestore(snapshotDoc.data()!)
        : evaluateCompetitiveRank(player: player);

    final targetRank = rankAfter(baseSnapshot.currentRank);
    if (targetRank == null) return false;

    final forcedSnapshot = CompetitiveRankSnapshot(
      currentRank: baseSnapshot.currentRank,
      weekKey: baseSnapshot.weekKey,
      activeDays: baseSnapshot.requiredActiveDays + 1,
      requiredActiveDays: baseSnapshot.requiredActiveDays,
      requiresBossClear: baseSnapshot.requiresBossClear,
      bossCompleted: true,
      status: RankMaintenanceStatus.promotionReady,
      demotionStrikes: 0,
      promotionReady: true,
      promotionTargetRank: targetRank,
      summary: 'Exame de promocao pronto para o rank $targetRank.',
      detail: 'Snapshot forcado em debug para testar a promocao sem depender da progressao natural.',
      updatedAt: DateTime.now(),
    );

    final batch = _firestore.batch();
    batch.set(snapshotRef, forcedSnapshot.toFirestore(), SetOptions(merge: true));
    batch.set(
      _historyCollection(uid).doc(forcedSnapshot.weekKey),
      forcedSnapshot.toFirestore(),
      SetOptions(merge: true),
    );
    await batch.commit();
    _lastSyncedFingerprintByUser[uid] = _fingerprintFor(forcedSnapshot);
    return true;
  }

  Future<bool> debugForceExamPassed(Player player) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final examRef = _promotionExamDoc(uid);
    final examDoc = await examRef.get();
    if (!examDoc.exists || examDoc.data() == null) return false;

    final exam = PromotionExam.fromFirestore(examDoc.data()!);
    if (exam.status == PromotionExamStatus.promoted) return false;

    final snapshotRef = _progressionDoc(uid);
    final snapshotDoc = await snapshotRef.get();
    final baseSnapshot = snapshotDoc.exists && snapshotDoc.data() != null
        ? CompetitiveRankSnapshot.fromFirestore(snapshotDoc.data()!)
        : evaluateCompetitiveRank(player: player);

    final forcedSnapshot = CompetitiveRankSnapshot(
      currentRank: baseSnapshot.currentRank,
      weekKey: exam.sourceWeekKey,
      activeDays: exam.targetActiveDays,
      requiredActiveDays: baseSnapshot.requiredActiveDays,
      requiresBossClear: baseSnapshot.requiresBossClear,
      bossCompleted: true,
      status: RankMaintenanceStatus.promotionReady,
      demotionStrikes: 0,
      promotionReady: true,
      promotionTargetRank: exam.targetRank,
      summary: 'Exame concluido para o rank ${exam.targetRank}.',
      detail: 'Snapshot forcado em debug para permitir a confirmacao da promocao.',
      updatedAt: DateTime.now(),
    );

    final batch = _firestore.batch();
    batch.set(snapshotRef, forcedSnapshot.toFirestore(), SetOptions(merge: true));
    batch.set(
      _historyCollection(uid).doc(forcedSnapshot.weekKey),
      forcedSnapshot.toFirestore(),
      SetOptions(merge: true),
    );
    batch.set(
      examRef,
      exam.copyWith(status: PromotionExamStatus.passed, resolvedAt: DateTime.now()).toFirestore(),
      SetOptions(merge: true),
    );
    await batch.commit();
    _lastSyncedFingerprintByUser[uid] = _fingerprintFor(forcedSnapshot);
    return true;
  }

  Future<void> debugClearPromotionState() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _promotionExamDoc(uid).delete().catchError((_) {});
  }

  DocumentReference<Map<String, dynamic>> _progressionDoc(String uid) {
    return _firestore.collection('users').doc(uid).collection('progression').doc('current');
  }

  CollectionReference<Map<String, dynamic>> _historyCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('progression_history');
  }

  DocumentReference<Map<String, dynamic>> _promotionExamDoc(String uid) {
    return _firestore.collection('users').doc(uid).collection('promotion_exam').doc('current');
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
