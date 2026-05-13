import 'quest_model.dart';

enum CompetitiveEvidenceType {
  timedFocus,
  runningDistance,
  readingComprehension,
  workoutSession,
  studySession,
}

enum CompetitiveEvidenceProvider { manual, appTimer, mockEvidence }

enum VerificationDecisionStatus {
  accepted,
  rejected,
  needsReview,
  insufficientEvidence,
}

enum CompetitiveRiskFlag {
  missingDuration,
  missingDistance,
  missingQuiz,
  durationTooShort,
  distanceTooShort,
  impossiblePace,
  unusuallyFastPace,
  invalidProvider,
  completedBeforeStart,
  staleEvidence,
}

String competitiveEvidenceRequirementSummary(
  CompetitiveVerificationRequirement requirement,
) {
  final parts = <String>[];

  parts.add(switch (requirement.evidenceType) {
    CompetitiveEvidenceType.timedFocus => 'timer de foco',
    CompetitiveEvidenceType.runningDistance => 'distancia registrada',
    CompetitiveEvidenceType.readingComprehension => 'leitura com resposta',
    CompetitiveEvidenceType.workoutSession => 'sessao de treino',
    CompetitiveEvidenceType.studySession => 'sessao de estudo',
  });

  if (requirement.minimumDurationMinutes > 0) {
    parts.add('${requirement.minimumDurationMinutes} min');
  }
  if (requirement.minimumDistanceMeters > 0) {
    parts.add('${requirement.minimumDistanceMeters} m');
  }
  if (requirement.minimumQuizScore > 0) {
    parts.add('resposta minima ${requirement.minimumQuizScore}%');
  }

  final providers = requirement.allowedProviders
      .map(_competitiveEvidenceProviderLabel)
      .join(', ');
  parts.add('fonte: $providers');

  return parts.join(' | ');
}

String competitiveRiskFlagUserMessage(CompetitiveRiskFlag flag) {
  return switch (flag) {
    CompetitiveRiskFlag.missingDuration => 'duracao ausente',
    CompetitiveRiskFlag.missingDistance => 'distancia ausente',
    CompetitiveRiskFlag.missingQuiz => 'resposta minima ausente',
    CompetitiveRiskFlag.durationTooShort => 'duracao abaixo do minimo',
    CompetitiveRiskFlag.distanceTooShort => 'distancia abaixo do minimo',
    CompetitiveRiskFlag.impossiblePace => 'ritmo impossivel',
    CompetitiveRiskFlag.unusuallyFastPace => 'ritmo acima do esperado',
    CompetitiveRiskFlag.invalidProvider => 'fonte de evidencia invalida',
    CompetitiveRiskFlag.completedBeforeStart => 'fim antes do inicio',
    CompetitiveRiskFlag.staleEvidence => 'evidencia antiga',
  };
}

String _competitiveEvidenceProviderLabel(CompetitiveEvidenceProvider provider) {
  return switch (provider) {
    CompetitiveEvidenceProvider.manual => 'manual',
    CompetitiveEvidenceProvider.appTimer => 'timer do app',
    CompetitiveEvidenceProvider.mockEvidence => 'simulada',
  };
}

class CompetitiveVerificationRequirement {
  const CompetitiveVerificationRequirement({
    required this.evidenceType,
    required this.minimumTrustTier,
    required this.allowedProviders,
    this.minimumDurationMinutes = 0,
    this.minimumDistanceMeters = 0,
    this.minimumQuizScore = 0,
  });

  final CompetitiveEvidenceType evidenceType;
  final int minimumTrustTier;
  final List<CompetitiveEvidenceProvider> allowedProviders;
  final int minimumDurationMinutes;
  final int minimumDistanceMeters;
  final int minimumQuizScore;

  bool get requiresDistance => minimumDistanceMeters > 0;

  bool get requiresQuiz => minimumQuizScore > 0;
}

class QuestEvidence {
  const QuestEvidence({
    required this.questId,
    required this.provider,
    required this.type,
    required this.startedAt,
    required this.completedAt,
    this.durationMinutes,
    this.distanceMeters,
    this.sourceActivityId,
    this.quizScore,
    this.answers = const [],
    this.reflection,
  });

  final String questId;
  final CompetitiveEvidenceProvider provider;
  final CompetitiveEvidenceType type;
  final DateTime startedAt;
  final DateTime completedAt;
  final int? durationMinutes;
  final int? distanceMeters;
  final String? sourceActivityId;
  final int? quizScore;
  final List<String> answers;
  final String? reflection;

  Map<String, dynamic> toPayload() {
    return <String, dynamic>{
      'questId': questId,
      'provider': provider.name,
      'type': type.name,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      if (distanceMeters != null) 'distanceMeters': distanceMeters,
      if (sourceActivityId != null) 'sourceActivityId': sourceActivityId,
      if (quizScore != null) 'quizScore': quizScore,
      if (answers.isNotEmpty) 'answers': answers,
      if (reflection != null) 'reflection': reflection,
    };
  }
}

class VerificationDecision {
  const VerificationDecision({
    required this.status,
    required this.confidenceScore,
    this.riskFlags = const [],
  });

  final VerificationDecisionStatus status;
  final int confidenceScore;
  final List<CompetitiveRiskFlag> riskFlags;

