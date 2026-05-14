import * as admin from 'firebase-admin';
import * as logger from 'firebase-functions/logger';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import {
  competitiveQuestAttemptDayKey,
  competitiveQuestAttemptDocId,
  evaluateCompetitiveQuestEvidence,
  matchesCompetitiveAttemptDay,
  resolveCompetitiveQuestCompletionVerification,
  resolveCompetitiveQuestSessionStart,
  ServerCompetitiveVerificationRequirement,
  validateQuestEvidencePayload,
} from './competitive/evidence';
import {
  buildDeterministicReadingQuizAttempt,
  evaluateReadingQuizSubmission,
  readingQuizAttemptFromData,
  readingQuizAttemptWrite,
  validateReadingQuizSubmission,
} from './competitive/readingQuiz';
import { createReadingQuizGenerator } from './competitive/readingQuizGenerator';
import {
  higherRank,
  playerRankForLevel,
  rankAfter,
  rankBefore,
  rankOrder,
  rankRequirements,
} from './competitive/rank';
import {
  buildSeasonLegacyPayload,
  buildSeasonProfilePayload,
  buildSeasonRewardFromHistory,
  currentWeekDateKeys,
  resolveExamAfterSnapshot,
  seasonKeyFor,
  weekKeyForDate,
} from './competitive/season';
import {
  normalizedDateFromKey,
  normalizedDateKey,
  uniqueTimestampsByDay,
} from './shared/date';
import {
  asNonNegativeInt,
  asTimestampOrNull,
  ensureBool,
  ensureInt,
  ensureOptionalString,
  ensureString,
  ensureTimestamp,
  ensureTimestampArray,
  ensureTimestampOrNull,
  normalizeRank,
  normalizeSyncSource,
  parseTimestampInput,
  sanitizeDisplayName,
  sanitizePhotoUrl,
} from './shared/validation';
import {
  applyXpRewardToProfile,
  buildPlayerProfileSyncWrite,
  ensurePrimaryFocus,
  historyWithDay,
  profileAggregateFromData,
  questCompletionProjectionFromDocs,
  ServerPlayerProfileSource,
  ServerWeeklyBossClaim,
  streakMetricsFromHistory,
  withProfileMetadata,
} from './profile/progression';
import {
  buildQuestDocData,
  buildQuestInventorySyncWrites,
  ensureAttributeName,
  ServerQuestInventorySource,
  validateQuestFromStoredDoc,
  validateQuestInventorySourcePayload,
  validateSingleQuestSourcePayload,
} from './quests/inventory';

export {
  competitiveQuestAttemptDayKey,
  competitiveQuestAttemptDocId,
  evaluateCompetitiveQuestEvidence,
  matchesCompetitiveAttemptDay,
  resolveCompetitiveQuestCompletionVerification,
  resolveCompetitiveQuestSessionStart,
} from './competitive/evidence';
export { buildPlayerProfileSyncWrite } from './profile/progression';
export { buildQuestInventorySyncWrites } from './quests/inventory';
export { parseTimestampInput } from './shared/validation';
export {
  buildDeterministicReadingQuizAttempt,
  evaluateReadingQuizSubmission,
  validateReadingQuizSubmission,
} from './competitive/readingQuiz';
export {
  AiReadingQuizGenerator,
  createReadingQuizGenerator,
  DeterministicReadingQuizGenerator,
} from './competitive/readingQuizGenerator';

admin.initializeApp();

type ClaimWeeklyBossPayload = {
  deviceSessionId?: unknown;
  deviceLabel?: unknown;
  bossId?: unknown;
  displayName?: unknown;
  photoUrl?: unknown;
  rankAtCompletion?: unknown;
};

type ClaimSeasonRewardPayload = {
  seasonKey?: unknown;
};

type StartPromotionExamPayload = {
  snapshot?: unknown;
};

type ConfirmPromotionPayload = {
  snapshot?: unknown;
};

type SeasonBracketLeaderboardPayload = {
  seasonKey?: unknown;
  rankBracket?: unknown;
  limit?: unknown;
};

type CompetitiveRankPayload = {
  snapshot?: unknown;
  exam?: unknown;
  seasonReward?: unknown;
};

type CompetitiveIntegrityPayload = {
  integrity?: unknown;
};

type CompetitiveSyncSourcePayload = {
  source?: unknown;
};

type CompetitiveIntegritySourcePayload = {
  source?: unknown;
};

type ActiveSessionPayload = {
  deviceSessionId?: unknown;
  deviceLabel?: unknown;
};

type PlayerProfileSyncPayload = {
  deviceSessionId?: unknown;
  source?: unknown;
};

type QuestInventorySyncPayload = {
  deviceSessionId?: unknown;
  source?: unknown;
};

type UpdateProfileSettingsPayload = {
  deviceSessionId?: unknown;
  name?: unknown;
  primaryFocus?: unknown;
  hasCompletedOnboarding?: unknown;
  lastResetDate?: unknown;
};

type AllocateAttributePointPayload = {
  deviceSessionId?: unknown;
  attribute?: unknown;
};

type PersonalQuestCommandPayload = {
  deviceSessionId?: unknown;
  questId?: unknown;
  quest?: unknown;
};

type CompetitiveQuestSessionPayload = {
  deviceSessionId?: unknown;
  deviceLabel?: unknown;
  questId?: unknown;
  templateCatalogId?: unknown;
  title?: unknown;
  templateType?: unknown;
  verificationMode?: unknown;
  targetDurationMinutes?: unknown;
  xpReward?: unknown;
  rewardAttribute?: unknown;
  verificationStartedAt?: unknown;
  reflectionAnswer?: unknown;
  evidence?: unknown;
};

type StartReadingQuizPayload = {
  deviceSessionId?: unknown;
  deviceLabel?: unknown;
  questId?: unknown;
  templateCatalogId?: unknown;
  topic?: unknown;
};

type ValidatedSeasonReward = NonNullable<
  ReturnType<typeof validateSeasonRewardPayload>
>;

type CompetitiveSource = ReturnType<typeof validateCompetitiveSourcePayload>;
type CompetitiveIntegritySource = ReturnType<
  typeof validateCompetitiveIntegritySourcePayload
>;

const COMPETITIVE_SYNC_SCHEMA_VERSION = 3;
const PLAYER_PROFILE_SYNC_SCHEMA_VERSION = 1;
const QUEST_INVENTORY_SYNC_SCHEMA_VERSION = 1;
const ACTIVE_SESSION_LEASE_MS = 5 * 60 * 1000;
const CALLABLE_OPTIONS = {
  region: 'southamerica-east1',
};
type ServerRankStatus =
  | 'secure'
  | 'warning'
  | 'critical'
  | 'promotionReady'
  | 'demoted';

type ServerTrustBand = 'high' | 'stable' | 'attention' | 'restricted';

type ServerQuestIntegritySource = {
  title: string;
  xpReward: number;
  isCompetitive: boolean;
  countsTowardCompetitive: boolean;
  isCompleted: boolean;
  completedAt: admin.firestore.Timestamp | null;
};

type ServerCompetitiveQuestDefinition = {
  id: string;
  title: string;
  templateType: string;
  verificationMode: string;
  targetDurationMinutes: number;
  xpReward: number;
  rewardAttribute: string;
  verificationRequirement: ServerCompetitiveVerificationRequirement;
};

function isValidSyncSource(value: string): boolean {
  return ['client', 'debug', 'backend'].includes(value);
}

function isValidSeasonRewardClaimStatus(value: string): boolean {
  return ['locked', 'readyToClaim', 'claimed'].includes(value);
}

function isValidTrustBand(value: string): boolean {
  return ['high', 'stable', 'attention', 'restricted'].includes(value);
}

function isValidRankEventType(value: string): boolean {
  return [
    'routine',
    'warning',
    'perfectWeek',
    'promotionUnlocked',
    'reconquestUnlocked',
    'promotionConfirmed',
    'demotionApplied',
  ].includes(value);
}

function isValidExamStatus(value: string): boolean {
  return ['inProgress', 'passed', 'failed', 'promoted'].includes(value);
}

function isValidExamMode(value: string): boolean {
  return ['ascension', 'reconquest'].includes(value);
}

function validateSnapshotPayload(snapshot: unknown) {
  if (!snapshot || typeof snapshot !== 'object') {
    throw new HttpsError('invalid-argument', 'snapshot obrigatorio.');
  }

  const data = snapshot as Record<string, unknown>;
  const currentRank = normalizeRank(data.currentRank);
  const peakRank = normalizeRank(data.peakRank);
  const highestEligibleRank = normalizeRank(data.highestEligibleRank);
  const promotionTargetRank = data.promotionTargetRank == null ? null : normalizeRank(data.promotionTargetRank);
  const eventType = ensureString(data.eventType, 'eventType', 32);
  const advancementMode =
    data.advancementMode == null ? null : ensureString(data.advancementMode, 'advancementMode', 32);
  const syncSource = normalizeSyncSource(data.syncSource);

  if (!['E', 'D', 'C', 'B', 'A', 'S'].includes(currentRank)) {
    throw new HttpsError('invalid-argument', 'currentRank invalido.');
  }
  if (!['E', 'D', 'C', 'B', 'A', 'S'].includes(peakRank)) {
    throw new HttpsError('invalid-argument', 'peakRank invalido.');
  }
  if (!['E', 'D', 'C', 'B', 'A', 'S'].includes(highestEligibleRank)) {
    throw new HttpsError('invalid-argument', 'highestEligibleRank invalido.');
  }
  if (promotionTargetRank && !['E', 'D', 'C', 'B', 'A', 'S'].includes(promotionTargetRank)) {
    throw new HttpsError('invalid-argument', 'promotionTargetRank invalido.');
  }
  if (!isValidRankEventType(eventType)) {
    throw new HttpsError('invalid-argument', 'eventType invalido.');
  }
  if (advancementMode && !isValidExamMode(advancementMode)) {
    throw new HttpsError('invalid-argument', 'advancementMode invalido.');
  }
  if (!isValidSyncSource(syncSource)) {
    throw new HttpsError('invalid-argument', 'syncSource invalido.');
  }

  return {
    currentRank,
    peakRank,
    highestEligibleRank,
    weekKey: ensureString(data.weekKey, 'weekKey', 24),
    activeDays: ensureInt(data.activeDays, 'activeDays', 0),
    requiredActiveDays: ensureInt(data.requiredActiveDays, 'requiredActiveDays', 0),
    requiresBossClear: ensureBool(data.requiresBossClear, 'requiresBossClear'),
    bossCompleted: ensureBool(data.bossCompleted, 'bossCompleted'),
    status: ensureString(data.status, 'status', 32),
    demotionStrikes: ensureInt(data.demotionStrikes, 'demotionStrikes', 0),
    promotionReady: ensureBool(data.promotionReady, 'promotionReady'),
    promotionTargetRank,
    targetRequiredLevel: ensureInt(data.targetRequiredLevel, 'targetRequiredLevel', 1),
    targetLevelGateMet: ensureBool(data.targetLevelGateMet, 'targetLevelGateMet'),
    advancementMode,
    eventType,
    summary: ensureString(data.summary, 'summary', 240),
    detail: ensureString(data.detail, 'detail', 500),
    syncSchemaVersion: ensureInt(data.syncSchemaVersion, 'syncSchemaVersion', 1),
    syncSource,
    updatedAt: ensureTimestamp(data.updatedAt, 'updatedAt'),
  };
}

function validateExamPayload(exam: unknown) {
  if (exam == null) return null;
  if (typeof exam !== 'object') {
    throw new HttpsError('invalid-argument', 'exam invalido.');
  }

  const data = exam as Record<string, unknown>;
  const sourceRank = normalizeRank(data.sourceRank);
  const targetRank = normalizeRank(data.targetRank);
  const status = ensureString(data.status, 'status', 32);
  const mode = ensureString(data.mode, 'mode', 32);
  const syncSource = normalizeSyncSource(data.syncSource);

  if (!['E', 'D', 'C', 'B', 'A', 'S'].includes(sourceRank) ||
      !['E', 'D', 'C', 'B', 'A', 'S'].includes(targetRank)) {
    throw new HttpsError('invalid-argument', 'Ranks do exame invalidos.');
  }
  if (!isValidSyncSource(syncSource)) {
    throw new HttpsError('invalid-argument', 'syncSource invalido.');
  }
  if (!isValidExamStatus(status)) {
    throw new HttpsError('invalid-argument', 'status invalido.');
  }
  if (!isValidExamMode(mode)) {
    throw new HttpsError('invalid-argument', 'mode invalido.');
  }

  return {
    sourceRank,
    targetRank,
    sourceWeekKey: ensureString(data.sourceWeekKey, 'sourceWeekKey', 24),
    status,
    mode,
    baselineActiveDays: ensureInt(data.baselineActiveDays, 'baselineActiveDays', 0),
    requiredExtraActiveDays: ensureInt(data.requiredExtraActiveDays, 'requiredExtraActiveDays', 0),
    bossRequired: ensureBool(data.bossRequired, 'bossRequired'),
    requiredLevel: ensureInt(data.requiredLevel, 'requiredLevel', 1),
    startedAt: ensureTimestamp(data.startedAt, 'startedAt'),
    expiresAt: ensureTimestamp(data.expiresAt, 'expiresAt'),
    syncSchemaVersion: ensureInt(data.syncSchemaVersion, 'syncSchemaVersion', 1),
    syncSource,
    resolvedAt: data.resolvedAt == null ? null : ensureTimestamp(data.resolvedAt, 'resolvedAt'),
  };
}

