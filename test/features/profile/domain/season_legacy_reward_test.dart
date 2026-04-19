import 'package:ascend/features/profile/domain/season_legacy_reward.dart';
import 'package:ascend/features/profile/domain/season_profile_snapshot.dart';
import 'package:ascend/features/profile/domain/season_reward_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Season legacy rewards', () {
    test('builds permanent legacy and profile from claimed season reward', () {
      final reward = SeasonRewardSnapshot(
        seasonKey: '2026-04',
        seasonLabel: 'ABR 2026',
        currentRankBracket: 'C',
        rewardTierLabel: 'MANUTENCAO',
        rewardStatusLabel: 'GARANTIDA',
        rewardUnlocked: true,
        rewardName: 'Pacote de Manutencao',
        rewardBadgeLabel: 'SIGILO DE BRONZE',
        rewardTitleLabel: 'VIGIA DO CICLO',
        rewardBonusLabel: 'Insignia sazonal e selo de consistencia.',
        recordedWeeks: 4,
        secureWeeks: 3,
        seasonScore: 18,
        scoreBandLabel: 'ELITE',
        clearRateLabel: '42% do rank concluiu',
        playerStandingLabel: 'TOP 10%',
        spotlightLabel: 'Seu ritmo sustentou a temporada inteira.',
        resetLabel: 'Reset em 0 semanas',
        claimStatus: SeasonRewardClaimStatus.claimed,
        syncSchemaVersion: 2,
        syncSource: 'client',
        updatedAt: DateTime(2026, 4, 30),
        claimedAt: DateTime(2026, 4, 30),
      );

      final legacy = SeasonLegacyReward.fromSeasonReward(
        reward: reward,
        claimedAt: DateTime(2026, 4, 30),
        syncSchemaVersion: 2,
        syncSource: 'client',
      );
      final profile = SeasonProfileSnapshot.fromLegacyReward(
        legacyReward: legacy,
        syncSchemaVersion: 2,
        syncSource: 'client',
      );

      expect(legacy.rewardTitleLabel, 'VIGIA DO CICLO');
      expect(legacy.cosmeticAuraLabel, 'AURA AZUL ASCENDENTE');
      expect(profile.activeBadgeLabel, 'SIGILO DE BRONZE');
      expect(profile.activeTitleLabel, 'VIGIA DO CICLO');
      expect(profile.cosmeticFrameLabel, 'QUADRO VANGUARDA');
    });

    test('serializes and restores profile snapshot payload', () {
      final profile = SeasonProfileSnapshot(
        activeSeasonKey: '2026-04',
        activeSeasonLabel: 'ABR 2026',
        activeRewardName: 'Pacote de Manutencao',
        activeBadgeLabel: 'SIGILO DE BRONZE',
        activeTitleLabel: 'VIGIA DO CICLO',
        cosmeticFrameLabel: 'QUADRO DE BRONZE',
        cosmeticAuraLabel: 'AURA DE DISCIPLINA',
        equippedAt: DateTime(2026, 4, 30),
        syncSchemaVersion: 2,
        syncSource: 'client',
        updatedAt: DateTime(2026, 4, 30),
      );

      final restored = SeasonProfileSnapshot.fromFirestore(profile.toFirestore());
      expect(restored.activeSeasonKey, '2026-04');
      expect(restored.activeTitleLabel, 'VIGIA DO CICLO');
      expect(restored.cosmeticAuraLabel, 'AURA DE DISCIPLINA');
    });
  });
}
