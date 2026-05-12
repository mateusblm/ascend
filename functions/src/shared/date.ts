import * as admin from 'firebase-admin';

export function normalizedDateKey(
  value: admin.firestore.Timestamp | Date,
): string {
  const date = value instanceof Date ? value : value.toDate();
  const normalized = new Date(
    date.getFullYear(),
    date.getMonth(),
    date.getDate(),
  );
  return `${normalized.getFullYear()}-${String(
    normalized.getMonth() + 1,
  ).padStart(2, '0')}-${String(normalized.getDate()).padStart(2, '0')}`;
}
