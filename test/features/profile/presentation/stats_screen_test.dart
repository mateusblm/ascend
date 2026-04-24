import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/profile/presentation/rank_progression_provider.dart';
import 'package:ascend/features/profile/presentation/stats_screen.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  testWidgets(
    'StatsScreen keeps score ownership in weekly read instead of header',
    (tester) async {
      final player = _buildPlayer();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              (ref) => _FakeAuthController(AuthInitial()),
            ),
            playerProvider.overrideWith((ref) => _TestPlayerNotifier(player)),
            rankProgressionSnapshotProvider.overrideWith(
              (ref) => Stream.value(_buildSnapshot()),
            ),
            rankProgressionHistoryProvider.overrideWith(
              (ref) => Stream.value(const <CompetitiveRankSnapshot>[]),
            ),
            promotionExamProvider.overrideWith((ref) => Stream.value(null)),
            remoteWeeklyBossProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: StatsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Proximo passo'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Plano'), findsOneWidget);
      expect(find.text('Leitura da semana'), findsOneWidget);
      expect(find.text('Proximo passo'), findsOneWidget);
      expect(find.text('Score'), findsOneWidget);
      expect(find.text('Grau'), findsOneWidget);
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

Player _buildPlayer() {
  return Player(
    name: 'TESTER',
    level: 4,
    xp: 48,
    maxXp: 120,
    statPoints: 1,
    attributes: PlayerAttributes(),
    lastResetDate: DateTime(2026, 4, 23),
    currentStreak: 3,
    bestStreak: 5,
    hasCompletedOnboarding: true,
    activityHistory: [
      DateTime(2026, 4, 20),
      DateTime(2026, 4, 21),
      DateTime(2026, 4, 22),
    ],
    competitiveActivityHistory: [DateTime(2026, 4, 21), DateTime(2026, 4, 22)],
    lastQuestCompletionDate: DateTime(2026, 4, 22),
    lastCompetitiveQuestCompletionDate: DateTime(2026, 4, 22),
  );
}

CompetitiveRankSnapshot _buildSnapshot() {
  return CompetitiveRankSnapshot(
    currentRank: 'E',
    weekKey: '2026W0417',
    activeDays: 2,
    requiredActiveDays: 3,
    requiresBossClear: false,
    bossCompleted: false,
    status: RankMaintenanceStatus.warning,
    demotionStrikes: 0,
    promotionReady: false,
    promotionTargetRank: 'D',
    eventType: CompetitiveRankEventType.warning,
    summary: 'A semana perdeu momentum e precisa de reinicio tatico.',
    detail: 'Dois dias ativos confirmados.',
    syncSchemaVersion: 2,
    syncSource: 'client',
    updatedAt: DateTime(2026, 4, 23),
  );
}