function validateSeasonRewardPayload(seasonReward: unknown) {
  if (seasonReward == null) return null;
  if (typeof seasonReward !== 'object') {
    throw new HttpsError('invalid-argument', 'seasonReward invalido.');
  }

  const data = seasonReward as Record<string, unknown>;
  const currentRankBracket = normalizeRank(data.currentRankBracket);
  const syncSource = normalizeSyncSource(data.syncSource);

  if (!['E', 'D', 'C', 'B', 'A', 'S'].includes(currentRankBracket)) {
    throw new HttpsError('invalid-argument', 'currentRankBracket invalido.');
  }
  if (!isValidSyncSource(syncSource)) {
    throw new HttpsError('invalid-argument', 'syncSource invalido.');
  }
  const claimStatus = ensureString(data.claimStatus, 'claimStatus', 32);
  if (!isValidSeasonRewardClaimStatus(claimStatus)) {
    throw new HttpsError('invalid-argument', 'claimStatus invalido.');
  }

  return {
    seasonKey: ensureString(data.seasonKey, 'seasonKey', 24),
    seasonLabel: ensureString(data.seasonLabel, 'seasonLabel', 24),
    currentRankBracket,
    rewardTierLabel: ensureString(data.rewardTierLabel, 'rewardTierLabel', 32),
    rewardStatusLabel: ensureString(data.rewardStatusLabel, 'rewardStatusLabel', 32),
    rewardUnlocked: ensureBool(data.rewardUnlocked, 'rewardUnlocked'),
    rewardName: ensureString(data.rewardName, 'rewardName', 80),
    rewardBadgeLabel: ensureString(data.rewardBadgeLabel, 'rewardBadgeLabel', 40),
    rewardTitleLabel: ensureString(data.rewardTitleLabel, 'rewardTitleLabel', 60),
    rewardBonusLabel: ensureString(data.rewardBonusLabel, 'rewardBonusLabel', 240),
    recordedWeeks: ensureInt(data.recordedWeeks, 'recordedWeeks', 0),
    secureWeeks: ensureInt(data.secureWeeks, 'secureWeeks', 0),
    seasonScore: ensureInt(data.seasonScore, 'seasonScore', -999),
    scoreBandLabel: ensureString(data.scoreBandLabel, 'scoreBandLabel', 24),
    clearRateLabel: ensureString(data.clearRateLabel, 'clearRateLabel', 64),
    playerStandingLabel: ensureString(data.playerStandingLabel, 'playerStandingLabel', 64),
    spotlightLabel: ensureString(data.spotlightLabel, 'spotlightLabel', 240),
    resetLabel: ensureString(data.resetLabel, 'resetLabel', 40),
    claimStatus,
    syncSchemaVersion: ensureInt(data.syncSchemaVersion, 'syncSchemaVersion', 1),
    syncSource,
    updatedAt: ensureTimestamp(data.updatedAt, 'updatedAt'),
    claimedAt: data.claimedAt == null ? null : ensureTimestamp(data.claimedAt, 'claimedAt'),
  };
}

function validateIntegrityPayload(integrity: unknown) {
  if (integrity == null) return null;
  if (typeof integrity !== 'object') {
    throw new HttpsError('invalid-argument', 'integrity invalida.');
  }

  const data = integrity as Record<string, unknown>;
  const trustBand = ensureString(data.trustBand, 'trustBand', 32);
  const syncSource = normalizeSyncSource(data.syncSource);

  if (!isValidTrustBand(trustBand)) {
    throw new HttpsError('invalid-argument', 'trustBand invalido.');
  }
  if (!isValidSyncSource(syncSource)) {
    throw new HttpsError('invalid-argument', 'syncSource invalido.');
  }

  return {
    weekKey: ensureString(data.weekKey, 'weekKey', 24),
    trustScore: ensureInt(data.trustScore, 'trustScore', 0),
    trustBand,
    weeklyActiveDays: ensureInt(data.weeklyActiveDays, 'weeklyActiveDays', 0),
    weeklyCompetitiveDays: ensureInt(
      data.weeklyCompetitiveDays,
      'weeklyCompetitiveDays',
      0,
    ),
    personalQuestCompletionsToday: ensureInt(
      data.personalQuestCompletionsToday,
      'personalQuestCompletionsToday',
      0,
    ),
    competitiveQuestCompletionsToday: ensureInt(
      data.competitiveQuestCompletionsToday,
      'competitiveQuestCompletionsToday',
      0,
    ),
    personalXpToday: ensureInt(data.personalXpToday, 'personalXpToday', 0),
    competitiveXpToday: ensureInt(
      data.competitiveXpToday,
      'competitiveXpToday',
      0,
    ),
    suspiciousPatternCount: ensureInt(
      data.suspiciousPatternCount,
      'suspiciousPatternCount',
      0,
    ),
    summary: ensureString(data.summary, 'summary', 80),
    detail: ensureString(data.detail, 'detail', 500),
    syncSchemaVersion: ensureInt(data.syncSchemaVersion, 'syncSchemaVersion', 1),
    syncSource,
    updatedAt: ensureTimestamp(data.updatedAt, 'updatedAt'),
  };
}

function validateCompetitiveSourcePayload(source: unknown) {
  if (!source || typeof source !== 'object') {
    throw new HttpsError('invalid-argument', 'source obrigatorio.');
  }

  const data = source as Record<string, unknown>;
  return {
    playerLevel: ensureInt(data.playerLevel, 'playerLevel', 1),
    activityHistory: ensureTimestampArray(data.activityHistory, 'activityHistory'),
    competitiveActivityHistory: ensureTimestampArray(
      data.competitiveActivityHistory,
      'competitiveActivityHistory',
    ),
  };
}

function validateCompetitiveIntegritySourcePayload(source: unknown) {
  if (!source || typeof source !== 'object') {
    throw new HttpsError('invalid-argument', 'source obrigatorio.');
  }

  const data = source as Record<string, unknown>;
  const rawQuests = data.quests;
  if (!Array.isArray(rawQuests)) {
    throw new HttpsError('invalid-argument', 'quests invalidas.');
  }

  const quests = rawQuests.map((entry, index) => {
    if (!entry || typeof entry !== 'object') {
      throw new HttpsError('invalid-argument', `quest[${index}] invalida.`);
    }
    const quest = entry as Record<string, unknown>;
    return {
      title: ensureString(quest.title, `quest[${index}].title`, 120),
      xpReward: ensureInt(quest.xpReward, `quest[${index}].xpReward`, 0),
      isCompetitive: ensureBool(quest.isCompetitive, `quest[${index}].isCompetitive`),
      countsTowardCompetitive: ensureBool(
        quest.countsTowardCompetitive,
        `quest[${index}].countsTowardCompetitive`,
      ),
      isCompleted: ensureBool(quest.isCompleted, `quest[${index}].isCompleted`),
      completedAt: quest.completedAt == null
        ? null
        : ensureTimestamp(quest.completedAt, `quest[${index}].completedAt`),
    } as ServerQuestIntegritySource;
  });

  return {
    activityHistory: ensureTimestampArray(data.activityHistory, 'activityHistory'),
    competitiveActivityHistory: ensureTimestampArray(
      data.competitiveActivityHistory,
      'competitiveActivityHistory',
    ),
    quests,
  };
}

function competitiveQuestDefinitions(): ServerCompetitiveQuestDefinition[] {
  const timer25: ServerCompetitiveVerificationRequirement = {
    evidenceType: 'timedFocus',
    minimumTrustTier: 2,
    minimumDurationMinutes: 25,
    minimumDistanceMeters: 0,
    minimumQuizScore: 0,
    allowedProviders: ['appTimer', 'mockEvidence'],
  };
  const timer20: ServerCompetitiveVerificationRequirement = {
    evidenceType: 'timedFocus',
    minimumTrustTier: 2,
    minimumDurationMinutes: 20,
    minimumDistanceMeters: 0,
    minimumQuizScore: 0,
    allowedProviders: ['appTimer', 'mockEvidence'],
  };
  const timer30: ServerCompetitiveVerificationRequirement = {
    evidenceType: 'timedFocus',
    minimumTrustTier: 2,
    minimumDurationMinutes: 30,
    minimumDistanceMeters: 0,
    minimumQuizScore: 0,
    allowedProviders: ['appTimer', 'mockEvidence'],
  };
  const reading20: ServerCompetitiveVerificationRequirement = {
    evidenceType: 'readingComprehension',
    minimumTrustTier: 2,
    minimumDurationMinutes: 20,
    minimumDistanceMeters: 0,
    minimumQuizScore: 70,
    allowedProviders: ['mockEvidence'],
  };
  const reading15: ServerCompetitiveVerificationRequirement = {
    evidenceType: 'readingComprehension',
    minimumTrustTier: 2,
    minimumDurationMinutes: 15,
    minimumDistanceMeters: 0,
    minimumQuizScore: 70,
    allowedProviders: ['mockEvidence'],
  };
  const study20: ServerCompetitiveVerificationRequirement = {
    evidenceType: 'studySession',
    minimumTrustTier: 2,
    minimumDurationMinutes: 20,
    minimumDistanceMeters: 0,
    minimumQuizScore: 70,
    allowedProviders: ['mockEvidence'],
  };
  const study30: ServerCompetitiveVerificationRequirement = {
    evidenceType: 'studySession',
    minimumTrustTier: 2,
    minimumDurationMinutes: 30,
    minimumDistanceMeters: 0,
    minimumQuizScore: 0,
    allowedProviders: ['appTimer', 'mockEvidence'],
  };
  const run2k: ServerCompetitiveVerificationRequirement = {
    evidenceType: 'runningDistance',
    minimumTrustTier: 2,
    minimumDurationMinutes: 10,
    minimumDistanceMeters: 2000,
    minimumQuizScore: 0,
    allowedProviders: ['healthConnect', 'mockEvidence'],
  };
  const run5k: ServerCompetitiveVerificationRequirement = {
    evidenceType: 'runningDistance',
    minimumTrustTier: 3,
    minimumDurationMinutes: 20,
    minimumDistanceMeters: 5000,
    minimumQuizScore: 0,
    allowedProviders: ['healthConnect', 'mockEvidence'],
  };
  const workout20: ServerCompetitiveVerificationRequirement = {
    evidenceType: 'workoutSession',
    minimumTrustTier: 2,
    minimumDurationMinutes: 20,
    minimumDistanceMeters: 0,
    minimumQuizScore: 0,
    allowedProviders: ['healthConnect', 'appTimer', 'mockEvidence'],
  };

  return [
    {
      id: 'run-2k-controlled',
      title: 'Corrida controlada de 2 km',
      templateType: 'runningSession',
      verificationMode: 'timer',
      targetDurationMinutes: 10,
      xpReward: 35,
      rewardAttribute: 'agility',
      verificationRequirement: run2k,
    },
    {
      id: 'run-5k-ranked',
      title: 'Corrida ranqueada de 5 km',
      templateType: 'runningSession',
      verificationMode: 'timer',
      targetDurationMinutes: 20,
      xpReward: 55,
      rewardAttribute: 'vitality',
      verificationRequirement: run5k,
    },
    {
      id: 'bodyweight-20',
      title: 'Treino corporal de 20 minutos',
      templateType: 'workoutSession',
      verificationMode: 'timer',
      targetDurationMinutes: 20,
      xpReward: 35,
      rewardAttribute: 'strength',
      verificationRequirement: workout20,
    },
    {
      id: 'focus-25',
      title: 'Sessao de foco de 25 minutos',
      templateType: 'focusSession',
      verificationMode: 'timer',
      targetDurationMinutes: 25,
      xpReward: 30,
      rewardAttribute: 'agility',
      verificationRequirement: timer25,
    },
    {
      id: 'reading-20',
      title: 'Leitura de 20 minutos',
      templateType: 'readingSession',
      verificationMode: 'timerWithReflection',
      targetDurationMinutes: 20,
      xpReward: 30,
      rewardAttribute: 'intelligence',
      verificationRequirement: reading20,
    },
    {
      id: 'study-30',
      title: 'Estudo profundo de 30 minutos',
      templateType: 'studySession',
      verificationMode: 'timer',
      targetDurationMinutes: 30,
      xpReward: 35,
      rewardAttribute: 'intelligence',
      verificationRequirement: study30,
    },
    {
      id: 'reading-15-training',
      title: 'Revisao de treino de 15 minutos',
      templateType: 'readingSession',
      verificationMode: 'timerWithReflection',
      targetDurationMinutes: 15,
      xpReward: 25,
      rewardAttribute: 'intelligence',
      verificationRequirement: reading15,
    },
    {
      id: 'focus-20',
      title: 'Sessao de foco de 20 minutos',
      templateType: 'focusSession',
      verificationMode: 'timer',
      targetDurationMinutes: 20,
      xpReward: 25,
      rewardAttribute: 'vitality',
      verificationRequirement: timer20,
    },
    {
      id: 'reading-15',
      title: 'Leitura ou revisao de 15 minutos',
      templateType: 'readingSession',
      verificationMode: 'timerWithReflection',
      targetDurationMinutes: 15,
      xpReward: 25,
      rewardAttribute: 'intelligence',
      verificationRequirement: reading15,
    },
    {
      id: 'focus-30',
      title: 'Bloco de foco de 30 minutos',
      templateType: 'focusSession',
      verificationMode: 'timer',
      targetDurationMinutes: 30,
      xpReward: 35,
      rewardAttribute: 'agility',
      verificationRequirement: timer30,
    },
    {
      id: 'study-20',
      title: 'Revisao de 20 minutos',
      templateType: 'studySession',
      verificationMode: 'timerWithReflection',
      targetDurationMinutes: 20,
      xpReward: 30,
      rewardAttribute: 'intelligence',
      verificationRequirement: study20,
    },
    {
      id: 'study-20-recall',
      title: 'Revisao ativa de 20 minutos',
      templateType: 'studySession',
      verificationMode: 'timerWithReflection',
      targetDurationMinutes: 20,
      xpReward: 30,
      rewardAttribute: 'intelligence',
      verificationRequirement: study20,
    },
  ];
}

function userDocRef(db: admin.firestore.Firestore, uid: string) {
  return db.collection('users').doc(uid);
}

function userCollectionRef(
  db: admin.firestore.Firestore,
  uid: string,
  collectionPath: string,
) {
  return userDocRef(db, uid).collection(collectionPath);
}

function activeSessionRef(db: admin.firestore.Firestore, uid: string) {
  return userCollectionRef(db, uid, 'session').doc('current');
}

function ensureActiveSessionPayload(payload: unknown) {
  if (!payload || typeof payload !== 'object') {
    throw new HttpsError('invalid-argument', 'Payload de sessao invalido.');
  }

  const data = payload as Record<string, unknown>;
  return {
    deviceSessionId: ensureString(data.deviceSessionId, 'deviceSessionId', 120),
    deviceLabel: ensureOptionalString(data.deviceLabel, 'deviceLabel', 120) ?? 'device',
  };
}

