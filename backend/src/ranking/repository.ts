import { QueryCommand } from '@aws-sdk/lib-dynamodb';
import type { AcademicClient } from '../quizzes/catalog.js';
import { encodeLocator, decode } from '../quizzes/keys.js';
import { changedRanking, GLOBAL_KEY, invalidRanking, publicMetrics, rankingUnavailable, validateMetrics, validCount,
  type RankingEntry, type RankingOptions, type RankingPage } from './model.js';
import { rankingPath, rankingSortKey } from './order.js';
import { RankingProjection } from './projection.js';
import { globalKey, meta, metricsKey, node, RankingStore } from './store.js';
export class DynamoRankingRepository extends RankingProjection {
  constructor(client: AcademicClient, tableName: string, makeUuid?: () => string) { super(new RankingStore(client, tableName), makeUuid); }
  async list(options: RankingOptions = {}): Promise<RankingPage> {
    const limit = options.limit ?? 20;
    if (!Number.isInteger(limit) || limit < 1 || limit > 50) throw invalidRanking();
    const before = meta(await this.store.get(globalKey('META')));
    let offset = 0;
    let start: { userKey: string; entryKey: string } | undefined;
    if (options.cursor) {
      let value: unknown;
      try { value = decode(options.cursor); } catch { throw invalidRanking(); }
      if (!Array.isArray(value) || value.length !== 3 || !validCount(value[0]) || !validCount(value[1]) ||
        typeof value[2] !== 'string' || !/^ENTRY#[a-f0-9]{82}$/.test(value[2])) throw invalidRanking();
      if (value[0] !== before.version) throw changedRanking();
      offset = value[1];
      if (offset < 1 || offset > before.totalCount) throw invalidRanking();
      // A client-supplied offset cannot forge public positions, even in a syntactically valid cursor.
      const sortKey = value[2].slice(6);
      if (await this.position(sortKey, before.version) !== offset) throw invalidRanking();
      start = { userKey: GLOBAL_KEY, entryKey: value[2] };
    }
    const response = await this.store.client.send(new QueryCommand({ TableName: this.store.table(), ConsistentRead: true,
      KeyConditionExpression: 'userKey = :global AND begins_with(entryKey, :prefix)',
      ExpressionAttributeValues: { ':global': GLOBAL_KEY, ':prefix': 'ENTRY#' }, Limit: limit, ExclusiveStartKey: start }));
    const after = meta(await this.store.get(globalKey('META')));
    if (before.version !== after.version) throw changedRanking();
    const items = (response.Items ?? []).map((item, index) => {
      const value = validateMetrics(item);
      if (item.userKey !== GLOBAL_KEY || item.entryKey !== `ENTRY#${value.sortKey}` || value.sortKey !== rankingSortKey(value)) throw rankingUnavailable();
      return { ...publicMetrics(value), rank: offset + index + 1 };
    });
    if (offset + items.length > before.totalCount) throw rankingUnavailable();
    const nextCursor = response.LastEvaluatedKey ? encodeLocator([before.version, offset + items.length, response.LastEvaluatedKey.entryKey]) : null;
    return { items, nextCursor };
  }
  private async position(sortKey: string, expectedRevision?: number, owner?: { subject: string; version: number }): Promise<number> {
    const path = rankingPath(sortKey);
    const values = await this.store.snapshot([globalKey('META'), globalKey(`ENTRY#${sortKey}`), ...path.map(({ prefix }) => globalKey(`NODE#${prefix}`)), ...(owner ? [metricsKey(owner.subject)] : [])]);
    const global = meta(values[0]);
    if (expectedRevision !== undefined && global.version !== expectedRevision) throw changedRanking();
    if (!values[1] || validateMetrics(values[1]).sortKey !== sortKey) throw changedRanking();
    if (owner) {
      const current = values[path.length + 2] ? validateMetrics(values[path.length + 2]) : undefined;
      if (current?.version !== owner.version || current?.sortKey !== sortKey) throw changedRanking();
    }
    let preceding = 0;
    for (const [index, { child }] of path.entries()) {
      const current = node(values[index + 2]);
      if (!current.children[child]) throw rankingUnavailable();
      for (const [candidate, count] of Object.entries(current.children)) if (candidate < child) preceding += count;
    }
    if (!validCount(preceding) || preceding >= global.totalCount) throw rankingUnavailable();
    return preceding + 1;
  }
  async me(subject: string): Promise<{ entry: RankingEntry | null }> {
    const metrics = await this.store.get(metricsKey(subject));
    if (!metrics) return { entry: null };
    const stats = validateMetrics(metrics);
    if (stats.sortKey !== rankingSortKey(stats)) throw rankingUnavailable();
    const before = meta(await this.store.get(globalKey('META')));
    const rank = await this.position(stats.sortKey, before.version, { subject, version: stats.version });
    const after = meta(await this.store.get(globalKey('META')));
    if (before.version !== after.version) throw changedRanking();
    return { entry: { ...publicMetrics(stats), rank } };
  }
}
