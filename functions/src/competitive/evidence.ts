import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';
import { normalizedDateKey } from '../shared/date';
import {
  ensureNonNegativeIntOrNull,
  ensureString,
  ensureStringArray,
  ensureTimestamp,
} from '../shared/validation';

export type ServerCompetitiveVerificationRequirement = {
  evidenceType: string;
  minimumTrustTier: number;
  minimumDurationMinutes: number;
  minimumDistanceMeters: number;
  minimumQuizScore: number;
  allowedProviders: string[];
};

export type ServerQuestEvidence = {
  questId: string;
  provider: string;
  type: string;
  startedAt: admin.firestore.Timestamp;
  completedAt: admin.firestore.Timestamp;
  durationMinutes: number | null;
  distanceMeters: number | null;
  sourceActivityId: string | null;
  quizScore: number | null;
  answers: string[];
  reflection: string | null;
};

export type CompetitiveQuestSessionRecord = {
  startedAt?: admin.firestore.Timestamp | null;
  status?: string | null;
  dayKey?: string | null;
};

export type CompetitiveQuestGrantRecord = {
  completedAt?: admin.firestore.Timestamp | null;
  dayKey?: string | null;
};

export type CompetitiveQuestForVerification = {
  questId: string;
  title: string;
  templateCatalogId: string | null;
  templateType: string;
  verificationMode: string;
  targetDurationMinutes: number;
  xpReward: number;
  rewardAttribute: string;
  verificationStartedAt: admin.firestore.Timestamp | null;
  reflectionAnswer: string | null;
  verificationRequirement: ServerCompetitiveVerificationRequirement;
  evidence: ServerQuestEvidence | null;
};

export function ensureEvidenceProvider(value: unknown, field: string): string {
  const provider = ensureString(value, field, 32);
  if (
    !['manual', 'appTimer', 'mockEvidence', 'healthConnect'].includes(provider)
  ) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }
  return provider;
}

export function ensureEvidenceType(value: unknown, field: string): string {
  const type = ensureString(value, field, 48);
  if (![
    'timedFocus',
    'runningDistance',
    'readingComprehension',
    'workoutSession',
    'studySession',
  ].includes(type)) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }
  return type;
}

export function validateQuestEvidencePayload(
  payload: unknown,
  expectedQuestId: string,
): ServerQuestEvidence {
  if (!payload || typeof payload !== 'object') {
    throw new HttpsError('invalid-argument', 'Evidencia competitiva invalida.');
  }

  const data = payload as Record<string, unknown>;
  const questId = ensureString(data.questId, 'evidence.questId', 120);
  if (questId !== expectedQuestId) {
    throw new HttpsError(
      'permission-denied',
      'Evidencia enviada para quest diferente.',
    );
  }

  return {
    questId,
    provider: ensureEvidenceProvider(data.provider, 'evidence.provider'),
    type: ensureEvidenceType(data.type, 'evidence.type'),
    startedAt: ensureTimestamp(data.startedAt, 'evidence.startedAt'),
    completedAt: ensureTimestamp(data.completedAt, 'evidence.completedAt'),
    durationMinutes: ensureNonNegativeIntOrNull(
      data.durationMinutes,
      'evidence.durationMinutes',
    ),
    distanceMeters: ensureNonNegativeIntOrNull(
      data.distanceMeters,
      'evidence.distanceMeters',
    ),
    sourceActivityId: data.sourceActivityId == null
      ? null
      : ensureString(data.sourceActivityId, 'evidence.sourceActivityId', 160),
    quizScore: ensureNonNegativeIntOrNull(data.quizScore, 'evidence.quizScore'),
    answers: data.answers == null
      ? []
      : ensureStringArray(data.answers, 'evidence.answers', 500),
    reflection: data.reflection == null
      ? null
      : ensureString(data.reflection, 'evidence.reflection', 500),
  };
}

