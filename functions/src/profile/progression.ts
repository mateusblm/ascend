import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';
import {
  normalizedDateFromKey,
  normalizedDateKey,
  uniqueTimestampsByDay,
} from '../shared/date';
import {
  asName,
  asNonNegativeInt,
  asTimestampArray,
  asTimestampOrNull,
  ensureString,
} from '../shared/validation';

const PLAYER_PROFILE_SYNC_SCHEMA_VERSION = 1;

export type ServerPlayerProfileQuestSource = {
  id: string;
  title: string;
  rewardAttribute: string;
  xpReward: number;
  category: string;
  templateType: string;
  verificationMode: string;
  verificationStatus: string;
  targetDurationMinutes: number;
  reflectionPrompt: string | null;
  reflectionAnswer: string | null;
  verificationStartedAt: admin.firestore.Timestamp | null;
  completedAt: admin.firestore.Timestamp | null;
  verifiedAt: admin.firestore.Timestamp | null;
  isCompleted: boolean;
  preRewardLevel: number | null;
  preRewardXp: number | null;
  preRewardMaxXp: number | null;
  preRewardStatPoints: number | null;
  preRewardStrength: number | null;
  preRewardIntelligence: number | null;
  preRewardVitality: number | null;
  preRewardAgility: number | null;
};

export type ServerPlayerProfileSource = {
  name: string;
  attributes: {
    strength: number;
    intelligence: number;
    vitality: number;
    agility: number;
  };
  lastResetDate: admin.firestore.Timestamp;
  primaryFocus: string;
  hasCompletedOnboarding: boolean;
  quests: ServerPlayerProfileQuestSource[];
};

export type ServerWeeklyBossClaim = {
  completedAt: admin.firestore.Timestamp;
  rewardXp: number;
  rewardStatPoints: number;
};

export function ensurePrimaryFocus(value: unknown, field: string): string {
  const focus = ensureString(value, field, 32);
  if (!['discipline', 'study', 'training', 'health', 'productivity'].includes(focus)) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }
  return focus;
}

export function playerMaxXpForLevel(level: number): number {
  let current = 100;
  for (let index = 1; index < level; index += 1) {
    current = Math.floor(current * 1.2);
  }
  return current;
}

