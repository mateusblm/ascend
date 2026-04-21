import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/competitive_integrity.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/rank_season.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';

class RankSeasonLeaderboardEntry {
  const RankSeasonLeaderboardEntry({
    required this.position,
    required this.displayName,
    required this.detail,
    required this.isPlayer,
  });

  final int position;
  final String displayName;
  final String detail;
  final bool isPlayer;
}

class RankSeasonLeaderboardSummary {
  const RankSeasonLeaderboardSummary({
    required this.divisionLabel,
    required this.boardStatusLabel,
    required this.playerStandingLabel,
    required this.momentumLabel,
    required this.clearRateLabel,
    required this.seasonScore,
    required this.scoreBandLabel,
    required this.nextThresholdLabel,
    required this.spotlightLabel,
    required this.podium,
  });

  final String divisionLabel;
  final String boardStatusLabel;
  final String playerStandingLabel;
  final String momentumLabel;
  final String clearRateLabel;
  final int seasonScore;
  final String scoreBandLabel;
  final String nextThresholdLabel;
  final String spotlightLabel;
  final List<RankSeasonLeaderboardEntry> podium;
}

RankSeasonLeaderboardSummary buildRankSeasonLeaderboardSummary({
  required Player player,
  required RankSeasonSummary season,
  required RemoteWeeklyBoss? activeBoss,
  required List<WeeklyBossCompletion> topCompletions,
  CompetitiveRankSnapshot? snapshot,
  CompetitiveIntegritySnapshot? integrity,
  List<RankSeasonLeaderboardEntry> globalLeaderboard = const [],
}) {
  final currentRank = snapshot?.currentRank ?? playerRankForLevel(player.level);
  final divisionLabel = '${season.seasonLabel} | RANK $currentRank';
  final normalizedPlayerName = _normalizeName(player.name);
  final topEntries = topCompletions
      .take(3)
      .toList(growable: false)
      .asMap()
      .entries
      .map((entry) {
        final completion = entry.value;
        final timeLabel = completion.completedAt == null
            ? 'Sincronizando clear'
            : _formatCompletionTime(completion.completedAt!);
        return RankSeasonLeaderboardEntry(
          position: entry.key + 1,
          displayName: completion.displayName,
          detail: 'Rank ${completion.rankAtCompletion} | $timeLabel',
          isPlayer: _normalizeName(completion.displayName) == normalizedPlayerName,
        );
      })
      .toList(growable: false);
  final leaders = globalLeaderboard.isNotEmpty ? globalLeaderboard : topEntries;
  final score = _seasonScoreFor(season);
  final band = _bandForScore(score);
  final playerPlacement = globalLeaderboard.isNotEmpty
      ? _playerPlacementFromGlobal(globalLeaderboard)
      : podiumPlacementForPlayer(
          playerName: player.name,
          topCompletions: topCompletions,
        );
  final clearRateLabel = _clearRateLabel(activeBoss);
  final boardStatusLabel = _boardStatusLabel(
    activeBoss: activeBoss,
    clearRateLabel: clearRateLabel,
    hasGlobalLeaderboard: globalLeaderboard.isNotEmpty,
  );
  final playerStandingLabel = switch (playerPlacement) {
    1 => 'LIDER DO RANK',
    2 => 'TOP 2 DA ARENA',
    3 => 'TOP 3 DA ARENA',
    _ when score >= 16 => 'ELITE DO GRUPO',
    _ when score >= 10 => 'NA ZONA DE PRESTIGIO',
    _ when score >= 6 => 'NA DISPUTA',
    _ => 'GANHANDO TERRENO',
  };
  final adjustedStandingLabel = _adjustStandingForIntegrity(
    playerStandingLabel,
    integrity,
  );
  final momentumLabel = switch (season.rewardStatusLabel) {
    'GARANTIDA' => 'Temporada sob controle total',
    'RECOMPENSA AVANCADA' => 'Falta pouco para fechar em elite',
    'EM ROTA' => 'Ritmo bom, ainda sem folga',
    'ABRINDO TRILHA' => 'A trilha abriu, mas ainda e cedo',
    'INSTAVEL' => 'A temporada entrou em recuperacao',
    _ => 'Sem ritmo competitivo suficiente',
  };
  final adjustedMomentumLabel = _adjustMomentumForIntegrity(
    momentumLabel,
    integrity,
  );

  return RankSeasonLeaderboardSummary(
    divisionLabel: divisionLabel,
    boardStatusLabel: boardStatusLabel,
    playerStandingLabel: adjustedStandingLabel,
    momentumLabel: adjustedMomentumLabel,
    clearRateLabel: clearRateLabel,
    seasonScore: score,
    scoreBandLabel: band.label,
    nextThresholdLabel: _nextThresholdLabel(score),
    spotlightLabel: _spotlightLabel(
      activeBoss: activeBoss,
      podium: leaders,
      playerPlacement: playerPlacement,
    ),
    podium: leaders,
  );
}

