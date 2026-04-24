import 'package:ascend/features/profile/domain/first_week_journey.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/progress_payoff.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/season_reward_snapshot.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'buildFirstWeekJourney activates guided loop for a new onboarded player',
    () {
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
      expect(summary.progress, closeTo(2 / 3, 0.001));
      expect(summary.steps.where((step) => step.isDone), hasLength(2));
      expect(summary.steps.last.isDone, isFalse);
    },
  );

  test(
    'buildFirstWeekJourney points to a personal quest first when no step is complete',
    () {
      final player = Player(
        name: 'Tester',
        level: 2,
        xp: 0,
        maxXp: 100,
        attributes: PlayerAttributes(),
        lastResetDate: DateTime(2026, 4, 20),
        hasCompletedOnboarding: true,
      );

      final summary = buildFirstWeekJourney(
        player: player,
        quests: const [],
        now: DateTime(2026, 4, 20),
      );

      expect(summary.isActive, isTrue);
      expect(summary.progress, 0);
      expect(summary.steps.where((step) => step.isDone), isEmpty);
      expect(summary.nextAction, isNotEmpty);
      expect(summary.steps.first.isDone, isFalse);
    },
  );

  test(
    'buildFirstWeekJourney shifts to competitive guidance after the first personal completion',
    () {
      final player = Player(
        name: 'Tester',
        level: 2,
        xp: 12,
        maxXp: 100,
        attributes: PlayerAttributes(),
        lastResetDate: DateTime(2026, 4, 20),
        hasCompletedOnboarding: true,
        activityHistory: [DateTime(2026, 4, 20)],
        lastQuestCompletionDate: DateTime(2026, 4, 20, 8),
      );
      final quests = [
        Quest(
          id: 'personal-1',
          title: 'Arrumar a cama',
          rewardAttribute: AttributeType.vitality,
          xpReward: 12,
          isCompleted: true,
        ),
      ];

      final summary = buildFirstWeekJourney(
        player: player,
        quests: quests,
        now: DateTime(2026, 4, 20),
      );

      expect(summary.progress, closeTo(1 / 3, 0.001));
      expect(summary.steps.where((step) => step.isDone), hasLength(1));
      expect(summary.nextAction, isNotEmpty);
      expect(summary.steps[0].isDone, isTrue);
      expect(summary.steps[1].isDone, isFalse);
    },
  );

  test(
    'buildFirstWeekJourney deactivates once the player is outside the early-rank window',
    () {
      final player = Player(
        name: 'Tester',
        level: 5,
        xp: 20,
        maxXp: 120,
        attributes: PlayerAttributes(),
        lastResetDate: DateTime(2026, 4, 20),
        hasCompletedOnboarding: true,
        activityHistory: [
          DateTime(2026, 4, 18),
          DateTime(2026, 4, 19),
          DateTime(2026, 4, 20),
        ],
      );

      final summary = buildFirstWeekJourney(
        player: player,
        quests: const [],
        snapshot: CompetitiveRankSnapshot(
          currentRank: 'D',
          weekKey: '2026W0420',
          activeDays: 3,
          requiredActiveDays: 3,
          requiresBossClear: false,
          bossCompleted: false,
          status: RankMaintenanceStatus.secure,
          demotionStrikes: 0,
          promotionReady: false,
          promotionTargetRank: 'C',
          eventType: CompetitiveRankEventType.routine,
          summary: 'Fora da janela inicial.',
          detail: 'Rank acima de E.',
          syncSchemaVersion: 3,
          syncSource: 'client',
          updatedAt: DateTime(2026, 4, 20),
        ),
        now: DateTime(2026, 4, 20),
      );

      expect(summary.isActive, isFalse);
    },
  );

  test(
    'buildProgressPayoff highlights next level, rank and seasonal reward',
    () {
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
    },
  );

  test(
    'buildReturnMotivation exposes tomorrow, weekly pressure and payoff',
    () {
      final player = Player(
        name: 'Tester',
        level: 4,
        xp: 90,
        maxXp: 100,
        attributes: PlayerAttributes(),
        lastResetDate: DateTime(2026, 4, 20),
        lastQuestCompletionDate: DateTime(2026, 4, 21),
        activityHistory: [DateTime(2026, 4, 21)],
        currentStreak: 2,
        bestStreak: 4,
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
        eventType: CompetitiveRankEventType.warning,
        summary: 'Rank E em alerta.',
        detail: 'Falta ritmo.',
        syncSchemaVersion: 3,
        syncSource: 'client',
        updatedAt: DateTime(2026, 4, 21),
      );
      final payoff = buildProgressPayoff(player: player, snapshot: snapshot);

      final summary = buildReturnMotivation(
        player: player,
        progressPayoff: payoff,
        snapshot: snapshot,
        now: DateTime(2026, 4, 21),
      );

      expect(summary.isUrgent, isTrue);
      expect(summary.statusLabel, 'RETOMAR');
      expect(summary.tomorrowAction, contains('3 dias'));
      expect(summary.weeklyPressure, contains('Rank em aviso'));
      expect(summary.payoffReason, payoff.levelLabel);
    },
  );
}
