import test from 'node:test';
import assert from 'node:assert/strict';
import { rankingSortKey, rankingPath, rankingDeltas } from '../dist/ranking/order.js';
import { validateMetrics, publicMetrics } from '../dist/ranking/model.js';
const id = number => `12345678-1234-4234-8234-${String(number).padStart(12, '0')}`;
const metrics = (index, stars, time, count) => ({ publicId: id(index), alias: `Estudiante 12345678`, totalStars: stars, totalQuizTimeSeconds: time, completedQuizzesCount: count, averageTimeSeconds: Number((time / count).toFixed(1)) });
test('sort bytes preserve stars descending, rounded average ascending, completions descending and deterministic ties', () => {
  const values = [metrics(6, 1, 5, 1), metrics(5, 2, 20, 1), metrics(4, 2, 10, 1), metrics(3, 2, 20, 2), metrics(2, 2, 20, 2), metrics(1, 3, 100, 1)];
  assert.deepEqual(values.sort((a, b) => rankingSortKey(a).localeCompare(rankingSortKey(b))).map(value => value.publicId), [1, 2, 3, 4, 5, 6].map(id));
});
test('ranking key is fixed 41 bytes and every prefix path has one distinct opaque-byte child', () => {
  const sort = rankingSortKey(metrics(1, 2, 23, 20));
  assert.equal(sort.length, 82);
  const path = rankingPath(sort);
  assert.equal(path.length, 41);
  assert.equal(path[0].prefix, '');
  assert.equal(path[40].prefix.length, 80);
  assert.equal(path.map(value => value.child).join(''), sort);
});
test('radix move remains below DynamoDB 100 items including grading/history/stats/meta/entries', () => {
  const deltas = rankingDeltas('00'.repeat(41), 'ff'.repeat(41));
  assert.ok(deltas.size <= 82);
  assert.ok(deltas.size + 4 + 3 <= 100);
  assert.deepEqual([...rankingDeltas('00'.repeat(41), '00'.repeat(41))], []);
});
test('metrics public projection deliberately excludes private subject, email, profile and sort internals', () => {
  const value = publicMetrics({ ...metrics(1, 2, 10, 1), subject: 'private', email: 'private@example.com', gender: 'private', version: 1, sortKey: 'private' });
  assert.equal(JSON.stringify(value).includes('private'), false);
  assert.deepEqual(Object.keys(value).sort(), ['alias', 'averageTimeSeconds', 'completedQuizzesCount', 'publicId', 'totalQuizTimeSeconds', 'totalStars']);
});
test('corrupt metrics and overflow fail closed rather than publishing invalid ranking', () => {
  const base = metrics(1, 2, 10, 1); const value = { ...base, version: 1, sortKey: rankingSortKey(base) };
  assert.deepEqual(validateMetrics(value), value);
  for (const invalid of [{ ...value, totalStars: -1 }, { ...value, alias: 'Actual private name' }, { ...value, averageTimeSeconds: 20 }, { ...value, publicId: 'owner-sub' }, { ...value, completedQuizzesCount: 0 }]) assert.throws(() => validateMetrics(invalid), { status: 503 });
  assert.throws(() => rankingSortKey({ ...base, totalStars: Number.MAX_SAFE_INTEGER + 1 }), { status: 503 });
});

test('participation precedes an uncompleted equal-star record and rounded-average ties use completion count', () => {
  const never = { ...metrics(1, 0, 0, 1), completedQuizzesCount: 0, averageTimeSeconds: 0 };
  const completed = metrics(2, 0, 999, 1);
  assert.ok(rankingSortKey(completed) < rankingSortKey(never));
  const first = metrics(1, 1, 11, 10), second = metrics(2, 1, 23, 20);
  assert.equal(first.averageTimeSeconds, second.averageTimeSeconds);
  assert.ok(rankingSortKey(second) < rankingSortKey(first));
});
