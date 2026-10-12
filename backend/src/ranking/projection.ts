import { randomUUID } from 'node:crypto';
import type { StoredTopic } from '../quizzes/private-store.js';
import { changedRanking, publicMetrics, rankingUnavailable, validateMetrics, validCount, type RankingStats } from './model.js';
import { rankingDeltas, rankingSortKey } from './order.js';
import { globalKey, meta, metricsKey, node, RankingStore, type RankingWrites } from './store.js';
export class RankingProjection {
  constructor(readonly store: RankingStore, private readonly makeUuid: () => string = randomUUID) {}
  /** All count paths and public/private metrics commit in the same transaction as the final result. */
  async prepareCompletion(subject: string, topic: StoredTopic, now: Date): Promise<RankingWrites> {
    const previousItem = await this.store.get(metricsKey(subject));
    const previous = previousItem ? validateMetrics(previousItem) : undefined;
    if (previous && previous.sortKey !== rankingSortKey(previous)) throw rankingUnavailable();
    const duration = Math.floor((now.getTime() - Date.parse(topic.activeAttempt.startedAt)) / 1000);
    if (!validCount(duration) || !validCount(topic.activeAttempt.totalEarnedStars) ||
      Object.keys(topic.activeAttempt.questionAnswers).length < 1 || topic.activeAttempt.completedAt !== now.toISOString()) throw rankingUnavailable();
    const publicId = previous?.publicId ?? this.makeUuid();
    const metrics = {
      publicId, alias: `Estudiante ${publicId.replaceAll('-', '').slice(0, 8)}`,
      totalStars: (previous?.totalStars ?? 0) + topic.activeAttempt.totalEarnedStars,
      totalQuizTimeSeconds: (previous?.totalQuizTimeSeconds ?? 0) + duration,
      completedQuizzesCount: (previous?.completedQuizzesCount ?? 0) + 1,
    };
    const averageTimeSeconds = Number((metrics.totalQuizTimeSeconds / metrics.completedQuizzesCount).toFixed(1));
    const stats: RankingStats = { ...metrics, averageTimeSeconds, version: (previous?.version ?? 0) + 1,
      sortKey: rankingSortKey({ ...metrics, averageTimeSeconds }) };
    validateMetrics(stats);
    const deltas = rankingDeltas(previous?.sortKey, stats.sortKey);
    const prefixes = [...deltas.keys()];
    const values = await this.store.snapshot([globalKey('META'), metricsKey(subject), ...prefixes.map(prefix => globalKey(`NODE#${prefix}`))]);
    const global = meta(values[0]);
    const current = values[1] ? validateMetrics(values[1]) : undefined;
    if (current?.version !== previous?.version || current?.sortKey !== previous?.sortKey) throw changedRanking();
    const totalCount = global.totalCount + (previous ? 0 : 1);
    if (!validCount(totalCount) || !validCount(global.version + 1) || (previous && global.totalCount < 1)) throw rankingUnavailable();
    const writes: RankingWrites = prefixes.map((prefix, index) => {
      const original = node(values[index + 2]);
      const children = { ...original.children };
      for (const [child, delta] of deltas.get(prefix)!) {
        const count = (children[child] ?? 0) + delta;
        if (!validCount(count)) throw rankingUnavailable();
        if (count === 0) delete children[child]; else children[child] = count;
      }
      if (!validCount(original.version + 1)) throw rankingUnavailable();
      return this.store.put(globalKey(`NODE#${prefix}`), { version: original.version + 1, children });
    });
    writes.push(this.store.put(globalKey('META'), { version: global.version + 1, totalCount }, global.version));
    writes.push(this.store.put(metricsKey(subject), stats, previous?.version ?? 0));
    if (previous) writes.push({ Delete: { TableName: this.store.table(), Key: globalKey(`ENTRY#${previous.sortKey}`),
      ConditionExpression: 'attribute_exists(entryKey)' } });
    const entry = { ...publicMetrics(stats), version: stats.version, sortKey: stats.sortKey };
    const entryWrite = this.store.put(globalKey(`ENTRY#${stats.sortKey}`), entry);
    if (entryWrite.Put) entryWrite.Put.ConditionExpression = 'attribute_not_exists(entryKey)';
    writes.push(entryWrite);
    if (writes.length > 90) throw rankingUnavailable();
    return writes;
  }
}
