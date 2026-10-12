import test from 'node:test';
import assert from 'node:assert/strict';
import { createAcademicHandler } from '../dist/academic/controller.js';
import { ApiError } from '../dist/http.mjs';
const id = '12345678-1234-4234-8234-123456789abc';
function setup(options = {}) {
  const calls = [], logs = [];
  const repository = name => async (...args) => {
    calls.push([name, ...args]);
    if (options.failure) throw options.failure;
    return name === 'detail' ? { id } : name === 'me' ? { entry: null } : { items: [], nextCursor: null };
  };
  const handler = createAcademicHandler({ enabled: options.enabled ?? true,
    history: { list: repository('history'), get: repository('detail') },
    ranking: { list: repository('ranking'), me: repository('me') },
    logger: { error: value => logs.push(value) },
    limiter: { consume: async subject => { calls.push(['quota', subject]); if (options.quotaError) throw options.quotaError; } },
    verifyCognitoToken: async token => {
      calls.push(['verify', token]);
      if (token !== 'cognito') throw new ApiError(401, 'unauthenticated', 'Sign in again.');
      return { sub: options.sub ?? 'local-owner' };
    } });
  return { handler, calls, logs };
}
const event = (path = '/api/v1/history', extra = {}) => ({ path, httpMethod: 'GET', headers: { Authorization: 'Bearer cognito' },
  queryStringParameters: null, body: null, requestContext: { requestId: 'academic-fixture' }, ...extra });
test('canonical history uses signed Cognito subject and scoped pagination', async () => {
  const { handler, calls } = setup();
  const result = await handler(event(undefined, { queryStringParameters: { limit: '5', cursor: 'YQ' } }));
  assert.equal(result.statusCode, 200); assert.deepEqual(calls[2], ['history', 'local-owner', { limit: 5, cursor: 'YQ' }]);
});
test('canonical history detail uses UUID and owner rather than client identity', async () => {
  const { handler, calls } = setup(); const result = await handler(event(`/api/v1/history/${id}`));
  assert.equal(result.statusCode, 200); assert.deepEqual(calls[2], ['detail', 'local-owner', id]);
});
test('ranking and personal position reuse read-only methods', async () => {
  const first = setup(); assert.equal((await first.handler(event('/api/v1/ranking'))).statusCode, 200);
  assert.deepEqual(first.calls[2], ['ranking', {}]);
  const second = setup(); const own = await second.handler(event('/api/v1/ranking/me'));
  assert.deepEqual(second.calls[2], ['me', 'local-owner']); assert.deepEqual(JSON.parse(own.body).data, { entry: null });
});
for (const path of ['/api/v1/history', `/api/v1/history/${id}`, '/api/v1/ranking', '/api/v1/ranking/me']) {
  test(`rejects unauthenticated ${path}`, async () => {
    const { handler, calls } = setup(); assert.equal((await handler(event(path, { headers: {} }))).statusCode, 401);
    assert.equal(calls.length, 0);
  });
}
test('Firebase tokens cannot fall back into Cognito academic views', async () => {
  const { handler, calls } = setup();
  assert.equal((await handler(event(undefined, { headers: { Authorization: 'Bearer firebase' } }))).statusCode, 401);
  assert.equal(calls.length, 1);
});
test('disabled views fail closed without provider or database requests', async () => {
  const { handler, calls } = setup({ enabled: false });
  assert.equal((await handler(event('/api/v1/ranking'))).statusCode, 503); assert.equal(calls.length, 0);
});
for (const [name, input] of [
  ['foreign subject query', event(undefined, { queryStringParameters: { userId: 'other' } })],
  ['forged rank query', event('/api/v1/ranking', { queryStringParameters: { rank: '1' } })],
  ['invalid UUID', event('/api/v1/history/not-uuid')],
  ['detail query', event(`/api/v1/history/${id}`, { queryStringParameters: { owner: 'other' } })],
  ['personal rank query', event('/api/v1/ranking/me', { queryStringParameters: { sub: 'other' } })],
  ['oversized page', event(undefined, { queryStringParameters: { limit: '51' } })],
  ['GET body', event(undefined, { body: '{}' })],
]) test(`rejects ${name} before reading repositories`, async () => {
  const { handler, calls } = setup(); assert.equal((await handler(input)).statusCode, 400); assert.equal(calls.length, 2);
});
test('ranking writes are unavailable to students and administrators alike', async () => {
  const { handler, calls } = setup();
  const result = await handler(event('/api/v1/ranking', { httpMethod: 'POST', body: '{"totalStars":100}' }));
  assert.equal(result.statusCode, 405); assert.equal(result.headers.Allow, 'GET'); assert.equal(calls.length, 0);
});
test('unknown academic paths return404', async () => assert.equal((await setup().handler(event('/api/v1/ranking/other'))).statusCode, 404));
test('quota exhaustion returns429 with safe Retry-After before queries', async () => {
  const { handler, calls } = setup({ quotaError: new ApiError(429, 'rate_limited', 'Try later.', { 'Retry-After': '30' }) });
  const result = await handler(event()); assert.equal(result.statusCode, 429); assert.equal(result.headers['Retry-After'], '30'); assert.equal(calls.length, 2);
});
test('unexpected errors never expose provider details or private records', async () => {
  const { handler, logs } = setup({ failure: new Error('private token and database stack') });
  const result = await handler(event()); assert.equal(result.statusCode, 500); assert.ok(!result.body.includes('private'));
  assert.deepEqual(logs, [{ requestId: 'academic-fixture', code: 'internal_error' }]);
});
test('known not-found and changed-ranking errors preserve their HTTP codes', async () => {
  for (const status of [404, 409]) assert.equal((await setup({ failure: new ApiError(status, 'safe', 'Refresh.') }).handler(event())).statusCode, status);
});
