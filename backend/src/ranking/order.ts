import { rankingUnavailable, type RankingMetrics } from './model.js';
const MAX_UINT64 = (1n << 64n) - 1n;
function integer(value: number, descending = false): string {
  if (!Number.isSafeInteger(value) || value < 0) throw rankingUnavailable();
  const result = descending ? MAX_UINT64 - BigInt(value) : BigInt(value);
  return result.toString(16).padStart(16, '0');
}
/** Fixed-width unsigned bytes preserve the original comparator in DynamoDB's lexical order. */
export function rankingSortKey(metrics: RankingMetrics): string {
  const averageTenths = Math.round(metrics.averageTimeSeconds * 10);
  const alias = metrics.publicId.replaceAll('-', '');
  if (!/^[a-f0-9]{32}$/.test(alias)) throw rankingUnavailable();
  return integer(metrics.totalStars, true) + (metrics.completedQuizzesCount > 0 ? '00' : '01') +
    integer(averageTenths) + integer(metrics.completedQuizzesCount, true) + alias;
}
export interface RankingPath { prefix: string; child: string }
export function rankingPath(sortKey: string): RankingPath[] {
  if (!/^[a-f0-9]{82}$/.test(sortKey)) throw rankingUnavailable();
  return Array.from({ length: 41 }, (_, index) => ({ prefix: sortKey.slice(0, index * 2), child: sortKey.slice(index * 2, index * 2 + 2) }));
}
export function rankingDeltas(previous: string | undefined, next: string): Map<string, Map<string, number>> {
  const deltas = new Map<string, Map<string, number>>();
  const add = (sort: string, delta: number): void => {
    for (const { prefix, child } of rankingPath(sort)) {
      const children = deltas.get(prefix) ?? new Map<string, number>();
      children.set(child, (children.get(child) ?? 0) + delta);
      deltas.set(prefix, children);
    }
  };
  if (previous) add(previous, -1);
  add(next, 1);
  for (const [prefix, children] of deltas) {
    for (const [child, delta] of children) if (delta === 0) children.delete(child);
    if (children.size === 0) deltas.delete(prefix);
  }
  return deltas;
}
