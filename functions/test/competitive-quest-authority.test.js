const test = require('node:test');
const assert = require('node:assert/strict');
const admin = require('firebase-admin');

const {
  buildDeterministicReadingQuizAttempt,
  createReadingQuizGenerator,
  competitiveQuestAttemptDayKey,
  evaluateReadingQuizSubmission,
  GeminiReadingQuizQuestionProvider,
  matchesCompetitiveAttemptDay,
  parseTimestampInput,
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
    templateCatalogId: null,
    verificationRequirement: {
      evidenceType: 'timedFocus',
      minimumTrustTier: 2,
      minimumDurationMinutes: 20,
      minimumDistanceMeters: 0,
      minimumQuizScore: 0,
      allowedProviders: ['appTimer', 'mockEvidence'],
    },
    reflectionAnswer: null,
    ...overrides,
  };
}

function buildEvidence(overrides = {}) {
  return {
    questId: 'quest-focus-20',
    provider: 'mockEvidence',
    type: 'timedFocus',
    startedAt: timestamp('2026-04-21T15:00:00.000Z'),
    completedAt: timestamp('2026-04-21T15:30:00.000Z'),
    durationMinutes: 30,
    distanceMeters: null,
    sourceActivityId: null,
    quizScore: null,
    answers: [],
    reflection: null,
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

test('accepts official template catalog id even when local title copy changed', () => {
  const now = timestamp('2026-04-21T15:00:00.000Z');

  const result = resolveCompetitiveQuestSessionStart({
    quest: buildQuest({
      templateCatalogId: 'study-20-recall',
      questId: 'study-20-recall-123',
      title: 'Copy local antiga',
      templateType: 'studySession',
      verificationMode: 'timerWithReflection',
      targetDurationMinutes: 20,
      xpReward: 30,
      rewardAttribute: 'intelligence',
    }),
    session: null,
    grant: null,
    now,
  });

  assert.equal(result.status, 'started');
  assert.equal(result.sessionWrite.templateCatalogId, 'study-20-recall');
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
      evidence: buildEvidence(),
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
  assert.equal(result.grantWrite.evidenceType, 'timedFocus');
  assert.equal(result.grantWrite.confidenceScore, 75);
  assert.equal(result.grantWrite.completedAt.toMillis(), now.toMillis());
  assert.equal(result.sessionWrite.status, 'verified');
});

test('evaluates backend-owned reading quiz answers before accepting reading evidence', () => {
  const now = timestamp('2026-04-21T15:30:00.000Z');
  const quest = buildQuest({
    questId: 'reading-20-123',
    title: 'Leitura de 20 minutos',
    templateType: 'readingSession',
    verificationMode: 'timerWithReflection',
    targetDurationMinutes: 20,
    xpReward: 30,
    rewardAttribute: 'intelligence',
    verificationRequirement: {
      evidenceType: 'readingComprehension',
      minimumTrustTier: 2,
      minimumDurationMinutes: 20,
      minimumDistanceMeters: 0,
      minimumQuizScore: 70,
      allowedProviders: ['mockEvidence'],
    },
    reflectionAnswer: 'Resumo curto da sessao.',
    evidence: buildEvidence({
      questId: 'reading-20-123',
      type: 'readingComprehension',
      durationMinutes: 30,
      answers: [
        'A ideia principal ficou clara.',
        'A acao pratica e revisar amanha.',
      ],
    }),
  });
  const attempt = buildDeterministicReadingQuizAttempt({
    questId: quest.questId,
    topic: quest.title,
    minimumScore: quest.verificationRequirement.minimumQuizScore,
    now: timestamp('2026-04-21T15:05:00.000Z'),
  });
  const submission = {
    quizId: attempt.quizId,
    answers: ['ideia principal', 'acao pratica'],
  };
  const readingQuizEvaluation = evaluateReadingQuizSubmission({
    attempt,
    questId: quest.questId,
    submission,
    now,
  });

  const result = resolveCompetitiveQuestCompletionVerification({
    quest: {
      ...quest,
      readingQuizEvaluation,
      evidence: {
        ...quest.evidence,
        quizId: readingQuizEvaluation.quizId,
        quizScore: readingQuizEvaluation.score,
      },
    },
    session: {
      startedAt: timestamp('2026-04-21T15:00:00.000Z'),
    },
    grant: null,
    now,
  });

  assert.equal(readingQuizEvaluation.score, 100);
  assert.equal(result.status, 'verified');
  assert.equal(result.grantWrite.confidenceScore, 75);
});

test('uses deterministic reading quiz generator by default', async () => {
  const generator = createReadingQuizGenerator({
    env: {},
  });

  const attempt = await generator.generateAttempt({
    questId: 'reading-20-123',
    topic: 'Habitos Atomicos',
    minimumScore: 70,
    now: timestamp('2026-04-21T15:05:00.000Z'),
  });

  assert.equal(generator.name, 'deterministic');
  assert.equal(attempt.generator, 'deterministic_contract_v1');
  assert.equal(attempt.questions.length, 2);
  assert.match(attempt.questions[0].prompt, /Habitos Atomicos/);
});

test('supports provider-backed AI reading quiz generation behind adapter', async () => {
  const generator = createReadingQuizGenerator({
    env: {
      ASCEND_READING_QUIZ_GENERATOR: 'ai',
    },
    aiProvider: {
      async generateQuestions() {
        return [
          {
            id: 'thesis',
            prompt: 'Qual tese central do texto?',
            acceptedAnswer: 'tese central',
          },
          {
            id: 'application',
            prompt: 'Qual aplicacao pratica voce encontrou?',
            acceptedAnswer: 'aplicacao pratica',
          },
        ];
      },
    },
  });

  const attempt = await generator.generateAttempt({
    questId: 'reading-20-123',
    topic: 'Habitos Atomicos',
    minimumScore: 70,
    now: timestamp('2026-04-21T15:05:00.000Z'),
  });

  assert.equal(generator.name, 'ai');
  assert.equal(attempt.generator, 'ai_adapter_v1');
  assert.equal(attempt.questions[0].id, 'thesis');
  assert.equal(attempt.questions[1].acceptedAnswer, 'aplicacao pratica');
});

test('fails closed when AI reading quiz generation is enabled without provider', async () => {
  const generator = createReadingQuizGenerator({
    env: {
      ASCEND_READING_QUIZ_GENERATOR: 'ai',
    },
  });

  await assert.rejects(
    () =>
      generator.generateAttempt({
        questId: 'reading-20-123',
        topic: 'Habitos Atomicos',
        minimumScore: 70,
        now: timestamp('2026-04-21T15:05:00.000Z'),
      }),
    (error) => {
      assert.equal(error.code, 'failed-precondition');
      assert.match(error.message, /IA nao configurado/);
      return true;
    },
  );
});

test('Gemini provider maps structured output into reading quiz questions', async () => {
  const calls = [];
  const provider = new GeminiReadingQuizQuestionProvider({
    apiKey: 'test-key',
    fetchFn: async (url, init) => {
      calls.push({url, init});
      return {
        ok: true,
        async json() {
          return {
            candidates: [
              {
                content: {
                  parts: [
                    {
                      text: JSON.stringify({
                        questions: [
                          {
                            id: 'main-argument',
                            prompt: 'Qual argumento central do texto?',
                            acceptedAnswer: 'argumento central',
                          },
                          {
                            id: 'next-action',
                            prompt: 'Qual acao pratica voce tirou?',
                            acceptedAnswer: 'acao pratica',
                          },
                        ],
                      }),
                    },
                  ],
                },
              },
            ],
          };
        },
      };
    },
  });

  const questions = await provider.generateQuestions({
    questId: 'reading-20-123',
    topic: 'Habitos Atomicos',
    minimumScore: 70,
    now: timestamp('2026-04-21T15:05:00.000Z'),
  });

  assert.equal(questions.length, 2);
  assert.equal(questions[0].id, 'main-argument');
  assert.equal(questions[1].acceptedAnswer, 'acao pratica');
  assert.match(calls[0].url, /gemini-2\.5-flash-lite:generateContent$/);
  const body = JSON.parse(calls[0].init.body);
  assert.equal(body.generationConfig.responseMimeType, 'application/json');
  assert.equal(body.generationConfig.responseJsonSchema.required[0], 'questions');
});

test('Gemini provider fails when the API returns an error', async () => {
  const provider = new GeminiReadingQuizQuestionProvider({
    apiKey: 'test-key',
    fetchFn: async () => ({
      ok: false,
      async json() {
        return {};
      },
    }),
  });

  await assert.rejects(
    () =>
      provider.generateQuestions({
        questId: 'reading-20-123',
        topic: 'Habitos Atomicos',
        minimumScore: 70,
        now: timestamp('2026-04-21T15:05:00.000Z'),
      }),
    (error) => {
      assert.equal(error.code, 'unavailable');
      assert.match(error.message, /Gemini/);
      return true;
    },
  );
});

test('rejects reading evidence when backend-owned quiz score is too low', () => {
  const now = timestamp('2026-04-21T15:30:00.000Z');
  const quest = buildQuest({
    questId: 'reading-20-123',
    title: 'Leitura de 20 minutos',
    templateType: 'readingSession',
    verificationMode: 'timerWithReflection',
    targetDurationMinutes: 20,
    xpReward: 30,
    rewardAttribute: 'intelligence',
    verificationRequirement: {
      evidenceType: 'readingComprehension',
      minimumTrustTier: 2,
      minimumDurationMinutes: 20,
      minimumDistanceMeters: 0,
      minimumQuizScore: 70,
      allowedProviders: ['mockEvidence'],
    },
    reflectionAnswer: 'Resumo curto da sessao.',
    evidence: buildEvidence({
      questId: 'reading-20-123',
      type: 'readingComprehension',
      durationMinutes: 30,
      answers: ['resposta vaga'],
    }),
  });
  const attempt = buildDeterministicReadingQuizAttempt({
    questId: quest.questId,
    topic: quest.title,
    minimumScore: quest.verificationRequirement.minimumQuizScore,
    now: timestamp('2026-04-21T15:05:00.000Z'),
  });
  const readingQuizEvaluation = evaluateReadingQuizSubmission({
    attempt,
    questId: quest.questId,
    submission: {
      quizId: attempt.quizId,
      answers: ['resposta vaga'],
    },
    now,
  });

  assert.throws(
    () =>
      resolveCompetitiveQuestCompletionVerification({
        quest: {
          ...quest,
          readingQuizEvaluation,
          evidence: {
            ...quest.evidence,
            quizId: readingQuizEvaluation.quizId,
            quizScore: readingQuizEvaluation.score,
          },
        },
        session: {
          startedAt: timestamp('2026-04-21T15:00:00.000Z'),
        },
        grant: null,
        now,
      }),
    (error) => {
      assert.equal(error.code, 'failed-precondition');
      assert.match(error.message, /lowQuizScore/);
      return true;
    },
  );
});

test('verifies valid Health Connect running evidence', () => {
  const now = timestamp('2026-04-21T15:30:00.000Z');

  const result = resolveCompetitiveQuestCompletionVerification({
    quest: buildQuest({
      title: 'Corrida controlada de 2 km',
      templateType: 'runningSession',
      verificationMode: 'timer',
      targetDurationMinutes: 10,
      xpReward: 35,
      rewardAttribute: 'agility',
      verificationRequirement: {
        evidenceType: 'runningDistance',
        minimumTrustTier: 2,
        minimumDurationMinutes: 10,
        minimumDistanceMeters: 2000,
        minimumQuizScore: 0,
        allowedProviders: ['healthConnect', 'mockEvidence'],
      },
      evidence: buildEvidence({
        provider: 'healthConnect',
        type: 'runningDistance',
        durationMinutes: 12,
        distanceMeters: 2200,
        sourceActivityId: 'health-session-1',
      }),
    }),
    session: {
      startedAt: timestamp('2026-04-21T15:00:00.000Z'),
    },
    grant: null,
    now,
  });

  assert.equal(result.status, 'verified');
  assert.equal(result.grantWrite.evidenceProvider, 'healthConnect');
  assert.equal(result.grantWrite.confidenceScore, 85);
});

test('rejects competitive quest completion when evidence is missing', () => {
  const now = timestamp('2026-04-21T15:30:00.000Z');

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
      assert.match(error.message, /missingEvidence/);
      return true;
    },
  );
});

