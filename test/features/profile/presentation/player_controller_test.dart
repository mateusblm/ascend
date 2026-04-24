import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
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

  group('PlayerNotifier attribute allocation', () {
    test('upgradeAttribute updates local state immediately and applies remote profile', () async {
      final notifier = PlayerNotifier(
        _NoopIsar(),
        _buildPlayer(statPoints: 2, strength: 12, ownerUid: 'uid-1'),
        enableLocalPersistence: false,
        allocateAttributePointOverride: ({
          required String uid,
          required String fallbackName,
          required AttributeType attribute,
        }) async {
          expect(attribute, AttributeType.strength);
          return _buildPlayer(
            statPoints: 1,
            strength: 13,
            ownerUid: uid,
          );
        },
      );
      notifier.debugSetActiveUid('uid-1');

      final future = notifier.upgradeAttribute(AttributeType.strength);

      expect(notifier.state.statPoints, 1);
      expect(notifier.state.attributes.strength, 13);

      await future;

      expect(notifier.state.statPoints, 1);
      expect(notifier.state.attributes.strength, 13);
    });

    test('upgradeAttribute rolls back optimistic state when allocation fails', () async {
      final notifier = PlayerNotifier(
        _NoopIsar(),
        _buildPlayer(statPoints: 2, intelligence: 11, ownerUid: 'uid-1'),
        enableLocalPersistence: false,
        allocateAttributePointOverride: ({
          required String uid,
          required String fallbackName,
          required AttributeType attribute,
        }) async {
          throw StateError('backend failed');
        },
      );
      notifier.debugSetActiveUid('uid-1');

      await expectLater(
        notifier.upgradeAttribute(AttributeType.intelligence),
        throwsStateError,
      );

      expect(notifier.state.statPoints, 2);
      expect(notifier.state.attributes.intelligence, 11);
    });
  });
}

class _NoopIsar implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Player _buildPlayer({
  int level = 6,
  int xp = 40,
  int maxXp = 100,
  int statPoints = 0,
  int strength = 10,
  int intelligence = 10,
  int vitality = 10,
  int agility = 10,
  String? ownerUid,
}) {
  return Player(
    ownerUid: ownerUid,
    name: 'Hunter',
    level: level,
    xp: xp,
    maxXp: maxXp,
    statPoints: statPoints,
    attributes: PlayerAttributes(
      strength: strength,
      intelligence: intelligence,
      vitality: vitality,
      agility: agility,
    ),
    lastResetDate: DateTime(2026, 4, 19),
    hasCompletedOnboarding: true,
  );
}
