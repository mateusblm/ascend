import 'package:ascend/features/profile/domain/season_reward_snapshot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeasonLegacyReward {
  const SeasonLegacyReward({
    required this.seasonKey,
    required this.seasonLabel,
    required this.claimedRankBracket,
    required this.rewardTierLabel,
    required this.rewardName,
    required this.rewardBadgeLabel,
    required this.rewardTitleLabel,
    required this.rewardBonusLabel,
    required this.scoreBandLabel,
    required this.seasonScore,
    required this.playerStandingLabel,
    required this.spotlightLabel,
    required this.cosmeticFrameLabel,
    required this.cosmeticAuraLabel,
    required this.claimedAt,
    required this.syncSchemaVersion,
    required this.syncSource,
    required this.updatedAt,
  });

  final String seasonKey;
  final String seasonLabel;
  final String claimedRankBracket;
  final String rewardTierLabel;
  final String rewardName;
  final String rewardBadgeLabel;
  final String rewardTitleLabel;
  final String rewardBonusLabel;
  final String scoreBandLabel;
  final int seasonScore;
  final String playerStandingLabel;
  final String spotlightLabel;
  final String cosmeticFrameLabel;
  final String cosmeticAuraLabel;
  final DateTime claimedAt;
  final int syncSchemaVersion;
  final String syncSource;
  final DateTime updatedAt;

  String get legacyHeadline =>
      '$rewardTitleLabel | $rewardBadgeLabel | $cosmeticAuraLabel';

  Map<String, dynamic> toFirestore() {
    return {
      'seasonKey': seasonKey,
      'seasonLabel': seasonLabel,
      'claimedRankBracket': claimedRankBracket,
      'rewardTierLabel': rewardTierLabel,
      'rewardName': rewardName,
      'rewardBadgeLabel': rewardBadgeLabel,
      'rewardTitleLabel': rewardTitleLabel,
      'rewardBonusLabel': rewardBonusLabel,
      'scoreBandLabel': scoreBandLabel,
      'seasonScore': seasonScore,
      'playerStandingLabel': playerStandingLabel,
      'spotlightLabel': spotlightLabel,
      'cosmeticFrameLabel': cosmeticFrameLabel,
      'cosmeticAuraLabel': cosmeticAuraLabel,
      'claimedAt': Timestamp.fromDate(claimedAt),
      'syncSchemaVersion': syncSchemaVersion,
      'syncSource': syncSource,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SeasonLegacyReward.fromFirestore(Map<String, dynamic> data) {
    return SeasonLegacyReward(
      seasonKey: data['seasonKey'] as String? ?? '',
      seasonLabel: data['seasonLabel'] as String? ?? '',
      claimedRankBracket: (data['claimedRankBracket'] as String? ?? 'E')
          .trim()
          .toUpperCase(),
      rewardTierLabel: data['rewardTierLabel'] as String? ?? 'EM FORMACAO',
      rewardName: data['rewardName'] as String? ?? 'Pacote sazonal bloqueado',
      rewardBadgeLabel: data['rewardBadgeLabel'] as String? ?? 'SEM EMBLEMA',
      rewardTitleLabel:
          data['rewardTitleLabel'] as String? ?? 'Sem titulo sazonal',
      rewardBonusLabel:
          data['rewardBonusLabel'] as String? ?? 'Nenhum legado sazonal liberado.',
      scoreBandLabel: data['scoreBandLabel'] as String? ?? 'RECUPERACAO',
      seasonScore: (data['seasonScore'] as num?)?.toInt() ?? 0,
      playerStandingLabel:
          data['playerStandingLabel'] as String? ?? 'FORA DO CORTE',
      spotlightLabel: data['spotlightLabel'] as String? ?? '',
      cosmeticFrameLabel:
          data['cosmeticFrameLabel'] as String? ?? 'QUADRO DE FERRO',
      cosmeticAuraLabel:
          data['cosmeticAuraLabel'] as String? ?? 'AURA CONTIDA',
      claimedAt: _readTimestamp(data['claimedAt']),
      syncSchemaVersion: (data['syncSchemaVersion'] as num?)?.toInt() ?? 1,
      syncSource: (data['syncSource'] as String? ?? 'client')
          .trim()
          .toLowerCase(),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  static SeasonLegacyReward fromSeasonReward({
    required SeasonRewardSnapshot reward,
    required DateTime claimedAt,
    required int syncSchemaVersion,
    required String syncSource,
    DateTime? updatedAt,
  }) {
    final cosmetics = _visualRewardFor(
      rewardTierLabel: reward.rewardTierLabel,
      rankBracket: reward.currentRankBracket,
      scoreBandLabel: reward.scoreBandLabel,
    );

    return SeasonLegacyReward(
      seasonKey: reward.seasonKey,
      seasonLabel: reward.seasonLabel,
      claimedRankBracket: reward.currentRankBracket,
      rewardTierLabel: reward.rewardTierLabel,
      rewardName: reward.rewardName,
      rewardBadgeLabel: reward.rewardBadgeLabel,
      rewardTitleLabel: reward.rewardTitleLabel,
      rewardBonusLabel: reward.rewardBonusLabel,
      scoreBandLabel: reward.scoreBandLabel,
      seasonScore: reward.seasonScore,
      playerStandingLabel: reward.playerStandingLabel,
      spotlightLabel: reward.spotlightLabel,
      cosmeticFrameLabel: cosmetics.frameLabel,
      cosmeticAuraLabel: cosmetics.auraLabel,
      claimedAt: claimedAt,
      syncSchemaVersion: syncSchemaVersion,
      syncSource: syncSource,
      updatedAt: updatedAt ?? claimedAt,
    );
  }
}

class _VisualReward {
  const _VisualReward({
    required this.frameLabel,
    required this.auraLabel,
  });

  final String frameLabel;
  final String auraLabel;
}

_VisualReward _visualRewardFor({
  required String rewardTierLabel,
  required String rankBracket,
  required String scoreBandLabel,
}) {
  final tier = rewardTierLabel.toUpperCase();
  final band = scoreBandLabel.toUpperCase();

  if (band == 'LIDERANCA' || rankBracket == 'S') {
    return const _VisualReward(
      frameLabel: 'QUADRO SOBERANO',
      auraLabel: 'AURA DO COMANDANTE',
    );
  }
  if (band == 'ELITE' || rankBracket == 'A') {
    return const _VisualReward(
      frameLabel: 'QUADRO VANGUARDA',
      auraLabel: 'AURA AZUL ASCENDENTE',
    );
  }
  if (tier.contains('MANUTENCAO') || rankBracket == 'B' || rankBracket == 'C') {
    return const _VisualReward(
      frameLabel: 'QUADRO DE BRONZE',
      auraLabel: 'AURA DE DISCIPLINA',
    );
  }
  return const _VisualReward(
    frameLabel: 'QUADRO DE FERRO',
    auraLabel: 'AURA CONTIDA',
  );
}

DateTime _readTimestamp(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.now();
}
