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

type FetchFn = typeof fetch;

type GeminiQuestionResponse = {
  questions?: Array<{
    id?: unknown;
    prompt?: unknown;
    acceptedAnswer?: unknown;
  }>;
};

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

export class GeminiReadingQuizQuestionProvider
  implements AiReadingQuizQuestionProvider {
  constructor(args: {
    apiKey: string;
    model?: string;
    fetchFn?: FetchFn;
  }) {
    this.apiKey = args.apiKey;
    this.model = args.model ?? 'gemini-2.5-flash-lite';
    this.fetchFn = args.fetchFn ?? fetch;
  }

  private readonly apiKey: string;
  private readonly model: string;
  private readonly fetchFn: FetchFn;

  async generateQuestions(
    request: ReadingQuizGenerationRequest,
  ): Promise<ReadingQuizQuestion[]> {
    const response = await this.fetchFn(
      `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(
        this.model,
      )}:generateContent`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': this.apiKey,
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text: buildGeminiReadingQuizPrompt(request),
                },
              ],
            },
          ],
          generationConfig: {
            temperature: 0.2,
            responseMimeType: 'application/json',
            responseJsonSchema: readingQuizGeminiSchema(),
          },
        }),
      },
    );

    if (!response.ok) {
      throw new HttpsError(
        'unavailable',
        'Gemini nao conseguiu gerar o quiz de leitura.',
      );
    }

    const payload = await response.json() as Record<string, unknown>;
    const text = extractGeminiText(payload);
    const parsed = JSON.parse(text) as GeminiQuestionResponse;
    return normalizeGeminiQuestions(parsed);
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
    const apiKey = env.GEMINI_API_KEY;
    const provider = args?.aiProvider ?? (
      apiKey
        ? new GeminiReadingQuizQuestionProvider({
          apiKey,
          model: env.GEMINI_READING_QUIZ_MODEL,
        })
        : undefined
    );
    return new AiReadingQuizGenerator(provider);
  }
  throw new HttpsError(
    'failed-precondition',
    'Gerador de quiz de leitura invalido.',
  );
}

function buildGeminiReadingQuizPrompt(
  request: ReadingQuizGenerationRequest,
): string {
  return [
    'Voce gera quizzes curtos de compreensao de leitura para o app Ascend.',
    'Responda somente no JSON exigido pelo schema.',
    'Crie 2 perguntas em portugues brasileiro.',
    'Cada pergunta deve verificar compreensao real, nao opiniao generica.',
    'acceptedAnswer deve conter uma resposta curta com 2 a 5 palavras-chave.',
    'Nao inclua dados pessoais, explicacoes ou markdown.',
    `Topico declarado pelo usuario: ${request.topic}`,
  ].join('\n');
}

function readingQuizGeminiSchema() {
  return {
    type: 'object',
    properties: {
      questions: {
        type: 'array',
        minItems: 2,
        maxItems: 4,
        items: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              description: 'Identificador curto em kebab-case.',
            },
            prompt: {
              type: 'string',
              description: 'Pergunta de compreensao em portugues brasileiro.',
            },
            acceptedAnswer: {
              type: 'string',
              description: 'Resposta curta com palavras-chave esperadas.',
            },
          },
          required: ['id', 'prompt', 'acceptedAnswer'],
        },
      },
    },
    required: ['questions'],
  };
}

function extractGeminiText(payload: Record<string, unknown>): string {
  const candidates = payload.candidates;
  if (!Array.isArray(candidates)) {
    throw new HttpsError('unavailable', 'Resposta invalida do Gemini.');
  }

  const first = candidates[0] as Record<string, unknown> | undefined;
  const content = first?.content as Record<string, unknown> | undefined;
  const parts = content?.parts;
  if (!Array.isArray(parts)) {
    throw new HttpsError('unavailable', 'Resposta vazia do Gemini.');
  }

  const text = (parts[0] as Record<string, unknown> | undefined)?.text;
  if (typeof text !== 'string' || text.trim().length === 0) {
    throw new HttpsError('unavailable', 'Texto de quiz ausente no Gemini.');
  }
  return text;
}

function normalizeGeminiQuestions(
  parsed: GeminiQuestionResponse,
): ReadingQuizQuestion[] {
  if (!Array.isArray(parsed.questions)) {
    throw new HttpsError('unavailable', 'Quiz do Gemini sem perguntas.');
  }

  return parsed.questions.map((question, index) => ({
    id: ensureString(
      question.id || `gemini-question-${index + 1}`,
      'geminiQuestion.id',
      80,
    ),
    prompt: ensureString(question.prompt, 'geminiQuestion.prompt', 500),
    acceptedAnswer: ensureString(
      question.acceptedAnswer,
      'geminiQuestion.acceptedAnswer',
      200,
    ),
  }));
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
