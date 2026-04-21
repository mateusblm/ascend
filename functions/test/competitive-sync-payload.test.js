const test = require('node:test');
const assert = require('node:assert/strict');
const admin = require('firebase-admin');

const { parseTimestampInput } = require('../lib/index.js');

function timestamp(value) {
  return admin.firestore.Timestamp.fromDate(new Date(value));
}

test('accepts ISO timestamps sent by callable clients', () => {
  const parsed = parseTimestampInput('2026-04-21T15:00:00.000Z');

  assert.ok(parsed);
  assert.equal(parsed.toMillis(), timestamp('2026-04-21T15:00:00.000Z').toMillis());
});

test('keeps accepting firestore timestamps for backend-originated payloads', () => {
  const current = timestamp('2026-04-21T15:00:00.000Z');
  const parsed = parseTimestampInput(current);

  assert.ok(parsed);
  assert.equal(parsed.toMillis(), current.toMillis());
});

test('rejects invalid timestamp inputs', () => {
  assert.equal(parseTimestampInput('not-a-date'), null);
  assert.equal(parseTimestampInput(123), null);
});
