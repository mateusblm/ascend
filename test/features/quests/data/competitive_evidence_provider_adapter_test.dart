import 'package:ascend/features/quests/data/competitive_evidence_provider_adapter.dart';
import 'package:ascend/features/quests/domain/competitive_quest_evidence.dart';
import 'package:ascend/features/quests/domain/competitive_quest_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mock adapter builds evidence through the provider boundary', () async {
    const adapter = MockCompetitiveEvidenceProviderAdapter();
    final template = officialCompetitiveQuestCatalog().firstWhere(
      (template) => template.id == 'run-2k-controlled',
    );
    final quest = template.toQuest();
    final startedAt = DateTime(2026, 5, 13, 7);

    final evidence = await adapter.buildEvidence(
      quest: quest,
      requirement: template.verificationRequirement,
      startedAt: startedAt,
      completedAt: startedAt.add(const Duration(minutes: 12)),
    );

    expect(adapter.provider, CompetitiveEvidenceProvider.mockEvidence);
    expect(evidence.provider, CompetitiveEvidenceProvider.mockEvidence);
    expect(evidence.type, CompetitiveEvidenceType.runningDistance);
    expect(evidence.distanceMeters, 2000);
    expect(evidence.sourceActivityId, isNotNull);
  });
}
