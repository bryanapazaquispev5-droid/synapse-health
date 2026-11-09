import {ApiError} from '../src/http.mjs';
import {cursorKey, encodeCursor} from '../src/aws/validation.mjs';
import {createAwsHandler} from '../src/aws/handler.mjs';
import {createCatalog} from '../src/aws/catalog.mjs';
import {createProfiles} from '../src/aws/profiles.mjs';
import {createProgress} from '../src/aws/progress.mjs';
import {createAwsHistory} from '../src/aws/history.mjs';
import {createLeaderboard} from '../src/aws/leaderboard.mjs';
export function memoryStore() {
  const records = new Map();
  const key = (pk, sk) => JSON.stringify([pk, sk]);
  return {
    records,
    seed(PK, SK, data) { records.set(key(PK, SK), {PK, SK, version: 1, data: structuredClone(data)}); },
    async get(PK, SK) { return structuredClone(records.get(key(PK, SK)) ?? null); },
    async put(item, expectedVersion = null, related = []) {
      const existing = records.get(key(item.PK, item.SK));
      if ((existing?.version ?? null) !== expectedVersion) throw new ApiError(409, 'conflict', 'Reload.');
      for (const write of related) {
        const before = records.get(key(write.item.PK, write.item.SK));
        if ((before?.version ?? null) !== write.expectedVersion) throw new ApiError(409, 'conflict', 'Reload.');
      }
      const stored = {...structuredClone(item), version: (expectedVersion ?? 0) + 1};
      for (const write of related) records.set(key(write.item.PK, write.item.SK), {...structuredClone(write.item), version: (write.expectedVersion ?? 0) + 1});
      records.set(key(item.PK, item.SK), stored); return structuredClone(stored);
    },
    async list(PK, prefix, {limit = 100, cursor = null} = {}) {
      const after = cursorKey(cursor, PK, prefix);
      const all = [...records.values()].filter(item => item.PK === PK && item.SK.startsWith(prefix) && (!after || item.SK > after.SK))
        .sort((a, b) => a.SK.localeCompare(b.SK));
      const items = all.slice(0, limit);
      return {items: structuredClone(items), nextCursor: all.length > limit ? encodeCursor(items.at(-1)) : null};
    },
    async remove(PK, SK) { records.delete(key(PK, SK)); },
    async consume() {},
  };
}
export function fixture() {
  const store = memoryStore();
  const catalog = createCatalog({areas: store, topics: store, quizzes: store, studyNotes: store});
  const now = () => '2026-10-22T12:00:00.000Z';
  const profiles = createProfiles(store, now);
  const progress = createProgress(store, catalog, now, {profilesStore: store, leaderboardStore: store});
  const identity = {async verifyCognitoToken(token) {
    if (!['owner-a', 'owner-b'].includes(token)) throw new ApiError(401, 'unauthenticated', 'Sign in.');
    return {sub: token, email: `${token}@example.invalid`, name: 'Synthetic tester', provider: 'password',
      groups: ['student']};
  }};
  const logs = [];
  const handler = createAwsHandler({identity, store, catalog, profiles, progress,
    history: createAwsHistory(store), leaderboard: createLeaderboard(store), logger: {error: entry => logs.push(entry)}});
  return {store, catalog, profiles, progress, handler, logs};
}
export const quiz = {areaId: 'synthetic-area', topicId: 'synthetic-topic', type: 'single_choice',
  question: 'Synthetic test question', options: ['Option A', 'Option B'], correctIndex: 1,
  rationale: 'Synthetic fixture only', sourceBook: '', orderIndex: 1};
export function seedQuiz(store, id = 'question-1', data = quiz) {
  store.seed('AREA#synthetic-area', `TOPIC#synthetic-topic#QUIZ#${id}`, data);
}
export function request(path, method = 'GET', input, owner = 'owner-a') {
  return {path, httpMethod: method, headers: {'Content-Type': 'application/json', Authorization: `Bearer ${owner}`},
    body: input === undefined ? null : JSON.stringify(input), requestContext: {requestId: 'synthetic-request'}};
}
