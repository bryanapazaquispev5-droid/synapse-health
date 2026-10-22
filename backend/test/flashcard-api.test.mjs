import test from 'node:test';
import assert from 'node:assert/strict';
import { createFlashcardHandler } from '../dist/flashcards/controller.js';
import { ApiError } from '../dist/http.mjs';
import { encodeLocator } from '../dist/flashcards/model.js';
const id = encodeLocator(['area', '12345678-1234-4234-8234-123456789abc']);
const input = { areaId: 'area', topicId: 'topic', title: 'Test fixture', contentMarkdown: 'Test content' };
function setup(options = {}) {
  const calls = [];
  const item = { ...input, id, version: 3 };
  const repository = Object.fromEntries(['list', 'get', 'create', 'update', 'delete'].map(name => [name, async (...args) => {
    calls.push({ name, args });
    if (options.failure) throw options.failure;
    return name === 'list' ? { items: [item], nextCursor: null } : name === 'delete' ? undefined : item;
  }]));
  const logs = [];
  const handler = createFlashcardHandler({ repository,
    verifyCognitoToken: async token => {
      if (token !== 'cognito') throw new ApiError(401, 'unauthenticated', 'Authentication is required.');
      return { sub: 'owner', groups: options.groups ?? ['admins'] };
    }, limiter: options.limiter, logger: { error: entry => logs.push(entry) } });
  return { handler, calls, logs };
}
function event(method = 'GET', item = false, extra = {}) {
  return { path: `/api/v1/flashcards${item ? `/${id}` : ''}`, httpMethod: method,
    requestContext: { requestId: 'request-1' }, headers: { authorization: 'Bearer cognito', 'content-type': 'application/json', 'if-match': '"3"' },
    queryStringParameters: method === 'GET' && !item ? { areaId: 'area' } : null, body: null, ...extra };
}
const payload = result => JSON.parse(result.body);
test('authenticated list forwards scoped query and returns page', async () => {
  const { handler, calls } = setup({ groups: [] });
  const result = await handler(event('GET', false, { queryStringParameters: { areaId: 'area', topicId: 'topic', limit: '5', cursor: 'YWJj' } }));
  assert.equal(result.statusCode, 200);
  assert.deepEqual(calls[0].args, ['area', { topicId: 'topic', limit: 5, cursor: 'YWJj' }]);
  assert.equal(payload(result).data.items[0].id, id);
});
test('get returns strong ETag and request ID', async () => {
  const result = await setup().handler(event('GET', true));
  assert.equal(result.statusCode, 200); assert.equal(result.headers.ETag, '"3"');
  assert.equal(payload(result).requestId, 'request-1');
});
test('admin create returns 201 Location and model defaults', async () => {
  const { handler, calls } = setup(); const result = await handler(event('POST', false, { body: JSON.stringify(input) }));
  assert.equal(result.statusCode, 201); assert.equal(result.headers.Location, `/api/v1/flashcards/${id}`);
  assert.equal(calls[0].args[0].isPremium, false); assert.deepEqual(calls[0].args[0].keyPoints, []);
});
test('admin patch preserves optimistic version and permits topic change', async () => {
  const { handler, calls } = setup(); const result = await handler(event('PATCH', true, { body: JSON.stringify({ title: 'Changed', topicId: 'new-topic' }) }));
  assert.equal(result.statusCode, 200); assert.deepEqual(calls[0].args, [id, { title: 'Changed', topicId: 'new-topic' }, 3]);
});
test('delete returns empty 204 without JSON content type', async () => {
  const { handler, calls } = setup(); const result = await handler(event('DELETE', true));
  assert.equal(result.statusCode, 204); assert.equal(result.body, ''); assert.equal(result.headers['Content-Type'], undefined);
  assert.deepEqual(calls[0].args, [id, 3]);
});
for (const method of ['POST', 'PATCH', 'DELETE']) {
  test(`student ${method} is forbidden before repository or body validation`, async () => {
    const { handler, calls } = setup({ groups: ['students'] });
    const result = await handler(event(method, method !== 'POST', { body: '{invalid', headers: { authorization: 'Bearer cognito', role: 'admins' } }));
    assert.equal(result.statusCode, 403); assert.equal(calls.length, 0);
  });
}
for (const authorization of [undefined, 'Bearer firebase', 'Bearer cognito extra']) {
  test(`rejects absent or invalid Cognito credentials: ${authorization}`, async () => {
    const { handler, calls } = setup(); const result = await handler(event('GET', false, { headers: { authorization } }));
    assert.equal(result.statusCode, 401); assert.equal(calls.length, 0);
  });
}
for (const query of [{}, { areaId: 'area', uid: 'another' }, { areaId: 'area', limit: '51' }, { areaId: 'area', limit: '1.0' }, { areaId: 'area', cursor: '' }]) {
  test(`rejects invalid query ${JSON.stringify(query)}`, async () => {
    const { handler, calls } = setup(); assert.equal((await handler(event('GET', false, { queryStringParameters: query }))).statusCode, 400);
    assert.equal(calls.length, 0);
  });
}
for (const patch of [{ areaId: 'new' }, { role: 'admins' }, { title: '' }, { keyPoints: [1] }, { isPremium: 'true' }, { readDurationInMinutes: -1 }, {}]) {
  test(`rejects invalid patch ${JSON.stringify(patch)}`, async () => {
    const { handler, calls } = setup(); assert.equal((await handler(event('PATCH', true, { body: JSON.stringify(patch) }))).statusCode, 400);
    assert.equal(calls.length, 0);
  });
}
for (const version of [undefined, '3', 'W/"3"', '"0"', '"9007199254740992"']) {
  test(`rejects invalid If-Match ${version}`, async () => {
    const result = await setup().handler(event('DELETE', true, { headers: { authorization: 'Bearer cognito', 'if-match': version } }));
    assert.equal(result.statusCode, 400);
  });
}
test('invalid identifier cannot reach repository', async () => {
  const { handler, calls } = setup(); assert.equal((await handler(event('GET', true, { path: '/api/v1/flashcards/arbitrary' }))).statusCode, 400);
  assert.equal(calls.length, 0);
});
test('wrong method returns Allow', async () => {
  const result = await setup().handler(event('PUT', true)); assert.equal(result.statusCode, 405); assert.equal(result.headers.Allow, 'GET, PATCH, DELETE');
});
test('JSON content type required', async () => {
  assert.equal((await setup().handler(event('POST', false, { body: JSON.stringify(input), headers: { authorization: 'Bearer cognito' } }))).statusCode, 415);
});
test('bounded body returns 413', async () => {
  assert.equal((await setup().handler(event('POST', false, { body: 'x'.repeat(16385) }))).statusCode, 413);
});
test('valid base64 JSON accepted and malformed base64 rejected', async () => {
  assert.equal((await setup().handler(event('POST', false, { body: Buffer.from(JSON.stringify(input)).toString('base64'), isBase64Encoded: true }))).statusCode, 201);
  assert.equal((await setup().handler(event('POST', false, { body: '%%%=', isBase64Encoded: true }))).statusCode, 400);
});
for (const status of [404, 409, 503]) {
  test(`repository known ${status} propagated safely`, async () => {
    const result = await setup({ failure: new ApiError(status, 'safe_code', 'Safe message') }).handler(event('GET', true));
    assert.equal(result.statusCode, status);
  });
}
test('unexpected failure logs no exception credentials or content', async () => {
  const { handler, logs } = setup({ failure: new Error('secret-token') }); const result = await handler(event('GET', true));
  assert.equal(result.statusCode, 500); assert.ok(!result.body.includes('secret-token'));
  assert.deepEqual(logs, [{ requestId: 'request-1', code: 'internal_error' }]);
});
test('rate limit returns 429 and Retry-After before repository', async () => {
  const { handler, calls } = setup({ limiter: { consume: async () => { throw new ApiError(429, 'rate_limited', 'Try later.', { 'Retry-After': '60' }); } } });
  const result = await handler(event()); assert.equal(result.statusCode, 429); assert.equal(result.headers['Retry-After'], '60'); assert.equal(calls.length, 0);
});
test('GET body and detail query rejected', async () => {
  assert.equal((await setup().handler(event('GET', true, { body: '{}' }))).statusCode, 400);
  assert.equal((await setup().handler(event('GET', true, { queryStringParameters: { areaId: 'area' } }))).statusCode, 400);
});
