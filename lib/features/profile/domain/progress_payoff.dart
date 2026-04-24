import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/season_profile_snapshot.dart';
import 'package:ascend/features/profile/domain/season_reward_snapshot.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';

class ProgressPayoffSummary {
  const ProgressPayoffSummary({
    required this.headline,
    required this.body,
    required this.levelLabel,
    required this.rankLabel,
    required this.seasonLabel,
  });

  final String headline;
  final String body;
  final String levelLabel;
  final String rankLabel;
  final String seasonLabel;
}

class ReturnMotivationSummary {
  const ReturnMotivationSummary({
    required this.statusLabel,
    required this.tomorrowAction,
    required this.weeklyPressure,
    required this.payoffReason,
    required this.isUrgent,
  });

  final String statusLabel;
  final String tomorrowAction;
  final String weeklyPressure;
  final String payoffReason;
  final bool isUrgent;
}

ProgressPayoffSummary buildProgressPayoff({
  required Player player,
  CompetitiveRankSnapshot? snapshot,
  SeasonRewardSnapshot? seasonReward,
  SeasonProfileSnapshot? seasonProfile,
}) {
  final currentRank = snapshot?.currentRank ?? playerRankForLevel(player.level);
  final nextRank = snapshot?.promotionTargetRank ?? rankAfter(currentRank);
  final xpToNextLevel = (player.maxXp - player.xp).clamp(0, player.maxXp);

  final rankLabel = switch ((
    snapshot?.promotionReady ?? false,
    snapshot?.targetLevelGateMet ?? true,
    nextRank,
  )) {
    (true, _, final target?) => 'Prova pronta para o rank $target',
    (_, false, final target?) =>
      'Level ${snapshot?.targetRequiredLevel ?? rankRuleFor(target).minimumLevel} libera o rank $target',
    (_, _, final target?) => 'Semana valida abre o rank $target',
    _ => 'Seu rank atual ja esta no topo da rota',
  };

  final seasonLabel = switch (seasonReward?.claimStatus) {
    SeasonRewardClaimStatus.readyToClaim => 'Recompensa sazonal pronta',
    SeasonRewardClaimStatus.claimed =>
      seasonProfile == null
          ? 'Legado sazonal equipado'
          : 'Titulo ativo: ${seasonProfile.activeTitleLabel}',
    _ =>
      seasonReward == null
          ? 'Temporada carregando'
          : '${seasonReward.rewardName} a caminho',
  };

  final headline = xpToNextLevel <= 20
      ? 'Seu proximo ganho esta perto'
      : 'Seu esforco desta semana ja esta rendendo';

  return ProgressPayoffSummary(
    headline: headline,
    body:
        'Seu level sobe com constancia, seu rank cresce com prova real e a temporada guarda o que voce conquistou.',
    levelLabel: '$xpToNextLevel XP para o proximo level (+5 pontos)',
    rankLabel: rankLabel,
    seasonLabel: seasonLabel,
  );
}

ReturnMotivationSummary buildReturnMotivation({
  required Player player,
  required ProgressPayoffSummary progressPayoff,
  CompetitiveRankSnapshot? snapshot,
  DateTime? now,
}) {
  final today = _dateOnly(now ?? DateTime.now());
  final activeThisWeek = _activeDaysInCurrentWeek(player, today);
  final daysLeftInWeek = (DateTime.daysPerWeek - today.weekday).clamp(0, 6);
  final xpToNextLevel = (player.maxXp - player.xp).clamp(0, player.maxXp);
  final rankStatus = snapshot?.status;
  final isRankUnderPressure =
      rankStatus == RankMaintenanceStatus.warning ||
      rankStatus == RankMaintenanceStatus.critical ||
      rankStatus == RankMaintenanceStatus.demoted;
  final isUrgent = player.currentStreak == 0 || isRankUnderPressure;

  final statusLabel = isUrgent
      ? 'RETOMAR'
      : activeThisWeek >= 4
      ? 'SUSTENTAR'
      : 'CONSTRUIR';

  final tomorrowAction = player.currentStreak == 0
      ? 'Volte amanha para transformar uma entrega isolada em streak.'
      : 'Volte amanha para manter ${player.currentStreak + 1} dias vivos.';

  final weeklyPressure = switch (rankStatus) {
    RankMaintenanceStatus.warning =>
      'Rank em aviso: faltam poucos dias para estabilizar a semana.',
    RankMaintenanceStatus.critical =>
      'Rank em risco: a proxima quest competitiva precisa entrar no plano.',
    RankMaintenanceStatus.demoted =>
      'Rank caiu: a semana precisa recomecar com uma entrega validada.',
    RankMaintenanceStatus.promotionReady =>
      'Promocao pronta: volte com energia para abrir a prova no momento certo.',
    RankMaintenanceStatus.secure =>
      'Semana segura: use os proximos $daysLeftInWeek dia(s) para consolidar.',
    null => 'Semana em montagem: $activeThisWeek/7 dia(s) ativos registrados.',
  };

  final payoffReason = xpToNextLevel <= 20
      ? progressPayoff.levelLabel
      : progressPayoff.rankLabel;

  return ReturnMotivationSummary(
    statusLabel: statusLabel,
    tomorrowAction: tomorrowAction,
    weeklyPressure: weeklyPressure,
    payoffReason: payoffReason,
    isUrgent: isUrgent,
  );
}

int _activeDaysInCurrentWeek(Player player, DateTime today) {
  final start = _weekStartFor(today);
  final end = start.add(const Duration(days: 7));
  final activeDates = {
    ...player.activityHistory.map(_dateOnly),
    ...player.competitiveActivityHistory.map(_dateOnly),
    if (player.lastQuestCompletionDate != null)
      _dateOnly(player.lastQuestCompletionDate!),
    if (player.lastCompetitiveQuestCompletionDate != null)
      _dateOnly(player.lastCompetitiveQuestCompletionDate!),
  };

  return activeDates
      .where((date) => !date.isBefore(start) && date.isBefore(end))
      .length;
}

DateTime _weekStartFor(DateTime date) {
  final normalized = _dateOnly(date);
  return normalized.subtract(Duration(days: normalized.weekday - 1));
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
