import 'package:ascend/features/profile/domain/season_reward_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeasonRewardSnapshot', () {
    test('serializes and restores firestore payload', () {
      final snapshot = SeasonRewardSnapshot(
        seasonKey: '2026-04',
        seasonLabel: 'ABR 2026',
        currentRankBracket: 'C',
        rewardTierLabel: 'MANUTENCAO',
        rewardStatusLabel: 'EM ROTA',
        rewardUnlocked: true,
        rewardName: 'Pacote de Manutencao',
        rewardBadgeLabel: 'SIGILO DE BRONZE',
        rewardTitleLabel: 'VIGIA DO CICLO',
        rewardBonusLabel: 'Insignia sazonal e selo de consistencia.',
        recordedWeeks: 2,
        secureWeeks: 2,
        seasonScore: 10,
        scoreBandLabel: 'ELITE',
        clearRateLabel: '30% do rank concluiu',
        playerStandingLabel: 'LIDER DO RANK',
        spotlightLabel: 'Seu clear esta no podio da arena atual.',
        resetLabel: 'Reset em 2 semanas',
        claimStatus: SeasonRewardClaimStatus.readyToClaim,
        syncSchemaVersion: 2,
        syncSource: 'client',
        updatedAt: DateTime(2026, 4, 18),
      );

      final restored = SeasonRewardSnapshot.fromFirestore(snapshot.toFirestore());

      expect(restored.seasonKey, '2026-04');
      expect(restored.rewardUnlocked, isTrue);
      expect(restored.rewardBadgeLabel, 'SIGILO DE BRONZE');
      expect(restored.scoreBandLabel, 'ELITE');
      expect(restored.claimStatus, SeasonRewardClaimStatus.readyToClaim);
      expect(restored.syncSchemaVersion, 2);
    });
  });
}
