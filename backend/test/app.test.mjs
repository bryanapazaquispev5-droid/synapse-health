import assert from 'node:assert/strict';
import test from 'node:test';
import { createHandler } from '../src/app.mjs';
import { ApiError } from '../src/http.mjs';

function fixture(overrides = {}) {
  const calls = [];
  const logs = [];
  const handler = createHandler({
    verifyToken: async token => { calls.push(['token', token]); return { uid: 'owner' }; },
    profiles: {
      get: async uid => { calls.push(['get', uid]); return { name: 'Existing' }; },
      update: async (uid, patch) => { calls.push(['update', uid, patch]); return patch; },
    },
    limiter: { consume: async uid => { calls.push(['limit', uid]); } },
    logger: { error: entry => logs.push(entry) },
    ...overrides,
  });
  const event = {
    httpMethod: 'GET', path: '/v1/me/profile', headers: { Authorization: 'Bearer token' },
    requestContext: { requestId: 'request-1' },
  };
  return { handler, event, calls, logs };
}

async function expectStatus(changes, expected, overrides) {
  const { handler, event, calls } = fixture(overrides);
  const result = await handler({ ...event, ...changes });
  assert.equal(result.statusCode, expected);
  assert.equal(result.headers['Cache-Control'], 'no-store');
  assert.equal(result.headers['X-Content-Type-Options'], 'nosniff');
  assert.equal(JSON.parse(result.body).requestId, 'request-1');
  return { result, calls };
}

test('GET scopes access to verified UID and consumes limiter first', async () => {
  const { handler, event, calls } = fixture();
  const result = await handler(event);
  assert.equal(result.statusCode, 200);
  assert.deepEqual(calls, [['token', 'token'], ['limit', 'owner'], ['get', 'owner']]);
  assert.deepEqual(JSON.parse(result.body).data, { name: 'Existing' });
});

test('PATCH validates and trims accepted fields only', async () => {
  const { calls } = await expectStatus({
    httpMethod: 'PATCH', headers: { authorization: 'bearer token', 'Content-Type': 'application/json; charset=utf-8' },
    body: JSON.stringify({ name: ' Student ', career: ' Medicine ', gender: 'Mujer' }),
  }, 200);
  assert.deepEqual(calls.at(-1), ['update', 'owner', { name: 'Student', career: 'Medicine', gender: 'Mujer' }]);
});

test('PATCH accepts valid base64 transport', async () => {
  await expectStatus({ httpMethod: 'PATCH', headers: {
    authorization: 'Bearer token', 'content-type': 'application/json',
  }, body: Buffer.from('{"name":"Student"}').toString('base64'), isBase64Encoded: true }, 200);
});

for (const authorization of [undefined, '', 'Basic token', 'Bearer', 'Bearer token extra']) {
  test(`missing or malformed authentication is rejected: ${authorization}`, async () => {
    const { calls } = await expectStatus({ headers: { authorization } }, 401);
    assert.deepEqual(calls, []);
  });
}

test('invalid/revoked authentication propagates a safe 401 without profile query', async () => {
  const { calls } = await expectStatus({}, 401, { verifyToken: async () => {
    throw new ApiError(401, 'unauthenticated', 'Authentication is required.');
  } });
  assert.deepEqual(calls, []);
});

test('authentication infrastructure errors preserve 503', async () => {
  await expectStatus({}, 503, { verifyToken: async () => {
    throw new ApiError(503, 'service_unavailable', 'Service temporarily unavailable.');
  } });
});

test('unknown route returns 404 without querying dependencies', async () => {
  const { calls } = await expectStatus({ path: '/v1/users/other/profile' }, 404);
  assert.deepEqual(calls, []);
});

test('unsupported method returns 405 and Allow header', async () => {
  const { result, calls } = await expectStatus({ httpMethod: 'DELETE' }, 405);
  assert.equal(result.headers.Allow, 'GET, PATCH');
  assert.deepEqual(calls, []);
});

test('UID and other query parameters cannot override owner', async () => {
  const { calls } = await expectStatus({ queryStringParameters: { uid: 'other' } }, 400);
  assert.deepEqual(calls, []);
});

test('GET refuses a body', async () => {
  const { calls } = await expectStatus({ body: '{}' }, 400);
  assert.equal(calls.some(call => call[0] === 'get'), false);
});

for (const body of ['not json', '{}', 'null', '[]', '{"uid":"other"}', '{"totalStars":9}',
  '{"name":""}', '{"name":"   "}', '{"name":12}', '{"gender":"invalid"}',
  JSON.stringify({ name: 'x'.repeat(101) })]) {
  test(`invalid patch rejected without update: ${body.slice(0, 40)}`, async () => {
    const { calls } = await expectStatus({ httpMethod: 'PATCH', headers: {
      authorization: 'Bearer token', 'content-type': 'application/json',
    }, body }, 400);
    assert.equal(calls.some(call => call[0] === 'update'), false);
  });
}

test('non-JSON content type returns 415', async () => {
  await expectStatus({ httpMethod: 'PATCH', body: '{"name":"Student"}' }, 415);
});

test('oversized request returns 413 before JSON parsing', async () => {
  await expectStatus({ httpMethod: 'PATCH', headers: {
    authorization: 'Bearer token', 'content-type': 'application/json',
  }, body: 'x'.repeat(4097) }, 413);
});

test('malformed base64 returns 400', async () => {
  await expectStatus({ httpMethod: 'PATCH', headers: {
    authorization: 'Bearer token', 'content-type': 'application/json',
  }, body: '!!!', isBase64Encoded: true }, 400);
});

test('rate limit returns 429 before persistence', async () => {
  const { result, calls } = await expectStatus({}, 429, { limiter: { consume: async () => {
    throw new ApiError(429, 'rate_limited', 'Please try again later.', { 'Retry-After': '60' });
  } } });
  assert.equal(result.headers['Retry-After'], '60');
  assert.equal(calls.some(call => call[0] === 'get'), false);
});

test('missing persisted profile remains 404', async () => {
  await expectStatus({}, 404, { profiles: { get: async () => {
    throw new ApiError(404, 'not_found', 'Profile not found.');
  } } });
});

test('internal errors hide private details from response and logs', async () => {
  const { handler, event, logs } = fixture({ profiles: { get: async () => {
    throw new Error('private token owner@example.com');
  } } });
  const result = await handler(event);
  assert.equal(result.statusCode, 500);
  assert.equal(result.body.includes('private'), false);
  assert.deepEqual(logs, [{ requestId: 'request-1', code: 'internal_error' }]);
});
