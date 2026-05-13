import 'package:ascend/features/quests/data/competitive_evidence_provider_adapter.dart';
import 'package:ascend/features/quests/domain/competitive_quest_evidence.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter/services.dart';

class HealthConnectEvidenceSession {
  const HealthConnectEvidenceSession({
    required this.startedAt,
    required this.completedAt,
    required this.durationMinutes,
    required this.sourceActivityId,
    this.distanceMeters,
  });

  final DateTime startedAt;
  final DateTime completedAt;
  final int durationMinutes;
  final int? distanceMeters;
  final String sourceActivityId;
}

abstract interface class HealthConnectEvidenceGateway {
  Future<HealthConnectEvidenceSession?> readSessionEvidence({
    required CompetitiveEvidenceType evidenceType,
    required DateTime startedAt,
    required DateTime completedAt,
  });
}

class MethodChannelHealthConnectEvidenceGateway
    implements HealthConnectEvidenceGateway {
  const MethodChannelHealthConnectEvidenceGateway({
    MethodChannel channel = const MethodChannel('ascend/health_connect'),
  }) : _channel = channel;

  final MethodChannel _channel;

  @override
  Future<HealthConnectEvidenceSession?> readSessionEvidence({
    required CompetitiveEvidenceType evidenceType,
    required DateTime startedAt,
    required DateTime completedAt,
  }) async {
    final payload = await _channel.invokeMapMethod<String, Object?>(
      'readSessionEvidence',
      <String, Object?>{
        'evidenceType': evidenceType.name,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'completedAt': completedAt.toUtc().toIso8601String(),
      },
    );

    if (payload == null) return null;

    return HealthConnectEvidenceSession(
      startedAt: DateTime.parse(payload['startedAt']! as String).toLocal(),
      completedAt: DateTime.parse(payload['completedAt']! as String).toLocal(),
      durationMinutes: payload['durationMinutes']! as int,
      distanceMeters: payload['distanceMeters'] as int?,
      sourceActivityId: payload['sourceActivityId']! as String,
    );
  }
}

class HealthConnectCompetitiveEvidenceProviderAdapter
    implements CompetitiveEvidenceProviderAdapter {
  const HealthConnectCompetitiveEvidenceProviderAdapter({
    HealthConnectEvidenceGateway gateway =
        const MethodChannelHealthConnectEvidenceGateway(),
  }) : _gateway = gateway;

  final HealthConnectEvidenceGateway _gateway;

  @override
  CompetitiveEvidenceProvider get provider =>
      CompetitiveEvidenceProvider.healthConnect;

  @override
  Future<QuestEvidence> buildEvidence({
    required Quest quest,
    required CompetitiveVerificationRequirement requirement,
    required DateTime startedAt,
    required DateTime completedAt,
    String? reflection,
    String? quizId,
    List<String> quizAnswers = const [],
  }) async {
    final session = await _gateway.readSessionEvidence(
      evidenceType: requirement.evidenceType,
      startedAt: startedAt,
      completedAt: completedAt,
    );

    return QuestEvidence(
      questId: quest.id,
      provider: provider,
      type: requirement.evidenceType,
      startedAt: session?.startedAt ?? startedAt,
      completedAt: session?.completedAt ?? completedAt,
      durationMinutes: session?.durationMinutes,
      distanceMeters: session?.distanceMeters,
      sourceActivityId: session?.sourceActivityId,
      quizId: quizId,
      answers: quizAnswers,
      reflection: reflection,
    );
  }
}
