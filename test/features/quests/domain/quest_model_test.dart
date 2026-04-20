import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Quest model', () {
    test('normalizePersonalQuestXp keeps personal rewards in the light XP lane', () {
      expect(normalizePersonalQuestXp(4), 8);
      expect(normalizePersonalQuestXp(12), 12);
      expect(normalizePersonalQuestXp(30), 15);
    });

    test('verified competitive quests count toward competitive systems', () {
      final quest = Quest(
        id: 'competitive-reading',
        title: 'Leitura validada',
        rewardAttribute: AttributeType.intelligence,
        xpReward: 30,
        category: QuestCategory.competitive,
        verificationMode: QuestVerificationMode.timerWithReflection,
        verificationStatus: QuestVerificationStatus.verified,
      );

      expect(quest.isCompetitive, isTrue);
      expect(quest.requiresTimer, isTrue);
      expect(quest.requiresReflection, isTrue);
      expect(quest.countsTowardCompetitive, isTrue);
    });

    test('clearVerificationProgress removes runtime proof state', () {
      final quest = Quest(
        id: 'focus-quest',
        title: 'Sessao de foco',
        rewardAttribute: AttributeType.agility,
        xpReward: 30,
        category: QuestCategory.competitive,
        verificationMode: QuestVerificationMode.timerWithReflection,
        verificationStatus: QuestVerificationStatus.inProgress,
        verificationStartedAt: DateTime(2026, 4, 19, 8),
        completedAt: DateTime(2026, 4, 19, 8, 30),
        verifiedAt: DateTime(2026, 4, 19, 8, 31),
        reflectionAnswer: 'Revisao concluida',
      );

      final cleared = quest.copyWith(
        verificationStatus: QuestVerificationStatus.none,
        clearVerificationProgress: true,
      );

      expect(cleared.verificationStatus, QuestVerificationStatus.none);
      expect(cleared.verificationStartedAt, isNull);
      expect(cleared.completedAt, isNull);
      expect(cleared.verifiedAt, isNull);
      expect(cleared.reflectionAnswer, isNull);
    });
  });
}
