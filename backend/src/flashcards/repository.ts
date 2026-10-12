import { randomUUID } from 'node:crypto';
import { GetCommand, PutCommand, QueryCommand, DeleteCommand } from '@aws-sdk/lib-dynamodb';
import type { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';
import { ApiError } from '../http.mjs';
import {
  decodeLocator, encodeLocator, flashcardKey, invalidFlashcard, validCatalogId,
  type Flashcard, type FlashcardInput, type FlashcardPatch, type FlashcardRepository,
  type FlashcardListOptions, type FlashcardPage,
} from './model.js';

type Key = { PK: string; SK: string };
interface StoredFlashcard extends Flashcard, Key { entityType: 'FLASHCARD' }
function publicRecord(item: Record<string, unknown>): Flashcard {
  const { PK: _pk, SK: _sk, entityType: _type, ...record } = item;
  return record as unknown as Flashcard;
}
function conditionalFailure(error: unknown): boolean {
  return error instanceof Error && error.name === 'ConditionalCheckFailedException';
}
function expectedVersion(version: number): void {
  if (!Number.isSafeInteger(version) || version < 1 || version >= Number.MAX_SAFE_INTEGER) throw invalidFlashcard();
}
function cursorKey(cursor: string, areaId: string, topicId?: string): Key {
  const decoded = decodeLocator(cursor);
  if (!Array.isArray(decoded) || decoded.length !== 4 || decoded[0] !== areaId ||
      decoded[1] !== (topicId ?? null) || typeof decoded[2] !== 'string' || typeof decoded[3] !== 'string') {
    throw invalidFlashcard();
  }
  const key = { PK: decoded[2], SK: decoded[3] };
  if (key.PK !== `AREA#${areaId}` || !/^FLASHCARD#[a-f0-9-]{36}$/.test(key.SK)) throw invalidFlashcard();
  return key;
}

/** Opaque IDs encode the immutable area locator, avoiding a second index and eventual reads. */
export class DynamoFlashcardRepository implements FlashcardRepository {
  constructor(
    private readonly client: Pick<DynamoDBDocumentClient, 'send'>,
    private readonly tableName: string,
    private readonly clock: () => Date = () => new Date(),
    private readonly makeUuid: () => string = randomUUID,
  ) {}
  private table(): string {
    if (!this.tableName.trim()) throw new ApiError(503, 'content_unavailable', 'Content service is unavailable.');
    return this.tableName;
  }
  async list(areaId: string, options: FlashcardListOptions = {}): Promise<FlashcardPage> {
    const { topicId, cursor } = options;
    const limit = options.limit ?? 20;
    if (!validCatalogId(areaId) || (topicId !== undefined && !validCatalogId(topicId)) ||
        !Number.isInteger(limit) || limit < 1 || limit > 50) throw invalidFlashcard();
    const exclusiveStartKey = cursor ? cursorKey(cursor, areaId, topicId) : undefined;
    const result = await this.client.send(new QueryCommand({
      TableName: this.table(), ConsistentRead: true, Limit: limit,
      KeyConditionExpression: '#pk = :area AND begins_with(#sk, :prefix)',
      ExpressionAttributeNames: { '#pk': 'PK', '#sk': 'SK', ...(topicId ? { '#topic': 'topicId' } : {}) },
      ExpressionAttributeValues: { ':area': `AREA#${areaId}`, ':prefix': 'FLASHCARD#', ...(topicId ? { ':topic': topicId } : {}) },
      ...(topicId ? { FilterExpression: '#topic = :topic' } : {}),
      ...(exclusiveStartKey ? { ExclusiveStartKey: exclusiveStartKey } : {}),
    }));
    return {
      items: (result.Items ?? []).map(publicRecord),
      // A filtered page can be empty and still have a continuation; never infer exhaustion from items.
      nextCursor: result.LastEvaluatedKey
        ? encodeLocator([areaId, topicId ?? null, result.LastEvaluatedKey.PK, result.LastEvaluatedKey.SK]) : null,
    };
  }
  async get(id: string): Promise<Flashcard> {
    const result = await this.client.send(new GetCommand({ TableName: this.table(), Key: flashcardKey(id), ConsistentRead: true }));
    if (!result.Item) throw new ApiError(404, 'flashcard_not_found', 'Flashcard was not found.');
    return publicRecord(result.Item);
  }
  async create(input: FlashcardInput): Promise<Flashcard> {
    const id = encodeLocator([input.areaId, this.makeUuid()]);
    const timestamp = this.clock().toISOString();
    const record: Flashcard = { ...input, id, version: 1, createdAt: timestamp, updatedAt: timestamp };
    const item: StoredFlashcard = { ...record, ...flashcardKey(id), entityType: 'FLASHCARD' };
    try {
      await this.client.send(new PutCommand({
        TableName: this.table(), Item: item,
        ConditionExpression: 'attribute_not_exists(#pk)', ExpressionAttributeNames: { '#pk': 'PK' },
      }));
    } catch (error) {
      if (conditionalFailure(error)) throw new ApiError(409, 'identifier_conflict', 'Flashcard already exists. Retry creation.');
      throw error;
    }
    return record;
  }
  async update(id: string, patch: FlashcardPatch, version: number): Promise<Flashcard> {
    expectedVersion(version);
    const current = await this.get(id);
    if (current.version !== version) throw new ApiError(409, 'version_conflict', 'Flashcard changed. Reload and retry.');
    const record: Flashcard = { ...current, ...patch, id, areaId: current.areaId, createdAt: current.createdAt,
      version: version + 1, updatedAt: this.clock().toISOString() };
    try {
      await this.client.send(new PutCommand({
        TableName: this.table(), Item: { ...record, ...flashcardKey(id), entityType: 'FLASHCARD' },
        ConditionExpression: 'attribute_exists(#pk) AND #version = :version',
        ExpressionAttributeNames: { '#pk': 'PK', '#version': 'version' }, ExpressionAttributeValues: { ':version': version },
      }));
    } catch (error) { await this.rethrowConflict(error, id); }
    return record;
  }
  async delete(id: string, version: number): Promise<void> {
    expectedVersion(version);
    try {
      await this.client.send(new DeleteCommand({
        TableName: this.table(), Key: flashcardKey(id),
        ConditionExpression: 'attribute_exists(#pk) AND #version = :version',
        ExpressionAttributeNames: { '#pk': 'PK', '#version': 'version' }, ExpressionAttributeValues: { ':version': version },
      }));
    } catch (error) { await this.rethrowConflict(error, id); }
  }
  private async rethrowConflict(error: unknown, id: string): Promise<never> {
    if (!conditionalFailure(error)) throw error;
    await this.get(id);
    throw new ApiError(409, 'version_conflict', 'Flashcard changed. Reload and retry.');
  }
}