async function assertActiveSession(
  db: admin.firestore.Firestore,
  uid: string,
  deviceSessionId: string,
) {
  const snapshot = await activeSessionRef(db, uid).get();
  const data = snapshot.data();
  if (!snapshot.exists || !data) {
    throw new HttpsError(
      'failed-precondition',
      'Sessao ativa nao encontrada.',
      {reason: 'active_session_missing'},
    );
  }

  const currentSessionId = typeof data.deviceSessionId === 'string' ? data.deviceSessionId : '';
  const expiresAt = data.expiresAt instanceof admin.firestore.Timestamp ? data.expiresAt : null;
  const now = admin.firestore.Timestamp.now();

  if (!currentSessionId || currentSessionId !== deviceSessionId || !expiresAt || expiresAt.toMillis() <= now.toMillis()) {
    throw new HttpsError(
      'failed-precondition',
      'Sessao ativa em outro dispositivo.',
      {reason: 'active_session_conflict'},
    );
  }
}

function validatePlayerProfileSourcePayload(source: unknown): ServerPlayerProfileSource {
  if (!source || typeof source !== 'object') {
    throw new HttpsError('invalid-argument', 'source obrigatorio.');
  }

  const data = source as Record<string, unknown>;

  if (!data.attributes || typeof data.attributes !== 'object') {
    throw new HttpsError('invalid-argument', 'attributes invalidos.');
  }
  const attributes = data.attributes as Record<string, unknown>;

  return {
    name: ensureString(data.name, 'name', 40),
    attributes: {
      strength: ensureInt(attributes.strength, 'attributes.strength', 10),
      intelligence: ensureInt(attributes.intelligence, 'attributes.intelligence', 10),
      vitality: ensureInt(attributes.vitality, 'attributes.vitality', 10),
      agility: ensureInt(attributes.agility, 'attributes.agility', 10),
    },
    lastResetDate: ensureTimestamp(data.lastResetDate, 'lastResetDate'),
    primaryFocus: ensurePrimaryFocus(data.primaryFocus, 'primaryFocus'),
    hasCompletedOnboarding: ensureBool(
      data.hasCompletedOnboarding,
      'hasCompletedOnboarding',
    ),
    quests: validateQuestInventorySourcePayload(source, competitiveQuestDefinitions()).quests,
  };
}

function profileDocRef(db: admin.firestore.Firestore, uid: string) {
  return userCollectionRef(db, uid, 'profile').doc('current');
}

function questDocRef(
  db: admin.firestore.Firestore,
  uid: string,
  questId: string,
) {
  return userCollectionRef(db, uid, 'quests').doc(questId);
}

function questsCollectionRef(db: admin.firestore.Firestore, uid: string) {
  return userCollectionRef(db, uid, 'quests');
}

function questsMetaDocRef(db: admin.firestore.Firestore, uid: string) {
  return userCollectionRef(db, uid, 'quests_meta').doc('current');
}

function questCompletionsCollectionRef(
  db: admin.firestore.Firestore,
  uid: string,
) {
  return userCollectionRef(db, uid, 'quest_completions');
}

function weeklyBossClaimsCollectionRef(
  db: admin.firestore.Firestore,
  uid: string,
) {
  return userCollectionRef(db, uid, 'weekly_boss_claims');
}

function attributeAllocationsCollectionRef(
  db: admin.firestore.Firestore,
  uid: string,
) {
  return userCollectionRef(db, uid, 'attribute_allocations');
}

function competitiveProgressionDocRef(db: admin.firestore.Firestore, uid: string) {
  return userCollectionRef(db, uid, 'progression').doc('current');
}

function competitiveProgressionHistoryDocRef(
  db: admin.firestore.Firestore,
  uid: string,
  weekKey: string,
) {
  return userCollectionRef(db, uid, 'progression_history').doc(weekKey);
}

function competitiveProgressionHistoryCollectionRef(
  db: admin.firestore.Firestore,
  uid: string,
) {
  return userCollectionRef(db, uid, 'progression_history');
}

function promotionExamDocRef(db: admin.firestore.Firestore, uid: string) {
  return userCollectionRef(db, uid, 'promotion_exam').doc('current');
}

function seasonRewardDocRef(db: admin.firestore.Firestore, uid: string) {
  return userCollectionRef(db, uid, 'season_rewards').doc('current');
}

function seasonRewardHistoryDocRef(
  db: admin.firestore.Firestore,
  uid: string,
  seasonKey: string,
) {
  return userCollectionRef(db, uid, 'season_reward_history').doc(seasonKey);
}

function seasonLegacyDocRef(
  db: admin.firestore.Firestore,
  uid: string,
  seasonKey: string,
) {
  return userCollectionRef(db, uid, 'season_legacy').doc(seasonKey);
}

function seasonProfileDocRef(db: admin.firestore.Firestore, uid: string) {
  return userCollectionRef(db, uid, 'season_profile').doc('current');
}

function competitiveIntegrityDocRef(db: admin.firestore.Firestore, uid: string) {
  return userCollectionRef(db, uid, 'integrity').doc('current');
}

function competitiveIntegrityHistoryDocRef(
  db: admin.firestore.Firestore,
  uid: string,
  weekKey: string,
) {
  return userCollectionRef(db, uid, 'integrity_history').doc(weekKey);
}

function competitiveQuestSessionDocRef(
  db: admin.firestore.Firestore,
  uid: string,
  attemptId: string,
) {
  return userCollectionRef(db, uid, 'competitive_quest_sessions').doc(attemptId);
}

function competitiveQuestGrantDocRef(
  db: admin.firestore.Firestore,
  uid: string,
  attemptId: string,
) {
  return userCollectionRef(db, uid, 'competitive_quest_grants').doc(attemptId);
}

function competitiveQuestGrantsCollectionRef(
  db: admin.firestore.Firestore,
  uid: string,
) {
  return userCollectionRef(db, uid, 'competitive_quest_grants');
}

function competitiveQuestEvidenceDocRef(
  db: admin.firestore.Firestore,
  uid: string,
  attemptId: string,
) {
  return userCollectionRef(db, uid, 'competitive_quest_evidence').doc(attemptId);
}

function readingQuizAttemptDocRef(
  db: admin.firestore.Firestore,
  uid: string,
  quizId: string,
) {
  return userCollectionRef(db, uid, 'reading_quiz_attempts').doc(quizId);
}

function validateProfileSettingsPayload(payload: unknown) {
  if (!payload || typeof payload !== 'object') {
    throw new HttpsError('invalid-argument', 'Payload de perfil invalido.');
  }

  const data = payload as Record<string, unknown>;
  return {
    session: ensureActiveSessionPayload(payload),
    name: ensureString(data.name, 'name', 40),
    primaryFocus: ensurePrimaryFocus(data.primaryFocus, 'primaryFocus'),
    hasCompletedOnboarding: ensureBool(
      data.hasCompletedOnboarding,
      'hasCompletedOnboarding',
    ),
    lastResetDate: ensureTimestamp(data.lastResetDate, 'lastResetDate'),
  };
}

function validateStartReadingQuizPayload(payload: unknown) {
  if (!payload || typeof payload !== 'object') {
    throw new HttpsError('invalid-argument', 'Payload de quiz invalido.');
  }

  const data = payload as Record<string, unknown>;
  const questId = ensureString(data.questId, 'questId', 120);
  const templateCatalogId = data.templateCatalogId == null
    ? null
    : ensureString(data.templateCatalogId, 'templateCatalogId', 120);
  const topic = data.topic == null
    ? 'leitura'
    : ensureString(data.topic, 'topic', 120);

  return {
    session: ensureActiveSessionPayload(payload),
    questId,
    templateCatalogId,
    topic,
  };
}

function validateAllocateAttributePointPayload(payload: unknown) {
  if (!payload || typeof payload !== 'object') {
    throw new HttpsError('invalid-argument', 'Payload de atributo invalido.');
  }

  const data = payload as Record<string, unknown>;
  return {
    session: ensureActiveSessionPayload(payload),
    attribute: ensureAttributeName(data.attribute, 'attribute'),
  };
}

function validatePersonalQuestCommandPayload(payload: unknown) {
  if (!payload || typeof payload !== 'object') {
    throw new HttpsError('invalid-argument', 'Payload de quest pessoal invalido.');
  }

  const data = payload as Record<string, unknown>;
  const questId = ensureString(data.questId, 'questId', 120);
  return {
    session: ensureActiveSessionPayload(payload),
    questId,
    quest: data.quest == null
      ? null
      : validateSingleQuestSourcePayload(data.quest, questId, competitiveQuestDefinitions()),
  };
}

function validateCompetitiveQuestSessionPayload(payload: unknown) {
  if (!payload || typeof payload !== 'object') {
    throw new HttpsError('invalid-argument', 'Payload da quest competitiva invalido.');
  }

  const data = payload as Record<string, unknown>;
  const questId = ensureString(data.questId, 'questId', 120);
  const templateCatalogId =
    data.templateCatalogId == null ? null : ensureString(data.templateCatalogId, 'templateCatalogId', 80);
  const title = ensureString(data.title, 'title', 120);
  const templateType = ensureString(data.templateType, 'templateType', 64);
  const verificationMode = ensureString(data.verificationMode, 'verificationMode', 64);
  const targetDurationMinutes = ensureInt(
    data.targetDurationMinutes,
    'targetDurationMinutes',
    0,
  );
  const xpReward = ensureInt(data.xpReward, 'xpReward', 0);
  const rewardAttribute = ensureString(data.rewardAttribute, 'rewardAttribute', 32);
  const verificationStartedAt = ensureTimestampOrNull(
    data.verificationStartedAt,
    'verificationStartedAt',
  );
  const reflectionAnswer =
    data.reflectionAnswer == null ? null : ensureString(data.reflectionAnswer, 'reflectionAnswer', 500);

  const definitions = competitiveQuestDefinitions();
  const definition = templateCatalogId == null
    ? definitions.find((entry) =>
      entry.title === title &&
      entry.templateType === templateType &&
      entry.verificationMode === verificationMode &&
      entry.targetDurationMinutes === targetDurationMinutes &&
      entry.xpReward === xpReward &&
      entry.rewardAttribute === rewardAttribute,
    )
    : definitions.find((entry) =>
      entry.id === templateCatalogId &&
      entry.templateType === templateType &&
      entry.verificationMode === verificationMode &&
      entry.targetDurationMinutes === targetDurationMinutes &&
      entry.xpReward === xpReward &&
      entry.rewardAttribute === rewardAttribute,
    );

  if (!definition) {
    throw new HttpsError(
      'permission-denied',
      'Quest competitiva fora do catalogo oficial.',
    );
  }

  return {
    questId,
    templateCatalogId: definition.id,
    title: definition.title,
    templateType,
    verificationMode,
    targetDurationMinutes,
    xpReward,
    rewardAttribute,
    verificationRequirement: definition.verificationRequirement,
    verificationStartedAt,
    reflectionAnswer,
    evidence: data.evidence == null ? null : validateQuestEvidencePayload(data.evidence, questId),
  };
}

function promotionModeFor(currentRank: string, peakRank: string): string {
  const nextRank = rankAfter(currentRank);
  if (!nextRank) return 'ascension';
  return rankOrder(nextRank) <= rankOrder(peakRank) ? 'reconquest' : 'ascension';
}

function isMaintenanceMet(
  activeDays: number,
  requiredActiveDays: number,
  requiresBossClear: boolean,
  bossCompleted: boolean,
): boolean {
  return activeDays >= requiredActiveDays && (!requiresBossClear || bossCompleted);
}

function isPromotionReady(
  currentRank: string,
  activeDays: number,
  bossCompleted: boolean,
  playerLevel: number,
): boolean {
  const nextRank = rankAfter(currentRank);
  if (!nextRank) return false;
  const nextRule = rankRequirements(nextRank);
  return (
    playerLevel >= nextRule.minimumLevel &&
    activeDays >= nextRule.requiredActiveDays &&
    (!nextRule.requiresBossClear || bossCompleted)
  );
}

function rankEventTypeForSnapshot(
  status: ServerRankStatus,
  activeDays: number,
  requiredActiveDays: number,
  bossCompleted: boolean,
  advancementMode: string | null,
): string {
  if (status === 'demoted') return 'demotionApplied';
  if (status === 'promotionReady') {
    return advancementMode === 'reconquest' ? 'reconquestUnlocked' : 'promotionUnlocked';
  }
  if (status === 'warning' || status === 'critical') return 'warning';
  if (activeDays >= requiredActiveDays + 1 && bossCompleted) return 'perfectWeek';
  return 'routine';
}

function summaryForRankStatus(
  status: ServerRankStatus,
  currentRank: string,
  nextRank: string | null,
  advancementMode: string | null,
): string {
  switch (status) {
  case 'secure':
    return `Rank ${currentRank} estabilizado.`;
  case 'warning':
    return `Rank ${currentRank} em alerta.`;
  case 'critical':
    return `Rank ${currentRank} em risco real.`;
  case 'promotionReady':
    return advancementMode === 'reconquest'
      ? `Reconquista pronta para o rank ${nextRank ?? currentRank}.`
      : `Exame de promocao pronto para o rank ${nextRank ?? currentRank}.`;
  case 'demoted':
    return `Queda confirmada para o rank ${currentRank}.`;
  }
}

