import assert from 'node:assert/strict';
import test from 'node:test';
import { createHistoryRepository, deriveHistory, parseHistoryQuery } from '../src/history-repository.mjs';
import { createHandler } from '../src/app.mjs';
const answer = (date, extra = {}) => ({ isAnswered: true, isCorrect: true, earnedStars: 2,
  maxStars: 3, answeredAt: date, ...extra });
const document = (topic, answers, extra = {}) => ({ data: () => ({ areaId: 'area', topicId: topic,
  activeAttempt: { attemptNumber: 2, questionAnswers: answers }, history: [], ...extra }) });
function repository(byOwner) {
  const reads = [];
  const db = { collection: collection => ({ doc: uid => ({ collection: sub => ({
    limit: bound => ({ get: async () => {
      reads.push([collection, uid, sub, bound]); return { docs: byOwner[uid] ?? [] };
    } }),
  }) }) }) };
  return { history: createHistoryRepository(db), reads };
}
test('orders all topic answers chronologically and paginates without overlap', async () => {
  const { history, reads } = repository({ alice: [document('one', {
    older: answer('2025-01-01T00:00:00Z'), newest: answer('2025-03-01T00:00:00Z'),
  }), document('two', { middle: answer('2025-02-01T00:00:00Z') })] });
  const page = await history.list('alice', { limit: 2 });
  assert.deepEqual(page.items.map(item => item.quizId), ['newest', 'middle']);
  const next = await history.list('alice', { limit: 2, cursor: page.nextCursor });
  assert.deepEqual(next.items.map(item => item.quizId), ['older']);
  assert.equal(next.nextCursor, null);
  assert.deepEqual(reads[0], ['users', 'alice', 'quiz_topics_progress', 201]);
});
test('cursor from another UID is rejected before any read', async () => {
  const { history, reads } = repository({ alice: [document('one', { a: answer(null), b: answer(null) })] });
  const page = await history.list('alice', { limit: 1 });
  await assert.rejects(history.list('bob', { cursor: page.nextCursor }), { status: 400 });
  assert.equal(reads.length, 1);
});
test('detail reads only verified owners collection and cannot find another owner entry', async () => {
  const { history, reads } = repository({ alice: [document('one', { a: answer(null) })] });
  const item = (await history.list('alice')).items[0];
  assert.deepEqual(await history.get('alice', item.id), item);
  await assert.rejects(history.get('bob', item.id), { status: 404 });
  assert.equal(reads.at(-1)[1], 'bob');
});
test('missing or malformed dates stay null; duration is unavailable', () => {
  const entries = deriveHistory([document('one', { a: answer('invalid'),
    b: answer(null), c: answer({ toDate: () => new Date('2025-01-01') }) })]);
  assert.equal(entries[0].quizId, 'c');
  assert.equal(entries[1].answeredAt, null);
  assert.equal(entries[2].durationSeconds, null);
});
test('retains only last three history attempts with active overriding duplicate', () => {
  const doc = document('one', { a: answer(null, { earnedStars: 3 }) }, {
    history: [1, 2, 3, 4].map(attemptNumber => ({ attemptNumber,
      questionAnswers: { a: answer(null, { earnedStars: 1 }) } })),
  });
  const entries = deriveHistory([doc]);
  assert.equal(entries.length, 3);
  assert.equal(entries.find(e => e.attemptNumber === 2).earnedStars, 3);
  assert.ok(!entries.some(e => e.attemptNumber === 1));
});
test('unanswered records are omitted and empty owner returns empty list', async () => {
  const { history } = repository({ alice: [document('one', { a: { isAnswered: false } })] });
  assert.deepEqual(await history.list('alice'), { items: [], nextCursor: null });
});
test('large datasets fail explicitly rather than silently truncate', async () => {
  const { history } = repository({ alice: Array(201).fill(document('one', {})) });
  await assert.rejects(history.list('alice'), { status: 503, code: 'history_dataset_too_large' });
});
test('deleted cursor target requires reload rather than skipping records', async () => {
  const docs = [document('one', { a: answer(null), b: answer(null) })];
  const { history } = repository({ alice: docs });
  const first = await history.list('alice', { limit: 1 });
  docs.length = 0;
  await assert.rejects(history.list('alice', { cursor: first.nextCursor }), { status: 409 });
});
for (const query of [{ userId: 'bob' }, { limit: '0' }, { limit: '51' },
  { limit: '01' }, { limit: 1 }, { cursor: '!!!' }, { cursor: 'e30=' }]) {
  test(`invalid query rejected ${JSON.stringify(query)}`, () => assert.throws(() => parseHistoryQuery(query)));
}
test('default query page size is twenty', () => assert.deepEqual(parseHistoryQuery(), { limit: 20, cursor: null }));
function handlerFixture(overrides = {}) {
  const calls = [];
  return { calls, handler: createHandler({ verifyToken: async () => { calls.push('auth'); return { uid: 'alice' }; },
    limiter: { consume: async uid => calls.push(`limit:${uid}`) },
    history: { list: async (uid, query) => { calls.push([uid, query]); return { items: [], nextCursor: null }; },
      get: async (uid, id) => ({ uid, id }) }, profiles: {}, logger: { error() {} }, ...overrides }) };
}
const event = { path: '/api/v1/history', httpMethod: 'GET', headers: { Authorization: 'Bearer token' } };
test('history route validates token and rate limit then passes verified UID', async () => {
  const { handler, calls } = handlerFixture();
  const result = await handler({ ...event, queryStringParameters: { limit: '3' } });
  assert.equal(result.statusCode, 200);
  assert.deepEqual(calls, ['auth', 'limit:alice', ['alice', { limit: 3, cursor: null }]]);
});
test('health is public and touches no auth or storage dependency', async () => {
  const { handler, calls } = handlerFixture();
  const result = await handler({ path: '/api/v1/health', httpMethod: 'GET' });
  assert.equal(result.statusCode, 200);
  assert.deepEqual(JSON.parse(result.body).data, { status: 'ok' });
  assert.deepEqual(calls, []);
});
test('history denies unsupported methods and owner override before dependencies', async () => {
  const { handler, calls } = handlerFixture();
  assert.equal((await handler({ ...event, httpMethod: 'POST' })).statusCode, 405);
  assert.equal((await handler({ ...event, queryStringParameters: { userId: 'bob' } })).statusCode, 400);
  assert.equal((await handler({ ...event, headers: {} })).statusCode, 401);
  assert.deepEqual(calls, []);
});
test('detail endpoint resolves opaque id and rejects malformed id', async () => {
  const { handler } = handlerFixture();
  const id = deriveHistory([document('one', { a: answer(null) })])[0].id;
  const result = await handler({ ...event, path: `${event.path}/${id}` });
  assert.equal(result.statusCode, 200);
  assert.equal(JSON.parse(result.body).data.uid, 'alice');
  assert.equal((await handler({ ...event, path: `${event.path}/bad!` })).statusCode, 400);
});
test('repository failures are safe server errors, never empty successful histories', async () => {
  const { handler } = handlerFixture({ history: { list: async () => { throw Error('private credential'); } } });
  const result = await handler(event);
  assert.equal(result.statusCode, 500);
  assert.ok(!result.body.includes('private credential'));
});
