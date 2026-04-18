import 'package:ascend/features/profile/domain/player_model.dart';

class WeeklyBossDefinition {
  const WeeklyBossDefinition({
    required this.title,
    required this.description,
    required this.targetActiveDays,
    required this.rewardXp,
    required this.rewardStatPoints,
  });

  final String title;
  final String description;
  final int targetActiveDays;
  final int rewardXp;
  final int rewardStatPoints;
}

extension WeeklyBossDefinitionX on WeeklyBossDefinition {
  int progressFor(Player player) {
    final now = DateTime.now();
    final weekStart = _weekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final activeDates = player.activityHistory
        .map((entry) => DateTime(entry.year, entry.month, entry.day))
        .toSet();

    final lastCompletion = player.lastQuestCompletionDate;
    if (lastCompletion != null) {
      activeDates.add(DateTime(lastCompletion.year, lastCompletion.month, lastCompletion.day));
    }

    return activeDates.where((date) => !date.isBefore(weekStart) && date.isBefore(weekEnd)).length;
  }

  bool isCompleted(Player player) => progressFor(player) >= targetActiveDays;

  bool isClaimedThisWeek(Player player) {
    final claimedAt = player.weeklyBossLastClaimedAt;
    if (claimedAt == null) return false;

    return _weekStart(claimedAt) == _weekStart(DateTime.now());
  }

  static DateTime _weekStart(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }
}

WeeklyBossDefinition weeklyBossFor(AwakeningPath focus) {
  return switch (focus) {
    AwakeningPath.discipline => const WeeklyBossDefinition(
        title: 'Protocolo de Constancia',
        description: 'Fique ativo em 4 dias da semana para consolidar a disciplina.',
        targetActiveDays: 4,
        rewardXp: 120,
        rewardStatPoints: 2,
      ),
    AwakeningPath.study => const WeeklyBossDefinition(
        title: 'Ritual do Conhecimento',
        description: 'Ative o sistema em 4 dias da semana para manter o estudo em alta.',
        targetActiveDays: 4,
        rewardXp: 130,
        rewardStatPoints: 2,
      ),
    AwakeningPath.training => const WeeklyBossDefinition(
        title: 'Circuito de Evolucao',
        description: 'Registre progresso em 5 dias da semana para dominar sua rotina fisica.',
        targetActiveDays: 5,
        rewardXp: 140,
        rewardStatPoints: 2,
      ),
    AwakeningPath.health => const WeeklyBossDefinition(
        title: 'Nucleo Vital',
        description: 'Mantenha 4 dias ativos na semana para estabilizar sua energia.',
        targetActiveDays: 4,
        rewardXp: 120,
        rewardStatPoints: 3,
      ),
    AwakeningPath.productivity => const WeeklyBossDefinition(
        title: 'Sprint de Execucao',
        description: 'Ative o sistema em 5 dias da semana para consolidar entregas.',
        targetActiveDays: 5,
        rewardXp: 140,
        rewardStatPoints: 2,
      ),
  };
}