int? podiumPlacementForPlayer({
  required String playerName,
  required List<WeeklyBossCompletion> topCompletions,
}) {
  final normalizedPlayerName = _normalizeName(playerName);
  for (var index = 0; index < topCompletions.length; index++) {
    if (_normalizeName(topCompletions[index].displayName) ==
        normalizedPlayerName) {
      return index + 1;
    }
  }
  return null;
}

int _seasonScoreFor(RankSeasonSummary season) {
  return (season.secureWeeks * 3) +
      (season.examWeeks * 2) +
      (season.promotionEvents * 5) +
      (season.perfectWeeks * 4) -
      (season.demotionEvents * 4);
}

({String label, int threshold}) _bandForScore(int score) {
  if (score >= 16) {
    return (label: 'LIDERANCA', threshold: 16);
  }
  if (score >= 10) {
    return (label: 'ELITE', threshold: 10);
  }
  if (score >= 6) {
    return (label: 'DISPUTA', threshold: 6);
  }
  return (label: 'RECUPERACAO', threshold: 0);
}

String _nextThresholdLabel(int score) {
  if (score >= 16) {
    return 'Pontuacao de lideranca garantida para esta temporada.';
  }
  if (score >= 10) {
    return 'Mais ${16 - score} ponto(s) para entrar em LIDERANCA.';
  }
  if (score >= 6) {
    return 'Mais ${10 - score} ponto(s) para entrar em ELITE.';
  }
  return 'Mais ${6 - score} ponto(s) para entrar de vez na disputa.';
}

String _clearRateLabel(RemoteWeeklyBoss? activeBoss) {
  if (activeBoss == null || activeBoss.participantCount <= 0) {
    return 'Clear rate aguardando lobby';
  }

  final rate = ((activeBoss.completedCount / activeBoss.participantCount) * 100)
      .round();
  return '$rate% do rank concluiu';
}

String _boardStatusLabel({
  required RemoteWeeklyBoss? activeBoss,
  required String clearRateLabel,
  required bool hasGlobalLeaderboard,
}) {
  if (hasGlobalLeaderboard) {
    return 'DISPUTA DO GRUPO | $clearRateLabel';
  }
  if (activeBoss == null) {
    return 'GRUPO AGUARDANDO';
  }
  if (activeBoss.completedCount == 0) {
    return 'NINGUEM ABRIU A ARENA';
  }
  return 'DISPUTA ABERTA | $clearRateLabel';
}

String _adjustStandingForIntegrity(
  String baseLabel,
  CompetitiveIntegritySnapshot? integrity,
) {
  if (integrity == null) return baseLabel;
  return switch (integrity.trustBand) {
    CompetitiveTrustBand.high || CompetitiveTrustBand.stable => baseLabel,
    CompetitiveTrustBand.attention => '$baseLabel | EM OBSERVACAO',
    CompetitiveTrustBand.restricted => '$baseLabel | EM CHECAGEM',
  };
}

String _adjustMomentumForIntegrity(
  String baseLabel,
  CompetitiveIntegritySnapshot? integrity,
) {
  if (integrity == null) return baseLabel;
  return switch (integrity.trustBand) {
    CompetitiveTrustBand.high || CompetitiveTrustBand.stable => baseLabel,
    CompetitiveTrustBand.attention =>
      '$baseLabel. Mais constancia validada ajuda a segurar esse lugar.',
    CompetitiveTrustBand.restricted =>
      '$baseLabel. Sua temporada ainda precisa de mais sinais confiaveis para ganhar forca total.',
  };
}

String _spotlightLabel({
  required RemoteWeeklyBoss? activeBoss,
  required List<RankSeasonLeaderboardEntry> podium,
  required int? playerPlacement,
}) {
  if (playerPlacement != null) {
    return 'Seu clear esta no podio da arena atual.';
  }
  if (activeBoss == null) {
    return 'Sem boss ativo. A disputa volta na proxima rotacao.';
  }
  if (podium.isEmpty) {
    return 'Ninguem concluiu ainda. O primeiro clear vai puxar o ritmo do grupo.';
  }
  return 'O podio da arena ja abriu. Entre agora para nao deixar o rank escapar.';
}

int? _playerPlacementFromGlobal(List<RankSeasonLeaderboardEntry> entries) {
  for (final entry in entries) {
    if (entry.isPlayer) return entry.position;
  }
  return null;
}

String _normalizeName(String value) => value.trim().toLowerCase();

String _formatCompletionTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}