export function evaluateCompetitiveQuestEvidence(args: {
  quest: CompetitiveQuestForVerification;
  evidence: ServerQuestEvidence | null;
  now: admin.firestore.Timestamp;
}) {
  const {quest, evidence, now} = args;
  const requirement = quest.verificationRequirement;
  const riskFlags: string[] = [];

  if (!evidence) {
    return {
      status: 'insufficientEvidence' as const,
      confidenceScore: 0,
      riskFlags: ['missingEvidence'],
    };
  }

  if (
    evidence.type !== requirement.evidenceType ||
    !requirement.allowedProviders.includes(evidence.provider)
  ) {
    riskFlags.push('invalidProvider');
  }

  if (evidence.completedAt.toMillis() < evidence.startedAt.toMillis()) {
    riskFlags.push('completedBeforeStart');
  }

  const elapsedMinutes = Math.floor(
    (evidence.completedAt.toMillis() - evidence.startedAt.toMillis()) /
      (60 * 1000),
  );
  const effectiveDuration = evidence.durationMinutes ?? elapsedMinutes;
  if (effectiveDuration <= 0) {
    riskFlags.push('missingDuration');
  } else if (effectiveDuration < requirement.minimumDurationMinutes) {
    riskFlags.push('durationTooShort');
  }

  if (requirement.minimumDistanceMeters > 0) {
    const distance = evidence.distanceMeters ?? 0;
    if (distance <= 0) {
      riskFlags.push('missingDistance');
    } else if (distance < requirement.minimumDistanceMeters) {
      riskFlags.push('distanceTooShort');
    }

    if (distance > 0 && effectiveDuration > 0) {
      const metersPerMinute = distance / effectiveDuration;
      if (metersPerMinute > 420) {
        riskFlags.push('impossiblePace');
      } else if (metersPerMinute > 300) {
        riskFlags.push('unusuallyFastPace');
      }
    }
  }

  if (
    requirement.minimumQuizScore > 0 &&
    (evidence.quizScore == null ||
      evidence.quizScore < requirement.minimumQuizScore)
  ) {
    riskFlags.push('missingQuiz');
  }

  if (
    evidence.completedAt.toMillis() <
    now.toMillis() - 2 * 24 * 60 * 60 * 1000
  ) {
    riskFlags.push('staleEvidence');
  }

  if (
    riskFlags.includes('invalidProvider') ||
    riskFlags.includes('completedBeforeStart') ||
    riskFlags.includes('impossiblePace') ||
    riskFlags.includes('staleEvidence')
  ) {
    return {
      status: 'rejected' as const,
      confidenceScore: 0,
      riskFlags,
    };
  }

  if (
    riskFlags.includes('missingDuration') ||
    riskFlags.includes('durationTooShort') ||
    riskFlags.includes('missingDistance') ||
    riskFlags.includes('distanceTooShort') ||
    riskFlags.includes('missingQuiz')
  ) {
    return {
      status: 'insufficientEvidence' as const,
      confidenceScore: 15,
      riskFlags,
    };
  }

  const baseConfidence = evidence.provider === 'manual'
    ? 35
    : evidence.provider === 'appTimer'
      ? 65
      : evidence.provider === 'healthConnect'
        ? 85
        : 75;
  const confidenceScore = riskFlags.includes('unusuallyFastPace')
    ? Math.max(0, baseConfidence - 25)
    : baseConfidence;

  return {
    status: riskFlags.includes('unusuallyFastPace')
      ? 'needsReview' as const
      : 'accepted' as const,
    confidenceScore,
    riskFlags,
  };
}

export function competitiveQuestAttemptDayKey(args: {
  quest: CompetitiveQuestForVerification;
  now: admin.firestore.Timestamp;
}): string {
  return normalizedDateKey(args.quest.verificationStartedAt ?? args.now);
}

export function competitiveQuestAttemptDocId(
  questId: string,
  dayKey: string,
): string {
  return `${questId}__${dayKey}`;
}

export function matchesCompetitiveAttemptDay(args: {
  record: CompetitiveQuestSessionRecord | CompetitiveQuestGrantRecord | null;
  dayKey: string;
  timestampField: 'startedAt' | 'completedAt';
}): boolean {
  const {record, dayKey} = args;
  if (!record) {
    return false;
  }

  if (typeof record.dayKey === 'string' && record.dayKey === dayKey) {
    return true;
  }

  const timestamp = args.timestampField === 'startedAt'
    ? ('startedAt' in record ? record.startedAt : null)
    : ('completedAt' in record ? record.completedAt : null);
  return (
    timestamp instanceof admin.firestore.Timestamp &&
    normalizedDateKey(timestamp) === dayKey
  );
}

