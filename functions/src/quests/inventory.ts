import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';
import {
  ensureBool,
  ensureInt,
  ensureNonNegativeIntOrNull,
  ensureOptionalString,
  ensureString,
  ensureTimestampOrNull,
} from '../shared/validation';

const QUEST_INVENTORY_SYNC_SCHEMA_VERSION = 1;
const MAX_QUESTS_PER_USER = 200;

export type ServerQuestInventorySource = {
  quests: Array<{
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
  }>;
};

export type CompetitiveQuestDefinitionForInventory = {
  title: string;
  templateType: string;
  verificationMode: string;
  targetDurationMinutes: number;
  xpReward: number;
  rewardAttribute: string;
};

export function ensureAttributeName(value: unknown, field: string): string {
  const attribute = ensureString(value, field, 32).toLowerCase();
  if (!['strength', 'intelligence', 'vitality', 'agility'].includes(attribute)) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }
  return attribute;
}

export function ensureQuestCategory(value: unknown, field: string): string {
  const category = ensureString(value, field, 32).toLowerCase();
  if (!['personal', 'competitive'].includes(category)) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }
  return category;
}

export function ensureQuestTemplateType(value: unknown, field: string): string {
  const templateType = ensureString(value, field, 32);
  if (![
    'custom',
    'focusSession',
    'studySession',
    'readingSession',
    'runningSession',
    'workoutSession',
  ].includes(templateType)) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }
  return templateType;
}

export function ensureQuestVerificationMode(value: unknown, field: string): string {
  const verificationMode = ensureString(value, field, 32);
  if (!['manual', 'timer', 'timerWithReflection'].includes(verificationMode)) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }
  return verificationMode;
}

export function ensureQuestVerificationStatus(value: unknown, field: string): string {
  const status = ensureString(value, field, 32);
  if (!['none', 'ready', 'inProgress', 'verified'].includes(status)) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }
  return status;
}