  bool get accepted => status == VerificationDecisionStatus.accepted;
}

VerificationDecision evaluateCompetitiveQuestEvidence({
  required Quest quest,
  required CompetitiveVerificationRequirement requirement,
  required QuestEvidence evidence,
  DateTime? now,
}) {
  final flags = <CompetitiveRiskFlag>[];

  if (evidence.type != requirement.evidenceType ||
      !requirement.allowedProviders.contains(evidence.provider)) {
    flags.add(CompetitiveRiskFlag.invalidProvider);
  }

  if (evidence.completedAt.isBefore(evidence.startedAt)) {
    flags.add(CompetitiveRiskFlag.completedBeforeStart);
  }

  final effectiveDuration =
      evidence.durationMinutes ??
      evidence.completedAt.difference(evidence.startedAt).inMinutes;
  if (effectiveDuration <= 0) {
    flags.add(CompetitiveRiskFlag.missingDuration);
  } else if (effectiveDuration < requirement.minimumDurationMinutes) {
    flags.add(CompetitiveRiskFlag.durationTooShort);
  }

  if (requirement.requiresDistance) {
    final distance = evidence.distanceMeters ?? 0;
    if (distance <= 0) {
      flags.add(CompetitiveRiskFlag.missingDistance);
    } else if (distance < requirement.minimumDistanceMeters) {
      flags.add(CompetitiveRiskFlag.distanceTooShort);
    }

    if (distance > 0 && effectiveDuration > 0) {
      final metersPerMinute = distance / effectiveDuration;
      if (metersPerMinute > 420) {
        flags.add(CompetitiveRiskFlag.impossiblePace);
      } else if (metersPerMinute > 300) {
        flags.add(CompetitiveRiskFlag.unusuallyFastPace);
      }
    }
  }

  if (requirement.requiresQuiz) {
    final quizScore = evidence.quizScore;
    if (quizScore == null) {
      flags.add(CompetitiveRiskFlag.missingQuiz);
    } else if (quizScore < requirement.minimumQuizScore) {
      flags.add(CompetitiveRiskFlag.missingQuiz);
    }
  }

  final checkedNow = now;
  if (checkedNow != null &&
      evidence.completedAt.isBefore(
        checkedNow.subtract(const Duration(days: 2)),
      )) {
    flags.add(CompetitiveRiskFlag.staleEvidence);
  }

  if (flags.contains(CompetitiveRiskFlag.impossiblePace) ||
      flags.contains(CompetitiveRiskFlag.invalidProvider) ||
      flags.contains(CompetitiveRiskFlag.completedBeforeStart) ||
      flags.contains(CompetitiveRiskFlag.staleEvidence)) {
    return VerificationDecision(
      status: VerificationDecisionStatus.rejected,
      confidenceScore: 0,
      riskFlags: flags,
    );
  }

  if (flags.any(
    (flag) =>
        flag == CompetitiveRiskFlag.missingDuration ||
        flag == CompetitiveRiskFlag.missingDistance ||
        flag == CompetitiveRiskFlag.missingQuiz ||
        flag == CompetitiveRiskFlag.durationTooShort ||
        flag == CompetitiveRiskFlag.distanceTooShort,
  )) {
    return VerificationDecision(
      status: VerificationDecisionStatus.insufficientEvidence,
      confidenceScore: 15,
      riskFlags: flags,
    );
  }

  final confidence = switch (evidence.provider) {
    CompetitiveEvidenceProvider.manual => 35,
    CompetitiveEvidenceProvider.appTimer => 65,
    CompetitiveEvidenceProvider.mockEvidence => 75,
  };
  final adjustedConfidence =
      flags.contains(CompetitiveRiskFlag.unusuallyFastPace)
      ? confidence - 25
      : confidence;

  return VerificationDecision(
    status: flags.contains(CompetitiveRiskFlag.unusuallyFastPace)
        ? VerificationDecisionStatus.needsReview
        : VerificationDecisionStatus.accepted,
    confidenceScore: adjustedConfidence.clamp(0, 100),
    riskFlags: flags,
  );
}

QuestEvidence mockEvidenceForQuest({
  required Quest quest,
  required CompetitiveVerificationRequirement requirement,
  required DateTime startedAt,
  DateTime? completedAt,
  String? reflection,
}) {
  final end =
      completedAt ??
      startedAt.add(Duration(minutes: requirement.minimumDurationMinutes));
  final duration = end.difference(startedAt).inMinutes;

  return QuestEvidence(
    questId: quest.id,
    provider: CompetitiveEvidenceProvider.mockEvidence,
    type: requirement.evidenceType,
    startedAt: startedAt,
    completedAt: end,
    durationMinutes: duration,
    distanceMeters: requirement.minimumDistanceMeters == 0
        ? null
        : requirement.minimumDistanceMeters,
    sourceActivityId: requirement.minimumDistanceMeters == 0
        ? null
        : 'mock-${quest.id}-${startedAt.microsecondsSinceEpoch}',
    quizScore: requirement.minimumQuizScore == 0
        ? null
        : requirement.minimumQuizScore,
    answers: requirement.minimumQuizScore == 0
        ? const []
        : const ['Resposta validada em ambiente simulado.'],
    reflection: reflection,
  );
}
