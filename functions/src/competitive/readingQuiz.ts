import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';
import { ensureString, ensureStringArray } from '../shared/validation';

export type ReadingQuizQuestion = {
  id: string;
  prompt: string;
  acceptedAnswer: string;
};

export type ReadingQuizAttempt = {
  quizId: string;
  questId: string;
  topic: string;
  minimumScore: number;
  questions: ReadingQuizQuestion[];
  issuedAt: admin.firestore.Timestamp;
  expiresAt: admin.firestore.Timestamp;
};

export type ReadingQuizSubmission = {
  quizId: string;
  answers: string[];
};

export type ReadingQuizEvaluation = {
  quizId: string;
  score: number;
  passed: boolean;
  riskFlags: string[];
};

const quizLifetimeMillis = 2 * 60 * 60 * 1000;

export function buildDeterministicReadingQuizAttempt(args: {
  questId: string;
  topic: string;
  minimumScore: number;
  now: admin.firestore.Timestamp;
}): ReadingQuizAttempt {
  const normalizedTopic = args.topic.trim().slice(0, 120);
  const quizId = `${args.questId}__${args.now.toMillis()}`;

  return {
    quizId,
    questId: args.questId,
    topic: normalizedTopic,
    minimumScore: args.minimumScore,
    issuedAt: args.now,
    expiresAt: admin.firestore.Timestamp.fromMillis(
      args.now.toMillis() + quizLifetimeMillis,
    ),
    questions: [
      {
        id: 'main-idea',
        prompt: `Qual foi a ideia principal de ${normalizedTopic}?`,
        acceptedAnswer: 'ideia principal',
      },
      {
        id: 'practical-action',
        prompt: `Qual acao pratica voce tira de ${normalizedTopic}?`,
        acceptedAnswer: 'acao pratica',
      },
    ],
  };
}

export function validateReadingQuizSubmission(
  payload: unknown,
): ReadingQuizSubmission {
  if (!payload || typeof payload !== 'object') {
    throw new HttpsError('invalid-argument', 'Quiz de leitura invalido.');
  }

  const data = payload as Record<string, unknown>;
  return {
    quizId: ensureString(data.quizId, 'quiz.quizId', 160),
    answers: ensureStringArray(data.answers, 'quiz.answers', 500),
  };
}

export function evaluateReadingQuizSubmission(args: {
  attempt: ReadingQuizAttempt | null;
  questId: string;
  submission: ReadingQuizSubmission | null;
  now: admin.firestore.Timestamp;
}): ReadingQuizEvaluation {
  const flags: string[] = [];
  const {attempt, submission, now} = args;

  if (!attempt) {
    return {
      quizId: submission?.quizId ?? '',
      score: 0,
      passed: false,
      riskFlags: ['missingQuizAttempt'],
    };
  }
  if (!submission) {
    return {
      quizId: attempt.quizId,
      score: 0,
      passed: false,
      riskFlags: ['missingQuizSubmission'],
    };
  }
  if (attempt.questId !== args.questId) {
    flags.push('quizQuestMismatch');
  }
  if (attempt.quizId !== submission.quizId) {
    flags.push('quizIdMismatch');
  }
  if (attempt.expiresAt.toMillis() < now.toMillis()) {
    flags.push('staleQuiz');
  }

  let correctCount = 0;
  for (const [index, question] of attempt.questions.entries()) {
    const answer = submission.answers[index];
    if (!answer) {
      flags.push('missingQuizAnswer');
      continue;
    }
    if (matchesExpectedAnswer(answer, question.acceptedAnswer)) {
      correctCount += 1;
    }
  }

  const score = Math.round((correctCount / attempt.questions.length) * 100);
  if (score < attempt.minimumScore) {
    flags.push('lowQuizScore');
  }

  return {
    quizId: attempt.quizId,
    score,
    passed: flags.length === 0,
    riskFlags: [...new Set(flags)],
  };
}

export function readingQuizAttemptFromData(
  data: Record<string, unknown> | undefined,
): ReadingQuizAttempt | null {
  if (!data) return null;
  const questions = Array.isArray(data.questions)
    ? data.questions.map((question: Record<string, unknown>) => ({
      id: ensureString(question.id, 'quiz.questions[].id', 80),
      prompt: ensureString(question.prompt, 'quiz.questions[].prompt', 500),
      acceptedAnswer: ensureString(
        question.acceptedAnswer,
        'quiz.questions[].acceptedAnswer',
        200,
      ),
    }))
    : [];
  if (
    typeof data.quizId !== 'string' ||
    typeof data.questId !== 'string' ||
    typeof data.topic !== 'string' ||
    typeof data.minimumScore !== 'number' ||
    !(data.issuedAt instanceof admin.firestore.Timestamp) ||
    !(data.expiresAt instanceof admin.firestore.Timestamp) ||
    questions.length === 0
  ) {
    return null;
  }

  return {
    quizId: data.quizId,
    questId: data.questId,
    topic: data.topic,
    minimumScore: data.minimumScore,
    questions,
    issuedAt: data.issuedAt,
    expiresAt: data.expiresAt,
  };
}

export function readingQuizAttemptWrite(attempt: ReadingQuizAttempt) {
  return {
    quizId: attempt.quizId,
    questId: attempt.questId,
    topic: attempt.topic,
    minimumScore: attempt.minimumScore,
    questions: attempt.questions,
    issuedAt: attempt.issuedAt,
    expiresAt: attempt.expiresAt,
    generator: 'deterministic_contract_v1',
  };
}

function matchesExpectedAnswer(answer: string, expected: string): boolean {
  const answerTokens = normalizeAnswer(answer);
  return normalizeAnswer(expected).every((token) => answerTokens.includes(token));
}

function normalizeAnswer(value: string): string[] {
  return value
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .split(/[^a-z0-9]+/)
    .filter(Boolean);
}
