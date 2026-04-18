import * as admin from 'firebase-admin';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

admin.initializeApp();

type ClaimWeeklyBossPayload = {
  bossId?: unknown;
  displayName?: unknown;
  photoUrl?: unknown;
  rankAtCompletion?: unknown;
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
