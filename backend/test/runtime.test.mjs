import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createRuntime} from '../src/firebase-runtime.mjs';

function runtime({env = {}, code, mismatch = false, failSecret = false} = {}) {
  const calls = [];
  const fakeAuth = {async verifyIdToken(token, revoked) {
    calls.push([token, revoked]);
    if (code) throw Object.assign(new Error('private internal details'), {code});
    return {uid: 'student'};
  }};
  const instance = createRuntime({env: {FIREBASE_PROJECT_ID: 'demo-synapse-health',
    FIREBASE_CREDENTIAL_SECRET_ARN: 'test-secret-reference', ...env},
    secretClient: {async send() {
      if (failSecret) throw new Error('secret unavailable');
      return {SecretString: JSON.stringify({type: 'service_account',
        project_id: mismatch ? 'other-project' : 'demo-synapse-health',
        client_email: 'local-test@example.invalid', private_key: 'test-only-placeholder'})};
    }}, credentialFor: () => ({}), initialize: () => ({}),
    authFor: () => fakeAuth, firestoreFor: () => ({})});
  return {instance, calls};
}
test('token verification explicitly checks revocation', async () => {
  const {instance, calls} = runtime();
  assert.equal((await instance.verifyToken('test-token')).uid, 'student');
  assert.deepEqual(calls, [['test-token', true]]);
});
for (const code of ['auth/id-token-expired', 'auth/id-token-revoked', 'auth/user-disabled',
  'auth/user-not-found', 'auth/argument-error', 'auth/invalid-id-token']) {
  test(`${code} is safe401`, async () => {
    await assert.rejects(runtime({code}).instance.verifyToken('test-token'), error => error.status === 401);
  });
}
test('auth infrastructure failure is503, not incorrect invalid-token401', async () => {
  await assert.rejects(runtime({code: 'auth/internal-error'}).instance.verifyToken('test-token'),
    error => error.status === 503);
});
test('project mismatch denied before authentication', async () => {
  const {instance, calls} = runtime({mismatch: true});
  await assert.rejects(instance.verifyToken('test-token'), error => error.status === 503);
  assert.equal(calls.length, 0);
});
for (const key of ['FIREBASE_AUTH_EMULATOR_HOST', 'FIRESTORE_EMULATOR_HOST']) {
  test(`Lambda runtime refuses ${key}`, async () => {
    await assert.rejects(runtime({env: {[key]: '127.0.0.1:9099'}}).instance.verifyToken('test-token'),
      error => error.status === 503);
  });
}
test('missing server configuration fails closed', async () => {
  await assert.rejects(runtime({env: {FIREBASE_PROJECT_ID: ''}}).instance.verifyToken('test-token'),
    error => error.status === 503);
});

test('credential provider failure is a safe503', async () => {
  await assert.rejects(runtime({failSecret: true}).instance.verifyToken('test-token'),
    error => error.status === 503);
});
