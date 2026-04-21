import * as admin from 'firebase-admin';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

admin.initializeApp();

type ClaimWeeklyBossPayload = {
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

type CompetitiveQuestSessionPayload = {
  questId?: unknown;
  title?: unknown;
  templateType?: unknown;
  verificationMode?: unknown;
  targetDurationMinutes?: unknown;
  xpReward?: unknown;
  rewardAttribute?: unknown;
  verificationStartedAt?: unknown;
  reflectionAnswer?: unknown;
};

type ValidatedSeasonReward = NonNullable<
  ReturnType<typeof validateSeasonRewardPayload>
>;

type CompetitiveSource = ReturnType<typeof validateCompetitiveSourcePayload>;
type CompetitiveIntegritySource = ReturnType<
  typeof validateCompetitiveIntegritySourcePayload
>;

type CompetitiveQuestSessionRecord = {
  startedAt?: admin.firestore.Timestamp | null;
};

type CompetitiveQuestGrantRecord = {
  completedAt?: admin.firestore.Timestamp | null;
};

const COMPETITIVE_SYNC_SCHEMA_VERSION = 3;

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
  title: string;
  templateType: string;
  verificationMode: string;
  targetDurationMinutes: number;
  xpReward: number;
  rewardAttribute: string;
};

type ServerSeasonRewardPayload = {
  seasonKey: string;
  seasonLabel: string;
  currentRankBracket: string;
  rewardTierLabel: string;
  rewardStatusLabel: string;
  rewardUnlocked: boolean;
  rewardName: string;
  rewardBadgeLabel: string;
  rewardTitleLabel: string;
  rewardBonusLabel: string;
  recordedWeeks: number;
  secureWeeks: number;
  seasonScore: number;
  scoreBandLabel: string;
  clearRateLabel: string;
  playerStandingLabel: string;
  spotlightLabel: string;
  resetLabel: string;
  claimStatus: string;
  syncSchemaVersion: number;
  syncSource: string;
  updatedAt: admin.firestore.Timestamp;
  claimedAt: admin.firestore.Timestamp | null;
};

function sanitizeDisplayName(value: unknown): string {
  const text = typeof value === 'string' ? value.trim() : '';
  if (!text) return 'Hunter';
  return text.length > 40 ? text.slice(0, 40) : text;
}

function sanitizePhotoUrl(value: unknown): string {
  const text = typeof value === 'string' ? value.trim() : '';
  if (!text) return '';
  return text.length > 500 ? text.slice(0, 500) : text;
}

function normalizeRank(value: unknown): string {
  const text = typeof value === 'string' ? value.trim().toUpperCase() : '';
  return text;
}

function normalizeSyncSource(value: unknown): string {
  const text = typeof value === 'string' ? value.trim().toLowerCase() : '';
  return text;
}

function rankOrder(rank: string): number {
  switch (rank.trim().toUpperCase()) {
  case 'E':
    return 0;
  case 'D':
    return 1;
  case 'C':
    return 2;
  case 'B':
    return 3;
  case 'A':
    return 4;
  default:
    return 5;
  }
}

function rankAfter(rank: string): string | null {
  switch (rank.trim().toUpperCase()) {
  case 'E':
    return 'D';
  case 'D':
    return 'C';
  case 'C':
    return 'B';
  case 'B':
    return 'A';
  case 'A':
    return 'S';
  default:
    return null;
  }
}

function higherRank(rankA: string, rankB: string): string {
  return rankOrder(rankA) >= rankOrder(rankB) ? rankA : rankB;
}

function rankRequirements(rank: string) {
  switch (rank.trim().toUpperCase()) {
  case 'E':
    return {
      minimumLevel: 1,
      requiredActiveDays: 3,
      requiresBossClear: false,
      maxFailedWeeksBeforeDemotion: 2,
    };
  case 'D':
    return {
      minimumLevel: 5,
      requiredActiveDays: 4,
      requiresBossClear: false,
      maxFailedWeeksBeforeDemotion: 2,
    };
  case 'C':
    return {
      minimumLevel: 10,
      requiredActiveDays: 5,
      requiresBossClear: true,
      maxFailedWeeksBeforeDemotion: 2,
    };
  case 'B':
    return {
      minimumLevel: 20,
      requiredActiveDays: 5,
      requiresBossClear: true,
      maxFailedWeeksBeforeDemotion: 2,
    };
  case 'A':
    return {
      minimumLevel: 30,
      requiredActiveDays: 6,
      requiresBossClear: true,
      maxFailedWeeksBeforeDemotion: 2,
    };
  default:
    return {
      minimumLevel: 40,
      requiredActiveDays: 6,
      requiresBossClear: true,
      maxFailedWeeksBeforeDemotion: 2,
    };
  }
}

function playerRankForLevel(level: number): string {
  if (level < 5) return 'E';
  if (level < 10) return 'D';
  if (level < 20) return 'C';
  if (level < 30) return 'B';
  if (level < 40) return 'A';
  return 'S';
}

