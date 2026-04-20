import 'dart:async';

import 'package:ascend/features/profile/domain/competitive_integrity.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/promotion_exam.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/rank_season.dart';
import 'package:ascend/features/profile/domain/rank_season_leaderboard.dart';
import 'package:ascend/features/profile/domain/season_legacy_reward.dart';
import 'package:ascend/features/profile/domain/season_profile_snapshot.dart';
import 'package:ascend/features/profile/domain/season_reward_snapshot.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RankProgressionRepository {
  RankProgressionRepository(
    this._firestore,
    this._auth, {
    FirebaseFunctions? functions,
  }) : _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  static const int syncSchemaVersion = 3;
  static const Duration _rpcTimeout = Duration(seconds: 4);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
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

  Stream<SeasonRewardSnapshot?> watchCurrentSeasonReward() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(null);
    }

    return _seasonRewardDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;
      return SeasonRewardSnapshot.fromFirestore(data);
    });
  }

  Stream<List<SeasonRewardSnapshot>> watchSeasonRewardHistory({int limit = 4}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(const <SeasonRewardSnapshot>[]);
    }

    return _seasonRewardHistoryCollection(uid)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SeasonRewardSnapshot.fromFirestore(doc.data()))
              .toList();
        });
  }

  Stream<List<SeasonLegacyReward>> watchSeasonLegacyHistory({int limit = 6}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(const <SeasonLegacyReward>[]);
    }

    return _seasonLegacyCollection(uid)
        .orderBy('claimedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SeasonLegacyReward.fromFirestore(doc.data()))
              .toList();
        });
  }

  Stream<SeasonProfileSnapshot?> watchSeasonProfile() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(null);
    }

    return _seasonProfileDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;
      return SeasonProfileSnapshot.fromFirestore(data);
    });
  }

  Stream<CompetitiveIntegritySnapshot?> watchCurrentIntegrity() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(null);
    }

    return _integrityDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;
      return CompetitiveIntegritySnapshot.fromFirestore(data);
    });
  }

  Stream<List<CompetitiveIntegritySnapshot>> watchIntegrityHistory({
    int limit = 6,
  }) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(const <CompetitiveIntegritySnapshot>[]);
    }

    return _integrityHistoryCollection(uid)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => CompetitiveIntegritySnapshot.fromFirestore(doc.data()),
              )
              .toList();
        });
  }

  Future<CompetitiveRankSnapshot?> syncCompetitiveState(Player player) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final snapshotRef = _progressionDoc(uid);
    final examRef = _promotionExamDoc(uid);
    final seasonRewardRef = _seasonRewardDoc(uid);
    final previousDoc = await snapshotRef.get();
    final examDoc = await examRef.get();
    final seasonRewardDoc = await seasonRewardRef.get();

    final previousSnapshot = previousDoc.exists && previousDoc.data() != null
        ? CompetitiveRankSnapshot.fromFirestore(previousDoc.data()!)
        : null;
    final currentExam = examDoc.exists && examDoc.data() != null
        ? PromotionExam.fromFirestore(examDoc.data()!)
        : null;
    final currentSeasonReward =
        seasonRewardDoc.exists && seasonRewardDoc.data() != null
        ? SeasonRewardSnapshot.fromFirestore(seasonRewardDoc.data()!)
        : null;

    final nextSnapshot = evaluateCompetitiveRank(
      player: player,
      previousSnapshot: previousSnapshot,
    ).copyWith(syncSchemaVersion: syncSchemaVersion, syncSource: 'client');
    final seasonHistory = await _loadCurrentSeasonHistory(uid);
    final mergedSeasonHistory = _mergeSeasonHistory(
      seasonHistory,
      nextSnapshot,
    );
    final season = buildCurrentSeasonSummary(mergedSeasonHistory);
    final seasonLeaderboard = buildRankSeasonLeaderboardSummary(
      player: player,
      season: season,
      activeBoss: null,
      topCompletions: const [],
      snapshot: nextSnapshot,
    );
    final seasonRewardBase = SeasonRewardSnapshot.fromSeasonSummary(
      season: season,
      currentRankBracket: nextSnapshot.currentRank,
      seasonScore: seasonLeaderboard.seasonScore,
      scoreBandLabel: seasonLeaderboard.scoreBandLabel,
      clearRateLabel: seasonLeaderboard.clearRateLabel,
      playerStandingLabel: seasonLeaderboard.playerStandingLabel,
      spotlightLabel: seasonLeaderboard.spotlightLabel,
      syncSchemaVersion: syncSchemaVersion,
      syncSource: 'client',
      updatedAt: nextSnapshot.updatedAt,
    );
    final seasonReward = _resolveSeasonRewardAfterSync(
      nextReward: seasonRewardBase,
      currentReward: currentSeasonReward,
    );
    final nextExam = _resolveExamAfterSnapshot(
      snapshot: nextSnapshot,
      currentExam: currentExam,
    );

    final fingerprint = _fingerprintFor(
      nextSnapshot,
      nextExam: nextExam,
      seasonReward: seasonReward,
    );
    if (_lastSyncedFingerprintByUser[uid] == fingerprint &&
        _shouldSkipRemoteWrite(
          currentSnapshot: previousSnapshot,
          nextSnapshot: nextSnapshot,
          currentExam: currentExam,
          nextExam: nextExam,
          nextSeasonReward: seasonReward,
        )) {
      return nextSnapshot;
    }

    final historyRef = _historyCollection(uid).doc(nextSnapshot.weekKey);
    final seasonRewardHistoryRef = _seasonRewardHistoryCollection(uid).doc(
      seasonReward.seasonKey,
    );
    final batch = _firestore.batch();
    batch.set(snapshotRef, nextSnapshot.toFirestore(), SetOptions(merge: true));
    batch.set(historyRef, nextSnapshot.toFirestore(), SetOptions(merge: true));
    batch.set(
      seasonRewardRef,
      seasonReward.toFirestore(),
      SetOptions(merge: true),
    );
    batch.set(
      seasonRewardHistoryRef,
      seasonReward.toFirestore(),
      SetOptions(merge: true),
    );
    if (nextExam != null) {
      batch.set(examRef, nextExam.toFirestore(), SetOptions(merge: true));
    }
    
    await _commitAndSyncRpc(
      batch: batch,
      snapshot: nextSnapshot,
      exam: nextExam,
      seasonReward: seasonReward,
    );
    
    _lastSyncedFingerprintByUser[uid] = fingerprint;
    return nextSnapshot;
  }

  Future<CompetitiveRankSnapshot?> syncSnapshot(Player player) =>
      syncCompetitiveState(player);

  Future<CompetitiveIntegritySnapshot?> syncCompetitiveIntegrity({
    required Player player,
    required List<Quest> quests,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final snapshot = evaluateCompetitiveIntegrity(
      player: player,
      quests: quests,
    );
    final currentRef = _integrityDoc(uid);
    final historyRef = _integrityHistoryCollection(uid).doc(snapshot.weekKey);
    final batch = _firestore.batch();
    batch.set(currentRef, snapshot.toFirestore(), SetOptions(merge: true));
    batch.set(historyRef, snapshot.toFirestore(), SetOptions(merge: true));
    await batch.commit();

    try {
      final callable = _functions.httpsCallable('upsertCompetitiveIntegrity');
      await callable
          .call({'integrity': snapshot.toFirestore()})
          .timeout(_rpcTimeout);
    } catch (_) {
      // Silent fallback keeps integrity signals local-first.
    }

    return snapshot;
  }

  Future<void> syncPromotionExam(CompetitiveRankSnapshot snapshot) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final examRef = _promotionExamDoc(uid);
    final examDoc = await examRef.get();
    if (!examDoc.exists || examDoc.data() == null) return;

    final currentExam = PromotionExam.fromFirestore(examDoc.data()!);
    final nextExam = _resolveExamAfterSnapshot(
      snapshot: snapshot.copyWith(
        syncSchemaVersion: syncSchemaVersion,
        syncSource: snapshot.syncSource,
      ),
      currentExam: currentExam,
    );
    if (nextExam == null ||
        nextExam.toFirestore().toString() ==
            currentExam.toFirestore().toString()) {
      return;
    }

    final batch = _firestore.batch();
    batch.set(examRef, nextExam.toFirestore(), SetOptions(merge: true));
    await _commitAndSyncRpc(
      batch: batch,
      snapshot: snapshot,
      exam: nextExam,
    );
  }

  Future<bool> startPromotionExam(CompetitiveRankSnapshot snapshot) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    if (!snapshot.promotionReady || snapshot.promotionTargetRank == null) {
      return false;
    }

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
      mode: (snapshot.advancementMode ?? RankAdvancementMode.ascension) ==
              RankAdvancementMode.reconquest
          ? PromotionExamMode.reconquest
          : PromotionExamMode.ascension,
      baselineActiveDays: snapshot.activeDays,
      requiredExtraActiveDays: 1,
      bossRequired: nextRule.requiresBossClear,
      requiredLevel: snapshot.targetRequiredLevel,
      startedAt: now,
      expiresAt: now.add(const Duration(days: 3)),
      syncSchemaVersion: syncSchemaVersion,
      syncSource: 'client',
    );

    final batch = _firestore.batch();
    batch.set(examRef, exam.toFirestore(), SetOptions(merge: true));
    await _commitAndSyncRpc(
      batch: batch,
      snapshot: snapshot,
      exam: exam,
    );
    
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
      peakRank: _higherRank(promotedRank, snapshot.peakRank),
      highestEligibleRank: snapshot.highestEligibleRank,
      weekKey: snapshot.weekKey,
      activeDays: snapshot.activeDays,
      requiredActiveDays: promotedRule.requiredActiveDays,
      requiresBossClear: promotedRule.requiresBossClear,
      bossCompleted: snapshot.bossCompleted,
      status: RankMaintenanceStatus.secure,
      demotionStrikes: 0,
      promotionReady: false,
      promotionTargetRank: rankAfter(promotedRank),
      targetRequiredLevel:
          rankAfter(promotedRank) == null ? promotedRule.minimumLevel : rankRuleFor(rankAfter(promotedRank)!).minimumLevel,
      targetLevelGateMet: true,
      advancementMode: _promotionModeFor(
        currentRank: promotedRank,
        peakRank: _higherRank(promotedRank, snapshot.peakRank),
      ),
      eventType: CompetitiveRankEventType.promotionConfirmed,
      summary: exam.mode == PromotionExamMode.reconquest
          ? 'Rank $promotedRank reconquistado.'
          : 'Promovido para o rank $promotedRank.',
      detail:
          exam.mode == PromotionExamMode.reconquest
              ? 'O exame de reconquista foi concluido e seu pico historico voltou a ficar ao alcance da rotina atual.'
              : 'O exame foi concluido e sua promocao agora faz parte do historico competitivo.',
      syncSchemaVersion: syncSchemaVersion,
      syncSource: 'client',
      updatedAt: now,
    );

    final batch = _firestore.batch();
    batch.set(
      _progressionDoc(uid),
      promotedSnapshot.toFirestore(),
      SetOptions(merge: true),
    );
    batch.set(
      _historyCollection(uid).doc(promotedSnapshot.weekKey),
      promotedSnapshot.toFirestore(),
      SetOptions(merge: true),
    );
    final updatedExam = exam.copyWith(
      status: PromotionExamStatus.promoted,
      resolvedAt: now,
      syncSchemaVersion: syncSchemaVersion,
      syncSource: 'client',
    );
    batch.set(examRef, updatedExam.toFirestore(), SetOptions(merge: true));
    
    await _commitAndSyncRpc(
      batch: batch,
      snapshot: promotedSnapshot,
      exam: updatedExam,
    );
    
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
      peakRank: baseSnapshot.peakRank,
      highestEligibleRank: baseSnapshot.highestEligibleRank,
      weekKey: baseSnapshot.weekKey,
      activeDays: baseSnapshot.requiredActiveDays + 1,
      requiredActiveDays: baseSnapshot.requiredActiveDays,
      requiresBossClear: baseSnapshot.requiresBossClear,
      bossCompleted: true,
      status: RankMaintenanceStatus.promotionReady,
      demotionStrikes: 0,
      promotionReady: true,
      promotionTargetRank: targetRank,
      targetRequiredLevel: rankRuleFor(targetRank).minimumLevel,
      targetLevelGateMet: true,
      advancementMode: _promotionModeFor(
        currentRank: baseSnapshot.currentRank,
        peakRank: baseSnapshot.peakRank,
      ),
      eventType: _promotionModeFor(
                currentRank: baseSnapshot.currentRank,
                peakRank: baseSnapshot.peakRank,
              ) ==
              RankAdvancementMode.reconquest
          ? CompetitiveRankEventType.reconquestUnlocked
          : CompetitiveRankEventType.promotionUnlocked,
      summary: _promotionModeFor(
                currentRank: baseSnapshot.currentRank,
                peakRank: baseSnapshot.peakRank,
              ) ==
              RankAdvancementMode.reconquest
          ? 'Exame de reconquista pronto para o rank $targetRank.'
          : 'Exame de promocao pronto para o rank $targetRank.',
      detail:
          'Snapshot forcado em debug para testar a promocao sem depender da progressao natural.',
      syncSchemaVersion: syncSchemaVersion,
      syncSource: 'debug',
      updatedAt: DateTime.now(),
    );

    final batch = _firestore.batch();
    batch.set(
      snapshotRef,
      forcedSnapshot.toFirestore(),
      SetOptions(merge: true),
    );
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
      peakRank: baseSnapshot.peakRank,
      highestEligibleRank: baseSnapshot.highestEligibleRank,
      weekKey: exam.sourceWeekKey,
      activeDays: exam.targetActiveDays,
      requiredActiveDays: baseSnapshot.requiredActiveDays,
      requiresBossClear: baseSnapshot.requiresBossClear,
      bossCompleted: true,
      status: RankMaintenanceStatus.promotionReady,
      demotionStrikes: 0,
      promotionReady: true,
      promotionTargetRank: exam.targetRank,
      targetRequiredLevel: exam.requiredLevel,
      targetLevelGateMet: true,
      advancementMode: exam.mode == PromotionExamMode.reconquest
          ? RankAdvancementMode.reconquest
          : RankAdvancementMode.ascension,
      eventType: exam.mode == PromotionExamMode.reconquest
          ? CompetitiveRankEventType.reconquestUnlocked
          : CompetitiveRankEventType.promotionUnlocked,
      summary: exam.mode == PromotionExamMode.reconquest
          ? 'Exame de reconquista concluido para o rank ${exam.targetRank}.'
          : 'Exame concluido para o rank ${exam.targetRank}.',
      detail:
          'Snapshot forcado em debug para permitir a confirmacao da promocao.',
      syncSchemaVersion: syncSchemaVersion,
      syncSource: 'debug',
      updatedAt: DateTime.now(),
    );

    final batch = _firestore.batch();
    batch.set(
      snapshotRef,
      forcedSnapshot.toFirestore(),
      SetOptions(merge: true),
    );
    batch.set(
      _historyCollection(uid).doc(forcedSnapshot.weekKey),
      forcedSnapshot.toFirestore(),
      SetOptions(merge: true),
    );
    batch.set(
      examRef,
      exam
          .copyWith(
            status: PromotionExamStatus.passed,
            resolvedAt: DateTime.now(),
            syncSchemaVersion: syncSchemaVersion,
            syncSource: 'debug',
          )
          .toFirestore(),
      SetOptions(merge: true),
    );
    await batch.commit();
    _lastSyncedFingerprintByUser[uid] = _fingerprintFor(forcedSnapshot);
    return true;
  }

  Future<void> debugClearPromotionState() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final examRef = _promotionExamDoc(uid);
    final examDoc = await examRef.get();
    if (!examDoc.exists || examDoc.data() == null) return;

    final exam = PromotionExam.fromFirestore(examDoc.data()!);
    await examRef.set(
      exam
          .copyWith(
            status: PromotionExamStatus.failed,
            resolvedAt: DateTime.now(),
            syncSchemaVersion: syncSchemaVersion,
            syncSource: 'debug',
          )
          .toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<bool> claimCurrentSeasonReward() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final rewardRef = _seasonRewardDoc(uid);
    final rewardDoc = await rewardRef.get();
    if (!rewardDoc.exists || rewardDoc.data() == null) {
      return false;
    }

    final currentReward = SeasonRewardSnapshot.fromFirestore(rewardDoc.data()!);
    if (!currentReward.canClaim) {
      return false;
    }

    try {
      final status = await _claimSeasonRewardRemotely(currentReward);
      if (status == 'claimed' || status == 'already_claimed') {
        return true;
      }
    } catch (error) {
      if (!_canFallbackSeasonClaim(error)) {
        rethrow;
      }
    }

    final now = DateTime.now();
    final claimedReward = currentReward.copyWith(
      claimStatus: SeasonRewardClaimStatus.claimed,
      claimedAt: now,
      syncSchemaVersion: syncSchemaVersion,
      syncSource: 'client',
      updatedAt: now,
    );
    final legacyReward = SeasonLegacyReward.fromSeasonReward(
      reward: claimedReward,
      claimedAt: claimedReward.claimedAt ?? now,
      syncSchemaVersion: syncSchemaVersion,
      syncSource: 'client',
      updatedAt: now,
    );
    final seasonProfile = SeasonProfileSnapshot.fromLegacyReward(
      legacyReward: legacyReward,
      syncSchemaVersion: syncSchemaVersion,
      syncSource: 'client',
      updatedAt: now,
    );

    final batch = _firestore.batch();
    batch.set(rewardRef, claimedReward.toFirestore(), SetOptions(merge: true));
    batch.set(
      _seasonRewardHistoryCollection(uid).doc(claimedReward.seasonKey),
      claimedReward.toFirestore(),
      SetOptions(merge: true),
    );
    batch.set(
      _seasonLegacyCollection(uid).doc(legacyReward.seasonKey),
      legacyReward.toFirestore(),
      SetOptions(merge: true),
    );
    batch.set(
      _seasonProfileDoc(uid),
      seasonProfile.toFirestore(),
      SetOptions(merge: true),
    );
    await batch.commit();
    return true;
  }

  DocumentReference<Map<String, dynamic>> _progressionDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('progression')
        .doc('current');
  }

  CollectionReference<Map<String, dynamic>> _historyCollection(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('progression_history');
  }

  DocumentReference<Map<String, dynamic>> _promotionExamDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('promotion_exam')
        .doc('current');
  }

  DocumentReference<Map<String, dynamic>> _seasonRewardDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('season_rewards')
        .doc('current');
  }

  CollectionReference<Map<String, dynamic>> _seasonRewardHistoryCollection(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('season_reward_history');
  }

  CollectionReference<Map<String, dynamic>> _seasonLegacyCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('season_legacy');
  }

  DocumentReference<Map<String, dynamic>> _seasonProfileDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('season_profile')
        .doc('current');
  }

  DocumentReference<Map<String, dynamic>> _integrityDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('integrity')
        .doc('current');
  }

  CollectionReference<Map<String, dynamic>> _integrityHistoryCollection(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('integrity_history');
  }

  PromotionExam? _resolveExamAfterSnapshot({
    required CompetitiveRankSnapshot snapshot,
    required PromotionExam? currentExam,
    DateTime? now,
  }) {
    if (currentExam == null) return null;
    if (currentExam.status != PromotionExamStatus.inProgress) {
      return currentExam.copyWith(
        syncSchemaVersion: syncSchemaVersion,
        syncSource: currentExam.syncSource,
      );
    }

    final currentTime = now ?? DateTime.now();
    if (snapshot.weekKey != currentExam.sourceWeekKey ||
        currentTime.isAfter(currentExam.expiresAt)) {
      return currentExam.copyWith(
        status: PromotionExamStatus.failed,
        resolvedAt: currentTime,
        syncSchemaVersion: syncSchemaVersion,
        syncSource: 'client',
      );
    }

    final passed =
        snapshot.activeDays >= currentExam.targetActiveDays &&
        (!currentExam.bossRequired || snapshot.bossCompleted);
    if (!passed) {
      return currentExam.copyWith(
        syncSchemaVersion: syncSchemaVersion,
        syncSource: currentExam.syncSource,
      );
    }

    return currentExam.copyWith(
      status: PromotionExamStatus.passed,
      resolvedAt: currentTime,
      syncSchemaVersion: syncSchemaVersion,
      syncSource: 'client',
    );
  }

  bool _shouldSkipRemoteWrite({
    required CompetitiveRankSnapshot? currentSnapshot,
    required CompetitiveRankSnapshot nextSnapshot,
    required PromotionExam? currentExam,
    required PromotionExam? nextExam,
    required SeasonRewardSnapshot nextSeasonReward,
  }) {
    if (currentSnapshot == null) return false;

    final snapshotUnchanged =
        _logicalSnapshotFingerprint(currentSnapshot) ==
        _logicalSnapshotFingerprint(nextSnapshot);
    final examUnchanged = switch ((currentExam, nextExam)) {
      (null, null) => true,
      (final examA?, final examB?) =>
        _logicalExamFingerprint(examA) == _logicalExamFingerprint(examB),
      _ => false,
    };
    return snapshotUnchanged &&
        examUnchanged &&
        _lastSyncedFingerprintByUser[_auth.currentUser?.uid] ==
            _fingerprintFor(
              nextSnapshot,
              nextExam: nextExam,
              seasonReward: nextSeasonReward,
            );
  }

  String _fingerprintFor(
    CompetitiveRankSnapshot snapshot, {
    PromotionExam? nextExam,
    SeasonRewardSnapshot? seasonReward,
  }) {
    return [
      _logicalSnapshotFingerprint(snapshot),
      nextExam?.status.name ?? 'no_exam',
      nextExam?.targetRank ?? '',
      nextExam?.syncSource ?? '',
      seasonReward == null ? 'no_season' : _logicalSeasonRewardFingerprint(seasonReward),
    ].join('|');
  }

  String _logicalSnapshotFingerprint(CompetitiveRankSnapshot snapshot) {
    return [
      snapshot.currentRank,
      snapshot.peakRank,
      snapshot.highestEligibleRank,
      snapshot.weekKey,
      snapshot.activeDays,
      snapshot.requiredActiveDays,
      snapshot.requiresBossClear,
      snapshot.bossCompleted,
      snapshot.status.name,
      snapshot.demotionStrikes,
      snapshot.promotionReady,
      snapshot.promotionTargetRank ?? '',
      snapshot.targetRequiredLevel,
      snapshot.targetLevelGateMet,
      snapshot.advancementMode?.name ?? 'no_mode',
      snapshot.eventType.name,
      snapshot.syncSource,
      snapshot.syncSchemaVersion,
    ].join('|');
  }

  String _logicalExamFingerprint(PromotionExam exam) {
    return [
      exam.sourceRank,
      exam.targetRank,
      exam.sourceWeekKey,
      exam.status.name,
      exam.mode.name,
      exam.baselineActiveDays,
      exam.requiredExtraActiveDays,
      exam.bossRequired,
      exam.requiredLevel,
      exam.syncSchemaVersion,
      exam.syncSource,
      exam.resolvedAt?.millisecondsSinceEpoch ?? 0,
    ].join('|');
  }

  String _logicalSeasonRewardFingerprint(SeasonRewardSnapshot reward) {
    return [
      reward.seasonKey,
      reward.currentRankBracket,
      reward.rewardTierLabel,
      reward.rewardStatusLabel,
      reward.rewardUnlocked,
      reward.claimStatus.name,
      reward.claimedAt?.millisecondsSinceEpoch ?? 0,
      reward.seasonScore,
      reward.scoreBandLabel,
      reward.playerStandingLabel,
      reward.syncSchemaVersion,
      reward.syncSource,
    ].join('|');
  }
  
  Future<void> _commitAndSyncRpc({
    required WriteBatch batch,
    required CompetitiveRankSnapshot snapshot,
    PromotionExam? exam,
    SeasonRewardSnapshot? seasonReward,
  }) async {
    // 1. Otimismo local / Offline fallback
    await batch.commit();

    if (
        !_shouldDispatchRpc(
          snapshot: snapshot,
          exam: exam,
          seasonReward: seasonReward,
        )) {
      return;
    }

    // 2. Chamada remota para o backend (autoritativo)
    try {
      final callable = _functions.httpsCallable('upsertCompetitiveProgression');
      await callable
          .call({
            'snapshot': snapshot.toFirestore(),
            if (exam != null) 'exam': exam.toFirestore(),
            if (seasonReward != null) 'seasonReward': seasonReward.toFirestore(),
          })
          .timeout(_rpcTimeout);
    } catch (_) {
      // Fallback silencioso permite funcionamento da UI offline ou se o Cloud demorar
    }
  }

  bool _shouldDispatchRpc({
    required CompetitiveRankSnapshot snapshot,
    PromotionExam? exam,
    SeasonRewardSnapshot? seasonReward,
  }) {
    if (_auth.currentUser == null) {
      return false;
    }

    if (snapshot.syncSource == 'debug' ||
        snapshot.syncSchemaVersion < syncSchemaVersion) {
      return false;
    }

    if (exam != null &&
        (exam.syncSource == 'debug' ||
            exam.syncSchemaVersion < syncSchemaVersion)) {
      return false;
    }

    if (seasonReward != null &&
        (seasonReward.syncSource == 'debug' ||
            seasonReward.syncSchemaVersion < syncSchemaVersion)) {
      return false;
    }

    return true;
  }

  Future<List<CompetitiveRankSnapshot>> _loadCurrentSeasonHistory(String uid) async {
    final docs = await _historyCollection(uid)
        .orderBy('updatedAt', descending: true)
        .limit(8)
        .get();
    return docs.docs
        .map((doc) => CompetitiveRankSnapshot.fromFirestore(doc.data()))
        .toList();
  }

  List<CompetitiveRankSnapshot> _mergeSeasonHistory(
    List<CompetitiveRankSnapshot> history,
    CompetitiveRankSnapshot nextSnapshot,
  ) {
    final merged = history
        .where((entry) => entry.weekKey != nextSnapshot.weekKey)
        .toList(growable: true)
      ..add(nextSnapshot);
    return merged;
  }

  SeasonRewardSnapshot _resolveSeasonRewardAfterSync({
    required SeasonRewardSnapshot nextReward,
    required SeasonRewardSnapshot? currentReward,
  }) {
    if (currentReward == null || currentReward.seasonKey != nextReward.seasonKey) {
      return nextReward;
    }

    if (currentReward.claimStatus == SeasonRewardClaimStatus.claimed) {
      return nextReward.copyWith(
        claimStatus: SeasonRewardClaimStatus.claimed,
        claimedAt: currentReward.claimedAt,
        syncSchemaVersion: syncSchemaVersion,
        syncSource: 'client',
      );
    }

    return nextReward.copyWith(
      claimStatus: nextReward.rewardUnlocked
          ? SeasonRewardClaimStatus.readyToClaim
          : SeasonRewardClaimStatus.locked,
      syncSchemaVersion: syncSchemaVersion,
      syncSource: 'client',
    );
  }

  Future<String> _claimSeasonRewardRemotely(
    SeasonRewardSnapshot currentReward,
  ) async {
    final callable = _functions.httpsCallable('claimSeasonReward');
    final response = await callable
        .call(<String, dynamic>{'seasonKey': currentReward.seasonKey})
        .timeout(_rpcTimeout);
    final data = response.data;
    if (data is Map && data['status'] is String) {
      return data['status'] as String;
    }
    return 'claimed';
  }

  bool _canFallbackSeasonClaim(Object error) {
    if (error is! FirebaseFunctionsException) {
      return true;
    }

    return switch (error.code) {
      'not-found' || 'unimplemented' || 'unavailable' || 'deadline-exceeded' =>
        true,
      'failed-precondition' || 'permission-denied' || 'unauthenticated' =>
        false,
      _ => true,
    };
  }

  RankAdvancementMode _promotionModeFor({
    required String currentRank,
    required String peakRank,
  }) {
    final nextRank = rankAfter(currentRank);
    if (nextRank == null) {
      return RankAdvancementMode.ascension;
    }
    return _rankOrder(nextRank) <= _rankOrder(peakRank)
        ? RankAdvancementMode.reconquest
        : RankAdvancementMode.ascension;
  }

  String _higherRank(String rankA, String rankB) {
    return _rankOrder(rankA) >= _rankOrder(rankB) ? rankA : rankB;
  }

  int _rankOrder(String rank) {
    return switch (rank.trim().toUpperCase()) {
      'E' => 0,
      'D' => 1,
      'C' => 2,
      'B' => 3,
      'A' => 4,
      _ => 5,
    };
  }
}
