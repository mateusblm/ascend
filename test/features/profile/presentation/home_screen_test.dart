import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/rank_season_leaderboard.dart';
import 'package:ascend/features/profile/domain/season_profile_snapshot.dart';
import 'package:ascend/features/profile/presentation/home_screen.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/profile/presentation/rank_progression_provider.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  testWidgets('HomeScreen renders active online boss and remote clears', (
    tester,
  ) async {
    final player = _buildPlayer();
    final snapshot = _buildSnapshot();
    final boss = RemoteWeeklyBoss(
      id: 'boss-e',
      rank: 'E',
      title: 'Primeira Ruptura',
      description:
          'Fique ativo em 4 dias da semana para provar que voce merece subir de rank.',
      targetActiveDays: 4,
      rewardXp: 120,
      rewardStatPoints: 2,
      participantCount: 8,
      completedCount: 3,
      startsAt: DateTime(2026, 4, 14),
      endsAt: DateTime(2026, 4, 21),
      isActive: true,
    );
    final topCompletions = [
      WeeklyBossCompletion(
        uid: 'uid-1',
        displayName: 'Mateus',
        photoUrl: '',
        rankAtCompletion: 'E',
        completedAt: DateTime(2026, 4, 18, 9, 30),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            (ref) => _FakeAuthController(
              AuthSuccess(uid: 'uid-1', displayName: 'Mateus', photoUrl: ''),
            ),
          ),
          playerProvider.overrideWith((ref) => _TestPlayerNotifier(player)),
          competitiveRankProvider.overrideWith((ref) => 'E'),
          rankProgressionSnapshotProvider.overrideWith(
            (ref) => Stream.value(snapshot),
          ),
          rankProgressionHistoryProvider.overrideWith(
            (ref) => Stream.value([snapshot]),
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
          seasonBracketLeaderboardProvider.overrideWith(
            (ref) async => const <RankSeasonLeaderboardEntry>[
              RankSeasonLeaderboardEntry(
                position: 1,
                displayName: 'VOCE',
                detail: 'LIDER | 10 pts',
                isPlayer: true,
              ),
              RankSeasonLeaderboardEntry(
                position: 2,
                displayName: 'HUNTER-ABCD',
                detail: 'CAIXA ALTA | 8 pts',
                isPlayer: false,
              ),
            ],
          ),
          remoteWeeklyBossProvider.overrideWith((ref) => Stream.value(boss)),
          weeklyBossTopCompletionsProvider.overrideWith(
            (ref) => Stream.value(topCompletions),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TESTER'), findsOneWidget);
    expect(find.text('VIGIA DO CICLO'), findsOneWidget);
    expect(find.text('ABR 2026'), findsOneWidget);
    expect(find.text('Momento atual'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Proximo ganho'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Proximo ganho'), findsOneWidget);
    expect(find.text('Disputa da Arena'), findsOneWidget);
    expect(find.text('Evento da Semana'), findsOneWidget);
    expect(find.text('Primeira Ruptura'), findsOneWidget);
  });

  testWidgets(
    'HomeScreen renders idle weekly boss state without active event',
    (tester) async {
      final player = _buildPlayer(level: 2);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              (ref) => _FakeAuthController(AuthInitial()),
            ),
            playerProvider.overrideWith((ref) => _TestPlayerNotifier(player)),
            competitiveRankProvider.overrideWith((ref) => 'E'),
            rankProgressionSnapshotProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
            rankProgressionHistoryProvider.overrideWith(
              (ref) => Stream.value(const <CompetitiveRankSnapshot>[]),
            ),
            seasonProfileProvider.overrideWith((ref) => Stream.value(null)),
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
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Proximo ganho'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Proximo ganho'), findsOneWidget);
      expect(find.text('Pulso competitivo'), findsOneWidget);
      expect(find.text('Nenhum boss remoto ativo agora.'), findsOneWidget);
    },
  );
}

class _TestPlayerNotifier extends PlayerNotifier {
  _TestPlayerNotifier(Player state) : super(_FakeIsar(), state);
}

class _FakeAuthController extends StateNotifier<AuthState>
    implements AuthController {
  _FakeAuthController(super.state);

  @override
  Future<void> handleActiveSessionConflict() async {}

  @override
  Future<void> refreshActiveSession() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

class _FakeIsar implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Player _buildPlayer({int level = 6}) {
  return Player(
    name: 'TESTER',
    level: level,
    xp: 60,
    maxXp: 120,
    statPoints: 2,
    attributes: PlayerAttributes(),
    lastResetDate: DateTime(2026, 4, 18),
    activityHistory: [
      DateTime(2026, 4, 14),
      DateTime(2026, 4, 15),
      DateTime(2026, 4, 16),
      DateTime(2026, 4, 17),
    ],
    competitiveActivityHistory: [
      DateTime(2026, 4, 14),
      DateTime(2026, 4, 15),
      DateTime(2026, 4, 16),
      DateTime(2026, 4, 17),
    ],
    lastQuestCompletionDate: DateTime(2026, 4, 17),
    lastCompetitiveQuestCompletionDate: DateTime(2026, 4, 17),
    currentStreak: 4,
    bestStreak: 4,
    hasCompletedOnboarding: true,
  );
}

CompetitiveRankSnapshot _buildSnapshot() {
  return CompetitiveRankSnapshot(
    currentRank: 'E',
    weekKey: '2026W0414',
    activeDays: 4,
    requiredActiveDays: 3,
    requiresBossClear: false,
    bossCompleted: true,
    status: RankMaintenanceStatus.secure,
    demotionStrikes: 0,
    promotionReady: false,
    promotionTargetRank: 'D',
    eventType: CompetitiveRankEventType.routine,
    summary: 'Seu rank esta estavel e pronto para sustentar mais pressao.',
    detail: 'Semana segura.',
    syncSchemaVersion: 2,
    syncSource: 'client',
    updatedAt: DateTime(2026, 4, 18),
  );
}
