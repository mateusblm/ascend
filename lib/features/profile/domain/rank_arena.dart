import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';

class RankArenaSummary {
  const RankArenaSummary({
    required this.hasActiveBoss,
    required this.stateLabel,
    required this.urgencyLabel,
    required this.progress,
    required this.target,
    required this.completedCount,
    required this.rewardLabel,
    required this.leaderHeadline,
    required this.crowdReading,
  });

  final bool hasActiveBoss;
  final String stateLabel;
  final String urgencyLabel;
  final int progress;
  final int target;
  final int completedCount;
  final String rewardLabel;
  final String leaderHeadline;
  final String crowdReading;
}

RankArenaSummary buildRankArenaSummary({
  required Player player,
  required RemoteWeeklyBoss? boss,
  required List<WeeklyBossCompletion> topCompletions,
  DateTime? now,
}) {
  if (boss == null) {
    return const RankArenaSummary(
      hasActiveBoss: false,
      stateLabel: 'SEM EVENTO',
      urgencyLabel: 'AGUARDANDO O PROXIMO',
      progress: 0,
      target: 0,
      completedCount: 0,
      rewardLabel: 'Nenhuma recompensa carregada.',
      leaderHeadline: 'Nenhum boss ativo para este rank.',
      crowdReading:
          'A arena esta vazia no momento. Assim que o evento abrir, esta area vira o centro da disputa.',
    );
  }

  final progress = _activeDaysThisWeek(player, now: now);
  final remaining = boss.endsAt.difference(now ?? DateTime.now());
  final urgencyLabel = switch (remaining.inHours) {
    <= 6 => 'JANELA FINAL',
    <= 24 => 'ULTIMAS HORAS',
    <= 72 => 'SEMANA DECISIVA',
    _ => 'ARENA ABERTA',
  };
  final stateLabel = switch (boss.completedCount) {
    >= 100 => 'ARENA LOTADA',
    >= 25 => 'DISPUTA PESADA',
    > 0 => 'PRIMEIROS CLEARS',
    _ => 'BOSS INVICTO',
  };
  final rewardLabel = '${boss.rewardXp} XP + ${boss.rewardStatPoints} ponto(s)';
  final leaderHeadline = topCompletions.isEmpty
      ? 'Nenhum clear remoto ainda. Quem romper primeiro define o ritmo do rank.'
      : 'Primeiro clear: ${topCompletions.first.displayName} abriu a arena.';
  final crowdReading = switch (boss.completedCount) {
    >= 100 =>
      'Muita gente ja passou pelo evento. Agora a disputa fica em ritmo e posicao.',
    >= 25 =>
      'O boss ja caiu bastante, mas a disputa ainda esta longe de terminar.',
    > 0 =>
      'Pouca gente conseguiu passar. Esse e um bom momento para subir no placar.',
    _ =>
      'Ninguem passou ainda. Quem abrir o caminho primeiro muda o ritmo da semana.',
  };

  return RankArenaSummary(
    hasActiveBoss: true,
    stateLabel: stateLabel,
    urgencyLabel: urgencyLabel,
    progress: progress,
    target: boss.targetActiveDays,
    completedCount: boss.completedCount,
    rewardLabel: rewardLabel,
    leaderHeadline: leaderHeadline,
    crowdReading: crowdReading,
  );
}

int _activeDaysThisWeek(Player player, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final weekStart = DateTime(
    current.year,
    current.month,
    current.day,
  ).subtract(Duration(days: current.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 7));
  final history = player.competitiveActivityHistory;
  final lastCompletion = player.lastCompetitiveQuestCompletionDate;

  final activeDates = <DateTime>{
    ...history.map(
      (entry) => DateTime(entry.year, entry.month, entry.day),
    ),
  };
  if (lastCompletion != null) {
    activeDates.add(
      DateTime(lastCompletion.year, lastCompletion.month, lastCompletion.day),
    );
  }

  return activeDates
      .where((date) => !date.isBefore(weekStart) && date.isBefore(weekEnd))
      .length;
}