export function buildPlayerProfileSyncWrite(args: {
  source: ServerPlayerProfileSource;
  weeklyBossClaims: ServerWeeklyBossClaim[];
  deviceSessionId: string;
  deviceLabel: string;
  now: admin.firestore.Timestamp;
}) {
  const completedQuests = args.source.quests
    .filter((quest) => quest.isCompleted && quest.completedAt instanceof admin.firestore.Timestamp)
    .sort((a, b) => (a.completedAt?.toMillis() ?? 0) - (b.completedAt?.toMillis() ?? 0));
  const competitiveCompletedQuests = completedQuests
    .filter((quest) => quest.category === 'competitive' && quest.verificationStatus === 'verified');
  const activityHistory = uniqueTimestampsByDay(
    completedQuests
      .map((quest) => quest.completedAt)
      .filter((value): value is admin.firestore.Timestamp => value instanceof admin.firestore.Timestamp),
  );
  const competitiveActivityHistory = uniqueTimestampsByDay(
    competitiveCompletedQuests
      .map((quest) => quest.completedAt)
      .filter((value): value is admin.firestore.Timestamp => value instanceof admin.firestore.Timestamp),
  );
  const lastQuestCompletionDate = activityHistory.length === 0
    ? null
    : activityHistory[activityHistory.length - 1];
  const lastCompetitiveQuestCompletionDate = competitiveActivityHistory.length === 0
    ? null
    : competitiveActivityHistory[competitiveActivityHistory.length - 1];
  const questXp = completedQuests.reduce((sum, quest) => sum + quest.xpReward, 0);
  const weeklyBossXp = args.weeklyBossClaims.reduce((sum, claim) => sum + claim.rewardXp, 0);
  const weeklyBossStatPoints = args.weeklyBossClaims.reduce(
    (sum, claim) => sum + claim.rewardStatPoints,
    0,
  );
  const progression = progressionFromTotalXp(questXp + weeklyBossXp);
  const questAttributeRewards = completedQuests.reduce<{
    strength: number;
    intelligence: number;
    vitality: number;
    agility: number;
  }>((accumulator, quest) => {
    switch (quest.rewardAttribute) {
    case 'strength':
      accumulator.strength += 1;
      break;
    case 'intelligence':
      accumulator.intelligence += 1;
      break;
    case 'vitality':
      accumulator.vitality += 1;
      break;
    case 'agility':
      accumulator.agility += 1;
      break;
    }
    return accumulator;
  }, {
    strength: 0,
    intelligence: 0,
    vitality: 0,
    agility: 0,
  });
  const baseAttributes = {
    strength: 10 + questAttributeRewards.strength,
    intelligence: 10 + questAttributeRewards.intelligence,
    vitality: 10 + questAttributeRewards.vitality,
    agility: 10 + questAttributeRewards.agility,
  };
  const authoritativeAttributes = {
    strength: Math.max(args.source.attributes.strength, baseAttributes.strength),
    intelligence: Math.max(args.source.attributes.intelligence, baseAttributes.intelligence),
    vitality: Math.max(args.source.attributes.vitality, baseAttributes.vitality),
    agility: Math.max(args.source.attributes.agility, baseAttributes.agility),
  };
  const allocatedStatPoints =
    (authoritativeAttributes.strength - baseAttributes.strength) +
    (authoritativeAttributes.intelligence - baseAttributes.intelligence) +
    (authoritativeAttributes.vitality - baseAttributes.vitality) +
    (authoritativeAttributes.agility - baseAttributes.agility);
  const earnedStatPoints = progression.levelUpStatPoints + weeklyBossStatPoints;
  const streaks = streakMetricsFromHistory(activityHistory, args.now);
  const weeklyBossLastClaimedAt = args.weeklyBossClaims.length === 0
    ? null
    : args.weeklyBossClaims
      .map((claim) => claim.completedAt)
      .sort((a, b) => a.toMillis() - b.toMillis())[args.weeklyBossClaims.length - 1];

  return {
    name: args.source.name,
    level: progression.level,
    xp: progression.xp,
    maxXp: progression.maxXp,
    statPoints: Math.max(0, earnedStatPoints - allocatedStatPoints),
    attributes: authoritativeAttributes,
    lastResetDate: args.source.lastResetDate,
    currentStreak: streaks.currentStreak,
    bestStreak: streaks.bestStreak,
    lastQuestCompletionDate,
    activityHistory,
    lastCompetitiveQuestCompletionDate,
    competitiveActivityHistory,
    primaryFocus: args.source.primaryFocus,
    hasCompletedOnboarding: args.source.hasCompletedOnboarding,
    weeklyBossLastClaimedAt,
    authoritativeQuestXp: questXp,
    authoritativeWeeklyBossXp: weeklyBossXp,
    authoritativeWeeklyBossStatPoints: weeklyBossStatPoints,
    authoritativeAllocatedStatPoints: allocatedStatPoints,
    syncSchemaVersion: PLAYER_PROFILE_SYNC_SCHEMA_VERSION,
    syncSource: 'callable_server_authoritative',
    activeDeviceSessionId: args.deviceSessionId,
    activeDeviceLabel: args.deviceLabel,
    updatedAt: args.now,
  };
}

export function progressionFromTotalXp(totalXp: number) {
  let remainingXp = Math.max(0, totalXp);
  let level = 1;
  let maxXp = 100;
  let levelUpStatPoints = 0;

  while (remainingXp >= maxXp) {
    remainingXp -= maxXp;
    level += 1;
    levelUpStatPoints += 5;
    maxXp = playerMaxXpForLevel(level);
  }

  return {
    level,
    xp: remainingXp,
    maxXp,
    levelUpStatPoints,
  };
}