function detailForRankStatus(args: {
  status: ServerRankStatus;
  currentRank: string;
  peakRank: string;
  highestEligibleRank: string;
  currentRule: ReturnType<typeof rankRequirements>;
  activeDays: number;
  bossCompleted: boolean;
  demotionStrikes: number;
  nextRank: string | null;
  targetRequiredLevel: number;
  targetLevelGateMet: boolean;
  advancementMode: string | null;
}): string {
  const bossLine = args.currentRule.requiresBossClear
    ? args.bossCompleted
      ? 'Boss competitivo confirmado.'
      : 'Boss competitivo ainda pendente.'
    : 'Boss competitivo nao e exigido neste rank.';
  const levelLine = !args.nextRank
    ? 'Voce ja esta no topo do sistema.'
    : args.targetLevelGateMet
      ? `Seu level ja libera a tentativa do rank ${args.nextRank}.`
      : `Seu level atual ainda nao libera o rank ${args.nextRank}. Necessario: level ${args.targetRequiredLevel}.`;
  const reconquestLine = rankOrder(args.currentRank) < rankOrder(args.peakRank)
    ? `Seu pico historico e ${args.peakRank}. O sistema abriu uma rota de reconquista acelerada.`
    : `Seu teto atual por level chega ate o rank ${args.highestEligibleRank}.`;

  switch (args.status) {
  case 'secure':
    return `Voce garantiu ${args.activeDays}/${args.currentRule.requiredActiveDays} dias competitivos validados. ${bossLine} ${reconquestLine} ${levelLine}`;
  case 'warning':
    return `Voce tem ${args.activeDays}/${args.currentRule.requiredActiveDays} dias competitivos validados. Falhar esta semana deixa o sistema em pressao real. ${levelLine}`;
  case 'critical':
    return `Voce esta abaixo da manutencao do rank ${args.currentRank}. Strikes atuais: ${args.demotionStrikes}. ${bossLine}`;
  case 'promotionReady':
    return args.advancementMode === 'reconquest'
      ? `Voce sustentou o padrao com atividade competitiva validada para reconquistar o rank ${args.nextRank ?? args.currentRank}. O exame agora valida a retomada do seu pico historico.`
      : `Voce atingiu o padrao competitivo validado do proximo rank${args.nextRank == null ? '' : ` ${args.nextRank}`}. Agora falta transformar isso em exame de promocao.`;
  case 'demoted':
    return `A manutencao falhou por semanas seguidas. O sistema aplicou queda de rank para preservar a seriedade da progressao. Seu pico historico continua registrado em ${args.peakRank}.`;
  }
}

function evaluateCompetitiveRankFromSource(args: {
  playerLevel: number;
  competitiveActivityHistory: admin.firestore.Timestamp[];
  previousSnapshot: ReturnType<typeof validateSnapshotPayload> | null;
  now: Date;
}) {
  const weekKey = weekKeyForDate(args.now);
  const highestEligibleRank = playerRankForLevel(args.playerLevel);
  const seedRank = args.previousSnapshot?.currentRank ?? playerRankForLevel(args.playerLevel);
  const previousPeakRank =
    args.previousSnapshot?.peakRank ?? args.previousSnapshot?.currentRank ?? seedRank;
  const peakRank = higherRank(previousPeakRank, seedRank);
  const baseRule = rankRequirements(seedRank);
  const bossTargetDays = rankRequirements(seedRank).requiredActiveDays;
  const activeDaysBase = currentWeekDateKeys(args.competitiveActivityHistory, args.now).size;
  const bossCompletedBase = activeDaysBase >= bossTargetDays;
  const maintenanceMetBase = isMaintenanceMet(
    activeDaysBase,
    baseRule.requiredActiveDays,
    baseRule.requiresBossClear,
    bossCompletedBase,
  );
  const isNewWeek = !args.previousSnapshot || args.previousSnapshot.weekKey !== weekKey;

  let currentRank = seedRank;
  let demotionStrikes = args.previousSnapshot?.demotionStrikes ?? 0;
  let status: ServerRankStatus = 'secure';

  if (maintenanceMetBase) {
    demotionStrikes = 0;
  } else if (isNewWeek) {
    demotionStrikes += 1;
    if (demotionStrikes >= baseRule.maxFailedWeeksBeforeDemotion) {
      const previousRank = rankBefore(seedRank);
      if (previousRank) {
        currentRank = previousRank;
        demotionStrikes = 0;
        status = 'demoted';
      }
    }
  }

  const currentRule = rankRequirements(currentRank);
  const currentActiveDays = activeDaysBase;
  const currentBossCompleted = currentActiveDays >= currentRule.requiredActiveDays;
  const currentMaintenanceMet = isMaintenanceMet(
    currentActiveDays,
    currentRule.requiredActiveDays,
    currentRule.requiresBossClear,
    currentBossCompleted,
  );
  const nextRank = rankAfter(currentRank);
  const nextRule = nextRank ? rankRequirements(nextRank) : null;
  const nextBossCompleted = nextRule
    ? currentActiveDays >= nextRule.requiredActiveDays
    : false;
  const targetRequiredLevel = nextRule?.minimumLevel ?? args.playerLevel;
  const targetLevelGateMet = nextRule ? args.playerLevel >= nextRule.minimumLevel : true;
  const advancementMode = nextRank ? promotionModeFor(currentRank, peakRank) : null;

  if (status !== 'demoted') {
    const promotionReady = isPromotionReady(
      currentRank,
      currentActiveDays,
      nextBossCompleted,
      args.playerLevel,
    );
    if (promotionReady) {
      status = 'promotionReady';
    } else if (currentMaintenanceMet) {
      status = 'secure';
    } else {
      const missingDays = Math.max(0, currentRule.requiredActiveDays - currentActiveDays);
      const bossBlocked = currentRule.requiresBossClear && !currentBossCompleted;
      status = missingDays <= 1 && !bossBlocked ? 'warning' : 'critical';
    }
  }

  const eventType = rankEventTypeForSnapshot(
    status,
    currentActiveDays,
    currentRule.requiredActiveDays,
    currentBossCompleted,
    advancementMode,
  );

  return {
    currentRank,
    peakRank,
    highestEligibleRank,
    weekKey,
    activeDays: currentActiveDays,
    requiredActiveDays: currentRule.requiredActiveDays,
    requiresBossClear: currentRule.requiresBossClear,
    bossCompleted: currentBossCompleted,
    status,
    demotionStrikes,
    promotionReady: status === 'promotionReady',
    promotionTargetRank: nextRank,
    targetRequiredLevel,
    targetLevelGateMet,
    advancementMode,
    eventType,
    summary: summaryForRankStatus(status, currentRank, nextRank, advancementMode),
    detail: detailForRankStatus({
      status,
      currentRank,
      peakRank,
      highestEligibleRank,
      currentRule,
      activeDays: currentActiveDays,
      bossCompleted: currentBossCompleted,
      demotionStrikes,
      nextRank,
      targetRequiredLevel,
      targetLevelGateMet,
      advancementMode,
    }),
    syncSchemaVersion: COMPETITIVE_SYNC_SCHEMA_VERSION,
    syncSource: 'backend',
    updatedAt: admin.firestore.Timestamp.fromDate(args.now),
  };
}

function trustScoreFromSource(args: {
  weeklyActiveDays: number;
  weeklyCompetitiveDays: number;
  personalQuestCompletionsToday: number;
  competitiveQuestCompletionsToday: number;
  personalXpToday: number;
  competitiveXpToday: number;
  suspiciousPatternCount: number;
}) {
  let score = 78;
  score += args.weeklyCompetitiveDays * 4;
  score += Math.min(12, args.competitiveQuestCompletionsToday * 3);
  score += args.weeklyCompetitiveDays > 0 && args.weeklyCompetitiveDays >= args.weeklyActiveDays ? 6 : 0;
  score -= Math.max(0, args.personalQuestCompletionsToday - 3) * 4;
  score -= args.personalXpToday > args.competitiveXpToday && args.weeklyCompetitiveDays === 0 ? 10 : 0;
  score -= args.suspiciousPatternCount * 12;
  return Math.max(0, Math.min(100, score));
}

function suspiciousPatternCountFromSource(args: {
  personalCompletedToday: ServerQuestIntegritySource[];
  competitiveCompletedToday: ServerQuestIntegritySource[];
  personalXpToday: number;
  weeklyActiveDays: number;
  weeklyCompetitiveDays: number;
}) {
  let count = 0;
  if (args.personalCompletedToday.length >= 5) count += 1;
  if (args.personalXpToday >= 45) count += 1;
  if (
    args.competitiveCompletedToday.length === 0 &&
    args.personalCompletedToday.length >= 3 &&
    args.weeklyActiveDays > args.weeklyCompetitiveDays
  ) {
    count += 1;
  }

  const normalizedTitles = new Map<string, number>();
  for (const quest of args.personalCompletedToday) {
    const key = quest.title.trim().toLowerCase();
    normalizedTitles.set(key, (normalizedTitles.get(key) ?? 0) + 1);
  }
  if (Array.from(normalizedTitles.values()).some((value) => value >= 2)) count += 1;

  const orderedTimes = args.personalCompletedToday
    .map((quest) => quest.completedAt)
    .filter((value): value is admin.firestore.Timestamp => value != null)
    .sort((a, b) => a.toMillis() - b.toMillis());
  let burstPairs = 0;
  for (let index = 1; index < orderedTimes.length; index += 1) {
    const gapMinutes = (orderedTimes[index].toMillis() - orderedTimes[index - 1].toMillis()) / 60000;
    if (gapMinutes <= 2) burstPairs += 1;
  }
  if (burstPairs >= 2) count += 1;
  return count;
}

function trustBandForScore(score: number): ServerTrustBand {
  if (score >= 85) return 'high';
  if (score >= 65) return 'stable';
  if (score >= 45) return 'attention';
  return 'restricted';
}

function integritySummaryForBand(band: ServerTrustBand): string {
  switch (band) {
  case 'high':
    return 'Integridade alta';
  case 'stable':
    return 'Integridade estavel';
  case 'attention':
    return 'Integridade em atencao';
  case 'restricted':
    return 'Integridade restrita';
  }
}

function integrityDetailForSnapshot(args: {
  trustBand: ServerTrustBand;
  weeklyActiveDays: number;
  weeklyCompetitiveDays: number;
  personalQuestCompletionsToday: number;
  competitiveQuestCompletionsToday: number;
  suspiciousPatternCount: number;
}) {
  const base = `Semana com ${args.weeklyCompetitiveDays} dia(s) competitivos validados em ${args.weeklyActiveDays} dia(s) ativos.`;
  const volume = `Hoje: ${args.competitiveQuestCompletionsToday} competitiva(s) e ${args.personalQuestCompletionsToday} pessoal(is).`;
  const risk = args.suspiciousPatternCount === 0
    ? 'Nenhum padrao suspeito relevante foi detectado.'
    : `Padroes suspeitos detectados: ${args.suspiciousPatternCount}.`;
  switch (args.trustBand) {
  case 'high':
    return `${base} ${volume} Sua trilha competitiva esta muito consistente. ${risk}`;
  case 'stable':
    return `${base} ${volume} Sua trilha competitiva segue confiavel. ${risk}`;
  case 'attention':
    return `${base} ${volume} O sistema esta pedindo mais consistencia validada para sustentar o standing. ${risk}`;
  case 'restricted':
    return `${base} ${volume} O peso competitivo desta conta precisa de mais consistencia validada antes de ganhar forca total. ${risk}`;
  }
}

function evaluateCompetitiveIntegrityFromSource(args: {
  source: CompetitiveIntegritySource;
  now: Date;
}) {
  const todayKey = normalizedDateKey(args.now);
  const weekKey = weekKeyForDate(args.now);
  const activeWeekDates = currentWeekDateKeys(args.source.activityHistory, args.now);
  const competitiveWeekDates = currentWeekDateKeys(args.source.competitiveActivityHistory, args.now);
  const todayCompletedQuests = args.source.quests.filter(
    (quest) => quest.isCompleted && quest.completedAt && normalizedDateKey(quest.completedAt) === todayKey,
  );
  const personalCompletedToday = todayCompletedQuests.filter((quest) => !quest.isCompetitive);
  const competitiveCompletedToday = todayCompletedQuests.filter((quest) => quest.countsTowardCompetitive);
  const personalXpToday = personalCompletedToday.reduce((sum, quest) => sum + quest.xpReward, 0);
  const competitiveXpToday = competitiveCompletedToday.reduce((sum, quest) => sum + quest.xpReward, 0);
  const suspiciousPatternCount = suspiciousPatternCountFromSource({
    personalCompletedToday,
    competitiveCompletedToday,
    personalXpToday,
    weeklyActiveDays: activeWeekDates.size,
    weeklyCompetitiveDays: competitiveWeekDates.size,
  });
  const trustScore = trustScoreFromSource({
    weeklyActiveDays: activeWeekDates.size,
    weeklyCompetitiveDays: competitiveWeekDates.size,
    personalQuestCompletionsToday: personalCompletedToday.length,
    competitiveQuestCompletionsToday: competitiveCompletedToday.length,
    personalXpToday,
    competitiveXpToday,
    suspiciousPatternCount,
  });
  const trustBand = trustBandForScore(trustScore);

  return {
    weekKey,
    trustScore,
    trustBand,
    weeklyActiveDays: activeWeekDates.size,
    weeklyCompetitiveDays: competitiveWeekDates.size,
    personalQuestCompletionsToday: personalCompletedToday.length,
    competitiveQuestCompletionsToday: competitiveCompletedToday.length,
    personalXpToday,
    competitiveXpToday,
    suspiciousPatternCount,
    summary: integritySummaryForBand(trustBand),
    detail: integrityDetailForSnapshot({
      trustBand,
      weeklyActiveDays: activeWeekDates.size,
      weeklyCompetitiveDays: competitiveWeekDates.size,
      personalQuestCompletionsToday: personalCompletedToday.length,
      competitiveQuestCompletionsToday: competitiveCompletedToday.length,
      suspiciousPatternCount,
    }),
    syncSchemaVersion: COMPETITIVE_SYNC_SCHEMA_VERSION,
    syncSource: 'backend',
    updatedAt: admin.firestore.Timestamp.fromDate(args.now),
  };
}

export const registerActiveSession = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = ensureActiveSessionPayload(
      (request.data ?? {}) as ActiveSessionPayload,
    );
    const uid = request.auth.uid;
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const expiresAt = admin.firestore.Timestamp.fromMillis(
      now.toMillis() + ACTIVE_SESSION_LEASE_MS,
    );
    const sessionDocRef = activeSessionRef(db, uid);

    await db.runTransaction(async (transaction) => {
      const currentSnap = await transaction.get(sessionDocRef);
      const current = currentSnap.data();
      const currentSessionId =
        typeof current?.deviceSessionId === 'string' ? current.deviceSessionId : '';
      const currentExpiresAt =
        current?.expiresAt instanceof admin.firestore.Timestamp
          ? current.expiresAt
          : null;

      if (
        currentSnap.exists &&
        currentSessionId &&
        currentSessionId !== payload.deviceSessionId &&
        currentExpiresAt &&
        currentExpiresAt.toMillis() > now.toMillis()
      ) {
        throw new HttpsError(
          'failed-precondition',
          'Sessao ativa em outro dispositivo.',
          {reason: 'active_session_conflict'},
        );
      }

      transaction.set(
        sessionDocRef,
        {
          deviceSessionId: payload.deviceSessionId,
          deviceLabel: payload.deviceLabel,
          registeredAt:
            current?.registeredAt instanceof admin.firestore.Timestamp
              ? current.registeredAt
              : now,
          lastSeenAt: now,
          expiresAt,
          updatedAt: now,
        },
        {merge: true},
      );
    });

    return {
      status: 'registered' as const,
      expiresAt: expiresAt.toDate().toISOString(),
    };
  },
);

