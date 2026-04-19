import 'package:ascend/features/profile/domain/rank_season.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SeasonRewardClaimStatus { locked, readyToClaim, claimed }

class SeasonRewardSnapshot {
  const SeasonRewardSnapshot({
    required this.seasonKey,
    required this.seasonLabel,
    required this.currentRankBracket,
    required this.rewardTierLabel,
    required this.rewardStatusLabel,
    required this.rewardUnlocked,
    required this.rewardName,
    required this.rewardBadgeLabel,
    required this.rewardTitleLabel,
    required this.rewardBonusLabel,
    required this.recordedWeeks,
    required this.secureWeeks,
    required this.seasonScore,
    required this.scoreBandLabel,
    required this.clearRateLabel,
    required this.playerStandingLabel,
    required this.spotlightLabel,
    required this.resetLabel,
    required this.claimStatus,
    required this.syncSchemaVersion,
    required this.syncSource,
    required this.updatedAt,
    this.claimedAt,
  });

  final String seasonKey;
  final String seasonLabel;
  final String currentRankBracket;
  final String rewardTierLabel;
  final String rewardStatusLabel;
  final bool rewardUnlocked;
  final String rewardName;
  final String rewardBadgeLabel;
  final String rewardTitleLabel;
  final String rewardBonusLabel;
  final int recordedWeeks;
  final int secureWeeks;
  final int seasonScore;
  final String scoreBandLabel;
  final String clearRateLabel;
  final String playerStandingLabel;
  final String spotlightLabel;
  final String resetLabel;
  final SeasonRewardClaimStatus claimStatus;
  final int syncSchemaVersion;
  final String syncSource;
  final DateTime updatedAt;
  final DateTime? claimedAt;

  bool get canClaim =>
      claimStatus == SeasonRewardClaimStatus.readyToClaim && rewardUnlocked;

  Map<String, dynamic> toFirestore() {
    return {
      'seasonKey': seasonKey,
      'seasonLabel': seasonLabel,
      'currentRankBracket': currentRankBracket,
      'rewardTierLabel': rewardTierLabel,
      'rewardStatusLabel': rewardStatusLabel,
      'rewardUnlocked': rewardUnlocked,
      'rewardName': rewardName,
      'rewardBadgeLabel': rewardBadgeLabel,
      'rewardTitleLabel': rewardTitleLabel,
      'rewardBonusLabel': rewardBonusLabel,
      'recordedWeeks': recordedWeeks,
      'secureWeeks': secureWeeks,
      'seasonScore': seasonScore,
      'scoreBandLabel': scoreBandLabel,
      'clearRateLabel': clearRateLabel,
      'playerStandingLabel': playerStandingLabel,
      'spotlightLabel': spotlightLabel,
      'resetLabel': resetLabel,
      'claimStatus': claimStatus.name,
      'syncSchemaVersion': syncSchemaVersion,
      'syncSource': syncSource,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'claimedAt': claimedAt == null ? null : Timestamp.fromDate(claimedAt!),
    };
  }

  factory SeasonRewardSnapshot.fromFirestore(Map<String, dynamic> data) {
    return SeasonRewardSnapshot(
      seasonKey: data['seasonKey'] as String? ?? '',
      seasonLabel: data['seasonLabel'] as String? ?? '',
      currentRankBracket: (data['currentRankBracket'] as String? ?? 'E')
          .trim()
          .toUpperCase(),
      rewardTierLabel: data['rewardTierLabel'] as String? ?? 'EM FORMACAO',
      rewardStatusLabel: data['rewardStatusLabel'] as String? ?? 'BLOQUEADA',
      rewardUnlocked: data['rewardUnlocked'] as bool? ?? false,
      rewardName: data['rewardName'] as String? ?? 'Trilha sazonal bloqueada',
      rewardBadgeLabel: data['rewardBadgeLabel'] as String? ?? 'SEM EMBLEMA',
      rewardTitleLabel:
          data['rewardTitleLabel'] as String? ?? 'Sem titulo sazonal',
      rewardBonusLabel:
          data['rewardBonusLabel'] as String? ?? 'Nenhum pacote sazonal liberado.',
      recordedWeeks: (data['recordedWeeks'] as num?)?.toInt() ?? 0,
      secureWeeks: (data['secureWeeks'] as num?)?.toInt() ?? 0,
      seasonScore: (data['seasonScore'] as num?)?.toInt() ?? 0,
      scoreBandLabel: data['scoreBandLabel'] as String? ?? 'RECUPERACAO',
      clearRateLabel:
          data['clearRateLabel'] as String? ?? 'Clear rate aguardando lobby',
      playerStandingLabel:
          data['playerStandingLabel'] as String? ?? 'FORA DO CORTE',
      spotlightLabel: data['spotlightLabel'] as String? ?? '',
      resetLabel: data['resetLabel'] as String? ?? '',
      claimStatus: SeasonRewardClaimStatus.values.firstWhere(
        (value) => value.name == data['claimStatus'],
        orElse: () => SeasonRewardClaimStatus.locked,
      ),
      syncSchemaVersion: (data['syncSchemaVersion'] as num?)?.toInt() ?? 1,
      syncSource: (data['syncSource'] as String? ?? 'client')
          .trim()
          .toLowerCase(),
      updatedAt: _readTimestamp(data['updatedAt']),
      claimedAt: data['claimedAt'] == null
          ? null
          : _readTimestamp(data['claimedAt']),
    );
  }

