import 'package:ascend/features/profile/domain/season_legacy_reward.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeasonProfileSnapshot {
  const SeasonProfileSnapshot({
    required this.activeSeasonKey,
    required this.activeSeasonLabel,
    required this.activeRewardName,
    required this.activeBadgeLabel,
    required this.activeTitleLabel,
    required this.cosmeticFrameLabel,
    required this.cosmeticAuraLabel,
    required this.equippedAt,
    required this.syncSchemaVersion,
    required this.syncSource,
    required this.updatedAt,
  });

  final String activeSeasonKey;
  final String activeSeasonLabel;
  final String activeRewardName;
  final String activeBadgeLabel;
  final String activeTitleLabel;
  final String cosmeticFrameLabel;
  final String cosmeticAuraLabel;
  final DateTime equippedAt;
  final int syncSchemaVersion;
  final String syncSource;
  final DateTime updatedAt;

  String get homeTitle => '$activeTitleLabel | $activeBadgeLabel';

  Map<String, dynamic> toFirestore() {
    return {
      'activeSeasonKey': activeSeasonKey,
      'activeSeasonLabel': activeSeasonLabel,
      'activeRewardName': activeRewardName,
      'activeBadgeLabel': activeBadgeLabel,
      'activeTitleLabel': activeTitleLabel,
      'cosmeticFrameLabel': cosmeticFrameLabel,
      'cosmeticAuraLabel': cosmeticAuraLabel,
      'equippedAt': Timestamp.fromDate(equippedAt),
      'syncSchemaVersion': syncSchemaVersion,
      'syncSource': syncSource,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SeasonProfileSnapshot.fromFirestore(Map<String, dynamic> data) {
    return SeasonProfileSnapshot(
      activeSeasonKey: data['activeSeasonKey'] as String? ?? '',
      activeSeasonLabel: data['activeSeasonLabel'] as String? ?? '',
      activeRewardName:
          data['activeRewardName'] as String? ?? 'Sem legado equipado',
      activeBadgeLabel: data['activeBadgeLabel'] as String? ?? 'SEM EMBLEMA',
      activeTitleLabel:
          data['activeTitleLabel'] as String? ?? 'Sem titulo sazonal',
      cosmeticFrameLabel:
          data['cosmeticFrameLabel'] as String? ?? 'QUADRO DE FERRO',
      cosmeticAuraLabel:
          data['cosmeticAuraLabel'] as String? ?? 'AURA CONTIDA',
      equippedAt: _readTimestamp(data['equippedAt']),
      syncSchemaVersion: (data['syncSchemaVersion'] as num?)?.toInt() ?? 1,
      syncSource: (data['syncSource'] as String? ?? 'client')
          .trim()
          .toLowerCase(),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  static SeasonProfileSnapshot fromLegacyReward({
    required SeasonLegacyReward legacyReward,
    required int syncSchemaVersion,
    required String syncSource,
    DateTime? updatedAt,
  }) {
    return SeasonProfileSnapshot(
      activeSeasonKey: legacyReward.seasonKey,
      activeSeasonLabel: legacyReward.seasonLabel,
      activeRewardName: legacyReward.rewardName,
      activeBadgeLabel: legacyReward.rewardBadgeLabel,
      activeTitleLabel: legacyReward.rewardTitleLabel,
      cosmeticFrameLabel: legacyReward.cosmeticFrameLabel,
      cosmeticAuraLabel: legacyReward.cosmeticAuraLabel,
      equippedAt: legacyReward.claimedAt,
      syncSchemaVersion: syncSchemaVersion,
      syncSource: syncSource,
      updatedAt: updatedAt ?? legacyReward.claimedAt,
    );
  }
}

DateTime _readTimestamp(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.now();
}
