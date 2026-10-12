import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { createServer } from 'node:http';
import { generateKeyPairSync, sign } from 'node:crypto';
import { CognitoJwtVerifier } from 'aws-jwt-verify';
import { DynamoDBClient, CreateTableCommand, DeleteTableCommand } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';
import { createCognitoRuntime } from '../dist/cognito-runtime.mjs';
import { withCors } from '../dist/cors.mjs';
import { createDynamoRateLimiter } from '../dist/flashcards/runtime.js';
import { createQuizHandler } from '../dist/quizzes/controller.js';
import { buildQuestionSnapshot } from '../dist/quizzes/scoring.js';
import { DynamoQuizRepository } from '../dist/quizzes/repository.js';
import { fixtureQuiz, contentItem, uuid } from './quiz-repository-fixtures.mjs';
const endpoint = process.env.DYNAMODB_LOCAL_ENDPOINT;
if (!endpoint || !/^http:\/\/127\.0\.0\.1:\d+$/.test(endpoint)) throw new Error('Local loopback endpoint required.');
const sdk = new DynamoDBClient({ endpoint, region: 'us-east-1', credentials: { accessKeyId: 'local', secretAccessKey: 'local' } });
const client = DynamoDBDocumentClient.from(sdk);
const content = `synapse-quiz-http-content-${process.pid}`, results = `synapse-quiz-http-private-${process.pid}`;
const created = [];
const pool = 'us-east-1_LocalQuiz', app = 'localquizclient';
const keys = generateKeyPairSync('rsa', { modulusLength: 2048 });
const jwk = { ...keys.publicKey.export({ format: 'jwk' }), kid: 'local-quiz-key', use: 'sig', alg: 'RS256' };
const verifier = CognitoJwtVerifier.create({ userPoolId: pool, clientId: app, tokenUse: 'access' });
verifier.cacheJwks({ keys: [jwk] });
function token(subject) {
  const now = Math.floor(Date.now() / 1000);
  const data = [ { alg: 'RS256', kid: jwk.kid }, { sub: subject, iss: `https://cognito-idp.us-east-1.amazonaws.com/${pool}`,
    client_id: app, token_use: 'access', iat: now, exp: now + 300 } ].map(value => Buffer.from(JSON.stringify(value)).toString('base64url')).join('.');
  return `${data}.${sign('RSA-SHA256', Buffer.from(data), keys.privateKey).toString('base64url')}`;
}
const ownerToken = token('local-owner'), otherToken = token('local-other');
const identities = new Map([[ownerToken, 'local-owner'], [otherToken, 'local-other']]);
// Actual RSA/JWKS verification; only GetUser account status is simulated locally.
const cognito = createCognitoRuntime({ env: { COGNITO_USER_POOL_ID: pool, COGNITO_CLIENT_ID: app },
  createVerifier: () => verifier, verifyUserStatus: async accessToken => identities.get(accessToken) });
