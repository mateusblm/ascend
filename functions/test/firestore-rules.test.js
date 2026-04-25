const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const path = require('node:path');

const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const { doc, getDoc, setDoc } = require('firebase/firestore');

const projectId = 'demo-ascend';
let testEnv;

function emulatorConfigFromEnv() {
  const value = process.env.FIRESTORE_EMULATOR_HOST;
  if (!value) {
    throw new Error(
      'FIRESTORE_EMULATOR_HOST is required. Run this suite through `npm run test:rules`.',
    );
  }

  const [host, portText] = value.split(':');
  const port = Number(portText);

  if (!host || Number.isNaN(port)) {
    throw new Error(
      'Invalid FIRESTORE_EMULATOR_HOST value. Expected "<host>:<port>".',
    );
  }

  return { host, port };
}

async function seedDoc(documentPath, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), documentPath), data);
  });
}

test.before(async () => {
  const emulator = emulatorConfigFromEnv();
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      host: emulator.host,
      port: emulator.port,
      rules: await fs.readFile(
        path.resolve(__dirname, '../../firestore.rules'),
        'utf8',
      ),
    },
  });
});

test.after(async () => {
  await testEnv?.cleanup();
});

test.beforeEach(async () => {
  await testEnv.clearFirestore();
});

test('public can read weekly boss and completion leaderboard docs', async () => {
  await seedDoc('weekly_bosses/boss-e', { rank: 'E', title: 'Primeira Ruptura' });
  await seedDoc('weekly_bosses/boss-e/completions/user-1', { displayName: 'Hunter' });

  const guestDb = testEnv.unauthenticatedContext().firestore();

  await assertSucceeds(getDoc(doc(guestDb, 'weekly_bosses/boss-e')));
  await assertSucceeds(
    getDoc(doc(guestDb, 'weekly_bosses/boss-e/completions/user-1')),
  );
});

test('unauthenticated users cannot read account-backed user docs', async () => {
  await seedDoc('users/user-1/profile/current', { name: 'Hunter', level: 6 });

  const guestDb = testEnv.unauthenticatedContext().firestore();

  await assertFails(getDoc(doc(guestDb, 'users/user-1/profile/current')));
});

test('authenticated user can read only their own profile aggregate', async () => {
  await seedDoc('users/user-1/profile/current', { name: 'Hunter', level: 6 });

  const ownDb = testEnv.authenticatedContext('user-1').firestore();
  const otherDb = testEnv.authenticatedContext('user-2').firestore();

  await assertSucceeds(getDoc(doc(ownDb, 'users/user-1/profile/current')));
  await assertFails(getDoc(doc(otherDb, 'users/user-1/profile/current')));
});

test('clients cannot write profile aggregates directly', async () => {
  const ownDb = testEnv.authenticatedContext('user-1').firestore();

  await assertFails(
    setDoc(doc(ownDb, 'users/user-1/profile/current'), {
      name: 'Hunter',
      level: 7,
    }),
  );
});

test('clients cannot write quest inventory directly', async () => {
  const ownDb = testEnv.authenticatedContext('user-1').firestore();

  await assertFails(
    setDoc(doc(ownDb, 'users/user-1/quests/quest-1'), {
      title: 'Sessao focada',
      xpReward: 25,
    }),
  );
});

test('authenticated users can read but not write competitive authority collections', async () => {
  await seedDoc('users/user-1/competitive_quest_sessions/quest-1', {
    status: 'inProgress',
  });
  await seedDoc('users/user-1/competitive_quest_evidence/quest-1', {
    status: 'accepted',
  });

  const ownDb = testEnv.authenticatedContext('user-1').firestore();

  await assertSucceeds(
    getDoc(doc(ownDb, 'users/user-1/competitive_quest_sessions/quest-1')),
  );
  await assertFails(
    setDoc(doc(ownDb, 'users/user-1/competitive_quest_sessions/quest-1'), {
      status: 'verified',
    }),
  );
  await assertSucceeds(
    getDoc(doc(ownDb, 'users/user-1/competitive_quest_evidence/quest-1')),
  );
  await assertFails(
    setDoc(doc(ownDb, 'users/user-1/competitive_quest_evidence/quest-1'), {
      status: 'accepted',
    }),
  );
});

test('all direct client writes under users/{uid} stay blocked by default', async () => {
  const ownDb = testEnv.authenticatedContext('user-1').firestore();
  const sensitivePaths = [
    'users/user-1/session/current',
    'users/user-1/weekly_boss_claims/current',
    'users/user-1/season_rewards/current',
    'users/user-1/integrity/current',
  ];

  for (const documentPath of sensitivePaths) {
    await assertFails(
      setDoc(doc(ownDb, documentPath), {
        touchedAt: '2026-04-23T12:00:00.000Z',
      }),
    );
  }

  assert.ok(sensitivePaths.length > 0);
});
