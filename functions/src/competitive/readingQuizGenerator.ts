import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';
import {
  buildDeterministicReadingQuizAttempt,
  ReadingQuizAttempt,
  ReadingQuizQuestion,
} from './readingQuiz';
import { ensureString } from '../shared/validation';

export type ReadingQuizGeneratorName = 'deterministic' | 'ai';

export type ReadingQuizGenerationRequest = {
  questId: string;
  topic: string;
  minimumScore: number;
  now: admin.firestore.Timestamp;
};

export interface ReadingQuizGenerator {
  readonly name: ReadingQuizGeneratorName;
  generateAttempt(
    request: ReadingQuizGenerationRequest,
  ): Promise<ReadingQuizAttempt>;
}

export interface AiReadingQuizQuestionProvider {
  generateQuestions(
    request: ReadingQuizGenerationRequest,
  ): Promise<ReadingQuizQuestion[]>;
}

export class DeterministicReadingQuizGenerator implements ReadingQuizGenerator {
  readonly name = 'deterministic' as const;

  async generateAttempt(
    request: ReadingQuizGenerationRequest,
  ): Promise<ReadingQuizAttempt> {
    return buildDeterministicReadingQuizAttempt(request);
  }
}

export class AiReadingQuizGenerator implements ReadingQuizGenerator {
  readonly name = 'ai' as const;

  constructor(private readonly provider?: AiReadingQuizQuestionProvider) {}

  async generateAttempt(
    request: ReadingQuizGenerationRequest,
  ): Promise<ReadingQuizAttempt> {
    if (!this.provider) {
      throw new HttpsError(
        'failed-precondition',
        'Gerador de quiz por IA nao configurado.',
      );
    }

    const questions = sanitizeAiQuestions(
      await this.provider.generateQuestions(request),
    );
    const baseAttempt = buildDeterministicReadingQuizAttempt(request);
    return {
      ...baseAttempt,
      generator: 'ai_adapter_v1',
      questions,
    };
  }
}

export function createReadingQuizGenerator(args?: {
  env?: NodeJS.ProcessEnv;
  aiProvider?: AiReadingQuizQuestionProvider;
}): ReadingQuizGenerator {
  const env = args?.env ?? process.env;
  const configured = env.ASCEND_READING_QUIZ_GENERATOR ?? 'deterministic';
  if (configured === 'deterministic') {
    return new DeterministicReadingQuizGenerator();
  }
  if (configured === 'ai') {
    return new AiReadingQuizGenerator(args?.aiProvider);
  }
  throw new HttpsError(
    'failed-precondition',
    'Gerador de quiz de leitura invalido.',
  );
}

function sanitizeAiQuestions(
  questions: ReadingQuizQuestion[],
): ReadingQuizQuestion[] {
  if (!Array.isArray(questions) || questions.length < 2) {
    throw new HttpsError(
      'failed-precondition',
      'IA retornou quiz de leitura incompleto.',
    );
  }

  return questions.slice(0, 4).map((question, index) => ({
    id: ensureString(
      question.id || `ai-question-${index + 1}`,
      'aiQuestion.id',
      80,
    ),
    prompt: ensureString(question.prompt, 'aiQuestion.prompt', 500),
    acceptedAnswer: ensureString(
      question.acceptedAnswer,
      'aiQuestion.acceptedAnswer',
      200,
    ),
  }));
}