export function validateQuestInventorySourcePayload(
  source: unknown,
  definitions: CompetitiveQuestDefinitionForInventory[],
): ServerQuestInventorySource {
  if (!source || typeof source !== 'object') {
    throw new HttpsError('invalid-argument', 'source obrigatorio.');
  }

  const data = source as Record<string, unknown>;
  const rawQuests = data.quests;
  if (!Array.isArray(rawQuests) || rawQuests.length > MAX_QUESTS_PER_USER) {
    throw new HttpsError('invalid-argument', 'quests invalidas.');
  }

  const seenActiveCompetitiveTemplates = new Set<string>();

  const quests = rawQuests.map((entry, index) => {
    if (!entry || typeof entry !== 'object') {
      throw new HttpsError('invalid-argument', `quest[${index}] invalida.`);
    }

    const quest = entry as Record<string, unknown>;
    const id = ensureString(quest.id, `quest[${index}].id`, 120);
    const title = ensureString(quest.title, `quest[${index}].title`, 120);
    const rewardAttribute = ensureAttributeName(
      quest.rewardAttribute,
      `quest[${index}].rewardAttribute`,
    );
    const category = ensureQuestCategory(quest.category, `quest[${index}].category`);
    const templateType = ensureQuestTemplateType(
      quest.templateType,
      `quest[${index}].templateType`,
    );
    const verificationMode = ensureQuestVerificationMode(
      quest.verificationMode,
      `quest[${index}].verificationMode`,
    );
    const verificationStatus = ensureQuestVerificationStatus(
      quest.verificationStatus,
      `quest[${index}].verificationStatus`,
    );
    const isCompleted = ensureBool(quest.isCompleted, `quest[${index}].isCompleted`);
    const targetDurationMinutes = ensureInt(
      quest.targetDurationMinutes,
      `quest[${index}].targetDurationMinutes`,
      0,
    );
    const verificationStartedAt = ensureTimestampOrNull(
      quest.verificationStartedAt,
      `quest[${index}].verificationStartedAt`,
    );
    const completedAt = ensureTimestampOrNull(
      quest.completedAt,
      `quest[${index}].completedAt`,
    );
    const verifiedAt = ensureTimestampOrNull(
      quest.verifiedAt,
      `quest[${index}].verifiedAt`,
    );
    const reflectionPrompt = ensureOptionalString(
      quest.reflectionPrompt,
      `quest[${index}].reflectionPrompt`,
      240,
    );
    const reflectionAnswer = ensureOptionalString(
      quest.reflectionAnswer,
      `quest[${index}].reflectionAnswer`,
      500,
    );

    if (category === 'personal') {
      return {
        id,
        title,
        rewardAttribute,
        xpReward: Math.max(8, Math.min(15, ensureInt(quest.xpReward, `quest[${index}].xpReward`, 0))),
        category,
        templateType: 'custom',
        verificationMode: 'manual',
        verificationStatus: isCompleted ? 'verified' : 'none',
        targetDurationMinutes: 0,
        reflectionPrompt: null,
        reflectionAnswer: null,
        verificationStartedAt: null,
        completedAt,
        verifiedAt: isCompleted ? (verifiedAt ?? completedAt) : null,
        isCompleted,
        preRewardLevel: ensureNonNegativeIntOrNull(
          quest.preRewardLevel,
          `quest[${index}].preRewardLevel`,
        ),
        preRewardXp: ensureNonNegativeIntOrNull(
          quest.preRewardXp,
          `quest[${index}].preRewardXp`,
        ),
        preRewardMaxXp: ensureNonNegativeIntOrNull(
          quest.preRewardMaxXp,
          `quest[${index}].preRewardMaxXp`,
        ),
        preRewardStatPoints: ensureNonNegativeIntOrNull(
          quest.preRewardStatPoints,
          `quest[${index}].preRewardStatPoints`,
        ),
        preRewardStrength: ensureNonNegativeIntOrNull(
          quest.preRewardStrength,
          `quest[${index}].preRewardStrength`,
        ),
        preRewardIntelligence: ensureNonNegativeIntOrNull(
          quest.preRewardIntelligence,
          `quest[${index}].preRewardIntelligence`,
        ),
        preRewardVitality: ensureNonNegativeIntOrNull(
          quest.preRewardVitality,
          `quest[${index}].preRewardVitality`,
        ),
        preRewardAgility: ensureNonNegativeIntOrNull(
          quest.preRewardAgility,
          `quest[${index}].preRewardAgility`,
        ),
      };
    }

    const xpReward = ensureInt(quest.xpReward, `quest[${index}].xpReward`, 0);
    const matchingDefinition = definitions.find((definition) =>
      definition.title === title &&
      definition.templateType === templateType &&
      definition.verificationMode === verificationMode &&
      definition.targetDurationMinutes === targetDurationMinutes &&
      definition.xpReward === xpReward &&
      definition.rewardAttribute === rewardAttribute,
    );

    if (!matchingDefinition) {
      throw new HttpsError('invalid-argument', `quest[${index}] invalida.`);
    }

    if (!isCompleted) {
      const duplicateKey = `${matchingDefinition.templateType}`;
      if (seenActiveCompetitiveTemplates.has(duplicateKey)) {
        throw new HttpsError('failed-precondition', 'Template competitivo duplicado.');
      }
      seenActiveCompetitiveTemplates.add(duplicateKey);
    }

    return {
      id,
      title: matchingDefinition.title,
      rewardAttribute: matchingDefinition.rewardAttribute,
      xpReward: matchingDefinition.xpReward,
      category,
      templateType: matchingDefinition.templateType,
      verificationMode: matchingDefinition.verificationMode,
      verificationStatus: isCompleted ? 'verified' : verificationStatus,
      targetDurationMinutes: matchingDefinition.targetDurationMinutes,
      reflectionPrompt,
      reflectionAnswer,
      verificationStartedAt,
      completedAt,
      verifiedAt: isCompleted ? (verifiedAt ?? completedAt) : null,
      isCompleted,
      preRewardLevel: ensureNonNegativeIntOrNull(
        quest.preRewardLevel,
        `quest[${index}].preRewardLevel`,
      ),
      preRewardXp: ensureNonNegativeIntOrNull(
        quest.preRewardXp,
        `quest[${index}].preRewardXp`,
      ),
      preRewardMaxXp: ensureNonNegativeIntOrNull(
        quest.preRewardMaxXp,
        `quest[${index}].preRewardMaxXp`,
      ),
      preRewardStatPoints: ensureNonNegativeIntOrNull(
        quest.preRewardStatPoints,
        `quest[${index}].preRewardStatPoints`,
      ),
      preRewardStrength: ensureNonNegativeIntOrNull(
        quest.preRewardStrength,
        `quest[${index}].preRewardStrength`,
      ),
      preRewardIntelligence: ensureNonNegativeIntOrNull(
        quest.preRewardIntelligence,
        `quest[${index}].preRewardIntelligence`,
      ),
      preRewardVitality: ensureNonNegativeIntOrNull(
        quest.preRewardVitality,
        `quest[${index}].preRewardVitality`,
      ),
      preRewardAgility: ensureNonNegativeIntOrNull(
        quest.preRewardAgility,
        `quest[${index}].preRewardAgility`,
      ),
    };
  });

  return {quests};
}