function rankBefore(rank: string): string | null {
  switch (rank.trim().toUpperCase()) {
  case 'D':
    return 'E';
  case 'C':
    return 'D';
  case 'B':
    return 'C';
  case 'A':
    return 'B';
  case 'S':
    return 'A';
  default:
    return null;
  }
}

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

function ensureString(value: unknown, field: string, maxLength: number): string {
  if (typeof value !== 'string') {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }

  const text = value.trim();
  if (!text || text.length > maxLength) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }

  return text;
}

function ensureInt(value: unknown, field: string, min: number): number {
  if (typeof value !== 'number' || !Number.isInteger(value) || value < min) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }

  return value;
}

function ensureBool(value: unknown, field: string): boolean {
  if (typeof value !== 'boolean') {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }

  return value;
}

export function parseTimestampInput(value: unknown): admin.firestore.Timestamp | null {
  if (value instanceof admin.firestore.Timestamp) {
    return value;
  }

  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    return admin.firestore.Timestamp.fromDate(value);
  }

  if (typeof value === 'string') {
    const parsed = new Date(value);
    if (!Number.isNaN(parsed.getTime())) {
      return admin.firestore.Timestamp.fromDate(parsed);
    }
  }

  return null;
}

function ensureTimestamp(value: unknown, field: string): admin.firestore.Timestamp {
  const timestamp = parseTimestampInput(value);
  if (timestamp != null) {
    return timestamp;
  }

  throw new HttpsError('invalid-argument', `${field} invalido.`);
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

function ensureTimestampArray(value: unknown, field: string): admin.firestore.Timestamp[] {
  if (!Array.isArray(value)) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }

  return value.map((entry, index) => ensureTimestamp(entry, `${field}[${index}]`));
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
  return [
    {
      title: 'Sessao de foco de 25 minutos',
      templateType: 'focusSession',
      verificationMode: 'timer',
      targetDurationMinutes: 25,
      xpReward: 30,
      rewardAttribute: 'agility',
    },
    {
      title: 'Leitura de 20 minutos',
      templateType: 'readingSession',
      verificationMode: 'timerWithReflection',
      targetDurationMinutes: 20,
      xpReward: 30,
      rewardAttribute: 'intelligence',
    },
    {
      title: 'Estudo profundo de 30 minutos',
      templateType: 'studySession',
      verificationMode: 'timer',
      targetDurationMinutes: 30,
      xpReward: 35,
      rewardAttribute: 'intelligence',
    },
    {
      title: 'Revisao de treino de 15 minutos',
      templateType: 'readingSession',
      verificationMode: 'timerWithReflection',
      targetDurationMinutes: 15,
      xpReward: 25,
      rewardAttribute: 'intelligence',
    },
    {
      title: 'Sessao de foco de 20 minutos',
      templateType: 'focusSession',
      verificationMode: 'timer',
      targetDurationMinutes: 20,
      xpReward: 25,
      rewardAttribute: 'vitality',
    },
    {
      title: 'Leitura ou revisao de 15 minutos',
      templateType: 'readingSession',
      verificationMode: 'timerWithReflection',
      targetDurationMinutes: 15,
      xpReward: 25,
      rewardAttribute: 'intelligence',
    },
    {
      title: 'Bloco de foco de 30 minutos',
      templateType: 'focusSession',
      verificationMode: 'timer',
      targetDurationMinutes: 30,
      xpReward: 35,
      rewardAttribute: 'agility',
    },
    {
      title: 'Revisao de 20 minutos',
      templateType: 'studySession',
      verificationMode: 'timerWithReflection',
      targetDurationMinutes: 20,
      xpReward: 30,
      rewardAttribute: 'intelligence',
    },
  ];
}

function validateCompetitiveQuestSessionPayload(payload: unknown) {
  if (!payload || typeof payload !== 'object') {
    throw new HttpsError('invalid-argument', 'Payload da quest competitiva invalido.');
  }

  const data = payload as Record<string, unknown>;
  const questId = ensureString(data.questId, 'questId', 120);
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
  const reflectionAnswer =
    data.reflectionAnswer == null ? null : ensureString(data.reflectionAnswer, 'reflectionAnswer', 500);

  const definition = competitiveQuestDefinitions().find((entry) =>
    entry.title === title &&
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
    title,
    templateType,
    verificationMode,
    targetDurationMinutes,
    xpReward,
    rewardAttribute,
    reflectionAnswer,
  };
}