export function resolveCompetitiveQuestSessionStart(args: {
  quest: CompetitiveQuestForVerification;
  session: CompetitiveQuestSessionRecord | null;
  grant: CompetitiveQuestGrantRecord | null;
  now: admin.firestore.Timestamp;
}) {
  const {quest, grant, now} = args;

  if (grant) {
    throw new HttpsError('failed-precondition', 'Essa quest ja foi validada.');
  }

  return {
    status: 'started' as const,
    startedAt: now.toDate().toISOString(),
    sessionWrite: {
      questId: quest.questId,
      title: quest.title,
      templateCatalogId: quest.templateCatalogId,
      dayKey: normalizedDateKey(now),
      templateType: quest.templateType,
      verificationMode: quest.verificationMode,
      targetDurationMinutes: quest.targetDurationMinutes,
      xpReward: quest.xpReward,
      rewardAttribute: quest.rewardAttribute,
      startedAt: now,
      status: 'inProgress',
      updatedAt: now,
    },
  };
}

export function resolveCompetitiveQuestCompletionVerification(args: {
  quest: CompetitiveQuestForVerification;
  session: CompetitiveQuestSessionRecord | null;
  grant: CompetitiveQuestGrantRecord | null;
  now: admin.firestore.Timestamp;
  sourceActivityIdAlreadyUsed?: boolean;
}) {
  const {quest, session, grant, now} = args;

  if (grant) {
    return {
      status: 'already_verified' as const,
      completedAt: grant.completedAt instanceof admin.firestore.Timestamp
        ? grant.completedAt.toDate().toISOString()
        : now.toDate().toISOString(),
      grantWrite: null,
      sessionWrite: null,
    };
  }

  if (
    quest.verificationMode === 'timer' ||
    quest.verificationMode === 'timerWithReflection'
  ) {
    if (!(session?.startedAt instanceof admin.firestore.Timestamp)) {
      throw new HttpsError(
        'failed-precondition',
        'A sessao ainda nao foi iniciada.',
      );
    }

    const elapsedMinutes = Math.floor(
      (now.toMillis() - session.startedAt.toMillis()) / (60 * 1000),
    );
    if (elapsedMinutes < quest.targetDurationMinutes) {
      throw new HttpsError(
        'failed-precondition',
        'Ainda falta tempo para validar essa quest.',
      );
    }
  }

  if (quest.verificationMode === 'timerWithReflection' && !quest.reflectionAnswer) {
    throw new HttpsError(
      'failed-precondition',
      'A resposta curta ainda nao foi enviada.',
    );
  }

  const decision = evaluateCompetitiveQuestEvidence({
    quest,
    evidence: quest.evidence,
    now,
  });
  if (args.sourceActivityIdAlreadyUsed) {
    throw new HttpsError(
      'failed-precondition',
      'Evidencia competitiva insuficiente: duplicateSourceActivityId.',
    );
  }
  if (decision.status !== 'accepted') {
    throw new HttpsError(
      'failed-precondition',
      `Evidencia competitiva insuficiente: ${
        decision.riskFlags.join(',') || decision.status
      }.`,
    );
  }

  return {
    status: 'verified' as const,
    completedAt: now.toDate().toISOString(),
    decision,
    grantWrite: {
      questId: quest.questId,
      title: quest.title,
      templateCatalogId: quest.templateCatalogId,
      dayKey: normalizedDateKey(session?.startedAt ?? now),
      templateType: quest.templateType,
      verificationMode: quest.verificationMode,
      targetDurationMinutes: quest.targetDurationMinutes,
      xpReward: quest.xpReward,
      rewardAttribute: quest.rewardAttribute,
      evidenceType: quest.evidence?.type ?? null,
      evidenceProvider: quest.evidence?.provider ?? null,
      confidenceScore: decision.confidenceScore,
      riskFlags: decision.riskFlags,
      sourceActivityId: quest.evidence?.sourceActivityId ?? null,
      completedAt: now,
      approvedAt: now,
    },
    sessionWrite: {
      dayKey: normalizedDateKey(session?.startedAt ?? now),
      status: 'verified',
      completedAt: now,
      updatedAt: now,
    },
  };
}
