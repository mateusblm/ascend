import * as admin from 'firebase-admin';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

admin.initializeApp();

type ClaimWeeklyBossPayload = {
  bossId?: unknown;
  displayName?: unknown;
  photoUrl?: unknown;
  rankAtCompletion?: unknown;
};

type CompetitiveRankPayload = {
  snapshot?: unknown;
  exam?: unknown;
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

function isValidSyncSource(value: string): boolean {
  return ['client', 'debug', 'backend'].includes(value);
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
  const promotionTargetRank = data.promotionTargetRank == null ? null : normalizeRank(data.promotionTargetRank);
  const syncSource = normalizeSyncSource(data.syncSource);

  if (!['E', 'D', 'C', 'B', 'A', 'S'].includes(currentRank)) {
    throw new HttpsError('invalid-argument', 'currentRank invalido.');
  }
  if (promotionTargetRank && !['E', 'D', 'C', 'B', 'A', 'S'].includes(promotionTargetRank)) {
    throw new HttpsError('invalid-argument', 'promotionTargetRank invalido.');
  }
  if (!isValidSyncSource(syncSource)) {
    throw new HttpsError('invalid-argument', 'syncSource invalido.');
  }

  return {
    currentRank,
    weekKey: ensureString(data.weekKey, 'weekKey', 24),
    activeDays: ensureInt(data.activeDays, 'activeDays', 0),
    requiredActiveDays: ensureInt(data.requiredActiveDays, 'requiredActiveDays', 0),
    requiresBossClear: ensureBool(data.requiresBossClear, 'requiresBossClear'),
    bossCompleted: ensureBool(data.bossCompleted, 'bossCompleted'),
    status: ensureString(data.status, 'status', 32),
    demotionStrikes: ensureInt(data.demotionStrikes, 'demotionStrikes', 0),
    promotionReady: ensureBool(data.promotionReady, 'promotionReady'),
    promotionTargetRank,
    eventType: ensureString(data.eventType, 'eventType', 32),
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
  const syncSource = normalizeSyncSource(data.syncSource);

  if (!['E', 'D', 'C', 'B', 'A', 'S'].includes(sourceRank) ||
      !['E', 'D', 'C', 'B', 'A', 'S'].includes(targetRank)) {
    throw new HttpsError('invalid-argument', 'Ranks do exame invalidos.');
  }
  if (!isValidSyncSource(syncSource)) {
    throw new HttpsError('invalid-argument', 'syncSource invalido.');
  }

  return {
    sourceRank,
    targetRank,
    sourceWeekKey: ensureString(data.sourceWeekKey, 'sourceWeekKey', 24),
    status: ensureString(data.status, 'status', 32),
    baselineActiveDays: ensureInt(data.baselineActiveDays, 'baselineActiveDays', 0),
    requiredExtraActiveDays: ensureInt(data.requiredExtraActiveDays, 'requiredExtraActiveDays', 0),
    bossRequired: ensureBool(data.bossRequired, 'bossRequired'),
    startedAt: ensureTimestamp(data.startedAt, 'startedAt'),
    expiresAt: ensureTimestamp(data.expiresAt, 'expiresAt'),
    syncSchemaVersion: ensureInt(data.syncSchemaVersion, 'syncSchemaVersion', 1),
    syncSource,
    resolvedAt: data.resolvedAt == null ? null : ensureTimestamp(data.resolvedAt, 'resolvedAt'),
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
        participantCount: admin.firestore.FieldValue.increment(1),
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
    const uid = request.auth.uid;
    const db = admin.firestore();
    const currentRef = db.collection('users').doc(uid).collection('progression').doc('current');
    const historyRef = db
      .collection('users')
      .doc(uid)
      .collection('progression_history')
      .doc(snapshot.weekKey);
    const examRef = db.collection('users').doc(uid).collection('promotion_exam').doc('current');

    const batch = db.batch();
    batch.set(currentRef, snapshot, { merge: true });
    batch.set(historyRef, snapshot, { merge: true });
    if (exam) {
      batch.set(examRef, exam, { merge: true });
    }
    await batch.commit();

    return {
      status: 'synced' as const,
      weekKey: snapshot.weekKey,
      wroteExam: Boolean(exam),
    };
  },
);
