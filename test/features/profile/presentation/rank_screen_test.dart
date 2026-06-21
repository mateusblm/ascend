import 'package:ascend/features/profile/domain/competitive_integrity.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/promotion_exam.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/rank_season_leaderboard.dart';
import 'package:ascend/features/profile/domain/season_legacy_reward.dart';
import 'package:ascend/features/profile/domain/season_profile_snapshot.dart';
import 'package:ascend/features/profile/domain/season_reward_snapshot.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/profile/presentation/rank_progression_provider.dart';
import 'package:ascend/features/profile/presentation/rank_screen.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  testWidgets('RankScreen switches between now, season and legacy surfaces', (
    tester,
  ) async {
    final player = _buildPlayer();
    final history = [
      _snapshot(
        weekKey: '2026W0407',
        currentRank: 'D',
        activeDays: 4,
        requiredActiveDays: 4,
        status: RankMaintenanceStatus.secure,
        eventType: CompetitiveRankEventType.routine,
        updatedAt: DateTime(2026, 4, 7),
      ),
      _snapshot(
        weekKey: '2026W0414',
        currentRank: 'C',
        activeDays: 5,
        requiredActiveDays: 4,
        status: RankMaintenanceStatus.promotionReady,
        eventType: CompetitiveRankEventType.promotionUnlocked,
        updatedAt: DateTime(2026, 4, 14),
      ),
    ];
    final snapshot = history.last;
    final exam = PromotionExam(
      sourceRank: 'C',
      targetRank: 'B',
      sourceWeekKey: '2026W0414',
      status: PromotionExamStatus.inProgress,
      baselineActiveDays: 5,
      requiredExtraActiveDays: 1,
      bossRequired: false,
      startedAt: DateTime(2026, 4, 18, 10),
      expiresAt: DateTime(2026, 4, 21, 10),
      syncSchemaVersion: 2,
      syncSource: 'client',
    );
    final boss = RemoteWeeklyBoss(
      id: 'boss-c',
      rank: 'C',
      title: 'Primeira Ruptura',
      description: 'Evento de teste.',
      targetActiveDays: 5,
      rewardXp: 120,
      rewardStatPoints: 2,
      participantCount: 8,
      completedCount: 3,
      startsAt: DateTime(2026, 4, 14),
      endsAt: DateTime(2026, 4, 21),
      isActive: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerProvider.overrideWith((ref) => _TestPlayerNotifier(player)),
          rankProgressionSnapshotProvider.overrideWith(
            (ref) => Stream.value(snapshot),
          ),
          rankProgressionHistoryProvider.overrideWith(
            (ref) => Stream.value(history),
          ),
          promotionExamProvider.overrideWith((ref) => Stream.value(exam)),
          currentSeasonRewardProvider.overrideWith(
            (ref) => Stream.value(
              SeasonRewardSnapshot(
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
              ),
            ),
          ),
          seasonProfileProvider.overrideWith(
            (ref) => Stream.value(
              SeasonProfileSnapshot(
                activeSeasonKey: '2026-04',
                activeSeasonLabel: 'ABR 2026',
                activeRewardName: 'Pacote de Manutencao',
                activeBadgeLabel: 'SIGILO DE BRONZE',
                activeTitleLabel: 'VIGIA DO CICLO',
                cosmeticFrameLabel: 'QUADRO DE BRONZE',
                cosmeticAuraLabel: 'AURA DE DISCIPLINA',
                equippedAt: DateTime(2026, 4, 18),
                syncSchemaVersion: 2,
                syncSource: 'client',
                updatedAt: DateTime(2026, 4, 18),
              ),
            ),
          ),
          seasonLegacyHistoryProvider.overrideWith(
            (ref) => Stream.value([
              SeasonLegacyReward(
                seasonKey: '2026-04',
                seasonLabel: 'ABR 2026',
                claimedRankBracket: 'C',
                rewardTierLabel: 'MANUTENCAO',
                rewardName: 'Pacote de Manutencao',
                rewardBadgeLabel: 'SIGILO DE BRONZE',
                rewardTitleLabel: 'VIGIA DO CICLO',
                rewardBonusLabel: 'Insignia sazonal e selo de consistencia.',
                seasonScore: 10,
                scoreBandLabel: 'ELITE',
                playerStandingLabel: 'LIDER DO RANK',
                spotlightLabel: 'Seu clear esta no podio da arena atual.',
                cosmeticFrameLabel: 'QUADRO DE BRONZE',
                cosmeticAuraLabel: 'AURA DE DISCIPLINA',
                claimedAt: DateTime(2026, 4, 18),
                syncSchemaVersion: 2,
                syncSource: 'client',
                updatedAt: DateTime(2026, 4, 18),
              ),
            ]),
          ),
          currentCompetitiveIntegrityProvider.overrideWith(
            (ref) => Stream.value(
              CompetitiveIntegritySnapshot(
                weekKey: '2026W0414',
                trustScore: 82,
                trustBand: CompetitiveTrustBand.stable,
                weeklyActiveDays: 5,
                weeklyCompetitiveDays: 5,
                personalQuestCompletionsToday: 1,
                competitiveQuestCompletionsToday: 1,
                personalXpToday: 12,
                competitiveXpToday: 35,
                suspiciousPatternCount: 0,
                summary: 'Conta estavel',
                detail: 'Seu ritmo recente segue confiavel.',
                syncSchemaVersion: 1,
                syncSource: 'client',
                updatedAt: DateTime(2026, 4, 18),
              ),
            ),
          ),
          seasonBracketLeaderboardProvider.overrideWith(
            (ref) async => const <RankSeasonLeaderboardEntry>[
              RankSeasonLeaderboardEntry(
                position: 1,
                displayName: 'VOCE',
                detail: 'LIDER | 10 pts',
                isPlayer: true,
              ),
            ],
          ),
          remoteWeeklyBossProvider.overrideWith((ref) => Stream.value(boss)),
          weeklyBossTopCompletionsProvider.overrideWith(
            (ref) => Stream.value(const <WeeklyBossCompletion>[]),
          ),
        ],
        child: const MaterialApp(home: RankScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('rank-entry-now')), findsOneWidget);
    expect(find.byKey(const ValueKey('rank-entry-season')), findsOneWidget);
    expect(find.byKey(const ValueKey('rank-entry-legacy')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('rank-entry-now')));
    await tester.tap(find.byKey(const ValueKey('rank-entry-now')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('rank-now')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('rank-entry-season')));
    await tester.tap(find.byKey(const ValueKey('rank-entry-season')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('rank-season')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('rank-entry-legacy')));
    await tester.tap(find.byKey(const ValueKey('rank-entry-legacy')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('rank-legacy')), findsOneWidget);
  });

  testWidgets('RankScreen keeps now detail accessible without active boss', (
    tester,
  ) async {
    final player = _buildPlayer(level: 2);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerProvider.overrideWith((ref) => _TestPlayerNotifier(player)),
          rankProgressionSnapshotProvider.overrideWith(
            (ref) => Stream.value(null),
          ),
          rankProgressionHistoryProvider.overrideWith(
            (ref) => Stream.value(const <CompetitiveRankSnapshot>[]),
          ),
          promotionExamProvider.overrideWith((ref) => Stream.value(null)),
          currentSeasonRewardProvider.overrideWith((ref) => Stream.value(null)),
          seasonProfileProvider.overrideWith((ref) => Stream.value(null)),
          seasonLegacyHistoryProvider.overrideWith(
            (ref) => Stream.value(const <SeasonLegacyReward>[]),
          ),
          currentCompetitiveIntegrityProvider.overrideWith(
            (ref) => Stream.value(null),
          ),
          seasonBracketLeaderboardProvider.overrideWith(
            (ref) async => const <RankSeasonLeaderboardEntry>[],
          ),
          remoteWeeklyBossProvider.overrideWith((ref) => Stream.value(null)),
          weeklyBossTopCompletionsProvider.overrideWith(
            (ref) => Stream.value(const <WeeklyBossCompletion>[]),
          ),
        ],
        child: const MaterialApp(home: RankScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('rank-entry-now')));
    await tester.tap(find.byKey(const ValueKey('rank-entry-now')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('rank-now')), findsOneWidget);
    expect(find.byKey(const ValueKey('rank-start-exam-action')), findsNothing);
    expect(find.byKey(const ValueKey('rank-promote-action')), findsNothing);
  });

  testWidgets('RankScreen exposes exam start action when promotion is ready', (
    tester,
  ) async {
    final player = _buildPlayer();
    final snapshot = _snapshot(
      weekKey: '2026W0414',
      currentRank: 'C',
      activeDays: 5,
      requiredActiveDays: 4,
      status: RankMaintenanceStatus.promotionReady,
      eventType: CompetitiveRankEventType.promotionUnlocked,
      updatedAt: DateTime(2026, 4, 14),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerProvider.overrideWith((ref) => _TestPlayerNotifier(player)),
          rankProgressionSnapshotProvider.overrideWith(
            (ref) => Stream.value(snapshot),
          ),
          rankProgressionHistoryProvider.overrideWith(
            (ref) => Stream.value([snapshot]),
          ),
          promotionExamProvider.overrideWith((ref) => Stream.value(null)),
          currentSeasonRewardProvider.overrideWith((ref) => Stream.value(null)),
          seasonProfileProvider.overrideWith((ref) => Stream.value(null)),
          seasonLegacyHistoryProvider.overrideWith(
            (ref) => Stream.value(const <SeasonLegacyReward>[]),
          ),
          currentCompetitiveIntegrityProvider.overrideWith(
            (ref) => Stream.value(null),
          ),
          seasonBracketLeaderboardProvider.overrideWith(
            (ref) async => const <RankSeasonLeaderboardEntry>[],
          ),
          remoteWeeklyBossProvider.overrideWith((ref) => Stream.value(null)),
          weeklyBossTopCompletionsProvider.overrideWith(
            (ref) => Stream.value(const <WeeklyBossCompletion>[]),
          ),
        ],
        child: const MaterialApp(home: RankScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('rank-entry-now')));
    await tester.tap(find.byKey(const ValueKey('rank-entry-now')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('rank-start-exam-action')),
      findsOneWidget,
    );
  });

  testWidgets('RankScreen exposes promotion action after exam is passed', (
    tester,
  ) async {
    final player = _buildPlayer();
    final snapshot = _snapshot(
      weekKey: '2026W0414',
      currentRank: 'C',
      activeDays: 6,
      requiredActiveDays: 4,
      status: RankMaintenanceStatus.promotionReady,
      eventType: CompetitiveRankEventType.promotionUnlocked,
      updatedAt: DateTime(2026, 4, 14),
    );
    final exam = PromotionExam(
      sourceRank: 'C',
      targetRank: 'B',
      sourceWeekKey: '2026W0414',
      status: PromotionExamStatus.passed,
      baselineActiveDays: 5,
      requiredExtraActiveDays: 1,
      bossRequired: false,
      startedAt: DateTime(2026, 4, 18, 10),
      expiresAt: DateTime(2026, 4, 21, 10),
      syncSchemaVersion: 2,
      syncSource: 'client',
      resolvedAt: DateTime(2026, 4, 19, 9),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerProvider.overrideWith((ref) => _TestPlayerNotifier(player)),
          rankProgressionSnapshotProvider.overrideWith(
            (ref) => Stream.value(snapshot),
          ),
          rankProgressionHistoryProvider.overrideWith(
            (ref) => Stream.value([snapshot]),
          ),
          promotionExamProvider.overrideWith((ref) => Stream.value(exam)),
          currentSeasonRewardProvider.overrideWith((ref) => Stream.value(null)),
          seasonProfileProvider.overrideWith((ref) => Stream.value(null)),
          seasonLegacyHistoryProvider.overrideWith(
            (ref) => Stream.value(const <SeasonLegacyReward>[]),
          ),
          currentCompetitiveIntegrityProvider.overrideWith(
            (ref) => Stream.value(null),
          ),
          seasonBracketLeaderboardProvider.overrideWith(
            (ref) async => const <RankSeasonLeaderboardEntry>[],
          ),
          remoteWeeklyBossProvider.overrideWith((ref) => Stream.value(null)),
          weeklyBossTopCompletionsProvider.overrideWith(
            (ref) => Stream.value(const <WeeklyBossCompletion>[]),
          ),
        ],
        child: const MaterialApp(home: RankScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('rank-entry-now')));
    await tester.tap(find.byKey(const ValueKey('rank-entry-now')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('rank-promote-action')), findsOneWidget);
  });
}