export function streakMetricsFromHistory(
  activityHistory: admin.firestore.Timestamp[],
  now: admin.firestore.Timestamp,
) {
  if (activityHistory.length === 0) {
    return {
      currentStreak: 0,
      bestStreak: 0,
    };
  }

  const dayKeys = activityHistory.map((entry) => normalizedDateKey(entry));
  let bestStreak = 1;
  let running = 1;
  for (let index = 1; index < dayKeys.length; index += 1) {
    const previous = normalizedDateFromKey(dayKeys[index - 1]);
    const current = normalizedDateFromKey(dayKeys[index]);
    const diffDays = Math.round((current.getTime() - previous.getTime()) / 86400000);
    if (diffDays === 1) {
      running += 1;
      bestStreak = Math.max(bestStreak, running);
      continue;
    }

    running = 1;
  }

  const lastDay = normalizedDateFromKey(dayKeys[dayKeys.length - 1]);
  const nowDay = normalizedDateFromKey(normalizedDateKey(now));
  const gapDays = Math.round((nowDay.getTime() - lastDay.getTime()) / 86400000);
  if (gapDays > 1) {
    return {
      currentStreak: 0,
      bestStreak,
    };
  }

  let currentStreak = 1;
  for (let index = dayKeys.length - 1; index > 0; index -= 1) {
    const current = normalizedDateFromKey(dayKeys[index]);
    const previous = normalizedDateFromKey(dayKeys[index - 1]);
    const diffDays = Math.round((current.getTime() - previous.getTime()) / 86400000);
    if (diffDays !== 1) {
      break;
    }
    currentStreak += 1;
  }

  return {
    currentStreak,
    bestStreak,
  };
}

export function profileAggregateFromData(args: {
  data: admin.firestore.DocumentData | undefined;
  fallbackName: string;
  deviceSessionId: string;
  deviceLabel: string;
  now: admin.firestore.Timestamp;
}) {
  const {data, fallbackName, deviceSessionId, deviceLabel, now} = args;
  const level = asNonNegativeInt(data?.level, 1) < 1 ? 1 : asNonNegativeInt(data?.level, 1);
  const maxXp = Math.max(1, asNonNegativeInt(data?.maxXp, playerMaxXpForLevel(level)));
  const xp = Math.min(asNonNegativeInt(data?.xp, 0), Math.max(0, maxXp - 1));

  return {
    name: asName(data?.name, fallbackName),
    level,
    xp,
    maxXp,
    statPoints: asNonNegativeInt(data?.statPoints, 0),
    attributes: {
      strength: Math.max(10, asNonNegativeInt(data?.attributes?.strength, 10)),
      intelligence: Math.max(10, asNonNegativeInt(data?.attributes?.intelligence, 10)),
      vitality: Math.max(10, asNonNegativeInt(data?.attributes?.vitality, 10)),
      agility: Math.max(10, asNonNegativeInt(data?.attributes?.agility, 10)),
    },
    lastResetDate: asTimestampOrNull(data?.lastResetDate) ?? now,
    currentStreak: asNonNegativeInt(data?.currentStreak, 0),
    bestStreak: asNonNegativeInt(data?.bestStreak, 0),
    lastQuestCompletionDate: asTimestampOrNull(data?.lastQuestCompletionDate),
    activityHistory: uniqueTimestampsByDay(asTimestampArray(data?.activityHistory)),
    lastCompetitiveQuestCompletionDate: asTimestampOrNull(
      data?.lastCompetitiveQuestCompletionDate,
    ),
    competitiveActivityHistory: uniqueTimestampsByDay(
      asTimestampArray(data?.competitiveActivityHistory),
    ),
    primaryFocus: ensurePrimaryFocus(data?.primaryFocus ?? 'discipline', 'primaryFocus'),
    hasCompletedOnboarding: typeof data?.hasCompletedOnboarding === 'boolean'
      ? data.hasCompletedOnboarding
      : false,
    weeklyBossLastClaimedAt: asTimestampOrNull(data?.weeklyBossLastClaimedAt),
    authoritativeQuestXp: asNonNegativeInt(data?.authoritativeQuestXp, 0),
    authoritativeWeeklyBossXp: asNonNegativeInt(data?.authoritativeWeeklyBossXp, 0),
    authoritativeWeeklyBossStatPoints: asNonNegativeInt(
      data?.authoritativeWeeklyBossStatPoints,
      0,
    ),
    authoritativeAllocatedStatPoints: asNonNegativeInt(
      data?.authoritativeAllocatedStatPoints,
      0,
    ),
    syncSchemaVersion: PLAYER_PROFILE_SYNC_SCHEMA_VERSION,
    syncSource: typeof data?.syncSource === 'string'
      ? data.syncSource
      : 'callable_server_authoritative',
    activeDeviceSessionId: typeof data?.activeDeviceSessionId === 'string'
      ? data.activeDeviceSessionId
      : deviceSessionId,
    activeDeviceLabel: typeof data?.activeDeviceLabel === 'string'
      ? data.activeDeviceLabel
      : deviceLabel,
    updatedAt: asTimestampOrNull(data?.updatedAt) ?? now,
  };
}

