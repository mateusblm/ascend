import 'package:ascend/features/quests/data/competitive_evidence_provider_adapter.dart';
import 'package:ascend/features/quests/data/health_connect_evidence_provider_adapter.dart';
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

  test(
    'Health Connect adapter maps native session data into quest evidence',
    () async {
      final template = officialCompetitiveQuestCatalog().firstWhere(
        (template) => template.id == 'run-2k-controlled',
      );
      final quest = template.toQuest();
      final startedAt = DateTime(2026, 5, 13, 7);
      final completedAt = startedAt.add(const Duration(minutes: 12));
      final adapter = HealthConnectCompetitiveEvidenceProviderAdapter(
        gateway: _FakeHealthConnectEvidenceGateway(
          session: HealthConnectEvidenceSession(
            startedAt: startedAt,
            completedAt: completedAt,
            durationMinutes: 12,
            distanceMeters: 2300,
            sourceActivityId: 'health-session-1',
          ),
        ),
      );

      final evidence = await adapter.buildEvidence(
        quest: quest,
        requirement: template.verificationRequirement,
        startedAt: startedAt,
        completedAt: completedAt,
      );

      expect(adapter.provider, CompetitiveEvidenceProvider.healthConnect);
      expect(evidence.provider, CompetitiveEvidenceProvider.healthConnect);
      expect(evidence.durationMinutes, 12);
      expect(evidence.distanceMeters, 2300);
      expect(evidence.sourceActivityId, 'health-session-1');
    },
  );

  test(
    'Health Connect adapter returns insufficient evidence when no session exists',
    () async {
      final template = officialCompetitiveQuestCatalog().firstWhere(
        (template) => template.id == 'run-2k-controlled',
      );
      final quest = template.toQuest();
      final startedAt = DateTime(2026, 5, 13, 7);
      final adapter = HealthConnectCompetitiveEvidenceProviderAdapter(
        gateway: const _FakeHealthConnectEvidenceGateway(),
      );

      final evidence = await adapter.buildEvidence(
        quest: quest,
        requirement: template.verificationRequirement,
        startedAt: startedAt,
        completedAt: startedAt.add(const Duration(minutes: 12)),
      );

      final decision = evaluateCompetitiveQuestEvidence(
        quest: quest,
        requirement: template.verificationRequirement,
        evidence: evidence,
      );

      expect(evidence.provider, CompetitiveEvidenceProvider.healthConnect);
      expect(decision.status, VerificationDecisionStatus.insufficientEvidence);
    },
  );
}

class _FakeHealthConnectEvidenceGateway
    implements HealthConnectEvidenceGateway {
  const _FakeHealthConnectEvidenceGateway({this.session});

  final HealthConnectEvidenceSession? session;

  @override
  Future<HealthConnectEvidenceSession?> readSessionEvidence({
    required CompetitiveEvidenceType evidenceType,
    required DateTime startedAt,
    required DateTime completedAt,
  }) async {
    return session;
  }
}
