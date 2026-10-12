import { createHash } from 'node:crypto';
import { ApiError } from './http.mjs';

const invalid = () => new ApiError(400, 'invalid_query', 'Provide valid history parameters.');
const encode = value => Buffer.from(JSON.stringify(value)).toString('base64url');
function decode(value) {
  if (typeof value !== 'string' || !/^[A-Za-z0-9_-]{1,2048}$/.test(value)) throw invalid();
  try {
    const parsed = JSON.parse(Buffer.from(value, 'base64url').toString('utf8'));
    if (encode(parsed) !== value) throw invalid();
    return parsed;
  } catch { throw invalid(); }
}
export function validateHistoryId(id) {
  const parts = decode(id);
  if (!Array.isArray(parts) || parts.length !== 4 ||
      !parts.slice(0, 2).every(v => typeof v === 'string' && v.length > 0) ||
      !Number.isSafeInteger(parts[2]) || parts[2] < 1 ||
      typeof parts[3] !== 'string' || !parts[3].length) throw invalid();
  return parts;
}
export function parseHistoryQuery(query = {}) {
  query ??= {};
  if (Object.keys(query).some(key => !['limit', 'cursor'].includes(key))) throw invalid();
  const raw = query.limit ?? '20';
  if (typeof raw !== 'string' || !/^(?:[1-9]|[1-4][0-9]|50)$/.test(raw)) throw invalid();
  if (query.cursor != null) decode(query.cursor);
  return { limit: Number(raw), cursor: query.cursor ?? null };
}
function date(value) {
  try {
    const parsed = typeof value?.toDate === 'function' ? value.toDate()
      : typeof value === 'string' ? new Date(value) : value instanceof Date ? value : null;
    return parsed && Number.isFinite(parsed.getTime()) ? parsed.toISOString() : null;
  } catch { return null; }
}
const integer = (value, fallback) => Number.isSafeInteger(Number(value)) && value != null
  ? Number(value) : fallback;
export function deriveHistory(documents) {
  const entries = new Map();
  for (const document of documents) {
    const data = document.data();
    if (typeof data.areaId !== 'string' || !data.areaId ||
        typeof data.topicId !== 'string' || !data.topicId) continue;
    const attempts = new Map();
    for (const attempt of [...(Array.isArray(data.history) ? data.history.slice(-3) : []), data.activeAttempt]) {
      if (attempt && typeof attempt === 'object') attempts.set(integer(attempt.attemptNumber, 1), attempt);
    }
    for (const [attemptNumber, attempt] of attempts) {
      if (attemptNumber < 1) continue;
      for (const [quizId, answer] of Object.entries(attempt.questionAnswers ?? {})) {
        if (!quizId || answer?.isAnswered !== true) continue;
        const id = encode([data.areaId, data.topicId, attemptNumber, quizId]);
        entries.set(id, { id, areaId: data.areaId, topicId: data.topicId, quizId,
          attemptNumber, answeredAt: date(answer.answeredAt), isCorrect: answer.isCorrect === true,
          earnedStars: integer(answer.earnedStars, 0), maxStars: integer(answer.maxStars, 3),
          selectedOptionIndex: integer(answer.selectedOptionIndex, null), durationSeconds: null });
      }
    }
  }
  return [...entries.values()].sort((a, b) => {
    if (a.answeredAt !== b.answeredAt) {
      if (a.answeredAt === null) return 1;
      if (b.answeredAt === null) return -1;
      return b.answeredAt.localeCompare(a.answeredAt);
    }
    return a.id < b.id ? -1 : a.id > b.id ? 1 : 0;
  });
}
const ownerHash = uid => createHash('sha256').update(uid).digest('base64url');
export function createHistoryRepository(db) {
  async function records(uid) {
    if (typeof uid !== 'string' || !uid.length || uid.length > 128 || uid.includes('/')) {
      throw new ApiError(401, 'unauthenticated', 'Authentication is required.');
    }
    // Nested answers cannot be chronologically paged by Firestore. Read a bounded
    // owner snapshot, sort globally, and fail explicitly instead of truncating.
    const snapshot = await db.collection('users').doc(uid)
      .collection('quiz_topics_progress').limit(201).get();
    if (snapshot.docs.length > 200) {
      throw new ApiError(503, 'history_dataset_too_large', 'History is temporarily unavailable.');
    }
    return deriveHistory(snapshot.docs);
  }
  return {
    async list(uid, { limit = 20, cursor = null } = {}) {
      if (!Number.isInteger(limit) || limit < 1 || limit > 50) throw invalid();
      let afterId = null;
      if (cursor !== null) {
        const parsed = decode(cursor);
        if (!Array.isArray(parsed) || parsed.length !== 2 || parsed[0] !== ownerHash(uid)) throw invalid();
        validateHistoryId(parsed[1]);
        afterId = parsed[1];
      }
      const all = await records(uid);
      const after = afterId === null ? -1 : all.findIndex(entry => entry.id === afterId);
      if (afterId !== null && after < 0) throw new ApiError(409, 'history_changed', 'Reload history to continue.');
      const items = all.slice(after + 1, after + 1 + limit);
      return { items, nextCursor: after + 1 + items.length < all.length
        ? encode([ownerHash(uid), items.at(-1).id]) : null };
    },
    async get(uid, id) {
      validateHistoryId(id);
      const entry = (await records(uid)).find(item => item.id === id);
      if (!entry) throw new ApiError(404, 'not_found', 'History entry is unavailable.');
      return entry;
    },
  };
}
