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
      attributes: {
        strength: 12,
        intelligence: 15,
        vitality: 11,
        agility: 14,
      },
      lastResetDate: timestamp('2026-04-21T08:00:00.000Z'),
      primaryFocus: 'study',
      hasCompletedOnboarding: true,
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
          preRewardLevel: 1,
          preRewardXp: 0,
          preRewardMaxXp: 100,
          preRewardStatPoints: 0,
          preRewardStrength: 10,
          preRewardIntelligence: 10,
          preRewardVitality: 10,
          preRewardAgility: 10,
        },
      ],
    },
    weeklyBossClaims: [
      {
        completedAt: timestamp('2026-04-21T11:00:00.000Z'),
        rewardXp: 120,
        rewardStatPoints: 2,
      },
    ],
    deviceSessionId: 'session-1',
    deviceLabel: 'android',
    now: timestamp('2026-04-21T12:00:00.000Z'),
  });

  assert.equal(write.syncSchemaVersion, 1);
  assert.equal(write.syncSource, 'callable_server_authoritative');
  assert.equal(write.activeDeviceSessionId, 'session-1');
  assert.equal(write.activeDeviceLabel, 'android');
  assert.equal(write.level, 2);
  assert.equal(write.xp, 45);
  assert.equal(write.maxXp, 120);
  assert.equal(write.authoritativeQuestXp, 25);
  assert.equal(write.authoritativeWeeklyBossXp, 120);
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
