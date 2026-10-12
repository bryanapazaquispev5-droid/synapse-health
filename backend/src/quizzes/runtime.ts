import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';
import { createDynamoRateLimiter } from '../flashcards/runtime.js';
import { DynamoQuizRepository } from './repository.js';
import { buildQuestionSnapshot } from './scoring.js';
export function createQuizRuntime(env: NodeJS.ProcessEnv = process.env): { repository: DynamoQuizRepository; limiter: ReturnType<typeof createDynamoRateLimiter> } {
  const client = DynamoDBDocumentClient.from(new DynamoDBClient({ maxAttempts: 3,
    requestHandler: { connectionTimeout: 2000, requestTimeout: 5000 } }));
  const contentTable = env.QUIZZES_TABLE_NAME ?? '';
  return {
    repository: new DynamoQuizRepository(client, contentTable, env.QUIZ_RESULTS_TABLE_NAME ?? '', buildQuestionSnapshot),
    limiter: createDynamoRateLimiter(client, contentTable, Date.now,
      env.QUIZZES_RATE_LIMIT === undefined ? 60 : /^[1-9]\d{0,3}$/.test(env.QUIZZES_RATE_LIMIT) ? Number(env.QUIZZES_RATE_LIMIT) : NaN),
  };
}
