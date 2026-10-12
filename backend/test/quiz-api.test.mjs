import test from 'node:test';
import assert from 'node:assert/strict';
import { createQuizHandler } from '../dist/quizzes/controller.js';
import { buildQuestionSnapshot } from '../dist/quizzes/scoring.js';
import { ApiError } from '../dist/http.mjs';
const attemptId = '12345678-1234-4234-8234-123456789abc';
const quiz = { id: 'question', areaId: 'area', topicId: 'topic', version: 1, type: 'single_choice', question: 'Fixture', options: ['A', 'B'], correctIndex: 1, rationale: 'PRIVATE', sourceBook: '', orderIndex: 1, matchingPairs: [], orderingItems: [] };
function setup(options = {}) {
  const calls = [], logs = [];
  const attempt = { id: attemptId, quizId: quiz.id, areaId: 'area', topicId: 'topic', topicAttemptNumber: 1, startedAt: '2026-01-01T00:00:00.000Z', status: 'started', snapshot: buildQuestionSnapshot(quiz) };
  const repository = Object.fromEntries(['list', 'get', 'start', 'getAttempt', 'submit', 'retry', 'progress'].map(name => [name, async (...args) => {
    calls.push({ name, args });
    if (options.failure) throw options.failure;
    if (name === 'list') return { items: [quiz], nextCursor: null };
    if (name === 'get') return quiz;
    if (name === 'start' || name === 'getAttempt') return attempt;
    if (name === 'submit') return { result: { attemptId, quizId: quiz.id, isCorrect: true, score: 1, earnedStars: 1, maxStars: 1, durationSeconds: 3 }, isReplay: options.replay ?? false };
    return { items: [], nextCursor: null };
  }]));
  const handler = createQuizHandler({ repository, limiter: options.limiter, logger: { error: value => logs.push(value) }, verifyCognitoToken: async token => {
    if (token !== 'cognito') throw new ApiError(401, 'unauthenticated', 'Authentication is required.');
    return { sub: 'owner' };
  } });
  return { handler, calls, logs, attempt };
}
function event(path = '/api/v1/quizzes', method = 'GET', extra = {}) {
  return { path, httpMethod: method, headers: { authorization: 'Bearer cognito', 'content-type': 'application/json', 'idempotency-key': attemptId }, requestContext: { requestId: 'request-1' }, queryStringParameters: path === '/api/v1/quizzes' ? { areaId: 'area' } : null, body: null, ...extra };
}
const payload = result => JSON.parse(result.body);
test('list returns safe public question and scoped pagination', async () => {
  const { handler, calls } = setup();
  const result = await handler(event(undefined, undefined, { queryStringParameters: { areaId: 'area', topicId: 'topic', limit: '5' } }));
  assert.equal(result.statusCode, 200);
  assert.deepEqual(calls[0].args, ['area', { limit: 5, topicId: 'topic' }]);
  assert.equal(JSON.stringify(payload(result).data).includes('PRIVATE'), false);
  assert.equal(Object.hasOwn(payload(result).data.items[0], 'correctIndex'), false);
});
test('detail hides answer keys', async () => {
  const { handler } = setup();
  const result = await handler(event('/api/v1/quizzes/question'));
  assert.equal(result.statusCode, 200);
  assert.equal(payload(result).data.id, 'question');
  assert.equal(Object.hasOwn(payload(result).data, 'rationale'), false);
});
test('start and recovery use authenticated subject without leaking snapshot', async () => {
  const { handler, calls } = setup();
  const start = await handler(event('/api/v1/quizzes/question/attempts/start', 'POST', { body: '{}' }));
  assert.equal(start.statusCode, 201);
  assert.deepEqual(calls[0].args, ['owner', 'question', attemptId]);
  assert.equal(Object.hasOwn(payload(start).data, 'snapshot'), false);
  const recovered = await handler(event(`/api/v1/quizzes/question/attempts/${attemptId}`));
  assert.equal(recovered.statusCode, 200);
  assert.deepEqual(calls[1].args, ['owner', 'question', attemptId]);
});
for (const replay of [false, true]) test(`submit calculates result server-side and reports replay=${replay}`, async () => {
  const { handler, calls, attempt } = setup({ replay });
  const result = await handler(event('/api/v1/quizzes/question/attempts', 'POST', { body: JSON.stringify({ attemptId, answer: { choiceId: attempt.snapshot.presentation.choiceIds[1] } }) }));
  assert.equal(result.statusCode, replay ? 200 : 201);
  assert.equal(calls[1].name, 'submit');
  assert.deepEqual(calls[1].args.slice(0, 3), ['owner', 'question', attemptId]);
  assert.deepEqual(calls[1].args[5], { isCorrect: true, score: 1, earnedStars: 1, maxStars: 1 });
});
test('retry validates expected topic attempt and idempotency key', async () => {
  const { handler, calls } = setup();
  const result = await handler(event('/api/v1/quizzes/topics/topic/retry', 'POST', { body: JSON.stringify({ areaId: 'area', expectedAttemptNumber: 2 }) }));
  assert.equal(result.statusCode, 200);
  assert.deepEqual(calls[0].args, ['owner', 'area', 'topic', attemptId, 2]);
});
test('progress is scoped only to current Cognito subject', async () => {
  const { handler, calls } = setup();
  assert.equal((await handler(event('/api/v1/progress/me', 'GET', { queryStringParameters: { limit: '10' } }))).statusCode, 200);
  assert.deepEqual(calls[0].args, ['owner', { limit: 10 }]);
});
for (const authorization of [undefined, 'Bearer firebase', 'Bearer two tokens']) test(`authentication rejects ${authorization}`, async () => {
  const { handler, calls } = setup();
  assert.equal((await handler(event(undefined, undefined, { headers: { authorization } }))).statusCode, 401);
  assert.equal(calls.length, 0);
});
for (const query of [{}, { areaId: 'area', userId: 'alien' }, { areaId: 'area', limit: '51' }, { areaId: 'area', cursor: '%' }]) test(`list query rejects ${JSON.stringify(query)}`, async () => {
  const { handler } = setup();
  assert.equal((await handler(event(undefined, undefined, { queryStringParameters: query }))).statusCode, 400);
});
for (const body of ['{"stars":99}', '{"attemptId":"bad","answer":{}}', '{"attemptId":"12345678-1234-4234-8234-123456789abc","answer":{},"userId":"alien"}', 'not JSON']) test(`submit rejects malformed or forged request ${body}`, async () => {
  const { handler } = setup();
  assert.equal((await handler(event('/api/v1/quizzes/question/attempts', 'POST', { body }))).statusCode, 400);
});
for (const status of [404, 409, 503]) test(`repository error ${status} maps safely`, async () => {
  const { handler } = setup({ failure: new ApiError(status, 'fixture_error', 'Safe message.') });
  assert.equal((await handler(event('/api/v1/quizzes/question'))).statusCode, status);
});
test('rate limit returns Retry-After and prevents repository execution', async () => {
  const { handler, calls } = setup({ limiter: { consume: async () => { throw new ApiError(429, 'rate_limited', 'Try later.', { 'Retry-After': '30' }); } } });
  const result = await handler(event());
  assert.equal(result.statusCode, 429);
  assert.equal(result.headers['Retry-After'], '30');
  assert.equal(calls.length, 0);
});
test('internal errors log only request id and code', async () => {
  const { handler, logs } = setup({ failure: new Error('SECRET credentials') });
  const result = await handler(event());
  assert.equal(result.statusCode, 500);
  assert.equal(result.body.includes('SECRET'), false);
  assert.deepEqual(logs, [{ requestId: 'request-1', code: 'internal_error' }]);
});
test('foreign result access returns safe not found', async () => {
  const { handler, calls } = setup({ failure: new ApiError(404, 'not_found', 'Attempt not found.') });
  assert.equal((await handler(event(`/api/v1/quizzes/question/attempts/${attemptId}`))).statusCode, 404);
  assert.equal(calls[0].args[0], 'owner');
});
test('unsupported methods and routes have explicit HTTP responses', async () => {
  const { handler } = setup();
  assert.equal((await handler(event('/api/v1/quizzes/question', 'DELETE'))).statusCode, 405);
  assert.equal((await handler(event('/api/v1/progress/alien'))).statusCode, 404);
});