let now = new Date();
const repo = new DynamoQuizRepository(client, content, results, buildQuestionSnapshot, () => now);
const handler = withCors(createQuizHandler({ ...cognito, repository: repo, limiter: createDynamoRateLimiter(client, content) }), 'https://synapse.invalid');
const server = createServer(async (request, reply) => {
  try {
    const chunks = []; for await (const chunk of request) chunks.push(chunk);
    const url = new URL(request.url, 'http://127.0.0.1');
    const result = await handler({ httpMethod: request.method, path: url.pathname, headers: request.headers,
      queryStringParameters: Object.fromEntries(url.searchParams), body: chunks.length ? Buffer.concat(chunks).toString() : null,
      requestContext: { requestId: 'quiz-http-local' } });
    reply.writeHead(result.statusCode, result.headers); reply.end(result.body);
  } catch { reply.writeHead(500); reply.end(); }
});
after(async () => {
  if (server.listening) { server.closeAllConnections(); await new Promise(resolve => server.close(resolve)); }
  for (const TableName of created) await sdk.send(new DeleteTableCommand({ TableName })); sdk.destroy();
});
test('real HTTP, signed JWTs and DynamoDB Local grade all question types and isolate progress', async () => {
  for (const [TableName, pk, sk] of [[content, 'PK', 'SK'], [results, 'userKey', 'entryKey']]) {
    await sdk.send(new CreateTableCommand({ TableName, BillingMode: 'PAY_PER_REQUEST',
      AttributeDefinitions: [{ AttributeName: pk, AttributeType: 'S' }, { AttributeName: sk, AttributeType: 'S' }],
      KeySchema: [{ AttributeName: pk, KeyType: 'HASH' }, { AttributeName: sk, KeyType: 'RANGE' }] })); created.push(TableName);
  }
  const quizzes = [fixtureQuiz(), fixtureQuiz(2, 'matching'), fixtureQuiz(3, 'ordering')];
  for (const quiz of quizzes) await client.send(new PutCommand({ TableName: content, Item: contentItem(quiz) }));
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  const base = `http://127.0.0.1:${server.address().port}`;
  const send = (path, method = 'GET', body, key, auth = ownerToken) => fetch(base + path, { method,
    headers: { Authorization: `Bearer ${auth}`, 'Content-Type': 'application/json', Origin: 'https://synapse.invalid', ...(key ? { 'Idempotency-Key': key } : {}) },
    ...(body === undefined ? {} : { body: JSON.stringify(body) }) });
  assert.equal((await send('/api/v1/quizzes?areaId=fixture-area', 'GET', undefined, undefined, 'invalid')).status, 401);
  const listing = await send('/api/v1/quizzes?areaId=fixture-area'); assert.equal(listing.status, 200);
  const data = (await listing.json()).data;
  assert.equal(data.items.length, 3); assert.ok(!JSON.stringify(data).includes('correctIndex')); assert.ok(!JSON.stringify(data).includes('Private fixture'));
  for (const [index, quiz] of quizzes.entries()) {
    const path = `/api/v1/quizzes/${quiz.id}`;
    const started = await send(`${path}/attempts/start`, 'POST', {}, uuid(70 + index)); assert.equal(started.status, 201);
    const attempt = (await started.json()).data; const question = attempt.question;
    const answer = quiz.type === 'single_choice' ? { choiceId: question.options.find(choice => choice.text === 'Fixture A').id }
      : quiz.type === 'matching' ? { pairs: question.leftItems.map(left => ({ leftId: left.id, rightId: question.rightItems.find(right => right.text === left.text.replace('L', 'R')).id })) }
      : { itemIds: ['Second', 'First'].map(text => question.items.find(item => item.text === text).id) };
    now = new Date(now.getTime() + 10_000);
    const body = { attemptId: attempt.attemptId, answer };
    assert.equal((await send(`${path}/attempts`, 'POST', { ...body, earnedStars: 100 })).status, 400);
    assert.equal((await send(`${path}/attempts`, 'POST', body, undefined, otherToken)).status, 404);
    const submission = await send(`${path}/attempts`, 'POST', body); assert.equal(submission.status, 201);
    const result = (await submission.json()).data;
    assert.equal(result.durationSeconds, 10); assert.equal(result.earnedStars, [1, 2, 0][index]);
    assert.equal((await send(`${path}/attempts`, 'POST', body)).status, 200);
    assert.equal((await send(`${path}/attempts/${attempt.attemptId}`, 'GET', undefined, undefined, otherToken)).status, 404);
  }
  const progress = (await (await send('/api/v1/progress/me')).json()).data;
  assert.equal(progress.items[0].activeAttempt.totalEarnedStars, 3); assert.equal(progress.items[0].activeAttempt.totalMaxStars, 5);
  const other = (await (await send('/api/v1/progress/me', 'GET', undefined, undefined, otherToken)).json()).data;
  assert.deepEqual(other.items, []);
});
