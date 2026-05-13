import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/quests/domain/competitive_quest_evidence.dart';
import 'package:ascend/features/quests/domain/competitive_quest_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluateCompetitiveQuestEvidence', () {
    test('accepts valid running evidence from the mock provider', () {
      final template = officialCompetitiveQuestCatalog().firstWhere(
        (template) => template.id == 'run-2k-controlled',
      );
      final startedAt = DateTime(2026, 4, 21, 8);
      final quest = template.toQuest();

      final decision = evaluateCompetitiveQuestEvidence(
        quest: quest,
        requirement: template.verificationRequirement,
        evidence: QuestEvidence(
          questId: quest.id,
          provider: CompetitiveEvidenceProvider.mockEvidence,
          type: CompetitiveEvidenceType.runningDistance,
          startedAt: startedAt,
          completedAt: startedAt.add(const Duration(minutes: 12)),
          durationMinutes: 12,
          distanceMeters: 2200,
          sourceActivityId: 'activity-1',
        ),
      );

      expect(decision.status, VerificationDecisionStatus.accepted);
      expect(decision.riskFlags, isEmpty);
    });

    test('rejects impossible running pace', () {
      final template = officialCompetitiveQuestCatalog().firstWhere(
        (template) => template.id == 'run-2k-controlled',
      );
      final startedAt = DateTime(2026, 4, 21, 8);
      final quest = template.toQuest();

      final decision = evaluateCompetitiveQuestEvidence(
        quest: quest,
        requirement: template.verificationRequirement,
        evidence: QuestEvidence(
          questId: quest.id,
          provider: CompetitiveEvidenceProvider.mockEvidence,
          type: CompetitiveEvidenceType.runningDistance,
          startedAt: startedAt,
          completedAt: startedAt.add(const Duration(minutes: 10)),
          durationMinutes: 10,
          distanceMeters: 5000,
        ),
      );

      expect(decision.status, VerificationDecisionStatus.rejected);
      expect(decision.riskFlags, contains(CompetitiveRiskFlag.impossiblePace));
    });

    test('requires reading quiz score before acceptance', () {
      final template = templatesForFocus(
        AwakeningPath.study,
      ).firstWhere((template) => template.id == 'reading-20');
      final startedAt = DateTime(2026, 4, 21, 8);
      final quest = template.toQuest();

      final decision = evaluateCompetitiveQuestEvidence(
        quest: quest,
        requirement: template.verificationRequirement,
        evidence: QuestEvidence(
          questId: quest.id,
          provider: CompetitiveEvidenceProvider.mockEvidence,
          type: CompetitiveEvidenceType.readingComprehension,
          startedAt: startedAt,
          completedAt: startedAt.add(const Duration(minutes: 20)),
          durationMinutes: 20,
        ),
      );

      expect(decision.status, VerificationDecisionStatus.insufficientEvidence);
      expect(decision.riskFlags, contains(CompetitiveRiskFlag.missingQuiz));
    });

    test(
      'builds deterministic mock evidence for non-device implementation',
      () {
        final template = officialCompetitiveQuestCatalog().firstWhere(
          (template) => template.id == 'run-2k-controlled',
        );
        final startedAt = DateTime(2026, 4, 21, 8);
        final quest = template.toQuest();

        final evidence = mockEvidenceForQuest(
          quest: quest,
          requirement: template.verificationRequirement,
          startedAt: startedAt,
        );

        expect(evidence.provider, CompetitiveEvidenceProvider.mockEvidence);
        expect(evidence.distanceMeters, 2000);
        expect(evidence.sourceActivityId, isNotNull);
      },
    );

    test('summarizes evidence requirements for competitive UI', () {
      final template = officialCompetitiveQuestCatalog().firstWhere(
        (template) => template.id == 'run-2k-controlled',
      );

      final summary = competitiveEvidenceRequirementSummary(
        template.verificationRequirement,
      );

      expect(summary, contains('distancia registrada'));
      expect(summary, contains('10 min'));
      expect(summary, contains('2000 m'));
      expect(summary, contains('fonte: simulada'));
    });

    test('translates risk flags into user-facing evidence details', () {
      expect(
        competitiveRiskFlagUserMessage(CompetitiveRiskFlag.impossiblePace),
        'ritmo impossivel',
      );
      expect(
        competitiveRiskFlagUserMessage(CompetitiveRiskFlag.durationTooShort),
        'duracao abaixo do minimo',
      );
    });
  });
}
