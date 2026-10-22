import { GetCommand, QueryCommand, TransactWriteCommand } from '@aws-sdk/lib-dynamodb';
import type { TransactWriteCommandInput } from '@aws-sdk/lib-dynamodb';
import { ApiError } from '../http.mjs';
import type { AcademicClient } from './catalog.js';
import type { ProgressListOptions, ProgressPage, TopicProgress } from './model.js';
import { decode, encodeLocator, invalidQuiz, topicKey, unavailable, userKey } from './keys.js';
export interface StoredTopic extends TopicProgress { inFlight: Record<string, string>; catalogFingerprint: string; catalogQuestionCount: number }
export interface RequestRecord { operation: string; attemptId?: string; progress?: TopicProgress }
export function publicTopic(topic: StoredTopic): TopicProgress {
  const { inFlight: _flight, catalogFingerprint: _catalog, catalogQuestionCount: _count, ...progress } = topic; return progress;
}
export class AcademicPrivateStore {
  constructor(readonly client: AcademicClient, readonly tableName: string) {}
  table(): string { if (!this.tableName.trim()) throw unavailable(); return this.tableName; }
  key(subject: string, entryKey: string): { userKey: string; entryKey: string } { return { userKey: userKey(subject), entryKey }; }
  async read<T>(subject: string, entryKey: string): Promise<T | null> {
    const response = await this.client.send(new GetCommand({ TableName: this.table(), Key: this.key(subject, entryKey), ConsistentRead: true }));
    if (!response.Item) return null;
    const { userKey: _user, entryKey: _entry, entityType: _type, ...value } = response.Item;
    return value as T;
  }
  put(subject: string, entryKey: string, record: object, condition = 'attribute_not_exists(entryKey)', version?: number): NonNullable<TransactWriteCommandInput['TransactItems']>[number] {
    return { Put: { TableName: this.table(), Item: { ...record, ...this.key(subject, entryKey) }, ConditionExpression: condition,
      ...(version === undefined ? {} : { ExpressionAttributeNames: { '#version': 'version' }, ExpressionAttributeValues: { ':version': version } }) } };
  }
  async transact(items: NonNullable<TransactWriteCommandInput['TransactItems']>): Promise<void> {
    if (!items.length || items.length > 100) throw unavailable();
    for (const item of items) {
      if (item.Put && Buffer.byteLength(JSON.stringify(item.Put.Item), 'utf8') > 256_000) throw unavailable();
    }
    await this.client.send(new TransactWriteCommand({ TransactItems: items }));
  }
  async topic(subject: string, areaId: string, topicId: string): Promise<StoredTopic | null> { return this.read(subject, topicKey(areaId, topicId)); }
  async progress(subject: string, options: ProgressListOptions = {}): Promise<ProgressPage> {
    const limit = options.limit ?? 20; if (!Number.isInteger(limit) || limit < 1 || limit > 50) throw invalidQuiz();
    let start: { userKey: string; entryKey: string } | undefined;
    if (options.cursor) {
      const parts = decode(options.cursor);
      if (!Array.isArray(parts) || parts.length !== 2 || parts[0] !== userKey(subject) ||
        typeof parts[1] !== 'string' || !/^TOPIC#[A-Za-z0-9_-]{1,128}#[A-Za-z0-9_-]{1,128}$/.test(parts[1])) throw invalidQuiz();
      start = { userKey: parts[0], entryKey: parts[1] };
    }
    const response = await this.client.send(new QueryCommand({ TableName: this.table(), ConsistentRead: true,
      KeyConditionExpression: 'userKey = :user AND begins_with(entryKey, :prefix)',
      ExpressionAttributeValues: { ':user': userKey(subject), ':prefix': 'TOPIC#' }, Limit: limit, ExclusiveStartKey: start }));
    const items = (response.Items ?? []).map(item => {
      const { userKey: _user, entryKey: _entry, entityType: _type, ...topic } = item;
      return publicTopic(topic as unknown as StoredTopic);
    });
    return { items, nextCursor: response.LastEvaluatedKey ? encodeLocator([response.LastEvaluatedKey.userKey, response.LastEvaluatedKey.entryKey]) : null };
  }
}
export function notFoundAttempt(): ApiError { return new ApiError(404, 'attempt_not_found', 'Attempt is unavailable.'); }
