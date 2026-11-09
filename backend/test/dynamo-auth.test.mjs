import test from 'node:test';
import assert from 'node:assert/strict';
import {createAwsHandler} from '../src/aws/handler.mjs';
import {createAuthRepository, hashPassword, verifyPassword} from '../src/aws/auth-repository.mjs';

function fixture() {
  const storeData = new Map();
  const mockStore = {
    async get(PK, SK) {
      return storeData.get(`${PK}#${SK}`) ?? null;
    },
    async put(item, expectedVersion) {
      const key = `${item.PK}#${item.SK}`;
      storeData.set(key, {data: item, ...item});
      return item;
    },
    async consume() { return true; }
  };
  const authRepo = createAuthRepository({profilesStore: mockStore, secret: 'test-jwt-secret-key-12345'});
  const handler = createAwsHandler({
    identity: {verifyCognitoToken: async () => { throw new Error('not cognito'); }},
    store: mockStore,
    profiles: {get: async () => ({})},
    catalog: {list: async () => ({})},
    progress: {},
    history: {},
    leaderboard: {},
    authRepo
  });
  return {mockStore, authRepo, handler};
}

test('password hashing with scrypt is secure and verifiable', () => {
  const hash = hashPassword('MySecurePass123!');
  assert.ok(hash.startsWith('scrypt$N=16384,r=8,p=1$'));
  assert.equal(verifyPassword('MySecurePass123!', hash), true);
  assert.equal(verifyPassword('WrongPassword!', hash), false);
});

test('POST /api/v1/auth/register registers account in DynamoDB and returns JWT', async () => {
  const {handler} = fixture();
  const res = await handler({
    path: '/api/v1/auth/register',
    httpMethod: 'POST',
    headers: {'content-type': 'application/json'},
    body: JSON.stringify({
      email: 'student@example.invalid',
      password: 'MyPassword123!',
      name: 'Maria Medico',
      career: 'General Medicine'
    })
  });
  assert.equal(res.statusCode, 200);
  const body = JSON.parse(res.body);
  assert.ok(body.data.token);
  assert.equal(body.data.user.email, 'student@example.invalid');
  assert.equal(body.data.user.name, 'Maria Medico');
});

test('POST /api/v1/auth/register prevents duplicate email registration', async () => {
  const {handler} = fixture();
  const payload = {
    email: 'duplicate@example.invalid',
    password: 'MyPassword123!',
    name: 'First User'
  };
  const res1 = await handler({path: '/api/v1/auth/register', httpMethod: 'POST', headers: {'content-type': 'application/json'}, body: JSON.stringify(payload)});
  assert.equal(res1.statusCode, 200);

  const res2 = await handler({path: '/api/v1/auth/register', httpMethod: 'POST', headers: {'content-type': 'application/json'}, body: JSON.stringify(payload)});
  assert.equal(res2.statusCode, 409);
});

test('POST /api/v1/auth/login verifies credentials and returns JWT', async () => {
  const {handler} = fixture();
  await handler({
    path: '/api/v1/auth/register',
    httpMethod: 'POST',
    headers: {'content-type': 'application/json'},
    body: JSON.stringify({email: 'login@example.invalid', password: 'ValidPassword123!'})
  });

  const successRes = await handler({
    path: '/api/v1/auth/login',
    httpMethod: 'POST',
    headers: {'content-type': 'application/json'},
    body: JSON.stringify({email: 'login@example.invalid', password: 'ValidPassword123!'})
  });
  assert.equal(successRes.statusCode, 200);
  const successBody = JSON.parse(successRes.body);
  assert.ok(successBody.data.token);

  const failRes = await handler({
    path: '/api/v1/auth/login',
    httpMethod: 'POST',
    headers: {'content-type': 'application/json'},
    body: JSON.stringify({email: 'login@example.invalid', password: 'WrongPassword123!'})
  });
  assert.equal(failRes.statusCode, 401);
});

test('GET /api/v1/auth/session authenticates with DynamoDB JWT', async () => {
  const {handler} = fixture();
  const regRes = await handler({
    path: '/api/v1/auth/register',
    httpMethod: 'POST',
    headers: {'content-type': 'application/json'},
    body: JSON.stringify({email: 'jwtuser@example.invalid', password: 'Password123!', name: 'Doctor'})
  });
  const token = JSON.parse(regRes.body).data.token;

  const sessionRes = await handler({
    path: '/api/v1/auth/session',
    httpMethod: 'GET',
    headers: {authorization: `Bearer ${token}`}
  });
  assert.equal(sessionRes.statusCode, 200);
  const sessionBody = JSON.parse(sessionRes.body);
  assert.equal(sessionBody.data.email, 'jwtuser@example.invalid');
  assert.equal(sessionBody.data.role, 'student');
});
