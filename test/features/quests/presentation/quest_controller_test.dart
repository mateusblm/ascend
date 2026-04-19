import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  group('Daily reset flow', () {
    test('isDailyResetDue returns true only when calendar day changes', () {
      final now = DateTime(2026, 4, 19, 8, 0);

      expect(
        isDailyResetDue(
          lastReset: DateTime(2026, 4, 18, 23, 59),
          now: now,
        ),
        isTrue,
      );
      expect(
        isDailyResetDue(
          lastReset: DateTime(2026, 4, 19, 0, 1),
          now: now,
        ),
        isFalse,
      );
    });

    test('handleDailyReset clears stale streak after missed days', () {
      final notifier = PlayerNotifier(
        _NoopIsar(),
        Player(
          name: 'Tester',
          level: 3,
          xp: 10,
          maxXp: 100,
          attributes: PlayerAttributes(),
          lastResetDate: DateTime(2026, 4, 18),
          currentStreak: 5,
          bestStreak: 5,
          lastQuestCompletionDate: DateTime(2026, 4, 15),
          hasCompletedOnboarding: true,
        ),
      );

      notifier.handleDailyReset(DateTime(2026, 4, 19));

      expect(notifier.state.currentStreak, 0);
      expect(notifier.state.lastResetDate, DateTime(2026, 4, 19));
    });

    test('handleDailyReset preserves streak when the last completion was yesterday', () {
      final notifier = PlayerNotifier(
        _NoopIsar(),
        Player(
          name: 'Tester',
          level: 3,
          xp: 10,
          maxXp: 100,
          attributes: PlayerAttributes(),
          lastResetDate: DateTime(2026, 4, 18),
          currentStreak: 5,
          bestStreak: 5,
          lastQuestCompletionDate: DateTime(2026, 4, 18),
          hasCompletedOnboarding: true,
        ),
      );

      notifier.handleDailyReset(DateTime(2026, 4, 19));

      expect(notifier.state.currentStreak, 5);
      expect(notifier.state.lastResetDate, DateTime(2026, 4, 19));
    });
  });
}

class _NoopIsar implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
