import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';
import { createDynamoRateLimiter } from '../flashcards/runtime.js';
import { DynamoQuizRepository } from './repository.js';
import { buildQuestionSnapshot } from './scoring.js';
import { DynamoRankingRepository } from '../ranking/repository.js';
import { DynamoHistoryRepository } from '../academic-history/repository.js';
export function createQuizRuntime(env: NodeJS.ProcessEnv = process.env): {
  repository: DynamoQuizRepository; limiter: ReturnType<typeof createDynamoRateLimiter>;
  views: { history: DynamoHistoryRepository; ranking: DynamoRankingRepository; enabled: boolean };
} {
  const client = DynamoDBDocumentClient.from(new DynamoDBClient({ maxAttempts: 3,
    requestHandler: { connectionTimeout: 2000, requestTimeout: 5000 } }));
  const contentTable = env.QUIZZES_TABLE_NAME ?? '';
  const enabled = env.ACADEMIC_VIEWS_ENABLED === 'true';
  const privateTable = env.QUIZ_RESULTS_TABLE_NAME ?? '';
  const ranking = new DynamoRankingRepository(client, privateTable);
  const history = new DynamoHistoryRepository(client, privateTable);
  return {
    views: { history, ranking, enabled },
    repository: new DynamoQuizRepository(client, contentTable, env.QUIZ_RESULTS_TABLE_NAME ?? '', buildQuestionSnapshot,
      undefined, undefined, enabled ? (subject, topic, now) => ranking.prepareCompletion(subject, topic, now) : undefined),
    limiter: createDynamoRateLimiter(client, contentTable, Date.now,
      env.QUIZZES_RATE_LIMIT === undefined ? 60 : /^[1-9]\d{0,3}$/.test(env.QUIZZES_RATE_LIMIT) ? Number(env.QUIZZES_RATE_LIMIT) : NaN),
  };
}
