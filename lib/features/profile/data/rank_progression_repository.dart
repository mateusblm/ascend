import 'dart:async';

import 'package:ascend/core/analytics/analytics_service.dart';
import 'package:ascend/core/crash/crash_reporting_service.dart';
import 'package:ascend/features/profile/data/backend_route_selector.dart';
import 'package:ascend/features/profile/data/java_backend_client.dart';
import 'package:ascend/features/profile/domain/competitive_integrity.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/promotion_exam.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/rank_season_leaderboard.dart';
import 'package:ascend/features/profile/domain/season_legacy_reward.dart';
import 'package:ascend/features/profile/domain/season_profile_snapshot.dart';
import 'package:ascend/features/profile/domain/season_reward_snapshot.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RankProgressionRepository {
  RankProgressionRepository(
    this._firestore,
    this._auth, {
    JavaBackendClient? javaBackendClient,
    AppAnalytics? analytics,
    AppCrashReporter? crashReporter,
  }) : _javaBackendClient = BackendRouteSelector.javaClient(javaBackendClient),
       _analytics = analytics ?? const NoopAppAnalytics(),
       _crashReporter = crashReporter ?? const NoopAppCrashReporter();

  static const int syncSchemaVersion = 3;
  static const Duration _rpcTimeout = Duration(seconds: 12);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final JavaBackendClient? _javaBackendClient;
  final AppAnalytics _analytics;
  final AppCrashReporter _crashReporter;
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

    return _integrityHistoryCollection(
      uid,
    ).orderBy('updatedAt', descending: true).limit(limit).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => CompetitiveIntegritySnapshot.fromFirestore(doc.data()))
          .toList();
    });
  }

  Future<CompetitiveRankSnapshot?> syncCompetitiveState(Player player) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final localFallback = evaluateCompetitiveRank(
      player: player,
    ).copyWith(syncSchemaVersion: syncSchemaVersion, syncSource: 'client');

    final javaBackendClient = _javaBackendClient;
    if (javaBackendClient == null) {
      return localFallback;
    }

    try {
      final javaSnapshot = await _syncCompetitiveStateWithJava(
        javaBackendClient: javaBackendClient,
        player: player,
      );
      if (javaSnapshot != null) {
        _lastSyncedFingerprintByUser[uid] = _fingerprintFor(javaSnapshot);
        return javaSnapshot;
      }
    } catch (error, stackTrace) {
      _reportRecoverable(
        error,
        stackTrace,
        stage: 'sync_competitive_state_java',
      );
    }

    return localFallback;
  }

  Future<CompetitiveRankSnapshot?> syncSnapshot(Player player) =>
      syncCompetitiveState(player);

  Future<CompetitiveRankSnapshot?> _syncCompetitiveStateWithJava({
    required JavaBackendClient javaBackendClient,
    required Player player,
  }) async {
    final idToken = await _auth.currentUser?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      return null;
    }

    final response = await javaBackendClient
        .syncCompetitiveState(
          idToken: idToken,
          rankSource: _competitiveSourceFor(player),
        )
        .timeout(_rpcTimeout);
    final snapshotData = response['rankSnapshot'];
    if (snapshotData is! Map) {
      return null;
    }
    return CompetitiveRankSnapshot.fromFirestore(
      snapshotData.cast<String, dynamic>(),
    );
  }

  Future<List<RankSeasonLeaderboardEntry>> fetchSeasonBracketLeaderboard({
    required String seasonKey,
    required String rankBracket,
    int limit = 5,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const <RankSeasonLeaderboardEntry>[];

    final javaBackendClient = _javaBackendClient;
    if (javaBackendClient == null) return const <RankSeasonLeaderboardEntry>[];

    try {
      final idToken = await _auth.currentUser?.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        return const <RankSeasonLeaderboardEntry>[];
      }
      return await javaBackendClient
          .fetchSeasonBracketLeaderboard(
            idToken: idToken,
            seasonKey: seasonKey,
            rankBracket: rankBracket,
            limit: limit,
          )
          .timeout(_rpcTimeout);
    } catch (error, stackTrace) {
      _reportRecoverable(
        error,
        stackTrace,
        stage: 'fetch_season_bracket_leaderboard_java',
      );
      return const <RankSeasonLeaderboardEntry>[];
    }
  }

  Future<CompetitiveIntegritySnapshot?> syncCompetitiveIntegrity({
    required Player player,
    required List<Quest> quests,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final localFallback = evaluateCompetitiveIntegrity(
      player: player,
      quests: quests,
    );

    final javaBackendClient = _javaBackendClient;
    if (javaBackendClient == null) {
      return localFallback;
    }

    try {
      final javaIntegrity = await _syncCompetitiveIntegrityWithJava(
        javaBackendClient: javaBackendClient,
        player: player,
        quests: quests,
      );
      if (javaIntegrity != null) {
        return javaIntegrity;
      }
    } catch (error, stackTrace) {
      _reportRecoverable(
        error,
        stackTrace,
        stage: 'sync_competitive_integrity_java',
      );
    }

    return localFallback;
  }

  Future<CompetitiveIntegritySnapshot?> _syncCompetitiveIntegrityWithJava({
    required JavaBackendClient javaBackendClient,
    required Player player,
    required List<Quest> quests,
  }) async {
    final idToken = await _auth.currentUser?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      return null;
    }

    final response = await javaBackendClient
        .syncCompetitiveState(
          idToken: idToken,
          integritySource: _competitiveIntegritySourceFor(
            player: player,
            quests: quests,
          ),
        )
        .timeout(_rpcTimeout);
    final integrityData = response['integritySnapshot'];
    if (integrityData is! Map) {
      return null;
    }
    return CompetitiveIntegritySnapshot.fromFirestore(
      integrityData.cast<String, dynamic>(),
    );
  }

  Map<String, dynamic> _competitiveSourceFor(Player player) {
    return <String, dynamic>{
      'playerLevel': player.level,
      'activityHistory': player.activityHistory
          .map((entry) => entry.toIso8601String())
          .toList(growable: false),
      'competitiveActivityHistory': player.competitiveActivityHistory
          .map((entry) => entry.toIso8601String())
          .toList(growable: false),
    };
  }

  Map<String, dynamic> _competitiveIntegritySourceFor({
    required Player player,
    required List<Quest> quests,
  }) {
    return <String, dynamic>{
      'activityHistory': player.activityHistory
          .map((entry) => entry.toIso8601String())
          .toList(growable: false),
      'competitiveActivityHistory': player.competitiveActivityHistory
          .map((entry) => entry.toIso8601String())
          .toList(growable: false),
      'quests': quests
          .map(
            (quest) => <String, dynamic>{
              'title': quest.title,
              'xpReward': quest.xpReward,
              'isCompetitive': quest.isCompetitive,
              'countsTowardCompetitive': quest.countsTowardCompetitive,
              'isCompleted': quest.isCompleted,
              if (quest.completedAt != null)
                'completedAt': quest.completedAt!.toIso8601String(),
            },
          )
          .toList(growable: false),
    };
  }

  Future<void> syncPromotionExam(CompetitiveRankSnapshot snapshot) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final javaBackendClient = _javaBackendClient;
    if (javaBackendClient == null) {
      return;
    }

    try {
      final idToken = await _auth.currentUser?.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        return;
      }

      await javaBackendClient
          .syncPromotionExam(
            idToken: idToken,
            snapshot: _rankSnapshotPayloadForJava(snapshot),
          )
          .timeout(_rpcTimeout);
    } catch (error, stackTrace) {
      _reportRecoverable(error, stackTrace, stage: 'sync_promotion_exam_java');
    }
  }

  Future<bool> startPromotionExam(CompetitiveRankSnapshot snapshot) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    if (!snapshot.promotionReady || snapshot.promotionTargetRank == null) {
      return false;
    }

    try {
      final status = await _startPromotionExamRemotely(snapshot);
      if (status == 'started' || status == 'already_in_progress') {
        unawaited(
          _analytics.logPromotionExamStarted(
            sourceRank: snapshot.currentRank,
            targetRank: snapshot.promotionTargetRank ?? '',
            mode: (snapshot.advancementMode ?? RankAdvancementMode.ascension)
                .name,
            status: status,
          ),
        );
      }
      return status == 'started' || status == 'already_in_progress';
    } catch (error, stackTrace) {
      _reportRecoverable(error, stackTrace, stage: 'start_promotion_exam');
      return false;
    }
  }

  Future<bool> promoteIfExamPassed(CompetitiveRankSnapshot snapshot) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      final status = await _confirmPromotionRemotely(snapshot);
      if (status == 'promoted' || status == 'already_promoted') {
        unawaited(
          _analytics.logPromotionConfirmed(
            sourceRank: snapshot.currentRank,
            targetRank: snapshot.promotionTargetRank ?? '',
            mode: (snapshot.advancementMode ?? RankAdvancementMode.ascension)
                .name,
            status: status,
          ),
        );
      }
      return status == 'promoted' || status == 'already_promoted';
    } catch (error, stackTrace) {
      _reportRecoverable(error, stackTrace, stage: 'confirm_promotion');
      return false;
    }
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
      eventType:
          _promotionModeFor(
                currentRank: baseSnapshot.currentRank,
                peakRank: baseSnapshot.peakRank,
              ) ==
              RankAdvancementMode.reconquest
          ? CompetitiveRankEventType.reconquestUnlocked
          : CompetitiveRankEventType.promotionUnlocked,
      summary:
          _promotionModeFor(
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
        unawaited(
          _analytics.logSeasonRewardClaimed(
            seasonKey: currentReward.seasonKey,
            rewardName: currentReward.rewardName,
            status: status,
          ),
        );
      }
      return status == 'claimed' || status == 'already_claimed';
    } catch (error, stackTrace) {
      _reportRecoverable(error, stackTrace, stage: 'claim_season_reward');
      return false;
    }
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

  CollectionReference<Map<String, dynamic>> _seasonLegacyCollection(
    String uid,
  ) {
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

  String _fingerprintFor(CompetitiveRankSnapshot snapshot) {
    return _logicalSnapshotFingerprint(snapshot);
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

  void _reportRecoverable(
    Object error,
    StackTrace stackTrace, {
    required String stage,
  }) {
    unawaited(
      _crashReporter.recordError(
        error,
        stackTrace,
        reason: 'competitive_remote:$stage',
        fatal: false,
      ),
    );
  }

  Future<String> _claimSeasonRewardRemotely(
    SeasonRewardSnapshot currentReward,
  ) async {
    final javaBackendClient = _javaBackendClientObrigatorio(
      'resgatar recompensa da temporada',
    );
    final idToken = await _idTokenObrigatorio(
      'resgatar recompensa da temporada',
    );
    final response = await javaBackendClient
        .claimSeasonReward(idToken: idToken, seasonKey: currentReward.seasonKey)
        .timeout(_rpcTimeout);
    final status = response['status'];
    if (status is String) {
      return status;
    }
    return 'claimed';
  }

  Future<String> _startPromotionExamRemotely(
    CompetitiveRankSnapshot snapshot,
  ) async {
    final javaBackendClient = _javaBackendClientObrigatorio(
      'iniciar exame de promocao',
    );
    final idToken = await _idTokenObrigatorio('iniciar exame de promocao');
    final response = await javaBackendClient
        .startPromotionExam(
          idToken: idToken,
          snapshot: _rankSnapshotPayloadForJava(snapshot),
        )
        .timeout(_rpcTimeout);
    final status = response['status'];
    if (status is String) {
      return status;
    }
    return 'started';
  }

  Future<String> _confirmPromotionRemotely(
    CompetitiveRankSnapshot snapshot,
  ) async {
    final javaBackendClient = _javaBackendClientObrigatorio(
      'confirmar promocao',
    );
    final idToken = await _idTokenObrigatorio('confirmar promocao');
    final response = await javaBackendClient
        .confirmPromotion(
          idToken: idToken,
          snapshot: _rankSnapshotPayloadForJava(snapshot),
        )
        .timeout(_rpcTimeout);
    final status = response['status'];
    if (status is String) {
      return status;
    }
    return 'promoted';
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

  Map<String, dynamic> _rankSnapshotPayloadForJava(
    CompetitiveRankSnapshot snapshot,
  ) {
    return <String, dynamic>{
      'currentRank': snapshot.currentRank,
      'peakRank': snapshot.peakRank,
      'highestEligibleRank': snapshot.highestEligibleRank,
      'weekKey': snapshot.weekKey,
      'activeDays': snapshot.activeDays,
      'requiredActiveDays': snapshot.requiredActiveDays,
      'requiresBossClear': snapshot.requiresBossClear,
      'bossCompleted': snapshot.bossCompleted,
      'status': snapshot.status.name,
      'demotionStrikes': snapshot.demotionStrikes,
      'promotionReady': snapshot.promotionReady,
      if (snapshot.promotionTargetRank != null)
        'promotionTargetRank': snapshot.promotionTargetRank,
      'targetRequiredLevel': snapshot.targetRequiredLevel,
      'targetLevelGateMet': snapshot.targetLevelGateMet,
      if (snapshot.advancementMode != null)
        'advancementMode': snapshot.advancementMode!.name,
      'eventType': snapshot.eventType.name,
      'summary': snapshot.summary,
      'detail': snapshot.detail,
      'syncSchemaVersion': snapshot.syncSchemaVersion,
      'syncSource': snapshot.syncSource,
      'updatedAt': snapshot.updatedAt.toUtc().toIso8601String(),
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
