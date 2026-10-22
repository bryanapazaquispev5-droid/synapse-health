import { ApiError } from '../http.mjs';
export const GLOBAL_KEY = 'RANKING#GLOBAL';
export const METRICS_KEY = 'RANKING#METRICS';
export interface RankingMetrics {
  publicId: string; alias: string; totalStars: number; totalQuizTimeSeconds: number;
  completedQuizzesCount: number; averageTimeSeconds: number;
}
export interface RankingStats extends RankingMetrics { version: number; sortKey: string }
export interface RankingEntry extends RankingMetrics { rank: number }
export interface RankingPage { items: RankingEntry[]; nextCursor: string | null }
export interface RankingOptions { limit?: number; cursor?: string | null }
export interface RankingMeta { version: number; totalCount: number }
export interface RankingNode { version: number; children: Record<string, number> }
export const invalidRanking = (): ApiError => new ApiError(400, 'invalid_ranking', 'Provide valid ranking parameters.');
export const changedRanking = (): ApiError => new ApiError(409, 'ranking_changed', 'The ranking changed. Refresh and try again.');
export const rankingUnavailable = (): ApiError => new ApiError(503, 'ranking_unavailable', 'Ranking service is unavailable.');
export function publicMetrics(value: RankingMetrics): RankingMetrics {
  return { publicId: value.publicId, alias: value.alias, totalStars: value.totalStars,
    totalQuizTimeSeconds: value.totalQuizTimeSeconds, completedQuizzesCount: value.completedQuizzesCount,
    averageTimeSeconds: value.averageTimeSeconds };
}
export function validCount(value: unknown): value is number { return Number.isSafeInteger(value) && Number(value) >= 0; }
export function validateMetrics(value: unknown): RankingStats {
  if (!value || typeof value !== 'object') throw rankingUnavailable();
  const stats = value as RankingStats;
  if (typeof stats.publicId !== 'string' || !/^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$/.test(stats.publicId) ||
    stats.alias !== `Estudiante ${stats.publicId.replaceAll('-', '').slice(0, 8)}` ||
    !validCount(stats.totalStars) || !validCount(stats.totalQuizTimeSeconds) || !validCount(stats.completedQuizzesCount) ||
    stats.completedQuizzesCount < 1 || !validCount(stats.version) || stats.version < 1 ||
    !Number.isFinite(stats.averageTimeSeconds) || stats.averageTimeSeconds < 0 ||
    stats.averageTimeSeconds !== Number((stats.totalQuizTimeSeconds / stats.completedQuizzesCount).toFixed(1)) ||
    typeof stats.sortKey !== 'string' || !/^[a-f0-9]{82}$/.test(stats.sortKey)) throw rankingUnavailable();
  return stats;
}
