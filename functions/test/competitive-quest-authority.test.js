const test = require('node:test');
const assert = require('node:assert/strict');
const admin = require('firebase-admin');

const {
  competitiveQuestAttemptDayKey,
  matchesCompetitiveAttemptDay,
  resolveCompetitiveQuestSessionStart,
  resolveCompetitiveQuestCompletionVerification,
} = require('../lib/index.js');

function timestamp(value) {
  return admin.firestore.Timestamp.fromDate(new Date(value));
}

function buildQuest(overrides = {}) {
  return {
    questId: 'quest-focus-20',
    title: 'Sessao de foco de 20 minutos',
    templateType: 'focusSession',
    verificationMode: 'timer',
    targetDurationMinutes: 20,
    xpReward: 25,
    rewardAttribute: 'vitality',
    reflectionAnswer: null,
    ...overrides,
  };
}

test('starts a competitive quest session and prepares the session write', () => {
  const now = timestamp('2026-04-21T15:00:00.000Z');

  const result = resolveCompetitiveQuestSessionStart({
    quest: buildQuest(),
    session: null,
    grant: null,
    now,
  });

  assert.equal(result.status, 'started');
  assert.equal(result.startedAt, '2026-04-21T15:00:00.000Z');
  assert.ok(result.sessionWrite);
  assert.equal(result.sessionWrite.questId, 'quest-focus-20');
  assert.equal(result.sessionWrite.status, 'inProgress');
  assert.equal(result.sessionWrite.startedAt.toMillis(), now.toMillis());
});

test('restarts an existing in-progress session with the current timestamp', () => {
  const now = timestamp('2026-04-21T18:00:00.000Z');

  const result = resolveCompetitiveQuestSessionStart({
    quest: buildQuest(),
    session: {
      startedAt: timestamp('2026-04-21T15:00:00.000Z'),
      status: 'inProgress',
    },
    grant: null,
    now,
  });

  assert.equal(result.status, 'started');
  assert.equal(result.startedAt, '2026-04-21T18:00:00.000Z');
  assert.ok(result.sessionWrite);
  assert.equal(result.sessionWrite.startedAt.toMillis(), now.toMillis());
  assert.equal(result.sessionWrite.status, 'inProgress');
});

test('rejects competitive quest completion before the minimum duration', () => {
  const now = timestamp('2026-04-21T15:10:00.000Z');

  assert.throws(
    () =>
      resolveCompetitiveQuestCompletionVerification({
        quest: buildQuest(),
        session: {
          startedAt: timestamp('2026-04-21T15:00:00.000Z'),
        },
        grant: null,
        now,
      }),
    (error) => {
      assert.equal(error.code, 'failed-precondition');
      assert.match(error.message, /Ainda falta tempo/);
      return true;
    },
  );
});

test('verifies a valid competitive quest completion and prepares the grant write', () => {
  const now = timestamp('2026-04-21T15:30:00.000Z');

  const result = resolveCompetitiveQuestCompletionVerification({
    quest: buildQuest({
      title: 'Revisao de treino de 15 minutos',
      templateType: 'readingSession',
      verificationMode: 'timerWithReflection',
      targetDurationMinutes: 15,
      xpReward: 25,
      rewardAttribute: 'intelligence',
      reflectionAnswer: 'Resumo curto da sessao.',
    }),
    session: {
      startedAt: timestamp('2026-04-21T15:00:00.000Z'),
    },
    grant: null,
    now,
  });

  assert.equal(result.status, 'verified');
  assert.equal(result.completedAt, '2026-04-21T15:30:00.000Z');
  assert.ok(result.grantWrite);
  assert.ok(result.sessionWrite);
  assert.equal(result.grantWrite.dayKey, '2026-04-21');
  assert.equal(result.grantWrite.completedAt.toMillis(), now.toMillis());
  assert.equal(result.sessionWrite.status, 'verified');
});

test('prevents duplicate grants by returning the existing verification result', () => {
  const now = timestamp('2026-04-21T15:45:00.000Z');

  const result = resolveCompetitiveQuestCompletionVerification({
    quest: buildQuest(),
    session: {
      startedAt: timestamp('2026-04-21T15:00:00.000Z'),
    },
    grant: {
      completedAt: timestamp('2026-04-21T15:25:00.000Z'),
    },
    now,
  });

  assert.equal(result.status, 'already_verified');
  assert.equal(result.completedAt, '2026-04-21T15:25:00.000Z');
  assert.equal(result.grantWrite, null);
  assert.equal(result.sessionWrite, null);
});

test('starts a fresh session when the previous record is already verified', () => {
  const now = timestamp('2026-04-21T18:00:00.000Z');

  const result = resolveCompetitiveQuestSessionStart({
    quest: buildQuest(),
    session: {
      startedAt: timestamp('2026-04-21T15:00:00.000Z'),
      status: 'verified',
    },
    grant: null,
    now,
  });

  assert.equal(result.status, 'started');
  assert.equal(result.startedAt, '2026-04-21T18:00:00.000Z');
  assert.ok(result.sessionWrite);
  assert.equal(result.sessionWrite.dayKey, '2026-04-21');
});

test('uses the verificationStartedAt day when resolving the attempt day key', () => {
  const now = timestamp('2026-04-22T00:10:00.000Z');

  const dayKey = competitiveQuestAttemptDayKey({
    quest: buildQuest({
      verificationStartedAt: timestamp('2026-04-21T23:50:00.000Z'),
    }),
    now,
  });

  assert.equal(dayKey, '2026-04-21');
});

test('matches only records from the same competitive attempt day', () => {
  assert.equal(
    matchesCompetitiveAttemptDay({
      record: {
        startedAt: timestamp('2026-04-21T23:50:00.000Z'),
      },
      dayKey: '2026-04-21',
      timestampField: 'startedAt',
    }),
    true,
  );

  assert.equal(
    matchesCompetitiveAttemptDay({
      record: {
        startedAt: timestamp('2026-04-20T23:50:00.000Z'),
      },
      dayKey: '2026-04-21',
      timestampField: 'startedAt',
    }),
    false,
  );
});
