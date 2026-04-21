import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  group('PlayerNotifier quest completion tracking', () {
    test(
      'personal completion updates general activity without touching competitive history',
      () {
        final notifier = PlayerNotifier(
          _NoopIsar(),
          Player(
            name: 'Hunter',
            level: 6,
            xp: 40,
            maxXp: 100,
            attributes: PlayerAttributes(),
            lastResetDate: DateTime(2026, 4, 19),
            hasCompletedOnboarding: true,
          ),
        );
        final completedAt = DateTime(2026, 4, 19, 9);

        notifier.recordQuestCompletion(completedAt: completedAt);

        expect(notifier.state.activityHistory, [DateTime(2026, 4, 19)]);
        expect(notifier.state.lastQuestCompletionDate, completedAt);
        expect(notifier.state.competitiveActivityHistory, isEmpty);
        expect(notifier.state.lastCompetitiveQuestCompletionDate, isNull);
      },
    );

    test('competitive completion updates dedicated competitive history', () {
      final notifier = PlayerNotifier(
        _NoopIsar(),
        Player(
          name: 'Hunter',
          level: 6,
          xp: 40,
          maxXp: 100,
          attributes: PlayerAttributes(),
          lastResetDate: DateTime(2026, 4, 19),
          hasCompletedOnboarding: true,
        ),
      );
      final completedAt = DateTime(2026, 4, 19, 21, 10);

      notifier.recordQuestCompletion(
        completedAt: completedAt,
        countsForCompetitive: true,
      );

      expect(notifier.state.activityHistory, [DateTime(2026, 4, 19)]);
      expect(notifier.state.competitiveActivityHistory, [
        DateTime(2026, 4, 19),
      ]);
      expect(notifier.state.lastCompetitiveQuestCompletionDate, completedAt);
    });
  });
}

class _NoopIsar implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
