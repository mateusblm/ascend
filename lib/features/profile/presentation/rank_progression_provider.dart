import 'package:ascend/features/profile/data/rank_progression_repository.dart';
import 'package:ascend/features/profile/domain/competitive_integrity.dart';
import 'package:ascend/features/profile/domain/promotion_exam.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/season_legacy_reward.dart';
import 'package:ascend/features/profile/domain/season_profile_snapshot.dart';
import 'package:ascend/features/profile/domain/season_reward_snapshot.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rankProgressionRepositoryProvider = Provider<RankProgressionRepository>((
  ref,
) {
  return RankProgressionRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

final rankProgressionSnapshotProvider =
    StreamProvider.autoDispose<CompetitiveRankSnapshot?>((ref) {
      final repository = ref.watch(rankProgressionRepositoryProvider);
      return repository.watchCurrentSnapshot();
    });

final rankProgressionHistoryProvider =
    StreamProvider.autoDispose<List<CompetitiveRankSnapshot>>((ref) {
      final repository = ref.watch(rankProgressionRepositoryProvider);
      return repository.watchRecentHistory();
    });

final promotionExamProvider = StreamProvider.autoDispose<PromotionExam?>((ref) {
  final repository = ref.watch(rankProgressionRepositoryProvider);
  return repository.watchCurrentPromotionExam();
});

final currentSeasonRewardProvider =
    StreamProvider.autoDispose<SeasonRewardSnapshot?>((ref) {
      final repository = ref.watch(rankProgressionRepositoryProvider);
      return repository.watchCurrentSeasonReward();
    });

final seasonRewardHistoryProvider =
    StreamProvider.autoDispose<List<SeasonRewardSnapshot>>((ref) {
      final repository = ref.watch(rankProgressionRepositoryProvider);
      return repository.watchSeasonRewardHistory();
    });

final seasonLegacyHistoryProvider =
    StreamProvider.autoDispose<List<SeasonLegacyReward>>((ref) {
      final repository = ref.watch(rankProgressionRepositoryProvider);
      return repository.watchSeasonLegacyHistory();
    });

final seasonProfileProvider =
    StreamProvider.autoDispose<SeasonProfileSnapshot?>((ref) {
      final repository = ref.watch(rankProgressionRepositoryProvider);
      return repository.watchSeasonProfile();
    });

final currentCompetitiveIntegrityProvider =
    StreamProvider.autoDispose<CompetitiveIntegritySnapshot?>((ref) {
      final repository = ref.watch(rankProgressionRepositoryProvider);
      return repository.watchCurrentIntegrity();
    });

final competitiveIntegrityHistoryProvider =
    StreamProvider.autoDispose<List<CompetitiveIntegritySnapshot>>((ref) {
      final repository = ref.watch(rankProgressionRepositoryProvider);
      return repository.watchIntegrityHistory();
    });

final competitiveRankProvider = Provider<String>((ref) {
  final player = ref.watch(playerProvider);
  final remoteSnapshot = ref.watch(rankProgressionSnapshotProvider).valueOrNull;
  return remoteSnapshot?.currentRank ?? playerRankForLevel(player.level);
});

// O sync competitivo agora e gerenciado por um listener com debounce
// em MainNavigationScreen, evitando side-effects durante avaliacao de providers.