  static SeasonRewardSnapshot fromSeasonSummary({
    required RankSeasonSummary season,
    required String currentRankBracket,
    required int seasonScore,
    required String scoreBandLabel,
    required String clearRateLabel,
    required String playerStandingLabel,
    required String spotlightLabel,
    required int syncSchemaVersion,
    required String syncSource,
    SeasonRewardClaimStatus? claimStatus,
    DateTime? claimedAt,
    DateTime? updatedAt,
  }) {
    return SeasonRewardSnapshot(
      seasonKey: season.seasonKey,
      seasonLabel: season.seasonLabel,
      currentRankBracket: currentRankBracket,
      rewardTierLabel: season.rewardTierLabel,
      rewardStatusLabel: season.rewardStatusLabel,
      rewardUnlocked: season.rewardUnlocked,
      rewardName: season.rewardName,
      rewardBadgeLabel: season.rewardBadgeLabel,
      rewardTitleLabel: season.rewardTitleLabel,
      rewardBonusLabel: season.rewardBonusLabel,
      recordedWeeks: season.recordedWeeks,
      secureWeeks: season.secureWeeks,
      seasonScore: seasonScore,
      scoreBandLabel: scoreBandLabel,
      clearRateLabel: clearRateLabel,
      playerStandingLabel: playerStandingLabel,
      spotlightLabel: spotlightLabel,
      resetLabel: season.resetLabel,
      claimStatus:
          claimStatus ??
          (season.rewardUnlocked
              ? SeasonRewardClaimStatus.readyToClaim
              : SeasonRewardClaimStatus.locked),
      syncSchemaVersion: syncSchemaVersion,
      syncSource: syncSource,
      updatedAt: updatedAt ?? DateTime.now(),
      claimedAt: claimedAt,
    );
  }

  SeasonRewardSnapshot copyWith({
    String? rewardStatusLabel,
    bool? rewardUnlocked,
    String? rewardName,
    String? rewardBadgeLabel,
    String? rewardTitleLabel,
    String? rewardBonusLabel,
    String? playerStandingLabel,
    String? spotlightLabel,
    SeasonRewardClaimStatus? claimStatus,
    int? syncSchemaVersion,
    String? syncSource,
    DateTime? updatedAt,
    DateTime? claimedAt,
  }) {
    return SeasonRewardSnapshot(
      seasonKey: seasonKey,
      seasonLabel: seasonLabel,
      currentRankBracket: currentRankBracket,
      rewardTierLabel: rewardTierLabel,
      rewardStatusLabel: rewardStatusLabel ?? this.rewardStatusLabel,
      rewardUnlocked: rewardUnlocked ?? this.rewardUnlocked,
      rewardName: rewardName ?? this.rewardName,
      rewardBadgeLabel: rewardBadgeLabel ?? this.rewardBadgeLabel,
      rewardTitleLabel: rewardTitleLabel ?? this.rewardTitleLabel,
      rewardBonusLabel: rewardBonusLabel ?? this.rewardBonusLabel,
      recordedWeeks: recordedWeeks,
      secureWeeks: secureWeeks,
      seasonScore: seasonScore,
      scoreBandLabel: scoreBandLabel,
      clearRateLabel: clearRateLabel,
      playerStandingLabel: playerStandingLabel ?? this.playerStandingLabel,
      spotlightLabel: spotlightLabel ?? this.spotlightLabel,
      resetLabel: resetLabel,
      claimStatus: claimStatus ?? this.claimStatus,
      syncSchemaVersion: syncSchemaVersion ?? this.syncSchemaVersion,
      syncSource: syncSource ?? this.syncSource,
      updatedAt: updatedAt ?? this.updatedAt,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }
}

DateTime _readTimestamp(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.now();
}
