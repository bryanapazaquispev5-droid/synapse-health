import assert from 'node:assert/strict';
import test from 'node:test';
import {generateKeyPairSync, sign} from 'node:crypto';
import {CognitoJwtVerifier} from 'aws-jwt-verify';
import {createCognitoRuntime} from '../src/cognito-runtime.mjs';

const pool = 'us-east-1_TestPool';
const client = 'localclient';
const issuer = `https://cognito-idp.us-east-1.amazonaws.com/${pool}`;
const keys = generateKeyPairSync('rsa', {modulusLength: 2048});
const jwk = {...keys.publicKey.export({format: 'jwk'}), kid: 'local-key', use: 'sig', alg: 'RS256'};
function token(overrides = {}, key = keys.privateKey, header = {}) {
  const now = Math.floor(Date.now() / 1000);
  const claims = {sub: 'local-subject', iss: issuer, client_id: client, token_use: 'access', iat: now, exp: now + 300, ...overrides};
  const encoded = [Buffer.from(JSON.stringify({alg: 'RS256', kid: jwk.kid, ...header})).toString('base64url'),
    Buffer.from(JSON.stringify(claims)).toString('base64url')].join('.');
  return `${encoded}.${sign('RSA-SHA256', Buffer.from(encoded), key).toString('base64url')}`;
}
function runtime() {
  const verifier = CognitoJwtVerifier.create({userPoolId: pool, clientId: client, tokenUse: 'access'});
  verifier.cacheJwks({keys: [jwk]});
  return createCognitoRuntime({env: {COGNITO_USER_POOL_ID: pool, COGNITO_CLIENT_ID: client}, createVerifier: () => verifier, verifyUserStatus: async () => 'local-subject'});
}
const isStatus = status => error => error.status === status && !error.message.includes('local-');

test('verifies a real RSA signature with cached JWKS and returns only subject', async () => {
  assert.deepEqual(await runtime().verifyCognitoToken(token({email: 'private@example.invalid'})), {sub: 'local-subject'});
});
for (const [name, claims] of [
  ['expired', {exp: Math.floor(Date.now() / 1000) - 60}],
  ['wrong issuer', {iss: 'https://issuer.invalid'}],
  ['wrong app client', {client_id: 'otherclient'}],
  ['ID token', {token_use: 'id', aud: client}],
  ['missing expiration', {exp: undefined}],
  ['empty subject', {sub: ''}],
  ['missing subject', {sub: undefined}],
  ['future not-before', {nbf: Math.floor(Date.now() / 1000) + 300}],
]) {
  test(`rejects ${name} without exposing claims`, async () => {
    await assert.rejects(runtime().verifyCognitoToken(token(claims)), isStatus(401));
  });
}
test('rejects wrong signature', async () => {
  const alternate = generateKeyPairSync('rsa', {modulusLength: 2048});
  await assert.rejects(runtime().verifyCognitoToken(token({}, alternate.privateKey)), isStatus(401));
});
test('rejects malformed tokens', async () => {
  await assert.rejects(runtime().verifyCognitoToken('not-a-jwt'), isStatus(401));
});
test('requires explicitly configured pool and client without calling verifier', async () => {
  let calls = 0;
  const service = createCognitoRuntime({env: {}, createVerifier: () => {calls++;}});
  await assert.rejects(service.verifyCognitoToken(token()), isStatus(503));
  assert.equal(calls, 0);
});
test('maps JWKS network failures to unavailable without leaking error', async () => {
  const service = createCognitoRuntime({env: {COGNITO_USER_POOL_ID: pool, COGNITO_CLIENT_ID: client},
    createVerifier: () => ({verify: async () => {throw new Error('private-network-details');}})});
  await assert.rejects(service.verifyCognitoToken(token()), isStatus(503));
});
test('reuses verifier and enforces access token configuration', async () => {
  let calls = 0;
  const service = createCognitoRuntime({env: {COGNITO_USER_POOL_ID: pool, COGNITO_CLIENT_ID: client},
    verifyUserStatus: async () => 'local-subject', createVerifier: properties => {
      calls++;
      assert.deepEqual(properties, {userPoolId: pool, clientId: client, tokenUse: 'access'});
      return {verify: async () => ({sub: 'local-subject', exp: Math.floor(Date.now() / 1000) + 300})};
    }});
  await service.verifyCognitoToken('first');
  await service.verifyCognitoToken('second');
  assert.equal(calls, 1);
});

test('rejects an online subject that differs from verified JWT', async () => {
  const service = createCognitoRuntime({env: {COGNITO_USER_POOL_ID: pool, COGNITO_CLIENT_ID: client},
    createVerifier: () => ({verify: async () => ({sub: 'verified-subject', exp: Math.floor(Date.now() / 1000) + 300})}), verifyUserStatus: async () => 'other-subject'});
  await assert.rejects(service.verifyCognitoToken('token'), isStatus(401));
});

test('rejects unknown signing key without network lookup in offline validation', async () => {
  const verifier = CognitoJwtVerifier.create({userPoolId: pool, clientId: client, tokenUse: 'access'});
  verifier.cacheJwks({keys: [jwk]});
  const service = createCognitoRuntime({env: {COGNITO_USER_POOL_ID: pool, COGNITO_CLIENT_ID: client},
    createVerifier: () => ({verify: async jwt => verifier.verifySync(jwt)}), verifyUserStatus: async () => 'local-subject'});
  await assert.rejects(service.verifyCognitoToken(token({}, keys.privateKey, {kid: 'unknown-key'})), isStatus(401));
});
test('rejects an unsupported JWT algorithm', async () => {
  await assert.rejects(runtime().verifyCognitoToken(token({}, keys.privateKey, {alg: 'HS256'})), isStatus(401));
});
test('does not call online account verification for an invalid JWT', async () => {
  let calls = 0;
  const verifier = CognitoJwtVerifier.create({userPoolId: pool, clientId: client, tokenUse: 'access'});
  verifier.cacheJwks({keys: [jwk]});
  const service = createCognitoRuntime({env: {COGNITO_USER_POOL_ID: pool, COGNITO_CLIENT_ID: client},
    createVerifier: () => verifier, verifyUserStatus: async () => {calls++; return 'local-subject';}});
  await assert.rejects(service.verifyCognitoToken(token({client_id: 'other'})), isStatus(401));
  assert.equal(calls, 0);
});
