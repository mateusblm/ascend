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
    _ => seasonReward == null
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
