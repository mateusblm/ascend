import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  group('Weekly boss flow', () {
    test('progress counts only current-week activity without duplicating the same day', () {
      final now = DateTime.now();
      final weekStart = weekStartFor(now);
      final player = Player(
        name: 'Hunter',
        level: 4,
        xp: 80,
        maxXp: 100,
        attributes: PlayerAttributes(),
        lastResetDate: now,
        competitiveActivityHistory: [
          weekStart,
          weekStart.add(const Duration(days: 1)),
          weekStart.add(const Duration(days: 2)),
          weekStart.add(const Duration(days: 3)),
          weekStart.subtract(const Duration(days: 2)),
        ],
        lastCompetitiveQuestCompletionDate: weekStart.add(const Duration(days: 3)),
        hasCompletedOnboarding: true,
      );

      final boss = weeklyBossForRank('E');

      expect(boss.progressFor(player), 4);
      expect(boss.isCompleted(player), isTrue);
    });

    test('progress prefers competitive activity history when it exists', () {
      final now = DateTime.now();
      final weekStart = weekStartFor(now);
      final player = Player(
        name: 'Hunter',
        level: 10,
        xp: 80,
        maxXp: 100,
        attributes: PlayerAttributes(),
        lastResetDate: now,
        activityHistory: [
          weekStart,
          weekStart.add(const Duration(days: 1)),
          weekStart.add(const Duration(days: 2)),
          weekStart.add(const Duration(days: 3)),
          weekStart.add(const Duration(days: 4)),
        ],
        competitiveActivityHistory: [
          weekStart,
          weekStart.add(const Duration(days: 1)),
        ],
        lastQuestCompletionDate: weekStart.add(const Duration(days: 4)),
        lastCompetitiveQuestCompletionDate: weekStart.add(const Duration(days: 1)),
        hasCompletedOnboarding: true,
      );

      final boss = weeklyBossForRank('C');

      expect(boss.progressFor(player), 2);
      expect(boss.isCompleted(player), isFalse);
    });

    test('claimWeeklyBossReward applies reward once and blocks duplicate claim in the same week', () {
      final now = DateTime.now();
      final weekStart = weekStartFor(now);
      final notifier = PlayerNotifier(
        _NoopIsar(),
        Player(
          name: 'Hunter',
          level: 4,
          xp: 90,
          maxXp: 100,
          attributes: PlayerAttributes(),
          lastResetDate: now,
          competitiveActivityHistory: [
            weekStart,
            weekStart.add(const Duration(days: 1)),
            weekStart.add(const Duration(days: 2)),
            weekStart.add(const Duration(days: 3)),
          ],
          lastCompetitiveQuestCompletionDate: weekStart.add(const Duration(days: 3)),
          hasCompletedOnboarding: true,
        ),
      );
      final boss = weeklyBossForRank('E');

      final firstClaim = notifier.claimWeeklyBossReward(boss);
      final claimedState = notifier.state;
      final secondClaim = notifier.claimWeeklyBossReward(boss);

      expect(firstClaim, isTrue);
      expect(secondClaim, isFalse);
      expect(claimedState.level, 5);
      expect(claimedState.xp, 110);
      expect(claimedState.maxXp, 120);
      expect(claimedState.statPoints, 7);
      expect(claimedState.weeklyBossLastClaimedAt, isNotNull);
    });
  });
}

class _NoopIsar implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
