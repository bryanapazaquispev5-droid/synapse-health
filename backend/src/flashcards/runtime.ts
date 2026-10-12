import { createHash } from 'node:crypto';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, UpdateCommand } from '@aws-sdk/lib-dynamodb';
import { ApiError } from '../http.mjs';
import type { FlashcardRepository } from './model.js';
import { DynamoFlashcardRepository } from './repository.js';

type Client = Pick<DynamoDBDocumentClient, 'send'>;
export interface FlashcardLimiter { consume(subject: string): Promise<void> }
interface FlashcardRuntime { repository: FlashcardRepository; limiter: FlashcardLimiter }
export function createDynamoRateLimiter(client: Client, tableName: string, now = Date.now, limit = 60): FlashcardLimiter {
  return {
    async consume(subject: string): Promise<void> {
      if (!tableName.trim() || !Number.isInteger(limit) || limit < 1 || limit > 1000) throw new ApiError(503, 'unavailable', 'Rate limit service is unavailable.');
      const seconds = Math.floor(now() / 1000);
      const start = Math.floor(seconds / 60) * 60;
      const key = createHash('sha256').update(subject).digest('hex');
      try {
        await client.send(new UpdateCommand({
          TableName: tableName, Key: { PK: `RATE#${key}`, SK: `WINDOW#${start}` },
          UpdateExpression: 'SET #expires = :expires ADD #count :one',
          ConditionExpression: 'attribute_not_exists(#count) OR #count < :limit',
          ExpressionAttributeNames: { '#count': 'count', '#expires': 'expiresAt' },
          ExpressionAttributeValues: { ':expires': start + 120, ':one': 1, ':limit': limit },
        }));
      } catch (error) {
        if (error instanceof Error && error.name === 'ConditionalCheckFailedException') {
          throw new ApiError(429, 'rate_limited', 'Try again later.', { 'Retry-After': String(Math.max(1, start + 60 - seconds)) });
        }
        throw new ApiError(503, 'unavailable', 'Rate limit service is unavailable.');
      }
    },
  };
}
export function createFlashcardRuntime(env: NodeJS.ProcessEnv = process.env): FlashcardRuntime {
  const client = DynamoDBDocumentClient.from(new DynamoDBClient({ maxAttempts: 3, requestHandler: { connectionTimeout: 2000, requestTimeout: 5000 } }));
  return {
    repository: new DynamoFlashcardRepository(client, env.FLASHCARDS_TABLE_NAME ?? ''),
    limiter: createDynamoRateLimiter(client, env.FLASHCARDS_TABLE_NAME ?? '', Date.now,
      env.FLASHCARDS_RATE_LIMIT === undefined ? 60 : /^[1-9]\d{0,3}$/.test(env.FLASHCARDS_RATE_LIMIT) ? Number(env.FLASHCARDS_RATE_LIMIT) : NaN),
  };
}
