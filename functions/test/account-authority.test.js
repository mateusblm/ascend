const test = require('node:test');
const assert = require('node:assert/strict');
const admin = require('firebase-admin');

const {
  buildPlayerProfileSyncWrite,
  buildQuestInventorySyncWrites,
} = require('../lib/index.js');

function timestamp(value) {
  return admin.firestore.Timestamp.fromDate(new Date(value));
}

test('buildPlayerProfileSyncWrite stamps audited sync metadata', () => {
  const write = buildPlayerProfileSyncWrite({
    source: {
      name: 'Hunter',
      level: 6,
      xp: 22,
      maxXp: 248,
      statPoints: 3,
      attributes: {
        strength: 12,
        intelligence: 15,
        vitality: 11,
        agility: 14,
      },
      lastResetDate: timestamp('2026-04-21T08:00:00.000Z'),
      currentStreak: 4,
      bestStreak: 7,
      lastQuestCompletionDate: timestamp('2026-04-21T10:00:00.000Z'),
      activityHistory: [timestamp('2026-04-21T00:00:00.000Z')],
      lastCompetitiveQuestCompletionDate: null,
      competitiveActivityHistory: [],
      primaryFocus: 'study',
      hasCompletedOnboarding: true,
      weeklyBossLastClaimedAt: null,
    },
    deviceSessionId: 'session-1',
    deviceLabel: 'android',
    now: timestamp('2026-04-21T12:00:00.000Z'),
  });

  assert.equal(write.syncSchemaVersion, 1);
  assert.equal(write.syncSource, 'callable_session_audited');
  assert.equal(write.activeDeviceSessionId, 'session-1');
  assert.equal(write.activeDeviceLabel, 'android');
  assert.equal(write.level, 6);
});

test('buildQuestInventorySyncWrites stamps audited sync metadata per quest', () => {
  const writes = buildQuestInventorySyncWrites({
    source: {
      quests: [
        {
          id: 'quest-1',
          title: 'Sessao focada',
          rewardAttribute: 'agility',
          xpReward: 25,
          category: 'competitive',
          templateType: 'focusSession',
          verificationMode: 'timer',
          verificationStatus: 'verified',
          targetDurationMinutes: 20,
          reflectionPrompt: null,
          reflectionAnswer: null,
          verificationStartedAt: timestamp('2026-04-21T10:00:00.000Z'),
          completedAt: timestamp('2026-04-21T10:20:00.000Z'),
          verifiedAt: timestamp('2026-04-21T10:20:00.000Z'),
          isCompleted: true,
          preRewardLevel: 5,
          preRewardXp: 90,
          preRewardMaxXp: 207,
          preRewardStatPoints: 2,
          preRewardStrength: 10,
          preRewardIntelligence: 11,
          preRewardVitality: 12,
          preRewardAgility: 13,
        },
      ],
    },
    deviceSessionId: 'session-1',
    deviceLabel: 'android',
    now: timestamp('2026-04-21T12:00:00.000Z'),
  });

  assert.equal(writes.length, 1);
  assert.equal(writes[0].id, 'quest-1');
  assert.equal(writes[0].data.syncSchemaVersion, 1);
  assert.equal(writes[0].data.syncSource, 'callable_session_audited');
  assert.equal(writes[0].data.activeDeviceSessionId, 'session-1');
  assert.equal(writes[0].data.orderIndex, 0);
});
