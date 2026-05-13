import 'package:ascend/features/quests/domain/competitive_quest_evidence.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';

abstract interface class CompetitiveEvidenceProviderAdapter {
  CompetitiveEvidenceProvider get provider;

  Future<QuestEvidence> buildEvidence({
    required Quest quest,
    required CompetitiveVerificationRequirement requirement,
    required DateTime startedAt,
    required DateTime completedAt,
    String? reflection,
  });
}

class MockCompetitiveEvidenceProviderAdapter
    implements CompetitiveEvidenceProviderAdapter {
  const MockCompetitiveEvidenceProviderAdapter();

  @override
  CompetitiveEvidenceProvider get provider =>
      CompetitiveEvidenceProvider.mockEvidence;

  @override
  Future<QuestEvidence> buildEvidence({
    required Quest quest,
    required CompetitiveVerificationRequirement requirement,
    required DateTime startedAt,
    required DateTime completedAt,
    String? reflection,
  }) async {
    return mockEvidenceForQuest(
      quest: quest,
      requirement: requirement,
      startedAt: startedAt,
      completedAt: completedAt,
      reflection: reflection,
    );
  }
}
