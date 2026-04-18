import 'package:ascend/features/profile/presentation/rank_progression_provider.dart';
import 'package:ascend/features/weekly_boss/data/weekly_boss_repository.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weeklyBossRepositoryProvider = Provider<WeeklyBossRepository>((ref) {
  return WeeklyBossRepository(FirebaseFirestore.instance);
});

final remoteWeeklyBossProvider = StreamProvider.autoDispose<RemoteWeeklyBoss?>((ref) {
  final rank = ref.watch(competitiveRankProvider);
  final repository = ref.watch(weeklyBossRepositoryProvider);
  return repository.watchActiveBossForRank(rank).map((boss) {
    if (kDebugMode) {
      debugPrint(
        boss == null
            ? '[WeeklyBoss] Nenhum boss remoto ativo para rank $rank.'
            : '[WeeklyBoss] Boss remoto carregado para rank $rank: ${boss.id}',
      );
    }
    return boss;
  }).handleError((error, stackTrace) {
    if (kDebugMode) {
      debugPrint('[WeeklyBoss] Erro ao carregar boss remoto para rank $rank: $error');
    }
  });
});

final weeklyBossTopCompletionsProvider =
    StreamProvider.autoDispose<List<WeeklyBossCompletion>>((ref) {
  final remoteBoss = ref.watch(remoteWeeklyBossProvider).valueOrNull;
  if (remoteBoss == null) {
    return Stream.value(const <WeeklyBossCompletion>[]);
  }

  final repository = ref.watch(weeklyBossRepositoryProvider);
  return repository.watchTopCompletions(remoteBoss.id);
});
