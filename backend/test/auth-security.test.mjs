import test from 'node:test';
import assert from 'node:assert/strict';
import {createAwsHandler} from '../src/aws/handler.mjs';
import {fixture, request} from './aws-fixtures.mjs';

test('regression: POST /api/v1/auth/google is removed and never authenticates email', async () => {
  const {handler, store} = fixture();
  const unauthRes = await handler({
    path: '/api/v1/auth/google',
    httpMethod: 'POST',
    headers: {'content-type': 'application/json'},
    body: JSON.stringify({email: 'otra-persona@gmail.com'}),
  });
  assert.equal(unauthRes.statusCode, 401);
  assert.equal(JSON.parse(unauthRes.body).error.code, 'unauthenticated');

  const authRes = await handler(request('/api/v1/auth/google', 'POST', {email: 'otra-persona@gmail.com'}));
  assert.equal(authRes.statusCode, 404);
  assert.equal(JSON.parse(authRes.body).error.code, 'not_found');

  const users = [...store.records.values()].filter(r => r.PK.includes('otra-persona'));
  assert.equal(users.length, 0);
});

test('backend strictly derives identity from verified Cognito token and ignores client-sent owner fields', async () => {
  const {handler, store} = fixture();
  const putRes = await handler(request('/v1/me/profile', 'PUT', {
    name: 'Verified User',
    career: 'Medicina',
    gender: 'Mujer',
  }));
  assert.equal(putRes.statusCode, 200);
  const profile = JSON.parse(putRes.body).data;
  assert.equal(profile.uid, 'owner-a');
  assert.equal(profile.email, 'owner-a@example.invalid');

  const forgedPut = await handler(request('/v1/me/profile', 'PUT', {
    name: 'Verified User',
    career: 'Medicina',
    gender: 'Mujer',
    uid: 'attacker-sub',
  }));
  assert.equal(forgedPut.statusCode, 400);

  const patchRes = await handler(request('/v1/me/profile', 'PATCH', {uid: 'attacker-sub'}));
  assert.equal(patchRes.statusCode, 400);

  const removedRoute = await handler(request('/api/v1/me/devices', 'PUT', {
    token: 'synthetic-device-token-auth-security-12345', platform: 'android', isWeb: false,
  }));
  assert.equal(removedRoute.statusCode, 404);
});

test('errors and internal exceptions do not leak tokens, secrets or stack traces', async () => {
  const logs = [];
  const fakeLogger = {
    error: (...args) => logs.push(args),
    info: (...args) => logs.push(args),
  };
  const {store, profiles, catalog, progress, history, leaderboard} = fixture();
  const leakyIdentity = {
    async verifyCognitoToken() {
      throw new Error('Fatal error with super-secret-leaked-raw-token in stack');
    },
  };
  const handler = createAwsHandler({
    identity: leakyIdentity, store, profiles, catalog, progress, history, leaderboard, logger: fakeLogger,
  });
  const res = await handler({
    path: '/v1/me/profile',
    httpMethod: 'GET',
    headers: {authorization: 'Bearer user-token'},
  });
  assert.equal(res.statusCode, 500);
  assert.ok(!res.body.includes('super-secret-leaked-raw-token'));
  for (const log of logs) {
    assert.ok(!JSON.stringify(log).includes('super-secret-leaked-raw-token'));
  }
});
