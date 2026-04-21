import 'package:ascend/features/profile/domain/player_model.dart';

class WeeklyBossDefinition {
  const WeeklyBossDefinition({
    required this.rank,
    required this.title,
    required this.description,
    required this.targetActiveDays,
    required this.rewardXp,
    required this.rewardStatPoints,
  });

  final String rank;
  final String title;
  final String description;
  final int targetActiveDays;
  final int rewardXp;
  final int rewardStatPoints;
}

extension WeeklyBossDefinitionX on WeeklyBossDefinition {
  int progressFor(
    Player player, {
    bool competitiveOnly = false,
    DateTime? now,
  }) {
    final referenceDate = now ?? DateTime.now();
    final weekStart = weekStartFor(referenceDate);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final sourceHistory = competitiveOnly
        ? player.competitiveActivityHistory
        : (player.competitiveActivityHistory.isNotEmpty
              ? player.competitiveActivityHistory
              : player.activityHistory);
    final sourceLastCompletion = competitiveOnly
        ? player.lastCompetitiveQuestCompletionDate
        : (player.lastCompetitiveQuestCompletionDate ??
              player.lastQuestCompletionDate);

    final activeDates = sourceHistory
        .map((entry) => DateTime(entry.year, entry.month, entry.day))
        .toSet();

    final lastCompletion = sourceLastCompletion;
    if (lastCompletion != null) {
      activeDates.add(DateTime(lastCompletion.year, lastCompletion.month, lastCompletion.day));
    }

    return activeDates.where((date) => !date.isBefore(weekStart) && date.isBefore(weekEnd)).length;
  }

  bool isCompleted(
    Player player, {
    bool competitiveOnly = false,
    DateTime? now,
  }) => progressFor(
        player,
        competitiveOnly: competitiveOnly,
        now: now,
      ) >=
      targetActiveDays;

  bool isClaimedThisWeek(Player player, {DateTime? now}) {
    final claimedAt = player.weeklyBossLastClaimedAt;
    if (claimedAt == null) return false;

    return weekStartFor(claimedAt) == weekStartFor(now ?? DateTime.now());
  }
}

DateTime weekStartFor(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return normalized.subtract(Duration(days: normalized.weekday - 1));
}

String playerRankForLevel(int level) {
  if (level < 5) return 'E';
  if (level < 10) return 'D';
  if (level < 20) return 'C';
  if (level < 30) return 'B';
  if (level < 40) return 'A';
  return 'S';
}

WeeklyBossDefinition weeklyBossForPlayer(Player player) {
  return weeklyBossForRank(playerRankForLevel(player.level));
}

WeeklyBossDefinition weeklyBossForRank(String rank) {
  return switch (rank) {
    'E' => const WeeklyBossDefinition(
        rank: 'E',
        title: 'Primeira Ruptura',
        description: 'Fique ativo em 4 dias da semana para provar que voce merece subir de rank.',
        targetActiveDays: 4,
        rewardXp: 120,
        rewardStatPoints: 2,
      ),
    'D' => const WeeklyBossDefinition(
        rank: 'D',
        title: 'Cerco do Iniciante',
        description: 'Mantenha 4 dias ativos e mostre consistencia acima da media do rank D.',
        targetActiveDays: 4,
        rewardXp: 140,
        rewardStatPoints: 2,
      ),
    'C' => const WeeklyBossDefinition(
        rank: 'C',
        title: 'Camara da Pressao',
        description: 'Entregue 5 dias ativos para suportar a pressao do rank C.',
        targetActiveDays: 5,
        rewardXp: 170,
        rewardStatPoints: 3,
      ),
    'B' => const WeeklyBossDefinition(
        rank: 'B',
        title: 'Fenda do Executor',
        description: 'Complete 5 dias ativos para dominar a semana como um executor de rank B.',
        targetActiveDays: 5,
        rewardXp: 200,
        rewardStatPoints: 3,
      ),
    'A' => const WeeklyBossDefinition(
        rank: 'A',
        title: 'Trono do Predador',
        description: 'Segure 6 dias ativos e prove que seu nivel de execucao e raro.',
        targetActiveDays: 6,
        rewardXp: 240,
        rewardStatPoints: 4,
      ),
    _ => const WeeklyBossDefinition(
        rank: 'S',
        title: 'Nucleo da Ascensao',
        description: 'Conquiste 6 dias ativos para sustentar um padrao digno do rank S.',
        targetActiveDays: 6,
        rewardXp: 300,
        rewardStatPoints: 5,
      ),
  };
}
