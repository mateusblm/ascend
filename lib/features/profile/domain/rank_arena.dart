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
    required this.participantCount,
    required this.clearRatePercent,
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
  final int participantCount;
  final int clearRatePercent;
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
      urgencyLabel: 'AGUARDANDO ROTACAO',
      progress: 0,
      target: 0,
      completedCount: 0,
      participantCount: 0,
      clearRatePercent: 0,
      rewardLabel: 'Nenhuma recompensa carregada.',
      leaderHeadline: 'Nenhum boss ativo para este rank.',
      crowdReading:
          'A arena esta vazia no momento. Assim que o evento abrir, esta area vira o centro da disputa.',
    );
  }

  final progress = _activeDaysThisWeek(player, now: now);
  final participants = boss.participantCount <= 0
      ? boss.completedCount
      : boss.participantCount;
  final clearRate = participants == 0
      ? 0
      : ((boss.completedCount / participants) * 100).round();
  final remaining = boss.endsAt.difference(now ?? DateTime.now());
  final urgencyLabel = switch (remaining.inHours) {
    <= 6 => 'JANELA FINAL',
    <= 24 => 'PRESSAO MAXIMA',
    <= 72 => 'SEMANA QUENTE',
    _ => 'ARENA ABERTA',
  };
  final stateLabel = switch (clearRate) {
    >= 70 => 'ARENA DOMINADA',
    >= 35 => 'PRESSAO DE ELITE',
    > 0 => 'PRIMEIROS HUNTERS',
    _ => 'BOSS INVICTO',
  };
  final rewardLabel = '${boss.rewardXp} XP + ${boss.rewardStatPoints} ponto(s)';
  final leaderHeadline = topCompletions.isEmpty
      ? 'Nenhum clear remoto ainda. Quem romper primeiro define o ritmo do rank.'
      : 'Primeiro clear: ${topCompletions.first.displayName} abriu a arena.';
  final crowdReading = switch (clearRate) {
    >= 70 =>
      'A maioria dos participantes ja rompeu o evento. Agora voce disputa reputacao e velocidade de clear.',
    >= 35 =>
      'O boss ainda oferece pressao competitiva real. O rank ja provou que e vencivel, mas ainda nao esta resolvido.',
    > 0 =>
      'Poucos hunters conseguiram passar. Esta e a zona ideal para ganhar prestigio rapido.',
    _ =>
      'Nenhum participante conseguiu clear ate agora. A arena ainda esta em estado bruto.',
  };

  return RankArenaSummary(
    hasActiveBoss: true,
    stateLabel: stateLabel,
    urgencyLabel: urgencyLabel,
    progress: progress,
    target: boss.targetActiveDays,
    completedCount: boss.completedCount,
    participantCount: participants,
    clearRatePercent: clearRate,
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
  final activeDates = <DateTime>{
    ...player.activityHistory.map(
      (entry) => DateTime(entry.year, entry.month, entry.day),
    ),
  };
  final lastCompletion = player.lastQuestCompletionDate;
  if (lastCompletion != null) {
    activeDates.add(
      DateTime(lastCompletion.year, lastCompletion.month, lastCompletion.day),
    );
  }

  return activeDates
      .where((date) => !date.isBefore(weekStart) && date.isBefore(weekEnd))
      .length;
}
