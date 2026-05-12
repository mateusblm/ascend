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

export function normalizedDateFromKey(value: string): Date {
  const parts = value.split('-');
  return new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
}

export function uniqueTimestampsByDay(
  timestamps: admin.firestore.Timestamp[],
): admin.firestore.Timestamp[] {
  const byDay = new Map<string, admin.firestore.Timestamp>();
  for (const timestamp of timestamps) {
    byDay.set(normalizedDateKey(timestamp), timestamp);
  }
  return Array.from(byDay.values()).sort((a, b) => a.toMillis() - b.toMillis());
}
