import assert from 'node:assert/strict';
import test from 'node:test';
import {createHandler} from '../src/app.mjs';
import {ApiError} from '../src/http.mjs';

function fixture(overrides = {}) {
  const calls = [];
  const logs = [];
  const handler = createHandler({
    verifyCognitoToken: async token => {calls.push(['cognito', token]); return {sub: 'cognito-sub', email: 'private@example.invalid'};},
    verifyToken: async token => {calls.push(['firebase', token]); return {uid: 'firebase-uid'};},
    limiter: {consume: async uid => calls.push(['limit', uid])},
    profiles: {get: async uid => {calls.push(['profile', uid]); return {}; }},
    history: {list: async uid => {calls.push(['history', uid]); return []; }},
    logger: {error: data => logs.push(data)},
    ...overrides,
  });
  const event = {path: '/api/v1/auth/session', httpMethod: 'GET', headers: {Authorization: 'Bearer access-token'},
    requestContext: {requestId: 'local-request'}};
  return {handler, event, calls, logs};
}
test('Cognito session is independent of Firebase and returns only subject', async () => {
  const {handler, event, calls} = fixture();
  const result = await handler(event);
  assert.equal(result.statusCode, 200);
  assert.equal(result.headers['Cache-Control'], 'no-store');
  assert.deepEqual(JSON.parse(result.body), {data: {sub: 'cognito-sub'}, requestId: 'local-request'});
  assert.deepEqual(calls, [['cognito', 'access-token']]);
});
for (const [name, change, expected] of [
  ['missing bearer', {headers: {}}, 401],
  ['unsupported method', {httpMethod: 'POST'}, 405],
  ['body', {body: '{}'}, 400],
  ['query', {queryStringParameters: {uid: 'someone'}}, 400],
]) {
  test(`rejects ${name} before verifier`, async () => {
    const {handler, event, calls} = fixture();
    assert.equal((await handler({...event, ...change})).statusCode, expected);
    assert.deepEqual(calls, []);
  });
}
test('disabled Cognito endpoint is unavailable', async () => {
  const {handler, event} = fixture({verifyCognitoToken: undefined});
  assert.equal((await handler(event)).statusCode, 503);
});
test('invalid access token returns safe 401 without private logs', async () => {
  const {handler, event, logs} = fixture({verifyCognitoToken: async () => {throw new ApiError(401, 'unauthenticated', 'Sign in again.');}});
  const result = await handler(event);
  assert.equal(result.statusCode, 401);
  assert.ok(!result.body.includes('access-token'));
  assert.deepEqual(logs, []);
});
test('upstream unavailability uses centralized safe errors and logs', async () => {
  const {handler, event, logs} = fixture({verifyCognitoToken: async () => {throw new Error('private-jwt-and-email');}});
  const result = await handler(event);
  assert.equal(result.statusCode, 500);
  assert.ok(!result.body.includes('private-jwt-and-email'));
  assert.deepEqual(logs, [{requestId: 'local-request', code: 'internal_error'}]);
});
test('session cannot accept a Firebase UID as a Cognito subject', async () => {
  const {handler, event} = fixture({verifyCognitoToken: async () => ({uid: 'firebase-uid'})});
  assert.equal((await handler(event)).statusCode, 401);
});
for (const path of ['/v1/me/profile', '/api/v1/history']) {
  test(`${path} continues to require Firebase verification`, async () => {
    const {handler, event, calls} = fixture({verifyToken: async () => {throw new ApiError(401, 'unauthenticated', 'Sign in again.');}});
    assert.equal((await handler({...event, path})).statusCode, 401);
    assert.deepEqual(calls, []);
  });
}
test('Firebase history still scopes records and quota to Firebase UID', async () => {
  const {handler, event, calls} = fixture();
  assert.equal((await handler({...event, path: '/api/v1/history'})).statusCode, 200);
  assert.deepEqual(calls, [['firebase', 'access-token'], ['limit', 'firebase-uid'], ['history', 'firebase-uid']]);
});