export const releaseActiveSession = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = ensureActiveSessionPayload(
      (request.data ?? {}) as ActiveSessionPayload,
    );
    const uid = request.auth.uid;
    const db = admin.firestore();
    const sessionDocRef = activeSessionRef(db, uid);

    await db.runTransaction(async (transaction) => {
      const currentSnap = await transaction.get(sessionDocRef);
      const current = currentSnap.data();
      const currentSessionId =
        typeof current?.deviceSessionId === 'string' ? current.deviceSessionId : '';

      if (!currentSnap.exists || currentSessionId !== payload.deviceSessionId) {
        return;
      }

      transaction.delete(sessionDocRef);
    });

    return {
      status: 'released' as const,
    };
  },
);

export const updateProfileSettings = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = validateProfileSettingsPayload(request.data ?? {});
    const uid = request.auth.uid;
    const db = admin.firestore();
    await assertActiveSession(db, uid, payload.session.deviceSessionId);

    const now = admin.firestore.Timestamp.now();
    const fallbackName = sanitizeDisplayName(request.auth.token.name ?? payload.name);
    const result = await db.runTransaction(async (transaction) => {
      const profileRef = profileDocRef(db, uid);
      const profileSnap = await transaction.get(profileRef);
      const currentProfile = profileAggregateFromData({
        data: profileSnap.data(),
        fallbackName,
        deviceSessionId: payload.session.deviceSessionId,
        deviceLabel: payload.session.deviceLabel,
        now,
      });

      let currentStreak = currentProfile.currentStreak;
      if (currentProfile.lastQuestCompletionDate instanceof admin.firestore.Timestamp) {
        const lastCompletion = normalizedDateFromKey(
          normalizedDateKey(currentProfile.lastQuestCompletionDate),
        );
        const nextReset = normalizedDateFromKey(normalizedDateKey(payload.lastResetDate));
        const diffDays = Math.round((nextReset.getTime() - lastCompletion.getTime()) / 86400000);
        if (diffDays > 1) {
          currentStreak = 0;
        }
      }

      const nextProfile = withProfileMetadata({
        profile: {
          ...currentProfile,
          name: payload.name,
          primaryFocus: payload.primaryFocus,
          hasCompletedOnboarding: payload.hasCompletedOnboarding,
          lastResetDate: payload.lastResetDate,
          currentStreak,
        },
        deviceSessionId: payload.session.deviceSessionId,
        deviceLabel: payload.session.deviceLabel,
        now,
        syncSource: 'callable_server_authoritative',
      });

      transaction.set(profileRef, nextProfile, {merge: true});
      return nextProfile;
    });

    return {
      status: 'updated' as const,
      profile: result,
    };
  },
);

export const allocateAttributePoint = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = validateAllocateAttributePointPayload(request.data ?? {});
    const uid = request.auth.uid;
    const db = admin.firestore();
    await assertActiveSession(db, uid, payload.session.deviceSessionId);

    const now = admin.firestore.Timestamp.now();
    const fallbackName = sanitizeDisplayName(request.auth.token.name);
    const result = await db.runTransaction(async (transaction) => {
      const profileRef = profileDocRef(db, uid);
      const profileSnap = await transaction.get(profileRef);
      const currentProfile = profileAggregateFromData({
        data: profileSnap.data(),
        fallbackName,
        deviceSessionId: payload.session.deviceSessionId,
        deviceLabel: payload.session.deviceLabel,
        now,
      });

      if (currentProfile.statPoints <= 0) {
        throw new HttpsError('failed-precondition', 'Nenhum ponto disponivel.');
      }

      const nextAttributes = {
        ...currentProfile.attributes,
      };
      switch (payload.attribute) {
      case 'strength':
        nextAttributes.strength += 1;
        break;
      case 'intelligence':
        nextAttributes.intelligence += 1;
        break;
      case 'vitality':
        nextAttributes.vitality += 1;
        break;
      case 'agility':
        nextAttributes.agility += 1;
        break;
      }

      const nextProfile = withProfileMetadata({
        profile: {
          ...currentProfile,
          statPoints: currentProfile.statPoints - 1,
          attributes: nextAttributes,
          authoritativeAllocatedStatPoints:
            currentProfile.authoritativeAllocatedStatPoints + 1,
        },
        deviceSessionId: payload.session.deviceSessionId,
        deviceLabel: payload.session.deviceLabel,
        now,
        syncSource: 'callable_server_authoritative',
      });

      transaction.set(profileRef, nextProfile, {merge: true});
      transaction.set(
        attributeAllocationsCollectionRef(db, uid).doc(),
        {
          attribute: payload.attribute,
          allocatedAt: now,
          syncSource: 'backend',
          activeDeviceSessionId: payload.session.deviceSessionId,
          activeDeviceLabel: payload.session.deviceLabel,
        },
      );

      return nextProfile;
    });

    return {
      status: 'allocated' as const,
      profile: result,
    };
  },
);

export const completePersonalQuest = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = validatePersonalQuestCommandPayload(request.data ?? {});
    const uid = request.auth.uid;
    const db = admin.firestore();
    await assertActiveSession(db, uid, payload.session.deviceSessionId);

    const now = admin.firestore.Timestamp.now();
    const fallbackName = sanitizeDisplayName(request.auth.token.name);
    const result = await db.runTransaction(async (transaction) => {
      const profileRef = profileDocRef(db, uid);
      const questRef = questDocRef(db, uid, payload.questId);
      const completionRef = questCompletionsCollectionRef(db, uid).doc(payload.questId);
      const [profileSnap, questSnap, completionSnap] = await Promise.all([
        transaction.get(profileRef),
        transaction.get(questRef),
        transaction.get(completionRef),
      ]);

      const currentProfile = profileAggregateFromData({
        data: profileSnap.data(),
        fallbackName,
        deviceSessionId: payload.session.deviceSessionId,
        deviceLabel: payload.session.deviceLabel,
        now,
      });
      const existingQuest = questSnap.exists
        ? validateQuestFromStoredDoc(payload.questId, questSnap.data(), competitiveQuestDefinitions())
        : null;
      const quest = existingQuest ?? payload.quest;
      if (!quest) {
        throw new HttpsError('not-found', 'Quest pessoal nao encontrada.');
      }
      if (quest.category !== 'personal') {
        throw new HttpsError('failed-precondition', 'Apenas quests pessoais usam este comando.');
      }
      if (quest.isCompleted || completionSnap.exists) {
        return {
          status: 'already_completed' as const,
          profile: currentProfile,
          questId: payload.questId,
          quest: buildQuestDocData(existingQuest ?? {
            ...quest,
            isCompleted: true,
            verificationStatus: 'verified',
            completedAt: asTimestampOrNull(quest.completedAt) ?? now,
            verifiedAt: asTimestampOrNull(quest.verifiedAt) ?? now,
          }, {
            orderIndex: asNonNegativeInt(questSnap.data()?.orderIndex, 0),
            deviceSessionId: payload.session.deviceSessionId,
            deviceLabel: payload.session.deviceLabel,
            now,
            syncSource: 'callable_server_authoritative',
          }),
        };
      }

      const rewardedProfile = applyXpRewardToProfile(currentProfile, {
        xpReward: quest.xpReward,
        bonusStatPoints: 0,
      });
      const nextAttributes = {
        ...rewardedProfile.attributes,
      };
      switch (quest.rewardAttribute) {
      case 'strength':
        nextAttributes.strength += 1;
        break;
      case 'intelligence':
        nextAttributes.intelligence += 1;
        break;
      case 'vitality':
        nextAttributes.vitality += 1;
        break;
      case 'agility':
        nextAttributes.agility += 1;
        break;
      }
      const nextHistory = historyWithDay(currentProfile.activityHistory, now);
      const streaks = streakMetricsFromHistory(nextHistory, now);
      const nextProfile = withProfileMetadata({
        profile: {
          ...rewardedProfile,
          attributes: nextAttributes,
          activityHistory: nextHistory,
          lastQuestCompletionDate: now,
          currentStreak: streaks.currentStreak,
          bestStreak: streaks.bestStreak,
          authoritativeQuestXp: currentProfile.authoritativeQuestXp + quest.xpReward,
        },
        deviceSessionId: payload.session.deviceSessionId,
        deviceLabel: payload.session.deviceLabel,
        now,
        syncSource: 'callable_server_authoritative',
      });
      const updatedQuest = {
        ...quest,
        verificationStatus: 'verified' as const,
        isCompleted: true,
        completedAt: now,
        verifiedAt: now,
        preRewardLevel: currentProfile.level,
        preRewardXp: currentProfile.xp,
        preRewardMaxXp: currentProfile.maxXp,
        preRewardStatPoints: currentProfile.statPoints,
        preRewardStrength: currentProfile.attributes.strength,
        preRewardIntelligence: currentProfile.attributes.intelligence,
        preRewardVitality: currentProfile.attributes.vitality,
        preRewardAgility: currentProfile.attributes.agility,
      };
      const questWrite = buildQuestDocData(updatedQuest, {
        orderIndex: asNonNegativeInt(questSnap.data()?.orderIndex, 0),
        deviceSessionId: payload.session.deviceSessionId,
        deviceLabel: payload.session.deviceLabel,
        now,
        syncSource: 'callable_server_authoritative',
      });

      transaction.set(profileRef, nextProfile, {merge: true});
      transaction.set(questRef, questWrite, {merge: true});
      transaction.set(
        completionRef,
        {
          questId: payload.questId,
          title: quest.title,
          rewardAttribute: quest.rewardAttribute,
          xpReward: quest.xpReward,
          countsTowardCompetitive: false,
          completedAt: now,
          preRewardLevel: currentProfile.level,
          preRewardXp: currentProfile.xp,
          preRewardMaxXp: currentProfile.maxXp,
          preRewardStatPoints: currentProfile.statPoints,
          preRewardStrength: currentProfile.attributes.strength,
          preRewardIntelligence: currentProfile.attributes.intelligence,
          preRewardVitality: currentProfile.attributes.vitality,
          preRewardAgility: currentProfile.attributes.agility,
          syncSource: 'backend',
        },
      );

      return {
        status: 'completed' as const,
        profile: nextProfile,
        questId: payload.questId,
        quest: questWrite,
      };
    });

    return result;
  },
);

export const revokePersonalQuestCompletion = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = validatePersonalQuestCommandPayload(request.data ?? {});
    const uid = request.auth.uid;
    const db = admin.firestore();
    await assertActiveSession(db, uid, payload.session.deviceSessionId);

    const now = admin.firestore.Timestamp.now();
    const fallbackName = sanitizeDisplayName(request.auth.token.name);
    const result = await db.runTransaction(async (transaction) => {
      const profileRef = profileDocRef(db, uid);
      const questRef = questDocRef(db, uid, payload.questId);
      const completionRef = questCompletionsCollectionRef(db, uid).doc(payload.questId);
      const [profileSnap, questSnap, completionSnap, completionQuerySnap] = await Promise.all([
        transaction.get(profileRef),
        transaction.get(questRef),
        transaction.get(completionRef),
        transaction.get(questCompletionsCollectionRef(db, uid)),
      ]);

      const currentProfile = profileAggregateFromData({
        data: profileSnap.data(),
        fallbackName,
        deviceSessionId: payload.session.deviceSessionId,
        deviceLabel: payload.session.deviceLabel,
        now,
      });
      if (!questSnap.exists) {
        throw new HttpsError('not-found', 'Quest pessoal nao encontrada.');
      }
      const quest = validateQuestFromStoredDoc(
        payload.questId,
        questSnap.data(),
        competitiveQuestDefinitions(),
      );
      if (quest.category !== 'personal') {
        throw new HttpsError('failed-precondition', 'Apenas quests pessoais usam este comando.');
      }
      if (!quest.isCompleted || !completionSnap.exists) {
        return {
          status: 'already_pending' as const,
          profile: currentProfile,
          questId: payload.questId,
          quest: buildQuestDocData(quest, {
            orderIndex: asNonNegativeInt(questSnap.data()?.orderIndex, 0),
            deviceSessionId: payload.session.deviceSessionId,
            deviceLabel: payload.session.deviceLabel,
            now,
            syncSource: 'callable_server_authoritative',
          }),
        };
      }

      const remainingCompletionDocs = completionQuerySnap.docs.filter(
        (doc) => doc.id !== payload.questId,
      );
      const completionProjection = questCompletionProjectionFromDocs(
        remainingCompletionDocs,
      );
      const streaks = streakMetricsFromHistory(
        completionProjection.activityHistory,
        now,
      );
      const nextProfile = withProfileMetadata({
        profile: {
          ...currentProfile,
          level: quest.preRewardLevel ?? currentProfile.level,
          xp: quest.preRewardXp ?? currentProfile.xp,
          maxXp: quest.preRewardMaxXp ?? currentProfile.maxXp,
          statPoints: quest.preRewardStatPoints ?? currentProfile.statPoints,
          attributes: {
            strength: quest.preRewardStrength ?? currentProfile.attributes.strength,
            intelligence: quest.preRewardIntelligence ?? currentProfile.attributes.intelligence,
            vitality: quest.preRewardVitality ?? currentProfile.attributes.vitality,
            agility: quest.preRewardAgility ?? currentProfile.attributes.agility,
          },
          activityHistory: completionProjection.activityHistory,
          competitiveActivityHistory: completionProjection.competitiveHistory,
          lastQuestCompletionDate: completionProjection.lastQuestCompletionDate,
          lastCompetitiveQuestCompletionDate:
            completionProjection.lastCompetitiveQuestCompletionDate,
          currentStreak: streaks.currentStreak,
          bestStreak: streaks.bestStreak,
          authoritativeQuestXp: completionProjection.questXp,
        },
        deviceSessionId: payload.session.deviceSessionId,
        deviceLabel: payload.session.deviceLabel,
        now,
        syncSource: 'callable_server_authoritative',
      });
      const revertedQuest = {
        ...quest,
        verificationStatus: 'none' as const,
        isCompleted: false,
        completedAt: null,
        verifiedAt: null,
        preRewardLevel: null,
        preRewardXp: null,
        preRewardMaxXp: null,
        preRewardStatPoints: null,
        preRewardStrength: null,
        preRewardIntelligence: null,
        preRewardVitality: null,
        preRewardAgility: null,
      };
      const questWrite = buildQuestDocData(revertedQuest, {
        orderIndex: asNonNegativeInt(questSnap.data()?.orderIndex, 0),
        deviceSessionId: payload.session.deviceSessionId,
        deviceLabel: payload.session.deviceLabel,
        now,
        syncSource: 'callable_server_authoritative',
      });

      transaction.set(profileRef, nextProfile, {merge: true});
      transaction.set(questRef, questWrite, {merge: true});
      transaction.delete(completionRef);

      return {
        status: 'revoked' as const,
        profile: nextProfile,
        questId: payload.questId,
        quest: questWrite,
      };
    });

    return result;
  },
);

