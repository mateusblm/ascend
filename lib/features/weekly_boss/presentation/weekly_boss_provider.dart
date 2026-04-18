import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/weekly_boss/data/weekly_boss_repository.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weeklyBossRepositoryProvider = Provider<WeeklyBossRepository>((ref) {
  return WeeklyBossRepository(FirebaseFirestore.instance);
});

final remoteWeeklyBossProvider = StreamProvider.autoDispose<RemoteWeeklyBoss?>((ref) {
  final player = ref.watch(playerProvider);
  final rank = playerRankForLevel(player.level);
  final repository = ref.watch(weeklyBossRepositoryProvider);
  return repository.watchActiveBossForRank(rank);
});
