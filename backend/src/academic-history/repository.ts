import { createHash } from 'node:crypto';
import { QueryCommand } from '@aws-sdk/lib-dynamodb';
import { ApiError } from '../http.mjs';
import type { AcademicClient } from '../quizzes/catalog.js';
import type { AttemptResult, StoredAttempt, ProgressListOptions } from '../quizzes/model.js';
import { decode, encodeLocator, invalidQuiz, unavailable, userKey, validUuid } from '../quizzes/keys.js';
import { AcademicPrivateStore } from '../quizzes/private-store.js';
import { publicQuestion } from '../quizzes/scoring.js';
export interface AcademicHistoryEntry {
  id: string; areaId: string; topicId: string; quizId: string; quizTitle: string;
  attemptNumber: number; startedAt: string; answeredAt: string; isCorrect: boolean;
  score: number; earnedStars: number; maxStars: number; selectedOptionIndex: null;
  durationSeconds: number; status: 'submitted';
}
export interface AcademicHistoryPage { items: AcademicHistoryEntry[]; nextCursor: string | null }
export const historyKey = (result: AttemptResult): string => `HISTORY#${result.answeredAt}#${result.attemptId}`;
/** Derive the view from the committed server result, never client-supplied metrics. */
export function historyEntry(attempt: StoredAttempt, result: AttemptResult): AcademicHistoryEntry {
  return { id: attempt.id, areaId: attempt.areaId, topicId: attempt.topicId, quizId: attempt.quizId,
    quizTitle: String(publicQuestion(attempt.snapshot).question), attemptNumber: attempt.topicAttemptNumber,
    startedAt: attempt.startedAt, answeredAt: result.answeredAt, isCorrect: result.isCorrect, score: result.score,
    earnedStars: result.earnedStars, maxStars: result.maxStars, selectedOptionIndex: null,
    durationSeconds: result.durationSeconds, status: 'submitted' };
}
const ownerHash = (subject: string): string => createHash('sha256').update(userKey(subject)).digest('base64url');
function validHistoryKey(value: unknown): value is string {
  if (typeof value !== 'string') return false;
  const match = /^HISTORY#([^#]+)#([^#]+)$/.exec(value);
  if (!match || !validUuid(match[2])) return false;
  try { return new Date(match[1]).toISOString() === match[1]; } catch { return false; }
}
export class DynamoHistoryRepository {
  private readonly store: AcademicPrivateStore;
  constructor(private readonly client: AcademicClient, tableName: string) {
    this.store = new AcademicPrivateStore(client, tableName);
  }
  async list(subject: string, options: ProgressListOptions = {}): Promise<AcademicHistoryPage> {
    const limit = options.limit ?? 20; if (!Number.isInteger(limit) || limit < 1 || limit > 50) throw invalidQuiz();
    let start: { userKey: string; entryKey: string } | undefined;
    if (options.cursor) {
      const parts = decode(options.cursor);
      if (!Array.isArray(parts) || parts.length !== 2 || parts[0] !== ownerHash(subject) || !validHistoryKey(parts[1])) throw invalidQuiz();
      start = { userKey: userKey(subject), entryKey: parts[1] };
    }
    const response = await this.client.send(new QueryCommand({ TableName: this.store.table(), ConsistentRead: true,
      KeyConditionExpression: 'userKey = :user AND begins_with(entryKey, :prefix)',
      ExpressionAttributeValues: { ':user': userKey(subject), ':prefix': 'HISTORY#' },
      Limit: limit, ScanIndexForward: false, ExclusiveStartKey: start }));
    const items = (response.Items ?? []).map(item => {
      if (item.entityType !== 'ACADEMIC_HISTORY' || !item.entry) throw unavailable();
      return item.entry as AcademicHistoryEntry;
    });
    return { items, nextCursor: response.LastEvaluatedKey ? encodeLocator([ownerHash(subject), response.LastEvaluatedKey.entryKey]) : null };
  }
  async get(subject: string, id: string): Promise<AcademicHistoryEntry> {
    if (!validUuid(id)) throw invalidQuiz();
    const attempt = await this.store.read<StoredAttempt>(subject, `ATTEMPT#${id}`);
    if (!attempt || attempt.status !== 'submitted' || !attempt.result) throw new ApiError(404, 'history_not_found', 'History entry is unavailable.');
    return historyEntry(attempt, attempt.result);
  }
}