export const syncPlayerProfileFromSource = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as PlayerProfileSyncPayload;
    const session = ensureActiveSessionPayload(payload);
    const source = validatePlayerProfileSourcePayload(payload.source);
    const uid = request.auth.uid;
    const db = admin.firestore();

    await assertActiveSession(db, uid, session.deviceSessionId);

    const now = admin.firestore.Timestamp.now();
    const weeklyBossClaims = await loadWeeklyBossClaimsForUser(db, uid);
    const write = buildPlayerProfileSyncWrite({
      source,
      weeklyBossClaims,
      deviceSessionId: session.deviceSessionId,
      deviceLabel: session.deviceLabel,
      now,
    });

    await profileDocRef(db, uid).set(write, {merge: true});

    return {
      status: 'synced' as const,
      profile: write,
    };
  },
);

async function loadWeeklyBossClaimsForUser(
  db: admin.firestore.Firestore,
  uid: string,
): Promise<ServerWeeklyBossClaim[]> {
  const claimsSnap = await db.collectionGroup('completions').where('uid', '==', uid).get();

  const claims = await Promise.all(claimsSnap.docs.map(async (doc) => {
    const data = doc.data();
    if (!(data.completedAt instanceof admin.firestore.Timestamp)) {
      return null;
    }

    let rewardXp = typeof data.rewardXp === 'number' ? Math.max(0, Math.floor(data.rewardXp)) : null;
    let rewardStatPoints = typeof data.rewardStatPoints === 'number'
      ? Math.max(0, Math.floor(data.rewardStatPoints))
      : null;

    if (rewardXp == null || rewardStatPoints == null) {
      const bossSnap = await doc.ref.parent.parent?.get();
      const bossData = bossSnap?.data() ?? {};
      rewardXp = rewardXp ?? ensureInt(bossData.rewardXp, 'weeklyBoss.rewardXp', 0);
      rewardStatPoints = rewardStatPoints ?? ensureInt(
        bossData.rewardStatPoints,
        'weeklyBoss.rewardStatPoints',
        0,
      );
    }

    return {
      completedAt: data.completedAt,
      rewardXp,
      rewardStatPoints,
    };
  }));

  return claims
    .filter((claim): claim is ServerWeeklyBossClaim => claim != null)
    .sort((a, b) => a.completedAt.toMillis() - b.completedAt.toMillis());
}

export const syncQuestInventoryFromSource = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as QuestInventorySyncPayload;
    const session = ensureActiveSessionPayload(payload);
    const source = validateQuestInventorySourcePayload(
      payload.source,
      competitiveQuestDefinitions(),
    );
    const uid = request.auth.uid;
    const db = admin.firestore();

    await assertActiveSession(db, uid, session.deviceSessionId);

    const now = admin.firestore.Timestamp.now();
    const writes = buildQuestInventorySyncWrites({
      source,
      deviceSessionId: session.deviceSessionId,
      deviceLabel: session.deviceLabel,
      now,
    });
    const questsRef = questsCollectionRef(db, uid);
    const metaDocRef = questsMetaDocRef(db, uid);
    const previousSnap = await questsRef.get();
    const nextIds = new Set(writes.map((entry) => entry.id));
    const batch = db.batch();

    for (const doc of previousSnap.docs) {
      if (!nextIds.has(doc.id)) {
        batch.delete(doc.ref);
      }
    }

    for (const entry of writes) {
      batch.set(questsRef.doc(entry.id), entry.data, {merge: true});
    }

    batch.set(
      metaDocRef,
      {
        initialized: true,
        questCount: writes.length,
        syncSchemaVersion: QUEST_INVENTORY_SYNC_SCHEMA_VERSION,
        syncSource: 'callable_session_audited',
        activeDeviceSessionId: session.deviceSessionId,
        activeDeviceLabel: session.deviceLabel,
        updatedAt: now,
      },
      {merge: true},
    );

    await batch.commit();

    return {
      status: 'synced' as const,
      questCount: writes.length,
    };
  },
);

export const claimWeeklyBoss = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as ClaimWeeklyBossPayload;
    const session = ensureActiveSessionPayload(payload);
    const bossId = typeof payload.bossId === 'string' ? payload.bossId.trim() : '';

    if (!bossId) {
      throw new HttpsError('invalid-argument', 'bossId obrigatorio.');
    }

    const displayName = sanitizeDisplayName(payload.displayName);
    const photoUrl = sanitizePhotoUrl(payload.photoUrl);
    const requestRank = normalizeRank(payload.rankAtCompletion);
    const uid = request.auth.uid;
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    await assertActiveSession(db, uid, session.deviceSessionId);

    const bossRef = db.collection('weekly_bosses').doc(bossId);
    const completionRef = bossRef.collection('completions').doc(uid);
    const userClaimRef = weeklyBossClaimsCollectionRef(db, uid).doc(bossId);
    const profileRef = profileDocRef(db, uid);

    return db.runTransaction(async (transaction) => {
      const [bossSnap, completionSnap, userClaimSnap, profileSnap] = await Promise.all([
        transaction.get(bossRef),
        transaction.get(completionRef),
        transaction.get(userClaimRef),
        transaction.get(profileRef),
      ]);

      if (!bossSnap.exists) {
        throw new HttpsError('not-found', 'Boss semanal nao encontrado.');
      }

      const data = bossSnap.data() ?? {};
      const isActive = Boolean(data.isActive);
      const startsAt = data.startsAt as admin.firestore.Timestamp | undefined;
      const endsAt = data.endsAt as admin.firestore.Timestamp | undefined;
      const bossRank = normalizeRank(data.rank);
      const rewardXp = ensureInt(data.rewardXp, 'rewardXp', 0);
      const rewardStatPoints = ensureInt(data.rewardStatPoints, 'rewardStatPoints', 0);

      if (!isActive) {
        throw new HttpsError('failed-precondition', 'Boss semanal inativo.');
      }

      if (!startsAt || !endsAt) {
        throw new HttpsError('failed-precondition', 'Boss semanal sem janela valida.');
      }

      if (startsAt.toMillis() > now.toMillis() || endsAt.toMillis() <= now.toMillis()) {
        throw new HttpsError('failed-precondition', 'Boss semanal fora da janela ativa.');
      }

      if (!bossRank) {
        throw new HttpsError('failed-precondition', 'Rank do boss invalido.');
      }

      if (requestRank && requestRank !== bossRank) {
        throw new HttpsError('permission-denied', 'Rank enviado nao corresponde ao boss.');
      }

      const currentProfile = profileAggregateFromData({
        data: profileSnap.data(),
        fallbackName: displayName,
        deviceSessionId: session.deviceSessionId,
        deviceLabel: session.deviceLabel,
        now,
      });

      if (completionSnap.exists || userClaimSnap.exists) {
        return {
          status: 'already_completed' as const,
          profile: currentProfile,
        };
      }

      const rewardedProfile = applyXpRewardToProfile(currentProfile, {
        xpReward: rewardXp,
        bonusStatPoints: rewardStatPoints,
      });
      const nextProfile = withProfileMetadata({
        profile: {
          ...rewardedProfile,
          weeklyBossLastClaimedAt: now,
          authoritativeWeeklyBossXp:
            currentProfile.authoritativeWeeklyBossXp + rewardXp,
          authoritativeWeeklyBossStatPoints:
            currentProfile.authoritativeWeeklyBossStatPoints + rewardStatPoints,
        },
        deviceSessionId: session.deviceSessionId,
        deviceLabel: session.deviceLabel,
        now,
        syncSource: 'callable_server_authoritative',
      });

      transaction.set(completionRef, {
        uid,
        displayName,
        photoUrl,
        rankAtCompletion: bossRank,
        completedAt: now,
        rewardXp,
        rewardStatPoints,
      });
      transaction.set(userClaimRef, {
        bossId,
        rankAtCompletion: bossRank,
        rewardXp,
        rewardStatPoints,
        claimedAt: now,
        syncSource: 'backend',
        activeDeviceSessionId: session.deviceSessionId,
        activeDeviceLabel: session.deviceLabel,
      });
      transaction.set(profileRef, nextProfile, {merge: true});

      transaction.update(bossRef, {
        completedCount: admin.firestore.FieldValue.increment(1),
      });

      return {
        status: 'claimed' as const,
        profile: nextProfile,
      };
    });
  },
);

export const startCompetitiveQuestSession = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as CompetitiveQuestSessionPayload;
    const session = ensureActiveSessionPayload(payload);
    const quest = validateCompetitiveQuestSessionPayload(payload);
    const uid = request.auth.uid;
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    await assertActiveSession(db, uid, session.deviceSessionId);
    // Start must always scope to "today". A stale local verificationStartedAt from the
    // client should never resurrect an old competitive attempt.
    const dayKey = normalizedDateKey(now);
    const attemptId = competitiveQuestAttemptDocId(quest.questId, dayKey);
    const sessionRef = competitiveQuestSessionDocRef(db, uid, attemptId);
    const grantRef = competitiveQuestGrantDocRef(db, uid, attemptId);
    const legacySessionRef = competitiveQuestSessionDocRef(db, uid, quest.questId);
    const legacyGrantRef = competitiveQuestGrantDocRef(db, uid, quest.questId);

    return db.runTransaction(async (transaction) => {
      const [sessionSnap, grantSnap, legacySessionSnap, legacyGrantSnap] = await Promise.all([
        transaction.get(sessionRef),
        transaction.get(grantRef),
        transaction.get(legacySessionRef),
        transaction.get(legacyGrantRef),
      ]);
      const scopedSession = sessionSnap.exists ? (sessionSnap.data() ?? null) : null;
      const scopedGrant = grantSnap.exists ? (grantSnap.data() ?? null) : null;
      const legacySession = legacySessionSnap.exists &&
          matchesCompetitiveAttemptDay({
            record: legacySessionSnap.data() ?? null,
            dayKey,
            timestampField: 'startedAt',
          })
        ? (legacySessionSnap.data() ?? null)
        : null;
      const legacyGrant = legacyGrantSnap.exists &&
          matchesCompetitiveAttemptDay({
            record: legacyGrantSnap.data() ?? null,
            dayKey,
            timestampField: 'completedAt',
          })
        ? (legacyGrantSnap.data() ?? null)
        : null;
      const resolution = resolveCompetitiveQuestSessionStart({
        quest,
        session: scopedSession ?? legacySession,
        grant: scopedGrant ?? legacyGrant,
        now,
      });

      if (resolution.sessionWrite) {
        transaction.set(sessionRef, resolution.sessionWrite, {merge: true});
      }

      return {
        status: resolution.status,
        startedAt: resolution.startedAt,
      };
    });
  },
);

export const startReadingQuizAttempt = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = validateStartReadingQuizPayload(request.data ?? {});
    const uid = request.auth.uid;
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    await assertActiveSession(db, uid, payload.session.deviceSessionId);

    const template = competitiveQuestDefinitions().find((definition) =>
      definition.id === payload.templateCatalogId ||
      definition.id === payload.questId.split('-').slice(0, -1).join('-'),
    );
    if (
      !template ||
      template.verificationRequirement.evidenceType !== 'readingComprehension'
    ) {
      throw new HttpsError(
        'failed-precondition',
        'Quiz de leitura indisponivel para essa quest.',
      );
    }

    const quizGenerator = createReadingQuizGenerator();
    const attempt = await quizGenerator.generateAttempt({
      questId: payload.questId,
      topic: payload.topic,
      minimumScore: template.verificationRequirement.minimumQuizScore,
      now,
    });

    await readingQuizAttemptDocRef(db, uid, attempt.quizId).set({
      ...readingQuizAttemptWrite(attempt),
      deviceSessionId: payload.session.deviceSessionId,
      deviceLabel: payload.session.deviceLabel,
      updatedAt: now,
    });

    return {
      quizId: attempt.quizId,
      questId: attempt.questId,
      topic: attempt.topic,
      minimumScore: attempt.minimumScore,
      issuedAt: attempt.issuedAt.toDate().toISOString(),
      expiresAt: attempt.expiresAt.toDate().toISOString(),
      questions: attempt.questions.map((question) => ({
        id: question.id,
        prompt: question.prompt,
      })),
    };
  },
);

