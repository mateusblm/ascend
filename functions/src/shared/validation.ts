import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';

export function sanitizeDisplayName(value: unknown): string {
  const text = typeof value === 'string' ? value.trim() : '';
  if (!text) return 'Hunter';
  return text.length > 40 ? text.slice(0, 40) : text;
}

export function sanitizePhotoUrl(value: unknown): string {
  const text = typeof value === 'string' ? value.trim() : '';
  if (!text) return '';
  return text.length > 500 ? text.slice(0, 500) : text;
}

export function normalizeRank(value: unknown): string {
  const text = typeof value === 'string' ? value.trim().toUpperCase() : '';
  return text;
}

export function normalizeSyncSource(value: unknown): string {
  const text = typeof value === 'string' ? value.trim().toLowerCase() : '';
  return text;
}

export function ensureString(
  value: unknown,
  field: string,
  maxLength: number,
): string {
  if (typeof value !== 'string') {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }

  const text = value.trim();
  if (!text || text.length > maxLength) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }

  return text;
}

export function ensureInt(value: unknown, field: string, min: number): number {
  if (typeof value !== 'number' || !Number.isInteger(value) || value < min) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }

  return value;
}

export function ensureBool(value: unknown, field: string): boolean {
  if (typeof value !== 'boolean') {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }

  return value;
}

export function ensureOptionalString(
  value: unknown,
  field: string,
  maxLength: number,
): string | null {
  if (value == null) {
    return null;
  }

  if (typeof value !== 'string') {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }

  const text = value.trim();
  if (!text) {
    return null;
  }
  if (text.length > maxLength) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }

  return text;
}

export function parseTimestampInput(
  value: unknown,
): admin.firestore.Timestamp | null {
  if (value instanceof admin.firestore.Timestamp) {
    return value;
  }

  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    return admin.firestore.Timestamp.fromDate(value);
  }

  if (typeof value === 'number' && Number.isFinite(value)) {
    return admin.firestore.Timestamp.fromMillis(value);
  }

  if (typeof value === 'string') {
    const parsed = new Date(value);
    if (!Number.isNaN(parsed.getTime())) {
      return admin.firestore.Timestamp.fromDate(parsed);
    }
  }

  if (value && typeof value === 'object') {
    const data = value as Record<string, unknown>;
    const seconds = typeof data.seconds === 'number'
      ? data.seconds
      : typeof data._seconds === 'number'
        ? data._seconds
        : null;
    const nanoseconds = typeof data.nanoseconds === 'number'
      ? data.nanoseconds
      : typeof data._nanoseconds === 'number'
        ? data._nanoseconds
        : 0;
    if (seconds != null) {
      return new admin.firestore.Timestamp(seconds, nanoseconds);
    }

    const milliseconds = typeof data.millisecondsSinceEpoch === 'number'
      ? data.millisecondsSinceEpoch
      : typeof data._millisecondsSinceEpoch === 'number'
        ? data._millisecondsSinceEpoch
        : null;
    if (milliseconds != null) {
      return admin.firestore.Timestamp.fromMillis(milliseconds);
    }

    const isoString = typeof data.iso8601 === 'string'
      ? data.iso8601
      : typeof data.isoString === 'string'
        ? data.isoString
        : null;
    if (isoString != null) {
      const parsed = new Date(isoString);
      if (!Number.isNaN(parsed.getTime())) {
        return admin.firestore.Timestamp.fromDate(parsed);
      }
    }
  }

  return null;
}

export function ensureTimestamp(
  value: unknown,
  field: string,
): admin.firestore.Timestamp {
  const timestamp = parseTimestampInput(value);
  if (timestamp != null) {
    return timestamp;
  }

  throw new HttpsError('invalid-argument', `${field} invalido.`);
}

export function ensureTimestampOrNull(
  value: unknown,
  field: string,
): admin.firestore.Timestamp | null {
  if (value == null) {
    return null;
  }

  return ensureTimestamp(value, field);
}

export function ensureStringArray(
  value: unknown,
  field: string,
  maxLength: number,
): string[] {
  if (!Array.isArray(value)) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }

  return value.map((entry, index) =>
    ensureString(entry, `${field}[${index}]`, maxLength),
  );
}

export function ensureNonNegativeIntOrNull(
  value: unknown,
  field: string,
): number | null {
  if (value == null) {
    return null;
  }

  return ensureInt(value, field, 0);
}

export function ensureTimestampArray(
  value: unknown,
  field: string,
): admin.firestore.Timestamp[] {
  if (!Array.isArray(value)) {
    throw new HttpsError('invalid-argument', `${field} invalido.`);
  }

  return value.map((entry, index) =>
    ensureTimestamp(entry, `${field}[${index}]`),
  );
}

export function asTimestampArray(value: unknown): admin.firestore.Timestamp[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value.filter(
    (entry): entry is admin.firestore.Timestamp =>
      entry instanceof admin.firestore.Timestamp,
  );
}

export function asTimestampOrNull(
  value: unknown,
): admin.firestore.Timestamp | null {
  return value instanceof admin.firestore.Timestamp ? value : null;
}

export function asNonNegativeInt(value: unknown, fallback: number): number {
  if (typeof value !== 'number' || !Number.isInteger(value) || value < 0) {
    return fallback;
  }
  return value;
}

export function asName(value: unknown, fallback: string): string {
  if (typeof value !== 'string' || !value.trim()) {
    return fallback;
  }
  return value.trim().slice(0, 40);
}
