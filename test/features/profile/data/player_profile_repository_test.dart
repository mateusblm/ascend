import 'package:ascend/features/profile/data/player_profile_repository.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldUploadPlayerProfileWhenRemoteMissing', () {
    test('uploads when local profile has meaningful progress', () {
      final player = Player(
        ownerUid: 'uid-1',
        name: 'Hunter',
        level: 4,
        xp: 35,
        maxXp: 100,
        attributes: PlayerAttributes(),
        lastResetDate: DateTime(2026, 4, 21),
        hasCompletedOnboarding: true,
      );

      expect(
        shouldUploadPlayerProfileWhenRemoteMissing(
          player,
          fallbackName: 'Hunter',
        ),
        isTrue,
      );
    });

    test('does not upload a fresh empty profile automatically', () {
      final player = Player.initial(name: 'Hunter', ownerUid: 'uid-1');

      expect(
        shouldUploadPlayerProfileWhenRemoteMissing(
          player,
          fallbackName: 'Hunter',
        ),
        isFalse,
      );
    });
  });

  test('parsePlayerProfileData rebuilds a player from firestore-safe data', () {
    final player = parsePlayerProfileData(
      <String, dynamic>{
        'name': 'Hunter',
        'level': 6,
        'xp': 22,
        'maxXp': 120,
        'statPoints': 3,
        'attributes': <String, dynamic>{
          'strength': 12,
          'intelligence': 15,
          'vitality': 11,
          'agility': 14,
        },
        'lastResetDate': DateTime(2026, 4, 21, 8),
        'currentStreak': 4,
        'bestStreak': 7,
        'lastQuestCompletionDate': DateTime(2026, 4, 20, 10),
        'activityHistory': <DateTime>[
          DateTime(2026, 4, 20, 10),
          DateTime(2026, 4, 21, 11),
        ],
        'primaryFocus': 'study',
        'hasCompletedOnboarding': true,
      },
      uid: 'uid-1',
      fallbackName: 'Jogador',
    );

    expect(player.ownerUid, 'uid-1');
    expect(player.name, 'Hunter');
    expect(player.level, 6);
    expect(player.xp, 22);
    expect(player.attributes.intelligence, 15);
    expect(player.activityHistory, [
      DateTime(2026, 4, 20),
      DateTime(2026, 4, 21),
    ]);
    expect(player.primaryFocus, AwakeningPath.study);
    expect(player.hasCompletedOnboarding, isTrue);
  });

  test('preserva o ciclo de vida e a Jornada ao sincronizar o perfil', () {
    final fonte = questSourceForProfileSync(Quest(
      id: 'quest-1',
      title: 'Organizar rota',
      journeyId: 'jornada-1',
      rewardAttribute: AttributeType.intelligence,
      xpReward: 12,
      plannedFor: DateTime(2026, 7, 20),
      isArchived: true,
    ));

    expect(fonte['journeyId'], 'jornada-1');
    expect(fonte['isArchived'], isTrue);
    expect(fonte['plannedFor'], contains('2026-07-20'));
  });
}