export function withProfileMetadata(args: {
  profile: ReturnType<typeof profileAggregateFromData>;
  deviceSessionId: string;
  deviceLabel: string;
  now: admin.firestore.Timestamp;
  syncSource: string;
}) {
  return {
    ...args.profile,
    syncSchemaVersion: PLAYER_PROFILE_SYNC_SCHEMA_VERSION,
    syncSource: args.syncSource,
    activeDeviceSessionId: args.deviceSessionId,
    activeDeviceLabel: args.deviceLabel,
    updatedAt: args.now,
  };
}

export function applyXpRewardToProfile(
  profile: ReturnType<typeof profileAggregateFromData>,
  args: {xpReward: number; bonusStatPoints: number},
) {
  let currentXp = profile.xp + args.xpReward;
  let currentLevel = profile.level;
  let currentMaxXp = profile.maxXp;
  let currentStatPoints = profile.statPoints + args.bonusStatPoints;

  while (currentXp >= currentMaxXp) {
    currentXp -= currentMaxXp;
    currentLevel += 1;
    currentStatPoints += 5;
    currentMaxXp = playerMaxXpForLevel(currentLevel);
  }

  return {
    ...profile,
    level: currentLevel,
    xp: currentXp,
    maxXp: currentMaxXp,
    statPoints: currentStatPoints,
  };
}

export function historyWithDay(
  history: admin.firestore.Timestamp[],
  completedAt: admin.firestore.Timestamp,
) {
  return uniqueTimestampsByDay([...history, completedAt]);
}

export function questCompletionProjectionFromDocs(
  docs: admin.firestore.QueryDocumentSnapshot[],
) {
  const completionDocs = docs
    .map((doc) => doc.data())
    .filter((data) => data.completedAt instanceof admin.firestore.Timestamp);
  const activityHistory = uniqueTimestampsByDay(
    completionDocs.map((data) => data.completedAt as admin.firestore.Timestamp),
  );
  const competitiveHistory = uniqueTimestampsByDay(
    completionDocs
      .filter((data) => data.countsTowardCompetitive === true)
      .map((data) => data.completedAt as admin.firestore.Timestamp),
  );
  const lastQuestCompletionDate = activityHistory.length === 0
    ? null
    : activityHistory[activityHistory.length - 1];
  const lastCompetitiveQuestCompletionDate = competitiveHistory.length === 0
    ? null
    : competitiveHistory[competitiveHistory.length - 1];
  const questXp = completionDocs.reduce(
    (sum, data) => sum + asNonNegativeInt(data.xpReward, 0),
    0,
  );

  return {
    activityHistory,
    competitiveHistory,
    lastQuestCompletionDate,
    lastCompetitiveQuestCompletionDate,
    questXp,
  };
}
