import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/quests/domain/competitive_quest_evidence.dart';
import 'package:ascend/features/quests/domain/competitive_quest_template.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompetitiveQuestTemplate', () {
    test(
      'templatesForFocus returns official competitive templates for each focus',
      () {
        for (final focus in AwakeningPath.values) {
          final templates = templatesForFocus(focus);

          expect(templates, isNotEmpty);
          expect(templates.every((template) => template.xpReward > 0), isTrue);
          expect(
            templates.every(
              (template) =>
                  template.verificationMode != QuestVerificationMode.manual,
            ),
            isTrue,
          );
        }
      },
    );

    test('toQuest creates a competitive quest with verification pending', () {
      const template = CompetitiveQuestTemplate(
        id: 'focus-25',
        title: 'Sessao de foco de 25 minutos',
        description: 'Bloco oficial',
        rewardAttribute: AttributeType.agility,
        xpReward: 30,
        templateType: QuestTemplateType.focusSession,
        verificationMode: QuestVerificationMode.timer,
        targetDurationMinutes: 25,
        verificationRequirement: CompetitiveVerificationRequirement(
          evidenceType: CompetitiveEvidenceType.timedFocus,
          minimumTrustTier: 2,
          minimumDurationMinutes: 25,
          allowedProviders: [CompetitiveEvidenceProvider.mockEvidence],
        ),
      );

      final quest = template.toQuest();

      expect(quest.category, QuestCategory.competitive);
      expect(quest.templateType, QuestTemplateType.focusSession);
      expect(quest.verificationStatus, QuestVerificationStatus.none);
      expect(quest.targetDurationMinutes, 25);
      expect(quest.countsTowardCompetitive, isFalse);
    });

    test('official catalog exposes richer evidence templates', () {
      final catalog = officialCompetitiveQuestCatalog();

      expect(
        catalog.any((template) => template.id == 'run-2k-controlled'),
        isTrue,
      );
      expect(catalog.any((template) => template.id == 'bodyweight-20'), isTrue);
      expect(
        catalog.any((template) => template.id == 'study-20-recall'),
        isTrue,
      );
      expect(
        catalog.every(
          (template) =>
              template.verificationRequirement.allowedProviders.isNotEmpty,
        ),
        isTrue,
      );
    });
  });
}