export function resolveCompetitiveQuestSessionStart(args: {
  quest: ReturnType<typeof validateCompetitiveQuestSessionPayload>;
  session: CompetitiveQuestSessionRecord | null;
  grant: CompetitiveQuestGrantRecord | null;
  now: admin.firestore.Timestamp;
}) {
  const {quest, session, grant, now} = args;

  if (grant) {
    throw new HttpsError('failed-precondition', 'Essa quest ja foi validada.');
  }

  if (session?.startedAt instanceof admin.firestore.Timestamp) {
    return {
      status: 'already_started' as const,
      startedAt: session.startedAt.toDate().toISOString(),
      sessionWrite: null,
    };
  }

  return {
    status: 'started' as const,
    startedAt: now.toDate().toISOString(),
    sessionWrite: {
      questId: quest.questId,
      title: quest.title,
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
  quest: ReturnType<typeof validateCompetitiveQuestSessionPayload>;
  session: CompetitiveQuestSessionRecord | null;
  grant: CompetitiveQuestGrantRecord | null;
  now: admin.firestore.Timestamp;
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

  if (quest.verificationMode === 'timer' || quest.verificationMode === 'timerWithReflection') {
    if (!(session?.startedAt instanceof admin.firestore.Timestamp)) {
      throw new HttpsError('failed-precondition', 'A sessao ainda nao foi iniciada.');
    }

    const elapsedMinutes = Math.floor((now.toMillis() - session.startedAt.toMillis()) / (60 * 1000));
    if (elapsedMinutes < quest.targetDurationMinutes) {
      throw new HttpsError('failed-precondition', 'Ainda falta tempo para validar essa quest.');
    }
  }

  if (quest.verificationMode === 'timerWithReflection' && !quest.reflectionAnswer) {
    throw new HttpsError('failed-precondition', 'A resposta curta ainda nao foi enviada.');
  }

  return {
    status: 'verified' as const,
    completedAt: now.toDate().toISOString(),
    grantWrite: {
      questId: quest.questId,
      title: quest.title,
      templateType: quest.templateType,
      verificationMode: quest.verificationMode,
      targetDurationMinutes: quest.targetDurationMinutes,
      xpReward: quest.xpReward,
      rewardAttribute: quest.rewardAttribute,
      completedAt: now,
      dayKey: normalizedDateKey(now),
      approvedAt: now,
    },
    sessionWrite: {
      status: 'verified',
      completedAt: now,
      updatedAt: now,
    },
  };
}

function normalizedDateKey(value: admin.firestore.Timestamp | Date): string {
  const date = value instanceof Date ? value : value.toDate();
  const normalized = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  return `${normalized.getFullYear()}-${String(normalized.getMonth() + 1).padStart(2, '0')}-${String(
    normalized.getDate(),
  ).padStart(2, '0')}`;
}

function normalizedDateFromKey(value: string): Date {
  const parts = value.split('-');
  return new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
}

function uniqueTimestampsByDay(
  timestamps: admin.firestore.Timestamp[],
): admin.firestore.Timestamp[] {
  const byDay = new Map<string, admin.firestore.Timestamp>();
  for (const timestamp of timestamps) {
    byDay.set(normalizedDateKey(timestamp), timestamp);
  }
  return Array.from(byDay.values()).sort((a, b) => a.toMillis() - b.toMillis());
}

function weekStartDate(value: Date): Date {
  const normalized = new Date(value.getFullYear(), value.getMonth(), value.getDate());
  return new Date(
    normalized.getFullYear(),
    normalized.getMonth(),
    normalized.getDate() - (normalized.getDay() === 0 ? 6 : normalized.getDay() - 1),
  );
}

function weekKeyForDate(value: Date): string {
  const weekStart = weekStartDate(value);
  return `${weekStart.getFullYear()}W${String(weekStart.getMonth() + 1).padStart(2, '0')}${String(
    weekStart.getDate(),
  ).padStart(2, '0')}`;
}

function dateFromWeekKey(weekKey: string): Date | null {
  const parts = weekKey.split('W');
  if (parts.length !== 2 || parts[1].length !== 4) return null;
  const year = Number(parts[0]);
  const month = Number(parts[1].slice(0, 2));
  const day = Number(parts[1].slice(2, 4));
  if (!Number.isInteger(year) || !Number.isInteger(month) || !Number.isInteger(day)) {
    return null;
  }
  return new Date(year, month - 1, day);
}

function currentWeekDateKeys(values: admin.firestore.Timestamp[], now: Date): Set<string> {
  const weekStart = weekStartDate(now);
  const weekEnd = new Date(weekStart.getFullYear(), weekStart.getMonth(), weekStart.getDate() + 7);
  return new Set(
    values
      .map((entry) => normalizedDateFromKey(normalizedDateKey(entry)))
      .filter((date) => date >= weekStart && date < weekEnd)
      .map((date) => normalizedDateKey(date)),
  );
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

function resolveExamAfterSnapshot(args: {
  snapshot: ReturnType<typeof evaluateCompetitiveRankFromSource>;
  currentExam: ReturnType<typeof validateExamPayload> | null;
  now: admin.firestore.Timestamp;
}) {
  const {snapshot, currentExam, now} = args;
  if (!currentExam) return null;
  if (currentExam.status !== 'inProgress') {
    return {
      ...currentExam,
      syncSchemaVersion: COMPETITIVE_SYNC_SCHEMA_VERSION,
      syncSource: 'backend',
    };
  }

  if (
    snapshot.weekKey !== currentExam.sourceWeekKey ||
    now.toMillis() > currentExam.expiresAt.toMillis()
  ) {
    return {
      ...currentExam,
      status: 'failed',
      resolvedAt: now,
      syncSchemaVersion: COMPETITIVE_SYNC_SCHEMA_VERSION,
      syncSource: 'backend',
    };
  }

  const targetActiveDays = currentExam.baselineActiveDays + currentExam.requiredExtraActiveDays;
  const passed =
    snapshot.activeDays >= targetActiveDays &&
    (!currentExam.bossRequired || snapshot.bossCompleted);
  if (!passed) {
    return {
      ...currentExam,
      syncSchemaVersion: COMPETITIVE_SYNC_SCHEMA_VERSION,
      syncSource: 'backend',
    };
  }

  return {
    ...currentExam,
    status: 'passed',
    resolvedAt: now,
    syncSchemaVersion: COMPETITIVE_SYNC_SCHEMA_VERSION,
    syncSource: 'backend',
  };
}

function seasonBoundsFor(now: Date) {
  const start = new Date(now.getFullYear(), now.getMonth(), 1);
  const end = new Date(now.getFullYear(), now.getMonth() + 1, 1);
  return {start, end};
}

function seasonKeyFor(now: Date): string {
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
}

function seasonLabelFor(now: Date): string {
  const months = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];
  return `${months[now.getMonth()]} ${now.getFullYear()}`;
}

function seasonWeekCapacity(now: Date): number {
  const bounds = seasonBoundsFor(now);
  return Math.ceil((bounds.end.getTime() - bounds.start.getTime()) / (7 * 24 * 60 * 60 * 1000));
}

function remainingSeasonWeeks(now: Date, seasonEnd: Date): number {
  const normalizedNow = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  if (normalizedNow >= seasonEnd) return 0;
  const days = Math.floor((seasonEnd.getTime() - normalizedNow.getTime()) / (24 * 60 * 60 * 1000));
  return Math.floor((days + 6) / 7);
}

function resetLabelFor(now: Date, seasonEnd: Date): string {
  const normalizedNow = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const days = Math.floor((seasonEnd.getTime() - normalizedNow.getTime()) / (24 * 60 * 60 * 1000));
  if (days <= 0) return 'Reset em andamento';
  if (days === 1) return 'Reset amanha';
  if (days <= 7) return `Reset em ${days} dias`;
  return `Reset em ${Math.floor((days + 6) / 7)} semana(s)`;
}

function rewardTrackForSeason(args: {
  secureWeeks: number;
  totalSeasonWeeks: number;
  promotionEvents: number;
  perfectWeeks: number;
  demotionEvents: number;
}) {
  if (args.demotionEvents > 0) {
    return {
      statusLabel: 'INSTAVEL',
      trackLabel: `${args.secureWeeks}/${args.totalSeasonWeeks} semanas seguras`,
      progress: Math.min(1, args.secureWeeks / args.totalSeasonWeeks),
      nextUnlockHint:
        'Elimine quedas e reconstrua 2 semanas seguras para voltar ao circuito sazonal.',
    };
  }
  if (args.secureWeeks < 2) {
    return {
      statusLabel: 'ABRINDO TRILHA',
      trackLabel: `${args.secureWeeks}/2 semanas seguras`,
      progress: Math.min(1, args.secureWeeks / 2),
      nextUnlockHint: `Mais ${2 - args.secureWeeks} semana(s) segura(s) para garantir a recompensa basica.`,
    };
  }
  if (args.secureWeeks < 3) {
    return {
      statusLabel: 'EM ROTA',
      trackLabel: `${args.secureWeeks}/3 semanas seguras`,
      progress: Math.min(1, args.secureWeeks / 3),
      nextUnlockHint: `Mais ${3 - args.secureWeeks} semana(s) segura(s) para destravar DOMINIO.`,
    };
  }
  if (args.promotionEvents < 1 || args.perfectWeeks < 1) {
    const missing: string[] = [];
    if (args.promotionEvents < 1) missing.push('1 promocao confirmada');
    if (args.perfectWeeks < 1) missing.push('1 semana perfeita');
    return {
      statusLabel: 'RECOMPENSA AVANCADA',
      trackLabel: `${args.secureWeeks}/${args.totalSeasonWeeks} semanas seguras`,
      progress: 0.85,
      nextUnlockHint: `Falta ${missing.join(' e ')} para atingir ASCENSAO nesta temporada.`,
    };
  }
  return {
    statusLabel: 'GARANTIDA',
    trackLabel: `${args.secureWeeks}/${args.totalSeasonWeeks} semanas seguras`,
    progress: 1,
    nextUnlockHint:
      'A trilha sazonal principal ja foi garantida. Agora o objetivo e fechar a temporada sem queda.',
  };
}

function rewardTierForSeason(args: {
  secureWeeks: number;
  promotionEvents: number;
  perfectWeeks: number;
  demotionEvents: number;
}) {
  if (args.promotionEvents >= 1 && args.perfectWeeks >= 1 && args.demotionEvents === 0) {
    return {
      label: 'ASCENSAO',
      preview: 'Selo de temporada limpa, moldura premium de rank e bonus futuro de prestigio.',
    };
  }
  if (args.secureWeeks >= 3 && args.demotionEvents === 0) {
    return {
      label: 'DOMINIO',
      preview: 'Recompensa futura de emblema competitivo e destaque no historico sazonal.',
    };
  }
  if (args.secureWeeks >= 2) {
    return {
      label: 'MANUTENCAO',
      preview: 'Temporada consistente. Voce ja esta em rota de recompensa sazonal basica.',
    };
  }
  if (args.demotionEvents > 0) {
    return {
      label: 'INSTAVEL',
      preview: 'Sem recompensa sazonal por enquanto. O sistema exige estabilizacao antes do reset.',
    };
  }
  return {
    label: 'EM FORMACAO',
    preview: 'Acumule semanas registradas para destravar a trilha de recompensa da temporada.',
  };
}

function rewardPayloadForSeason(tierLabel: string, rewardStatusLabel: string) {
  switch (tierLabel) {
  case 'ASCENSAO':
    return {
      unlocked: true,
      rewardName: 'Pacote Ascensao da Temporada',
      badgeLabel: 'SIGILO DE OURO',
      titleLabel: 'ASCENDENTE DA TEMPORADA',
      bonusLabel: 'Moldura premium de rank, selo dourado e destaque maximo no historico sazonal.',
    };
  case 'DOMINIO':
    return {
      unlocked: true,
      rewardName: 'Pacote Dominio do Rank',
      badgeLabel: 'SIGILO DE PRATA',
      titleLabel: 'COMANDANTE DO RANK',
      bonusLabel: 'Moldura de temporada, selo prateado e destaque elevado no historico competitivo.',
    };
  case 'MANUTENCAO':
    return {
      unlocked: true,
      rewardName: 'Pacote de Manutencao',
      badgeLabel: 'SIGILO DE BRONZE',
      titleLabel: 'VIGIA DO CICLO',
      bonusLabel: 'Insignia sazonal, selo de consistencia e registro de temporada valida.',
    };
  case 'INSTAVEL':
    return {
      unlocked: false,
      rewardName: 'Pacote em recuperacao',
      badgeLabel: 'EM RISCO',
      titleLabel: 'RECUPERANDO POSICAO',
      bonusLabel:
        rewardStatusLabel === 'INSTAVEL'
          ? 'Sem premio liberado. Reconstrua a trilha com semanas seguras.'
          : 'A trilha ainda nao estabilizou o bastante para liberar premio.',
    };
  default:
    return {
      unlocked: false,
      rewardName: 'Trilha sazonal bloqueada',
      badgeLabel: 'SEM EMBLEMA',
      titleLabel: 'Sem titulo sazonal',
      bonusLabel: 'Nenhum pacote sazonal liberado.',
    };
  }
}

function seasonScoreForSnapshotHistory(history: ReturnType<typeof validateSnapshotPayload>[]) {
  const secureWeeks = history.filter((entry) => entry.status === 'secure' || entry.status === 'promotionReady').length;
  const examWeeks = history.filter(
    (entry) => entry.eventType === 'promotionUnlocked' || entry.eventType === 'promotionConfirmed',
  ).length;
  const promotionEvents = history.filter((entry) => entry.eventType === 'promotionConfirmed').length;
  const perfectWeeks = history.filter((entry) => entry.eventType === 'perfectWeek').length;
  const demotionEvents = history.filter((entry) => entry.status === 'demoted').length;
  return {
    secureWeeks,
    examWeeks,
    promotionEvents,
    perfectWeeks,
    demotionEvents,
    seasonScore: secureWeeks * 3 + examWeeks * 2 + promotionEvents * 5 + perfectWeeks * 4 - demotionEvents * 4,
  };
}

function scoreBandForSeasonScore(score: number) {
  if (score >= 16) return 'LIDERANCA';
  if (score >= 10) return 'ELITE';
  if (score >= 6) return 'DISPUTA';
  return 'RECUPERACAO';
}

function playerStandingForSeasonScore(score: number): string {
  if (score >= 16) return 'LIDER DO RANK';
  if (score >= 10) return 'NA ZONA DE PRESTIGIO';
  if (score >= 6) return 'NA DISPUTA';
  return 'FORA DO CORTE';
}

function buildSeasonRewardFromHistory(args: {
  history: ReturnType<typeof validateSnapshotPayload>[];
  snapshot: ReturnType<typeof evaluateCompetitiveRankFromSource>;
  currentReward: ValidatedSeasonReward | null;
  now: Date;
}): ServerSeasonRewardPayload {
  const seasonKey = seasonKeyFor(args.now);
  const seasonLabel = seasonLabelFor(args.now);
  const bounds = seasonBoundsFor(args.now);
  const seasonEntries = args.history
    .filter((entry) => {
      const date = dateFromWeekKey(entry.weekKey);
      return date != null && date >= bounds.start && date < bounds.end;
    })
    .sort((a, b) => rankOrder(b.currentRank) - rankOrder(a.currentRank));

  const totalSeasonWeeks = seasonWeekCapacity(args.now);
  const updatedAt = admin.firestore.Timestamp.fromDate(args.now);

  if (seasonEntries.length === 0) {
    const lockedReward = rewardPayloadForSeason('EM FORMACAO', 'BLOQUEADA');
    return {
      seasonKey,
      seasonLabel,
      currentRankBracket: args.snapshot.currentRank,
      rewardTierLabel: 'SEM DADOS',
      rewardStatusLabel: 'BLOQUEADA',
      rewardUnlocked: false,
      rewardName: lockedReward.rewardName,
      rewardBadgeLabel: lockedReward.badgeLabel,
      rewardTitleLabel: lockedReward.titleLabel,
      rewardBonusLabel: lockedReward.bonusLabel,
      recordedWeeks: 0,
      secureWeeks: 0,
      seasonScore: 0,
      scoreBandLabel: 'RECUPERACAO',
      clearRateLabel: 'Clear rate aguardando lobby',
      playerStandingLabel: 'FORA DO CORTE',
      spotlightLabel: 'Sem boss ativo. O placar sazonal volta com a proxima rotacao.',
      resetLabel: resetLabelFor(args.now, bounds.end),
      claimStatus: 'locked',
      syncSchemaVersion: COMPETITIVE_SYNC_SCHEMA_VERSION,
      syncSource: 'backend',
      updatedAt,
      claimedAt: null,
    };
  }

  const seasonScoreData = seasonScoreForSnapshotHistory(seasonEntries);
  const rewardTier = rewardTierForSeason({
    secureWeeks: seasonScoreData.secureWeeks,
    promotionEvents: seasonScoreData.promotionEvents,
    perfectWeeks: seasonScoreData.perfectWeeks,
    demotionEvents: seasonScoreData.demotionEvents,
  });
  const rewardTrack = rewardTrackForSeason({
    secureWeeks: seasonScoreData.secureWeeks,
    totalSeasonWeeks,
    promotionEvents: seasonScoreData.promotionEvents,
    perfectWeeks: seasonScoreData.perfectWeeks,
    demotionEvents: seasonScoreData.demotionEvents,
  });
  const rewardPayload = rewardPayloadForSeason(rewardTier.label, rewardTrack.statusLabel);
  const previousClaimed =
    args.currentReward != null &&
    args.currentReward.seasonKey === seasonKey &&
    args.currentReward.claimStatus === 'claimed';
  const claimStatus = previousClaimed
    ? 'claimed'
    : rewardPayload.unlocked
      ? 'readyToClaim'
      : 'locked';

  return {
    seasonKey,
    seasonLabel,
    currentRankBracket: args.snapshot.currentRank,
    rewardTierLabel: rewardTier.label,
    rewardStatusLabel: rewardTrack.statusLabel,
    rewardUnlocked: rewardPayload.unlocked,
    rewardName: rewardPayload.rewardName,
    rewardBadgeLabel: rewardPayload.badgeLabel,
    rewardTitleLabel: rewardPayload.titleLabel,
    rewardBonusLabel: rewardPayload.bonusLabel,
    recordedWeeks: seasonEntries.length,
    secureWeeks: seasonScoreData.secureWeeks,
    seasonScore: seasonScoreData.seasonScore,
    scoreBandLabel: scoreBandForSeasonScore(seasonScoreData.seasonScore),
    clearRateLabel: 'Clear rate aguardando lobby',
    playerStandingLabel: playerStandingForSeasonScore(seasonScoreData.seasonScore),
    spotlightLabel: 'Sem boss ativo. O placar sazonal volta com a proxima rotacao.',
    resetLabel: resetLabelFor(args.now, bounds.end),
    claimStatus,
    syncSchemaVersion: COMPETITIVE_SYNC_SCHEMA_VERSION,
    syncSource: 'backend',
    updatedAt,
    claimedAt: previousClaimed ? args.currentReward?.claimedAt ?? null : null,
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

function buildSeasonLegacyPayload(
  seasonReward: ValidatedSeasonReward,
  claimedAt: admin.firestore.Timestamp,
) {
  const cosmetics = buildSeasonCosmetics(
    seasonReward.rewardTierLabel,
    seasonReward.currentRankBracket,
    seasonReward.scoreBandLabel,
  );

  return {
    seasonKey: seasonReward.seasonKey,
    seasonLabel: seasonReward.seasonLabel,
    claimedRankBracket: seasonReward.currentRankBracket,
    rewardTierLabel: seasonReward.rewardTierLabel,
    rewardName: seasonReward.rewardName,
    rewardBadgeLabel: seasonReward.rewardBadgeLabel,
    rewardTitleLabel: seasonReward.rewardTitleLabel,
    rewardBonusLabel: seasonReward.rewardBonusLabel,
    scoreBandLabel: seasonReward.scoreBandLabel,
    seasonScore: seasonReward.seasonScore,
    playerStandingLabel: seasonReward.playerStandingLabel,
    spotlightLabel: seasonReward.spotlightLabel,
    cosmeticFrameLabel: cosmetics.frameLabel,
    cosmeticAuraLabel: cosmetics.auraLabel,
    claimedAt,
    syncSchemaVersion: seasonReward.syncSchemaVersion,
    syncSource: 'backend',
    updatedAt: claimedAt,
  };
}

function buildSeasonProfilePayload(
  legacyReward: ReturnType<typeof buildSeasonLegacyPayload>,
) {
  return {
    activeSeasonKey: legacyReward.seasonKey,
    activeSeasonLabel: legacyReward.seasonLabel,
    activeRewardName: legacyReward.rewardName,
    activeBadgeLabel: legacyReward.rewardBadgeLabel,
    activeTitleLabel: legacyReward.rewardTitleLabel,
    cosmeticFrameLabel: legacyReward.cosmeticFrameLabel,
    cosmeticAuraLabel: legacyReward.cosmeticAuraLabel,
    equippedAt: legacyReward.claimedAt,
    syncSchemaVersion: legacyReward.syncSchemaVersion,
    syncSource: 'backend',
    updatedAt: legacyReward.updatedAt,
  };
}

function buildSeasonCosmetics(
  rewardTierLabel: string,
  rankBracket: string,
  scoreBandLabel: string,
) {
  const tier = rewardTierLabel.trim().toUpperCase();
  const band = scoreBandLabel.trim().toUpperCase();

  if (band === 'LIDERANCA' || rankBracket === 'S') {
    return {
      frameLabel: 'QUADRO SOBERANO',
      auraLabel: 'AURA DO COMANDANTE',
    };
  }
  if (band === 'ELITE' || rankBracket === 'A') {
    return {
      frameLabel: 'QUADRO VANGUARDA',
      auraLabel: 'AURA AZUL ASCENDENTE',
    };
  }
  if (tier.includes('MANUTENCAO') || rankBracket === 'B' || rankBracket === 'C') {
    return {
      frameLabel: 'QUADRO DE BRONZE',
      auraLabel: 'AURA DE DISCIPLINA',
    };
  }

  return {
    frameLabel: 'QUADRO DE FERRO',
    auraLabel: 'AURA CONTIDA',
  };
}

export const claimWeeklyBoss = onCall(
  {
    region: 'southamerica-east1',
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as ClaimWeeklyBossPayload;
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

    const bossRef = db.collection('weekly_bosses').doc(bossId);
    const completionRef = bossRef.collection('completions').doc(uid);

    return db.runTransaction(async (transaction) => {
      const [bossSnap, completionSnap] = await Promise.all([
        transaction.get(bossRef),
        transaction.get(completionRef),
      ]);

      if (!bossSnap.exists) {
        throw new HttpsError('not-found', 'Boss semanal nao encontrado.');
      }

      if (completionSnap.exists) {
        return { status: 'already_completed' as const };
      }

      const data = bossSnap.data() ?? {};
      const isActive = Boolean(data.isActive);
      const startsAt = data.startsAt as admin.firestore.Timestamp | undefined;
      const endsAt = data.endsAt as admin.firestore.Timestamp | undefined;
      const bossRank = normalizeRank(data.rank);

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

      transaction.set(completionRef, {
        uid,
        displayName,
        photoUrl,
        rankAtCompletion: bossRank,
        completedAt: now,
      });

      transaction.update(bossRef, {
        completedCount: admin.firestore.FieldValue.increment(1),
      });

      return { status: 'claimed' as const };
    });
  },
);

export const startCompetitiveQuestSession = onCall(
  {
    region: 'southamerica-east1',
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as CompetitiveQuestSessionPayload;
    const quest = validateCompetitiveQuestSessionPayload(payload);
    const uid = request.auth.uid;
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const sessionRef = db
      .collection('users')
      .doc(uid)
      .collection('competitive_quest_sessions')
      .doc(quest.questId);
    const grantRef = db
      .collection('users')
      .doc(uid)
      .collection('competitive_quest_grants')
      .doc(quest.questId);

    return db.runTransaction(async (transaction) => {
      const [sessionSnap, grantSnap] = await Promise.all([
        transaction.get(sessionRef),
        transaction.get(grantRef),
      ]);
      const resolution = resolveCompetitiveQuestSessionStart({
        quest,
        session: sessionSnap.exists ? (sessionSnap.data() ?? null) : null,
        grant: grantSnap.exists ? (grantSnap.data() ?? null) : null,
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

export const verifyCompetitiveQuestCompletion = onCall(
  {
    region: 'southamerica-east1',
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as CompetitiveQuestSessionPayload;
    const quest = validateCompetitiveQuestSessionPayload(payload);
    const uid = request.auth.uid;
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const sessionRef = db
      .collection('users')
      .doc(uid)
      .collection('competitive_quest_sessions')
      .doc(quest.questId);
    const grantRef = db
      .collection('users')
      .doc(uid)
      .collection('competitive_quest_grants')
      .doc(quest.questId);

    return db.runTransaction(async (transaction) => {
      const [sessionSnap, grantSnap] = await Promise.all([
        transaction.get(sessionRef),
        transaction.get(grantRef),
      ]);
      const resolution = resolveCompetitiveQuestCompletionVerification({
        quest,
        session: sessionSnap.exists ? (sessionSnap.data() ?? null) : null,
        grant: grantSnap.exists ? (grantSnap.data() ?? null) : null,
        now,
      });

      if (resolution.grantWrite) {
        transaction.set(grantRef, resolution.grantWrite, {merge: true});
      }
      if (resolution.sessionWrite) {
        transaction.set(sessionRef, resolution.sessionWrite, {merge: true});
      }

      return {
        status: resolution.status,
        completedAt: resolution.completedAt,
      };
    });
  },
);

export const syncCompetitiveStateFromSource = onCall(
  {
    region: 'southamerica-east1',
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as CompetitiveSyncSourcePayload;
    const source = validateCompetitiveSourcePayload(payload.source);
    const uid = request.auth.uid;
    const db = admin.firestore();
    const now = new Date();

    const currentRef = db.collection('users').doc(uid).collection('progression').doc('current');
    const examRef = db.collection('users').doc(uid).collection('promotion_exam').doc('current');
    const seasonRewardRef = db.collection('users').doc(uid).collection('season_rewards').doc('current');
    const competitiveGrantQuery = db
      .collection('users')
      .doc(uid)
      .collection('competitive_quest_grants')
      .orderBy('completedAt', 'desc')
      .limit(180);
    const historyQuery = db
      .collection('users')
      .doc(uid)
      .collection('progression_history')
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
      db.collection('users').doc(uid).collection('progression_history').doc(serverSnapshot.weekKey),
      serverSnapshot,
      {merge: true},
    );
    if (resolvedExam) {
      batch.set(examRef, resolvedExam, {merge: true});
    }
    batch.set(seasonRewardRef, seasonReward, {merge: true});
    batch.set(
      db.collection('users').doc(uid).collection('season_reward_history').doc(seasonReward.seasonKey),
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
  {
    region: 'southamerica-east1',
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as CompetitiveIntegritySourcePayload;
    const source = validateCompetitiveIntegritySourcePayload(payload.source);
    const uid = request.auth.uid;
    const db = admin.firestore();
    const now = new Date();
    const competitiveGrantSnap = await db
      .collection('users')
      .doc(uid)
      .collection('competitive_quest_grants')
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
    const currentRef = db.collection('users').doc(uid).collection('integrity').doc('current');
    const historyRef = db
      .collection('users')
      .doc(uid)
      .collection('integrity_history')
      .doc(integrity.weekKey);

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
  {
    region: 'southamerica-east1',
  },
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
    const currentRef = db.collection('users').doc(uid).collection('progression').doc('current');
    const historyRef = db
      .collection('users')
      .doc(uid)
      .collection('progression_history')
      .doc(snapshot.weekKey);
    const examRef = db.collection('users').doc(uid).collection('promotion_exam').doc('current');
    const seasonRewardRef = db.collection('users').doc(uid).collection('season_rewards').doc('current');
    const seasonRewardHistoryRef = validatedSeasonReward == null
      ? null
      : db.collection('users').doc(uid).collection('season_reward_history').doc(validatedSeasonReward.seasonKey);

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
  {
    region: 'southamerica-east1',
  },
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
    const currentRef = db.collection('users').doc(uid).collection('integrity').doc('current');
    const historyRef = db
      .collection('users')
      .doc(uid)
      .collection('integrity_history')
      .doc(integrity.weekKey);

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
  {
    region: 'southamerica-east1',
  },
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
    const examRef = db.collection('users').doc(uid).collection('promotion_exam').doc('current');
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
  {
    region: 'southamerica-east1',
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Usuario nao autenticado.');
    }

    const payload = (request.data ?? {}) as ConfirmPromotionPayload;
    const snapshot = validateSnapshotPayload(payload.snapshot);
    const uid = request.auth.uid;
    const db = admin.firestore();
    const currentRef = db.collection('users').doc(uid).collection('progression').doc('current');
    const historyRef = db.collection('users').doc(uid).collection('progression_history').doc(snapshot.weekKey);
    const examRef = db.collection('users').doc(uid).collection('promotion_exam').doc('current');

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
  {
    region: 'southamerica-east1',
  },
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
  {
    region: 'southamerica-east1',
  },
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
    const rewardRef = db.collection('users').doc(uid).collection('season_rewards').doc('current');
    const profileRef = db.collection('users').doc(uid).collection('season_profile').doc('current');

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
      const legacyRef = db
        .collection('users')
        .doc(uid)
        .collection('season_legacy')
        .doc(seasonReward.seasonKey);
      const historyRef = db
        .collection('users')
        .doc(uid)
        .collection('season_reward_history')
        .doc(seasonReward.seasonKey);
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
