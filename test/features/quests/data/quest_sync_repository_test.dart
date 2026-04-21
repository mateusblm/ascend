import 'package:ascend/features/quests/data/quest_sync_repository.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'shouldUploadQuestCacheWhenRemoteMissing returns false for empty cache',
    () {
      expect(shouldUploadQuestCacheWhenRemoteMissing(const <Quest>[]), isFalse);
    },
  );

  test(
    'shouldUploadQuestCacheWhenRemoteMissing returns true when quests exist',
    () {
      expect(
        shouldUploadQuestCacheWhenRemoteMissing([
          Quest(
            ownerUid: 'uid-1',
            id: 'quest-1',
            title: 'Estudar 20 minutos',
            rewardAttribute: AttributeType.intelligence,
            xpReward: 12,
          ),
        ]),
        isTrue,
      );
    },
  );

  test('parseQuestSyncData rebuilds a remote quest', () {
    final quest = parseQuestSyncData(
      <String, dynamic>{
        'title': 'Sessao focada',
        'rewardAttribute': 'agility',
        'xpReward': 30,
        'category': 'competitive',
        'templateType': 'focusSession',
        'verificationMode': 'timer',
        'verificationStatus': 'inProgress',
        'targetDurationMinutes': 25,
        'verificationStartedAt': DateTime(2026, 4, 21, 10),
      },
      uid: 'uid-1',
      questId: 'focus-25',
    );

    expect(quest.ownerUid, 'uid-1');
    expect(quest.id, 'focus-25');
    expect(quest.isCompetitive, isTrue);
    expect(quest.rewardAttribute, AttributeType.agility);
    expect(quest.targetDurationMinutes, 25);
    expect(quest.verificationStatus, QuestVerificationStatus.inProgress);
  });
}