export function buildQuestInventorySyncWrites(args: {
  source: ServerQuestInventorySource;
  deviceSessionId: string;
  deviceLabel: string;
  now: admin.firestore.Timestamp;
}) {
  return args.source.quests.map((quest, index) => ({
    id: quest.id,
    data: buildQuestDocData(quest, {
      orderIndex: index,
      deviceSessionId: args.deviceSessionId,
      deviceLabel: args.deviceLabel,
      now: args.now,
      syncSource: 'callable_session_audited',
    }),
  }));
}

export function buildQuestDocData(
  quest: ServerQuestInventorySource['quests'][number],
  args: {
    orderIndex: number;
    deviceSessionId: string;
    deviceLabel: string;
    now: admin.firestore.Timestamp;
    syncSource: string;
  },
) {
  return {
    title: quest.title,
    rewardAttribute: quest.rewardAttribute,
    xpReward: quest.xpReward,
    category: quest.category,
    templateType: quest.templateType,
    verificationMode: quest.verificationMode,
    verificationStatus: quest.verificationStatus,
    targetDurationMinutes: quest.targetDurationMinutes,
    reflectionPrompt: quest.reflectionPrompt,
    reflectionAnswer: quest.reflectionAnswer,
    verificationStartedAt: quest.verificationStartedAt,
    completedAt: quest.completedAt,
    verifiedAt: quest.verifiedAt,
    isCompleted: quest.isCompleted,
    preRewardLevel: quest.preRewardLevel,
    preRewardXp: quest.preRewardXp,
    preRewardMaxXp: quest.preRewardMaxXp,
    preRewardStatPoints: quest.preRewardStatPoints,
    preRewardStrength: quest.preRewardStrength,
    preRewardIntelligence: quest.preRewardIntelligence,
    preRewardVitality: quest.preRewardVitality,
    preRewardAgility: quest.preRewardAgility,
    orderIndex: args.orderIndex,
    syncSchemaVersion: QUEST_INVENTORY_SYNC_SCHEMA_VERSION,
    syncSource: args.syncSource,
    activeDeviceSessionId: args.deviceSessionId,
    activeDeviceLabel: args.deviceLabel,
    updatedAt: args.now,
  };
}

export function validateSingleQuestSourcePayload(
  source: unknown,
  questId: string,
  definitions: CompetitiveQuestDefinitionForInventory[],
): ServerQuestInventorySource['quests'][number] {
  if (!source || typeof source !== 'object') {
    throw new HttpsError('invalid-argument', 'quest invalida.');
  }

  const data = source as Record<string, unknown>;
  if (typeof data.id === 'string' && data.id.trim() !== questId) {
    throw new HttpsError('invalid-argument', 'questId divergente.');
  }

  return validateQuestInventorySourcePayload({
    quests: [{...data, id: questId}],
  }, definitions).quests[0];
}

export function validateQuestFromStoredDoc(
  questId: string,
  data: admin.firestore.DocumentData | undefined,
  definitions: CompetitiveQuestDefinitionForInventory[],
): ServerQuestInventorySource['quests'][number] {
  return validateQuestInventorySourcePayload({
    quests: [{...(data ?? {}), id: questId}],
  }, definitions).quests[0];
}
