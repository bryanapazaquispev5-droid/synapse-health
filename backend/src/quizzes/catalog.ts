import { createHash } from 'node:crypto';
import { GetCommand, QueryCommand } from '@aws-sdk/lib-dynamodb';
import type { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';
import { ApiError } from '../http.mjs';
import type { FlashcardListOptions } from '../flashcards/model.js';
import type { QuizPage, QuizRecord } from './model.js';
import { catalogRecord } from './catalog-record.js';
import { quizKey, decode, encodeLocator, validCatalogId, invalidQuiz, unavailable } from './keys.js';
export type AcademicClient = Pick<DynamoDBDocumentClient, 'send'>;
export class DynamoQuizCatalog {
  constructor(protected readonly client: AcademicClient, protected readonly contentTable: string) {}
  protected table(): string { if (!this.contentTable.trim()) throw unavailable(); return this.contentTable; }
  async get(id: string): Promise<QuizRecord> {
    const response = await this.client.send(new GetCommand({ TableName: this.table(), Key: quizKey(id), ConsistentRead: true }));
    if (!response.Item || response.Item.entityType !== 'QUIZ') throw new ApiError(404, 'quiz_not_found', 'Quiz is unavailable.');
    const quiz = catalogRecord(response.Item);
    if (quiz.id !== id) throw unavailable();
    return quiz;
  }
  async list(areaId: string, options: FlashcardListOptions = {}): Promise<QuizPage> {
    const { topicId, cursor } = options; const limit = options.limit ?? 20;
    if (!validCatalogId(areaId) || (topicId !== undefined && !validCatalogId(topicId)) || !Number.isInteger(limit) || limit < 1 || limit > 50) throw invalidQuiz();
    let start: { PK: string; SK: string } | undefined;
    if (cursor) {
      const parts = decode(cursor);
      if (!Array.isArray(parts) || parts.length !== 4 || parts[0] !== areaId || parts[1] !== (topicId ?? null) ||
        parts[2] !== `AREA#${areaId}` || typeof parts[3] !== 'string' || !/^QUIZ#[a-f0-9-]{36}$/.test(parts[3])) throw invalidQuiz();
      start = { PK: parts[2], SK: parts[3] };
    }
    const response = await this.client.send(new QueryCommand({
      TableName: this.table(), ConsistentRead: true, KeyConditionExpression: 'PK = :area AND begins_with(SK, :prefix)',
      ExpressionAttributeValues: { ':area': `AREA#${areaId}`, ':prefix': 'QUIZ#', ...(topicId ? { ':topic': topicId } : {}) },
      ...(topicId ? { FilterExpression: 'topicId = :topic' } : {}), Limit: limit, ExclusiveStartKey: start,
    }));
    return { items: (response.Items ?? []).map(catalogRecord), nextCursor: response.LastEvaluatedKey
      ? encodeLocator([areaId, topicId ?? null, response.LastEvaluatedKey.PK, response.LastEvaluatedKey.SK]) : null };
  }
  /** Full topic denominator is bounded by DynamoDB's item limit, never a truncated catalog page. */
  async topicCatalog(areaId: string, topicId: string): Promise<{ maxStars: number; fingerprint: string; quizzes: QuizRecord[] }> {
    let cursor: string | null = null; let stars = 0; let count = 0; let pages = 0; const quizzes: QuizRecord[] = [];
    do {
      const page: QuizPage = await this.list(areaId, { topicId, cursor, limit: 50 });
      for (const quiz of page.items) {
        stars += quiz.type === 'matching' ? quiz.matchingPairs.length : quiz.type === 'ordering' ? quiz.orderingItems.length : 1;
        count++; quizzes.push(quiz);
      }
      cursor = page.nextCursor;
      if (++pages > 200 || count > 500 || !Number.isSafeInteger(stars)) throw unavailable();
    } while (cursor);
    if (count === 0) throw new ApiError(404, 'topic_not_found', 'Topic is unavailable.');
    const normalized = quizzes.sort((a, b) => a.id.localeCompare(b.id)).map(quiz => ({
      id: quiz.id, areaId: quiz.areaId, topicId: quiz.topicId, version: quiz.version, type: quiz.type,
      question: quiz.question, options: quiz.options, correctIndex: quiz.correctIndex,
      rationale: quiz.rationale, sourceBook: quiz.sourceBook, orderIndex: quiz.orderIndex,
      matchingPairs: quiz.matchingPairs.map(pair => ({ left: pair.left, right: pair.right })), orderingItems: quiz.orderingItems,
    }));
    return { maxStars: stars, fingerprint: createHash('sha256').update(JSON.stringify(normalized)).digest('hex'), quizzes };
  }
  async topicMaxStars(areaId: string, topicId: string): Promise<number> {
    return (await this.topicCatalog(areaId, topicId)).maxStars;
  }
}
