import 'dart:async';

import 'package:ascend/core/analytics/analytics_service.dart';
import 'package:ascend/core/config/java_backend_config.dart';
import 'package:ascend/core/crash/crash_reporting_service.dart';
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
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class RankProgressionRepository {
  RankProgressionRepository(
    this._firestore,
    this._auth, {
    FirebaseFunctions? functions,
    JavaBackendClient? javaBackendClient,
    AppAnalytics? analytics,
    AppCrashReporter? crashReporter,
  }) : _functions =
           functions ??
           FirebaseFunctions.instanceFor(region: 'southamerica-east1'),
       _javaBackendClient =
           javaBackendClient ??
           (JavaBackendConfig.isEnabled
               ? JavaBackendClient(baseUrl: JavaBackendConfig.baseUrl)
               : null),
       _analytics = analytics ?? const NoopAppAnalytics(),
       _crashReporter = crashReporter ?? const NoopAppCrashReporter();

  static const int syncSchemaVersion = 3;
  static const Duration _rpcTimeout = Duration(seconds: 12);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
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

    try {
      final remoteSnapshot = await _syncCompetitiveStateFromSourceRemotely(
        player,
      );
      if (remoteSnapshot == null) {
        return localFallback;
      }

      _lastSyncedFingerprintByUser[uid] = _fingerprintFor(remoteSnapshot);
      unawaited(
        _runCompetitiveShadowPreview(
          player: player,
          remoteSnapshot: remoteSnapshot,
          stage: 'competitive_rank_shadow_preview',
        ),
      );
      return remoteSnapshot;
    } catch (error, stackTrace) {
      _reportRecoverable(
        error,
        stackTrace,
        stage: 'sync_competitive_state_from_source',
      );
      return localFallback;
    }
  }

  Future<CompetitiveRankSnapshot?> syncSnapshot(Player player) =>
      syncCompetitiveState(player);

  Future<CompetitiveRankSnapshot?> _syncCompetitiveStateFromSourceRemotely(
    Player player,
  ) async {
    final callable = _functions.httpsCallable('syncCompetitiveStateFromSource');
    final response = await callable
        .call(<String, dynamic>{'source': _competitiveSourceFor(player)})
        .timeout(_rpcTimeout);
    final data = response.data;
    if (data is! Map) {
      return null;
    }

    final snapshotData = data['snapshot'];
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
    if (javaBackendClient != null) {
      try {
        final idToken = await _auth.currentUser?.getIdToken();
        if (idToken != null && idToken.isNotEmpty) {
          return await javaBackendClient
              .fetchSeasonBracketLeaderboard(
                idToken: idToken,
                seasonKey: seasonKey,
                rankBracket: rankBracket,
                limit: limit,
              )
              .timeout(_rpcTimeout);
        }
      } catch (error, stackTrace) {
        _reportRecoverable(
          error,
          stackTrace,
          stage: 'fetch_season_bracket_leaderboard_java',
        );
      }
    }

    try {
      final callable = _functions.httpsCallable('getSeasonBracketLeaderboard');
      final response = await callable
          .call(<String, dynamic>{
            'seasonKey': seasonKey,
            'rankBracket': rankBracket,
            'limit': limit,
          })
          .timeout(_rpcTimeout);
      final data = response.data;
      if (data is! Map || data['entries'] is! List) {
        return const <RankSeasonLeaderboardEntry>[];
      }

      return (data['entries'] as List)
          .whereType<Map>()
          .map((entry) {
            final map = entry.cast<String, dynamic>();
            return RankSeasonLeaderboardEntry(
              position: (map['position'] as num?)?.toInt() ?? 0,
              displayName: map['displayName'] as String? ?? 'HUNTER',
              detail: map['detail'] as String? ?? '',
              isPlayer: map['isPlayer'] as bool? ?? false,
            );
          })
          .toList(growable: false);
    } catch (error, stackTrace) {
      _reportRecoverable(
        error,
        stackTrace,
        stage: 'fetch_season_bracket_leaderboard',
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

    try {
      final remoteIntegrity = await _syncCompetitiveIntegrityFromSourceRemotely(
        player: player,
        quests: quests,
      );
      if (remoteIntegrity != null) {
        unawaited(
          _runCompetitiveShadowPreview(
            player: player,
            quests: quests,
            remoteIntegrity: remoteIntegrity,
            stage: 'competitive_integrity_shadow_preview',
          ),
        );
      }
      return remoteIntegrity ?? localFallback;
    } catch (error, stackTrace) {
      _reportRecoverable(
        error,
        stackTrace,
        stage: 'sync_competitive_integrity_from_source',
      );
      return localFallback;
    }
  }

  Future<CompetitiveIntegritySnapshot?>
  _syncCompetitiveIntegrityFromSourceRemotely({
    required Player player,
    required List<Quest> quests,
  }) async {
    final callable = _functions.httpsCallable(
      'syncCompetitiveIntegrityFromSource',
    );
    final response = await callable
        .call(<String, dynamic>{
          'source': _competitiveIntegritySourceFor(
            player: player,
            quests: quests,
          ),
        })
        .timeout(_rpcTimeout);
    final data = response.data;
    if (data is! Map) {
      return null;
    }

    final integrityData = data['integrity'];
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
              'completedAt': quest.completedAt?.toIso8601String(),
            },
          )
          .toList(growable: false),
    };
  }

  Future<void> _runCompetitiveShadowPreview({
    required Player player,
    List<Quest> quests = const <Quest>[],
    CompetitiveRankSnapshot? remoteSnapshot,
    CompetitiveIntegritySnapshot? remoteIntegrity,
    required String stage,
  }) async {
    final javaBackendClient = _javaBackendClient;
    final currentUser = _auth.currentUser;
    if (javaBackendClient == null || currentUser == null) {
      return;
    }

    try {
      final idToken = await currentUser.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        return;
      }

      final response = await javaBackendClient
          .previewCompetitiveState(
            idToken: idToken,
            rankSource: _competitiveSourceFor(player),
            integritySource: _competitiveIntegritySourceFor(
              player: player,
              quests: quests,
            ),
          )
          .timeout(_rpcTimeout);
      _compareCompetitiveShadowPreview(
        response: response,
        remoteSnapshot: remoteSnapshot,
        remoteIntegrity: remoteIntegrity,
        stage: stage,
      );
    } catch (error, stackTrace) {
      _reportRecoverable(error, stackTrace, stage: stage);
    }
  }

  void _compareCompetitiveShadowPreview({
    required Map<String, dynamic> response,
    CompetitiveRankSnapshot? remoteSnapshot,
    CompetitiveIntegritySnapshot? remoteIntegrity,
    required String stage,
  }) {
    final rankSnapshot = response['rankSnapshot'];
    if (remoteSnapshot != null && rankSnapshot is Map) {
      final javaStatus = rankSnapshot['status'] as String?;
      final javaRank = rankSnapshot['currentRank'] as String?;
      if (javaStatus != remoteSnapshot.status.name ||
          javaRank != remoteSnapshot.currentRank) {
        _reportShadowDivergence(
          stage: stage,
          message:
              'Rank Java=$javaRank/$javaStatus Firebase=${remoteSnapshot.currentRank}/${remoteSnapshot.status.name}',
        );
      }
    }

    final integritySnapshot = response['integritySnapshot'];
    if (remoteIntegrity != null && integritySnapshot is Map) {
      final javaTrustBand = integritySnapshot['trustBand'] as String?;
      final javaTrustScore = (integritySnapshot['trustScore'] as num?)?.toInt();
      if (javaTrustBand != remoteIntegrity.trustBand.name ||
          javaTrustScore != remoteIntegrity.trustScore) {
        _reportShadowDivergence(
          stage: stage,
          message:
              'Integridade Java=$javaTrustBand/$javaTrustScore Firebase=${remoteIntegrity.trustBand.name}/${remoteIntegrity.trustScore}',
        );
      }
    }
  }

  void _reportShadowDivergence({
    required String stage,
    required String message,
  }) {
    final error = StateError('Divergencia shadow competitiva: $message');
    if (kDebugMode) {
      debugPrint('[CompetitiveShadow] $stage: $message');
    }
    _reportRecoverable(error, StackTrace.current, stage: stage);
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

    if (_shouldDispatchRpc(snapshot: snapshot, exam: nextExam)) {
      await _upsertCompetitiveProgressionRemotely(
        snapshot: snapshot,
        exam: nextExam,
      );
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

  Future<void> _upsertCompetitiveProgressionRemotely({
    required CompetitiveRankSnapshot snapshot,
    PromotionExam? exam,
    SeasonRewardSnapshot? seasonReward,
  }) async {
    if (!_shouldDispatchRpc(
      snapshot: snapshot,
      exam: exam,
      seasonReward: seasonReward,
    )) {
      return;
    }

    try {
      final callable = _functions.httpsCallable('upsertCompetitiveProgression');
      await callable
          .call({
            'snapshot': snapshot.toFirestore(),
            if (exam != null) 'exam': exam.toFirestore(),
            if (seasonReward != null)
              'seasonReward': seasonReward.toFirestore(),
          })
          .timeout(_rpcTimeout);
    } catch (error, stackTrace) {
      _reportRecoverable(
        error,
        stackTrace,
        stage: 'upsert_competitive_progression',
      );
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
        reason: 'competitive_remote:$stage',
        fatal: false,
      ),
    );
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

  Future<String> _startPromotionExamRemotely(
    CompetitiveRankSnapshot snapshot,
  ) async {
    final callable = _functions.httpsCallable('startPromotionExam');
    final response = await callable
        .call(<String, dynamic>{'snapshot': snapshot.toFirestore()})
        .timeout(_rpcTimeout);
    final data = response.data;
    if (data is Map && data['status'] is String) {
      return data['status'] as String;
    }
    return 'started';
  }

  Future<String> _confirmPromotionRemotely(
    CompetitiveRankSnapshot snapshot,
  ) async {
    final callable = _functions.httpsCallable('confirmPromotion');
    final response = await callable
        .call(<String, dynamic>{'snapshot': snapshot.toFirestore()})
        .timeout(_rpcTimeout);
    final data = response.data;
    if (data is Map && data['status'] is String) {
      return data['status'] as String;
    }
    return 'promoted';
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
