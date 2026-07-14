import 'package:ascend/features/profile/domain/player_model.dart';

/// Desafio semanal individual. O progresso e baseado apenas em dias ativos.
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
  int progressFor(Player player, {DateTime? now}) {
    final inicio = weekStartFor(now ?? DateTime.now());
    final fim = inicio.add(const Duration(days: 7));
    final dias = player.activityHistory
        .map((data) => DateTime(data.year, data.month, data.day))
        .toSet();
    final ultimaQuest = player.lastQuestCompletionDate;
    if (ultimaQuest != null) {
      dias.add(DateTime(ultimaQuest.year, ultimaQuest.month, ultimaQuest.day));
    }
    return dias
        .where((data) => !data.isBefore(inicio) && data.isBefore(fim))
        .length;
  }

  bool isCompleted(Player player, {DateTime? now}) =>
      progressFor(player, now: now) >= targetActiveDays;

  bool isClaimedThisWeek(Player player, {DateTime? now}) {
    final resgatadoEm = player.weeklyBossLastClaimedAt;
    return resgatadoEm != null &&
        weekStartFor(resgatadoEm) == weekStartFor(now ?? DateTime.now());
  }
}

DateTime weekStartFor(DateTime data) {
  final normalizada = DateTime(data.year, data.month, data.day);
  return normalizada.subtract(Duration(days: normalizada.weekday - 1));
}

WeeklyBossDefinition weeklyBossForPlayer(Player player) =>
    const WeeklyBossDefinition(
      title: 'Ruptura Semanal',
      description: 'Complete missoes em quatro dias desta semana.',
      targetActiveDays: 4,
      rewardXp: 120,
      rewardStatPoints: 2,
    );