export const verifyCompetitiveQuestCompletion = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as CompetitiveQuestSessionPayload;
    const session = ensureActiveSessionPayload(payload);
    const quest = validateCompetitiveQuestSessionPayload(payload);
    const uid = request.auth.uid;
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    await assertActiveSession(db, uid, session.deviceSessionId);
    const dayKey = competitiveQuestAttemptDayKey({quest, now});
    const attemptId = competitiveQuestAttemptDocId(quest.questId, dayKey);
    const sessionRef = competitiveQuestSessionDocRef(db, uid, attemptId);
    const grantRef = competitiveQuestGrantDocRef(db, uid, attemptId);
    const legacySessionRef = competitiveQuestSessionDocRef(db, uid, quest.questId);
    const legacyGrantRef = competitiveQuestGrantDocRef(db, uid, quest.questId);
    const profileRef = profileDocRef(db, uid);
    const questRef = questDocRef(db, uid, quest.questId);
    const completionRef = questCompletionsCollectionRef(
      db,
      uid,
    ).doc(attemptId);
    const evidenceRef = competitiveQuestEvidenceDocRef(db, uid, attemptId);
    const duplicateSourceActivityQuery = quest.evidence?.sourceActivityId == null
      ? null
      : competitiveQuestGrantsCollectionRef(db, uid)
        .where('sourceActivityId', '==', quest.evidence.sourceActivityId)
        .limit(3);
    const quizSubmission = quest.evidence?.type === 'readingComprehension'
      ? validateReadingQuizSubmission(quest.evidence)
      : null;
    const quizAttemptRef = quizSubmission == null
      ? null
      : readingQuizAttemptDocRef(db, uid, quizSubmission.quizId);
    const fallbackName = sanitizeDisplayName(request.auth.token.name);

    return db.runTransaction(async (transaction) => {
      const [
        sessionSnap,
        grantSnap,
        legacySessionSnap,
        legacyGrantSnap,
        profileSnap,
        questSnap,
        duplicateSourceActivitySnap,
        quizAttemptSnap,
      ] = await Promise.all([
        transaction.get(sessionRef),
        transaction.get(grantRef),
        transaction.get(legacySessionRef),
        transaction.get(legacyGrantRef),
        transaction.get(profileRef),
        transaction.get(questRef),
        duplicateSourceActivityQuery == null
          ? Promise.resolve(null)
          : transaction.get(duplicateSourceActivityQuery),
        quizAttemptRef == null
          ? Promise.resolve(null)
          : transaction.get(quizAttemptRef),
      ]);
      const scopedSession = sessionSnap.exists ? (sessionSnap.data() ?? null) : null;
      const scopedGrant = grantSnap.exists ? (grantSnap.data() ?? null) : null;
      const legacySession = legacySessionSnap.exists &&
          matchesCompetitiveAttemptDay({
            record: legacySessionSnap.data() ?? null,
            dayKey,
            timestampField: 'startedAt',
          })
        ? (legacySessionSnap.data() ?? null)
        : null;
      const legacyGrant = legacyGrantSnap.exists &&
          matchesCompetitiveAttemptDay({
            record: legacyGrantSnap.data() ?? null,
            dayKey,
            timestampField: 'completedAt',
          })
        ? (legacyGrantSnap.data() ?? null)
        : null;
      const sourceActivityIdAlreadyUsed = duplicateSourceActivitySnap == null
        ? false
        : duplicateSourceActivitySnap.docs.some((doc) =>
          doc.id !== attemptId && doc.id !== quest.questId,
        );
      const readingQuizEvaluation = evaluateReadingQuizSubmission({
        attempt: readingQuizAttemptFromData(quizAttemptSnap?.data()),
        questId: quest.questId,
        submission: quizSubmission,
        now,
      });
      const verifiedQuestPayload = quizSubmission == null || quest.evidence == null
        ? quest
        : {
          ...quest,
          readingQuizEvaluation,
          evidence: {
            ...quest.evidence,
            quizScore: readingQuizEvaluation.score,
            quizId: readingQuizEvaluation.quizId,
          },
        };
      const resolution = resolveCompetitiveQuestCompletionVerification({
        quest: verifiedQuestPayload,
        session: scopedSession ?? legacySession,
        grant: scopedGrant ?? legacyGrant,
        now,
        sourceActivityIdAlreadyUsed,
      });
      const currentProfile = profileAggregateFromData({
        data: profileSnap.data(),
        fallbackName,
        deviceSessionId: session.deviceSessionId,
        deviceLabel: session.deviceLabel,
        now,
      });
      const existingQuest = questSnap.exists
        ? validateQuestFromStoredDoc(quest.questId, questSnap.data(), competitiveQuestDefinitions())
        : null;
      const competitiveQuest = existingQuest ?? {
        id: quest.questId,
        title: quest.title,
        rewardAttribute: quest.rewardAttribute,
        xpReward: quest.xpReward,
        category: 'competitive' as const,
        templateType: quest.templateType,
        verificationMode: quest.verificationMode,
        verificationStatus: 'none' as const,
        targetDurationMinutes: quest.targetDurationMinutes,
        reflectionPrompt: null,
        reflectionAnswer: quest.reflectionAnswer,
        verificationStartedAt: quest.verificationStartedAt,
        completedAt: null,
        verifiedAt: null,
        isCompleted: false,
        preRewardLevel: null,
        preRewardXp: null,
        preRewardMaxXp: null,
        preRewardStatPoints: null,
        preRewardStrength: null,
        preRewardIntelligence: null,
        preRewardVitality: null,
        preRewardAgility: null,
      };

      if (!resolution.grantWrite) {
        const completedAt = scopedGrant?.completedAt instanceof admin.firestore.Timestamp
          ? scopedGrant.completedAt
          : legacyGrant?.completedAt instanceof admin.firestore.Timestamp
            ? legacyGrant.completedAt
            : now;
        const alreadyVerifiedQuest = {
          ...competitiveQuest,
          verificationStatus: 'verified' as const,
          isCompleted: true,
          completedAt,
          verifiedAt: completedAt,
          reflectionAnswer: quest.reflectionAnswer ?? competitiveQuest.reflectionAnswer,
        };

        return {
          status: resolution.status,
          completedAt: resolution.completedAt,
          profile: currentProfile,
          questId: quest.questId,
          quest: buildQuestDocData(alreadyVerifiedQuest, {
            orderIndex: asNonNegativeInt(questSnap.data()?.orderIndex, 0),
            deviceSessionId: session.deviceSessionId,
            deviceLabel: session.deviceLabel,
            now,
            syncSource: 'callable_server_authoritative',
          }),
        };
      }

      const rewardedProfile = applyXpRewardToProfile(currentProfile, {
        xpReward: quest.xpReward,
        bonusStatPoints: 0,
      });
      const nextAttributes = {
        ...rewardedProfile.attributes,
      };
      switch (quest.rewardAttribute) {
      case 'strength':
        nextAttributes.strength += 1;
        break;
      case 'intelligence':
        nextAttributes.intelligence += 1;
        break;
      case 'vitality':
        nextAttributes.vitality += 1;
        break;
      case 'agility':
        nextAttributes.agility += 1;
        break;
      }
      const nextHistory = historyWithDay(currentProfile.activityHistory, now);
      const nextCompetitiveHistory = historyWithDay(
        currentProfile.competitiveActivityHistory,
        now,
      );
      const streaks = streakMetricsFromHistory(nextHistory, now);
      const nextProfile = withProfileMetadata({
        profile: {
          ...rewardedProfile,
          attributes: nextAttributes,
          activityHistory: nextHistory,
          competitiveActivityHistory: nextCompetitiveHistory,
          lastQuestCompletionDate: now,
          lastCompetitiveQuestCompletionDate: now,
          currentStreak: streaks.currentStreak,
          bestStreak: streaks.bestStreak,
          authoritativeQuestXp: currentProfile.authoritativeQuestXp + quest.xpReward,
        },
        deviceSessionId: session.deviceSessionId,
        deviceLabel: session.deviceLabel,
        now,
        syncSource: 'callable_server_authoritative',
      });
      const updatedQuest = {
        ...competitiveQuest,
        verificationStatus: 'verified' as const,
        isCompleted: true,
        completedAt: now,
        verifiedAt: now,
        reflectionAnswer: quest.reflectionAnswer ?? competitiveQuest.reflectionAnswer,
        preRewardLevel: currentProfile.level,
        preRewardXp: currentProfile.xp,
        preRewardMaxXp: currentProfile.maxXp,
        preRewardStatPoints: currentProfile.statPoints,
        preRewardStrength: currentProfile.attributes.strength,
        preRewardIntelligence: currentProfile.attributes.intelligence,
        preRewardVitality: currentProfile.attributes.vitality,
        preRewardAgility: currentProfile.attributes.agility,
      };
      const questWrite = buildQuestDocData(updatedQuest, {
        orderIndex: asNonNegativeInt(questSnap.data()?.orderIndex, 0),
        deviceSessionId: session.deviceSessionId,
        deviceLabel: session.deviceLabel,
        now,
        syncSource: 'callable_server_authoritative',
      });

      transaction.set(grantRef, resolution.grantWrite, {merge: true});
      if (resolution.sessionWrite) {
        transaction.set(sessionRef, resolution.sessionWrite, {merge: true});
      }
      transaction.set(
        evidenceRef,
        {
          questId: quest.questId,
          title: quest.title,
          templateType: quest.templateType,
          evidenceType: verifiedQuestPayload.evidence?.type ?? null,
          evidenceProvider: verifiedQuestPayload.evidence?.provider ?? null,
          startedAt: verifiedQuestPayload.evidence?.startedAt ?? null,
          completedAt: verifiedQuestPayload.evidence?.completedAt ?? null,
          durationMinutes: verifiedQuestPayload.evidence?.durationMinutes ?? null,
          distanceMeters: verifiedQuestPayload.evidence?.distanceMeters ?? null,
          sourceActivityId: verifiedQuestPayload.evidence?.sourceActivityId ?? null,
          quizId: verifiedQuestPayload.evidence?.quizId ?? null,
          quizScore: verifiedQuestPayload.evidence?.quizScore ?? null,
          quizRiskFlags: quizSubmission == null
            ? []
            : readingQuizEvaluation.riskFlags,
          confidenceScore: resolution.decision.confidenceScore,
          riskFlags: resolution.decision.riskFlags,
          status: resolution.decision.status,
          auditedAt: now,
          syncSource: 'backend',
          activeDeviceSessionId: session.deviceSessionId,
          activeDeviceLabel: session.deviceLabel,
        },
        {merge: true},
      );
      transaction.set(profileRef, nextProfile, {merge: true});
      transaction.set(questRef, questWrite, {merge: true});
      transaction.set(
        completionRef,
        {
          questId: quest.questId,
          title: quest.title,
          rewardAttribute: quest.rewardAttribute,
          xpReward: quest.xpReward,
          countsTowardCompetitive: true,
          completedAt: now,
          preRewardLevel: currentProfile.level,
          preRewardXp: currentProfile.xp,
          preRewardMaxXp: currentProfile.maxXp,
          preRewardStatPoints: currentProfile.statPoints,
          preRewardStrength: currentProfile.attributes.strength,
          preRewardIntelligence: currentProfile.attributes.intelligence,
          preRewardVitality: currentProfile.attributes.vitality,
          preRewardAgility: currentProfile.attributes.agility,
          syncSource: 'backend',
          activeDeviceSessionId: session.deviceSessionId,
          activeDeviceLabel: session.deviceLabel,
        },
      );

      return {
        status: resolution.status,
        completedAt: resolution.completedAt,
        verificationDecision: resolution.decision,
        profile: nextProfile,
        questId: quest.questId,
        quest: questWrite,
      };
    });
  },
);

export const syncCompetitiveStateFromSource = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as CompetitiveSyncSourcePayload;
    const source = validateCompetitiveSourcePayload(payload.source);
    const uid = request.auth.uid;
    const db = admin.firestore();
    const now = new Date();

    const currentRef = competitiveProgressionDocRef(db, uid);
    const examRef = promotionExamDocRef(db, uid);
    const seasonRewardRef = seasonRewardDocRef(db, uid);
    const competitiveGrantQuery = competitiveQuestGrantsCollectionRef(db, uid)
      .orderBy('completedAt', 'desc')
      .limit(180);
    const historyQuery = competitiveProgressionHistoryCollectionRef(db, uid)
      .orderBy('updatedAt', 'desc')
      .limit(8);

    const [
      currentSnap,
      examSnap,
      currentSeasonRewardSnap,
      historySnap,
      competitiveGrantSnap,
    ] = await Promise.all([
      currentRef.get(),
      examRef.get(),
      seasonRewardRef.get(),
      historyQuery.get(),
      competitiveGrantQuery.get(),
    ]);

    const previousSnapshot = currentSnap.exists && currentSnap.data()
      ? validateSnapshotPayload(currentSnap.data())
      : null;
    const currentExam = examSnap.exists && examSnap.data()
      ? validateExamPayload(examSnap.data())
      : null;
    const currentSeasonReward = currentSeasonRewardSnap.exists && currentSeasonRewardSnap.data()
      ? validateSeasonRewardPayload(currentSeasonRewardSnap.data())
      : null;
    const grantTimestamps = competitiveGrantSnap.docs
      .map((doc) => doc.data().completedAt)
      .filter((entry): entry is admin.firestore.Timestamp => entry instanceof admin.firestore.Timestamp);
    const authoritativeCompetitiveHistory = grantTimestamps.length > 0
      ? uniqueTimestampsByDay(grantTimestamps)
      : source.competitiveActivityHistory;
    const serverSnapshot = evaluateCompetitiveRankFromSource({
      playerLevel: source.playerLevel,
      competitiveActivityHistory: authoritativeCompetitiveHistory,
      previousSnapshot,
      now,
    });
    const resolvedExam = resolveExamAfterSnapshot({
      snapshot: serverSnapshot,
      currentExam,
      now: admin.firestore.Timestamp.fromDate(now),
    });
    const history = historySnap.docs
      .map((doc) => validateSnapshotPayload(doc.data()))
      .filter((entry): entry is NonNullable<typeof entry> => entry != null);
    const mergedHistory = [
      serverSnapshot,
      ...history.filter((entry) => entry.weekKey !== serverSnapshot.weekKey),
    ];
    const seasonReward = buildSeasonRewardFromHistory({
      history: mergedHistory,
      snapshot: serverSnapshot,
      currentReward: currentSeasonReward,
      now,
    });

    const batch = db.batch();
    batch.set(currentRef, serverSnapshot, {merge: true});
    batch.set(
      competitiveProgressionHistoryDocRef(db, uid, serverSnapshot.weekKey),
      serverSnapshot,
      {merge: true},
    );
    if (resolvedExam) {
      batch.set(examRef, resolvedExam, {merge: true});
    }
    batch.set(seasonRewardRef, seasonReward, {merge: true});
    batch.set(
      seasonRewardHistoryDocRef(db, uid, seasonReward.seasonKey),
      seasonReward,
      {merge: true},
    );
    await batch.commit();

    return {
      status: 'synced' as const,
      snapshot: serverSnapshot,
      exam: resolvedExam,
      seasonReward,
    };
  },
);

