import 'package:ascend/features/profile/domain/first_week_journey.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/progress_payoff.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/season_reward_snapshot.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildFirstWeekJourney activates guided loop for a new onboarded player', () {
    final player = Player(
      name: 'Tester',
      level: 2,
      xp: 24,
      maxXp: 100,
      attributes: PlayerAttributes(),
      lastResetDate: DateTime(2026, 4, 20),
      hasCompletedOnboarding: true,
    );
    final quests = [
      Quest(
        id: 'personal-1',
        title: 'Arrumar a cama',
        rewardAttribute: AttributeType.vitality,
        xpReward: 12,
        isCompleted: true,
      ),
      Quest(
        id: 'comp-1',
        title: 'Sessao de foco de 25 minutos',
        rewardAttribute: AttributeType.agility,
        xpReward: 30,
        category: QuestCategory.competitive,
        verificationMode: QuestVerificationMode.timer,
        verificationStatus: QuestVerificationStatus.verified,
        isCompleted: true,
      ),
    ];

    final summary = buildFirstWeekJourney(
      player: player,
      quests: quests,
      now: DateTime(2026, 4, 20),
    );

    expect(summary.isActive, isTrue);
    expect(summary.progressLabel, '2/3 passos');
    expect(summary.nextAction, contains('3 dias ativos'));
  });

  test('buildProgressPayoff highlights next level, rank and seasonal reward', () {
    final player = Player(
      name: 'Tester',
      level: 4,
      xp: 90,
      maxXp: 100,
      attributes: PlayerAttributes(),
      lastResetDate: DateTime(2026, 4, 20),
      hasCompletedOnboarding: true,
    );
    final snapshot = CompetitiveRankSnapshot(
      currentRank: 'E',
      weekKey: '2026W0420',
      activeDays: 2,
      requiredActiveDays: 3,
      requiresBossClear: false,
      bossCompleted: false,
      status: RankMaintenanceStatus.warning,
      demotionStrikes: 0,
      promotionReady: false,
      promotionTargetRank: 'D',
      targetRequiredLevel: 5,
      targetLevelGateMet: false,
      eventType: CompetitiveRankEventType.warning,
      summary: 'Rank E em alerta.',
      detail: 'Falta ritmo.',
      syncSchemaVersion: 3,
      syncSource: 'client',
      updatedAt: DateTime(2026, 4, 20),
    );
    final seasonReward = SeasonRewardSnapshot(
      seasonKey: '2026-04',
      seasonLabel: 'ABR 2026',
      currentRankBracket: 'E',
      rewardTierLabel: 'EM FORMACAO',
      rewardStatusLabel: 'EM ROTA',
      rewardUnlocked: false,
      rewardName: 'Pacote inicial',
      rewardBadgeLabel: 'SEM EMBLEMA',
      rewardTitleLabel: 'Sem titulo sazonal',
      rewardBonusLabel: 'Continue firme.',
      recordedWeeks: 1,
      secureWeeks: 0,
      seasonScore: 2,
      scoreBandLabel: 'RECUPERACAO',
      clearRateLabel: '0%',
      playerStandingLabel: 'FORA DO CORTE',
      spotlightLabel: 'Primeira temporada em andamento.',
      resetLabel: 'Reset em 3 semanas',
      claimStatus: SeasonRewardClaimStatus.locked,
      syncSchemaVersion: 3,
      syncSource: 'client',
      updatedAt: DateTime(2026, 4, 20),
    );

    final summary = buildProgressPayoff(
      player: player,
      snapshot: snapshot,
      seasonReward: seasonReward,
    );

    expect(summary.levelLabel, contains('10 XP'));
    expect(summary.rankLabel, contains('Level 5'));
    expect(summary.seasonLabel, contains('Pacote inicial'));
  });
}
