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

type CompetitiveRankPayload = {
  snapshot?: unknown;
  exam?: unknown;
  seasonReward?: unknown;
};

type ValidatedSeasonReward = NonNullable<
  ReturnType<typeof validateSeasonRewardPayload>
>;

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

function isValidSyncSource(value: string): boolean {
  return ['client', 'debug', 'backend'].includes(value);
}

function isValidSeasonRewardClaimStatus(value: string): boolean {
  return ['locked', 'readyToClaim', 'claimed'].includes(value);
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

function ensureTimestamp(value: unknown, field: string): admin.firestore.Timestamp {
  if (value instanceof admin.firestore.Timestamp) {
    return value;
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