export const syncCompetitiveIntegrityFromSource = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as CompetitiveIntegritySourcePayload;
    const source = validateCompetitiveIntegritySourcePayload(payload.source);
    const uid = request.auth.uid;
    const db = admin.firestore();
    const now = new Date();
    const competitiveGrantSnap = await competitiveQuestGrantsCollectionRef(db, uid)
      .orderBy('completedAt', 'desc')
      .limit(180)
      .get();
    const grantTimestamps = competitiveGrantSnap.docs
      .map((doc) => doc.data().completedAt)
      .filter((entry): entry is admin.firestore.Timestamp => entry instanceof admin.firestore.Timestamp);
    const authoritativeCompetitiveHistory = grantTimestamps.length > 0
      ? uniqueTimestampsByDay(grantTimestamps)
      : source.competitiveActivityHistory;
    const integrity = evaluateCompetitiveIntegrityFromSource({
      source: {
        ...source,
        competitiveActivityHistory: authoritativeCompetitiveHistory,
      },
      now,
    });
    const currentRef = competitiveIntegrityDocRef(db, uid);
    const historyRef = competitiveIntegrityHistoryDocRef(db, uid, integrity.weekKey);

    const batch = db.batch();
    batch.set(currentRef, integrity, {merge: true});
    batch.set(historyRef, integrity, {merge: true});
    await batch.commit();

    return {
      status: 'synced' as const,
      integrity,
    };
  },
);

export const upsertCompetitiveProgression = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as CompetitiveRankPayload;
    const snapshot = validateSnapshotPayload(payload.snapshot);
    const exam = validateExamPayload(payload.exam);
    const validatedSeasonReward = validateSeasonRewardPayload(payload.seasonReward);
    const uid = request.auth.uid;
    const db = admin.firestore();
    const currentRef = competitiveProgressionDocRef(db, uid);
    const historyRef = competitiveProgressionHistoryDocRef(db, uid, snapshot.weekKey);
    const examRef = promotionExamDocRef(db, uid);
    const seasonRewardRef = seasonRewardDocRef(db, uid);
    const seasonRewardHistoryRef = validatedSeasonReward == null
      ? null
      : seasonRewardHistoryDocRef(db, uid, validatedSeasonReward.seasonKey);

    const batch = db.batch();
    batch.set(currentRef, snapshot, { merge: true });
    batch.set(historyRef, snapshot, { merge: true });
    if (exam) {
      batch.set(examRef, exam, { merge: true });
    }
    if (validatedSeasonReward && seasonRewardHistoryRef) {
      batch.set(seasonRewardRef, validatedSeasonReward, { merge: true });
      batch.set(seasonRewardHistoryRef, validatedSeasonReward, { merge: true });
    }
    await batch.commit();

    return {
      status: 'synced' as const,
      weekKey: snapshot.weekKey,
      wroteExam: Boolean(exam),
      wroteSeasonReward: Boolean(validatedSeasonReward),
    };
  },
);

export const upsertCompetitiveIntegrity = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as CompetitiveIntegrityPayload;
    const integrity = validateIntegrityPayload(payload.integrity);
    if (integrity == null) {
      throw new HttpsError('invalid-argument', 'integrity obrigatoria.');
    }

    const uid = request.auth.uid;
    const db = admin.firestore();
    const currentRef = competitiveIntegrityDocRef(db, uid);
    const historyRef = competitiveIntegrityHistoryDocRef(db, uid, integrity.weekKey);

    const batch = db.batch();
    batch.set(currentRef, integrity, { merge: true });
    batch.set(historyRef, integrity, { merge: true });
    await batch.commit();

    return {
      status: 'synced' as const,
      weekKey: integrity.weekKey,
      trustBand: integrity.trustBand,
      trustScore: integrity.trustScore,
    };
  },
);

export const startPromotionExam = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as StartPromotionExamPayload;
    const snapshot = validateSnapshotPayload(payload.snapshot);
    const targetRank = snapshot.promotionTargetRank;
    if (!snapshot.promotionReady || !targetRank) {
      throw new HttpsError(
        'failed-precondition',
        'A prova ainda nao esta liberada para este rank.',
      );
    }

    const uid = request.auth.uid;
    const db = admin.firestore();
    const examRef = promotionExamDocRef(db, uid);
    const requirements = rankRequirements(targetRank);

    return db.runTransaction(async (transaction) => {
      const examSnap = await transaction.get(examRef);
      if (examSnap.exists) {
        const existing = validateExamPayload(examSnap.data());
        if (existing?.status === 'inProgress') {
          return {
            status: 'already_in_progress' as const,
            targetRank,
          };
        }
      }

      const now = admin.firestore.Timestamp.now();
      const examPayload = {
        sourceRank: snapshot.currentRank,
        targetRank,
        sourceWeekKey: snapshot.weekKey,
        status: 'inProgress',
        mode: snapshot.advancementMode ?? 'ascension',
        baselineActiveDays: snapshot.activeDays,
        requiredExtraActiveDays: 1,
        bossRequired: requirements.requiresBossClear,
        requiredLevel: snapshot.targetRequiredLevel,
        startedAt: now,
        expiresAt: admin.firestore.Timestamp.fromMillis(
          now.toMillis() + 3 * 24 * 60 * 60 * 1000,
        ),
        syncSchemaVersion: snapshot.syncSchemaVersion,
        syncSource: 'backend',
        resolvedAt: null,
      };

      transaction.set(examRef, examPayload, { merge: true });
      return {
        status: 'started' as const,
        targetRank,
      };
    });
  },
);

export const confirmPromotion = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as ConfirmPromotionPayload;
    const snapshot = validateSnapshotPayload(payload.snapshot);
    const uid = request.auth.uid;
    const db = admin.firestore();
    const currentRef = competitiveProgressionDocRef(db, uid);
    const historyRef = competitiveProgressionHistoryDocRef(db, uid, snapshot.weekKey);
    const examRef = promotionExamDocRef(db, uid);

    return db.runTransaction(async (transaction) => {
      const examSnap = await transaction.get(examRef);
      if (!examSnap.exists || !examSnap.data()) {
        throw new HttpsError('not-found', 'Nenhuma prova ativa encontrada.');
      }

      const exam = validateExamPayload(examSnap.data());
      if (!exam) {
        throw new HttpsError('failed-precondition', 'A prova atual esta invalida.');
      }
      if (exam.status === 'promoted') {
        return {
          status: 'already_promoted' as const,
          currentRank: exam.targetRank,
        };
      }
      if (exam.status !== 'passed') {
        throw new HttpsError(
          'failed-precondition',
          'A prova ainda nao foi concluida com sucesso.',
        );
      }
      if (exam.sourceRank !== snapshot.currentRank || exam.sourceWeekKey !== snapshot.weekKey) {
        throw new HttpsError(
          'failed-precondition',
          'O estado competitivo mudou antes da confirmacao.',
        );
      }

      const promotedRank = exam.targetRank;
      const promotedRule = rankRequirements(promotedRank);
      const nextRank = rankAfter(promotedRank);
      const nextRule = nextRank == null ? null : rankRequirements(nextRank);
      const peakRank = higherRank(promotedRank, snapshot.peakRank);
      const now = admin.firestore.Timestamp.now();
      const nextLevelGateMet = nextRank == null
        ? true
        : rankOrder(snapshot.highestEligibleRank) >= rankOrder(nextRank);
      const nextMode = nextRank == null
        ? null
        : rankOrder(nextRank) <= rankOrder(peakRank)
          ? 'reconquest'
          : 'ascension';

      const promotedSnapshot = {
        currentRank: promotedRank,
        peakRank,
        highestEligibleRank: snapshot.highestEligibleRank,
        weekKey: snapshot.weekKey,
        activeDays: snapshot.activeDays,
        requiredActiveDays: promotedRule.requiredActiveDays,
        requiresBossClear: promotedRule.requiresBossClear,
        bossCompleted: snapshot.bossCompleted,
        status: 'secure',
        demotionStrikes: 0,
        promotionReady: false,
        promotionTargetRank: nextRank,
        targetRequiredLevel: nextRule?.minimumLevel ?? promotedRule.minimumLevel,
        targetLevelGateMet: nextLevelGateMet,
        advancementMode: nextMode,
        eventType: 'promotionConfirmed',
        summary: exam.mode === 'reconquest'
          ? `Rank ${promotedRank} reconquistado.`
          : `Promovido para o rank ${promotedRank}.`,
        detail: exam.mode === 'reconquest'
          ? 'A prova confirmou sua retomada de posto competitivo.'
          : 'A prova confirmou sua subida de rank e registrou o novo posto.',
        syncSchemaVersion: snapshot.syncSchemaVersion,
        syncSource: 'backend',
        updatedAt: now,
      };

      transaction.set(currentRef, promotedSnapshot, { merge: true });
      transaction.set(historyRef, promotedSnapshot, { merge: true });
      transaction.set(
        examRef,
        {
          ...exam,
          status: 'promoted',
          resolvedAt: now,
          syncSource: 'backend',
        },
        { merge: true },
      );

      return {
        status: 'promoted' as const,
        currentRank: promotedRank,
      };
    });
  },
);

export const getSeasonBracketLeaderboard = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as SeasonBracketLeaderboardPayload;
    const seasonKey = ensureString(payload.seasonKey, 'seasonKey', 24);
    const rankBracket = normalizeRank(payload.rankBracket);
    if (!['E', 'D', 'C', 'B', 'A', 'S'].includes(rankBracket)) {
      throw new HttpsError('invalid-argument', 'rankBracket invalido.');
    }
    const limit = typeof payload.limit === 'number' && Number.isInteger(payload.limit)
      ? Math.min(Math.max(payload.limit, 1), 10)
      : 5;

    const db = admin.firestore();
    const snapshot = await db
      .collectionGroup('season_rewards')
      .where('seasonKey', '==', seasonKey)
      .where('currentRankBracket', '==', rankBracket)
      .get();

    const entries = snapshot.docs
      .map((doc) => {
        try {
          const data = validateSeasonRewardPayload(doc.data());
          if (data == null) return null;
          const uid = doc.ref.parent.parent?.id ?? '';
          const shortId = uid ? uid.slice(0, 4).toUpperCase() : '----';
          return {
            uid,
            displayName: uid === request.auth?.uid ? 'VOCE' : `HUNTER-${shortId}`,
            detail: `${data.playerStandingLabel} | ${data.seasonScore} pts`,
            score: data.seasonScore,
            secureWeeks: data.secureWeeks,
            updatedAt: data.updatedAt.toMillis(),
            isPlayer: uid === request.auth?.uid,
          };
        } catch (error) {
          logger.warn('Skipping malformed season reward leaderboard entry', {
            seasonKey,
            rankBracket,
            path: doc.ref.path,
            error: error instanceof Error ? error.message : String(error),
          });
          return null;
        }
      })
      .filter((entry): entry is NonNullable<typeof entry> => entry !== null)
      .sort((a, b) => {
        if (b.score != a.score) return b.score - a.score;
        if (b.secureWeeks != a.secureWeeks) return b.secureWeeks - a.secureWeeks;
        return a.updatedAt - b.updatedAt;
      })
      .slice(0, limit)
      .map((entry, index) => ({
        position: index + 1,
        displayName: entry.displayName,
        detail: entry.detail,
        isPlayer: entry.isPlayer,
      }));

    return {
      status: 'ok' as const,
      seasonKey,
      rankBracket,
      entries,
    };
  },
);

export const claimSeasonReward = onCall(
  CALLABLE_OPTIONS,
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as ClaimSeasonRewardPayload;
    const requestedSeasonKey =
      typeof payload.seasonKey === 'string' ? payload.seasonKey.trim() : '';
    const uid = request.auth.uid;
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const rewardRef = seasonRewardDocRef(db, uid);
    const profileRef = seasonProfileDocRef(db, uid);

    return db.runTransaction(async (transaction) => {
      const rewardSnap = await transaction.get(rewardRef);
      if (!rewardSnap.exists || !rewardSnap.data()) {
        throw new HttpsError('not-found', 'Recompensa sazonal atual nao encontrada.');
      }

      const rawSeasonReward = validateSeasonRewardPayload(rewardSnap.data());
      if (rawSeasonReward == null) {
        throw new HttpsError('failed-precondition', 'Recompensa sazonal atual invalida.');
      }
      const seasonReward: ValidatedSeasonReward = rawSeasonReward;
      if (requestedSeasonKey && requestedSeasonKey !== seasonReward.seasonKey) {
        throw new HttpsError('failed-precondition', 'A recompensa sazonal atual mudou.');
      }

      if (!seasonReward.rewardUnlocked || seasonReward.claimStatus === 'locked') {
        throw new HttpsError('failed-precondition', 'Recompensa sazonal ainda bloqueada.');
      }

      if (seasonReward.claimStatus === 'claimed') {
        return {
          status: 'already_claimed' as const,
          seasonKey: seasonReward.seasonKey,
        };
      }

      if (seasonReward.claimStatus !== 'readyToClaim') {
        throw new HttpsError('failed-precondition', 'Recompensa sazonal ainda nao esta pronta.');
      }

      const claimedReward: ValidatedSeasonReward = {
        ...seasonReward,
        claimStatus: 'claimed',
        claimedAt: now,
        syncSource: 'backend',
        updatedAt: now,
      };
      const legacyReward = buildSeasonLegacyPayload(claimedReward, now);
      const legacyRef = seasonLegacyDocRef(db, uid, seasonReward.seasonKey);
      const historyRef = seasonRewardHistoryDocRef(db, uid, seasonReward.seasonKey);
      const profilePayload = buildSeasonProfilePayload(legacyReward);

      transaction.set(rewardRef, claimedReward, { merge: true });
      transaction.set(historyRef, claimedReward, { merge: true });
      transaction.set(legacyRef, legacyReward, { merge: true });
      transaction.set(profileRef, profilePayload, { merge: true });

      return {
        status: 'claimed' as const,
        seasonKey: seasonReward.seasonKey,
        rewardName: seasonReward.rewardName,
        activeTitleLabel: profilePayload.activeTitleLabel,
      };
    });
  },
);