class _TestPlayerNotifier extends PlayerNotifier {
  _TestPlayerNotifier(Player state) : super(_FakeIsar(), state);
}

class _FakeIsar implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Player _buildPlayer({int level = 6}) {
  return Player(
    name: 'TESTER',
    level: level,
    xp: 40,
    maxXp: 100,
    statPoints: 3,
    attributes: PlayerAttributes(),
    lastResetDate: DateTime(2026, 4, 18),
    activityHistory: [
      DateTime(2026, 4, 14),
      DateTime(2026, 4, 15),
      DateTime(2026, 4, 16),
      DateTime(2026, 4, 17),
      DateTime(2026, 4, 18),
    ],
    competitiveActivityHistory: [
      DateTime(2026, 4, 14),
      DateTime(2026, 4, 15),
      DateTime(2026, 4, 16),
      DateTime(2026, 4, 17),
      DateTime(2026, 4, 18),
    ],
    lastQuestCompletionDate: DateTime(2026, 4, 18),
    lastCompetitiveQuestCompletionDate: DateTime(2026, 4, 18),
    hasCompletedOnboarding: true,
  );
}

CompetitiveRankSnapshot _snapshot({
  required String weekKey,
  required String currentRank,
  required int activeDays,
  required int requiredActiveDays,
  required RankMaintenanceStatus status,
  required CompetitiveRankEventType eventType,
  required DateTime updatedAt,
}) {
  return CompetitiveRankSnapshot(
    currentRank: currentRank,
    weekKey: weekKey,
    activeDays: activeDays,
    requiredActiveDays: requiredActiveDays,
    requiresBossClear: false,
    bossCompleted: true,
    status: status,
    demotionStrikes: 0,
    promotionReady: status == RankMaintenanceStatus.promotionReady,
    promotionTargetRank: rankAfter(currentRank),
    eventType: eventType,
    summary: 'summary',
    detail: 'detail',
    syncSchemaVersion: 2,
    syncSource: 'client',
    updatedAt: updatedAt,
  );
}
