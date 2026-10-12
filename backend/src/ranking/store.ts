import { GetCommand, TransactGetCommand } from '@aws-sdk/lib-dynamodb';
import type { TransactWriteCommandInput } from '@aws-sdk/lib-dynamodb';
import type { AcademicClient } from '../quizzes/catalog.js';
import { userKey } from '../quizzes/keys.js';
import { GLOBAL_KEY, METRICS_KEY, rankingUnavailable, validCount, type RankingMeta, type RankingNode } from './model.js';
export type RankingWrites = NonNullable<TransactWriteCommandInput['TransactItems']>;
export interface RankingKey { userKey: string; entryKey: string }
export const globalKey = (entryKey: string): RankingKey => ({ userKey: GLOBAL_KEY, entryKey });
export const metricsKey = (subject: string): RankingKey => ({ userKey: userKey(subject), entryKey: METRICS_KEY });
export class RankingStore {
  constructor(readonly client: AcademicClient, readonly tableName: string) {}
  table(): string { if (!this.tableName.trim()) throw rankingUnavailable(); return this.tableName; }
  async get(key: RankingKey): Promise<Record<string, unknown> | undefined> {
    const value = await this.client.send(new GetCommand({ TableName: this.table(), Key: key, ConsistentRead: true }));
    return value.Item;
  }
  async snapshot(keys: RankingKey[]): Promise<Array<Record<string, unknown> | undefined>> {
    if (keys.length > 100) throw rankingUnavailable();
    const response = await this.client.send(new TransactGetCommand({ TransactItems: keys.map(Key => ({ Get: { TableName: this.table(), Key } })) }));
    if (response.Responses?.length !== keys.length) throw rankingUnavailable();
    return response.Responses.map(response => response.Item);
  }
  put(key: RankingKey, value: object, expectedVersion?: number): RankingWrites[number] {
    const Item = { ...value, ...key };
    if (Buffer.byteLength(JSON.stringify(Item)) > 256_000) throw rankingUnavailable();
    return { Put: { TableName: this.table(), Item,
      ...(expectedVersion === undefined ? {} : {
        ConditionExpression: expectedVersion === 0 ? 'attribute_not_exists(entryKey)' : '#version = :version',
        ...(expectedVersion === 0 ? {} : { ExpressionAttributeNames: { '#version': 'version' }, ExpressionAttributeValues: { ':version': expectedVersion } }),
      }),
    } };
  }
}
export function meta(item: Record<string, unknown> | undefined): RankingMeta {
  if (!item) return { version: 0, totalCount: 0 };
  if (!validCount(item.version) || Number(item.version) < 1 || !validCount(item.totalCount)) throw rankingUnavailable();
  return { version: Number(item.version), totalCount: Number(item.totalCount) };
}
export function node(item: Record<string, unknown> | undefined): RankingNode {
  if (!item) return { version: 0, children: {} };
  if (!validCount(item.version) || Number(item.version) < 1 || !item.children || typeof item.children !== 'object' || Array.isArray(item.children)) throw rankingUnavailable();
  const children = item.children as Record<string, number>;
  if (Object.entries(children).some(([key, count]) => !/^[a-f0-9]{2}$/.test(key) || !validCount(count))) throw rankingUnavailable();
  return { version: Number(item.version), children: { ...children } };
}
