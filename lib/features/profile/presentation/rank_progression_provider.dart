import 'package:ascend/features/profile/data/rank_progression_repository.dart';
import 'package:ascend/features/profile/domain/promotion_exam.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
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

final competitiveRankProvider = Provider<String>((ref) {
  final player = ref.watch(playerProvider);
  final remoteSnapshot = ref.watch(rankProgressionSnapshotProvider).valueOrNull;
  return remoteSnapshot?.currentRank ?? playerRankForLevel(player.level);
});

// O sync competitivo agora é gerenciado por um listener com debounce
// em MainNavigationScreen, evitando side-effects durante avaliação de providers.