test('rejects impossible running evidence before granting rank progress', () => {
  const now = timestamp('2026-04-21T15:30:00.000Z');

  assert.throws(
    () =>
      resolveCompetitiveQuestCompletionVerification({
        quest: buildQuest({
          title: 'Corrida controlada de 2 km',
          templateType: 'runningSession',
          verificationMode: 'timer',
          targetDurationMinutes: 10,
          xpReward: 35,
          rewardAttribute: 'agility',
          verificationRequirement: {
            evidenceType: 'runningDistance',
            minimumTrustTier: 2,
            minimumDurationMinutes: 10,
            minimumDistanceMeters: 2000,
            minimumQuizScore: 0,
            allowedProviders: ['mockEvidence'],
          },
          evidence: buildEvidence({
            type: 'runningDistance',
            durationMinutes: 10,
            distanceMeters: 5000,
            sourceActivityId: 'activity-1',
          }),
        }),
        session: {
          startedAt: timestamp('2026-04-21T15:00:00.000Z'),
        },
        grant: null,
        now,
      }),
    (error) => {
      assert.equal(error.code, 'failed-precondition');
      assert.match(error.message, /impossiblePace/);
      return true;
    },
  );
});

test('rejects reused source activity evidence before granting rank progress', () => {
  const now = timestamp('2026-04-21T15:30:00.000Z');

  assert.throws(
    () =>
      resolveCompetitiveQuestCompletionVerification({
        quest: buildQuest({
          evidence: buildEvidence({
            sourceActivityId: 'activity-1',
          }),
        }),
        session: {
          startedAt: timestamp('2026-04-21T15:00:00.000Z'),
        },
        grant: null,
        now,
        sourceActivityIdAlreadyUsed: true,
      }),
    (error) => {
      assert.equal(error.code, 'failed-precondition');
      assert.match(error.message, /duplicateSourceActivityId/);
      return true;
    },
  );
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

test('parses timestamp payloads sent by mobile callable clients', () => {
  assert.equal(
    parseTimestampInput('2026-04-21T15:00:00.000Z').toMillis(),
    timestamp('2026-04-21T15:00:00.000Z').toMillis(),
  );
  assert.equal(
    parseTimestampInput({seconds: 1776783600, nanoseconds: 0}).toMillis(),
    timestamp('2026-04-21T15:00:00.000Z').toMillis(),
  );
  assert.equal(
    parseTimestampInput({millisecondsSinceEpoch: 1776783600000}).toMillis(),
    timestamp('2026-04-21T15:00:00.000Z').toMillis(),
  );
});
