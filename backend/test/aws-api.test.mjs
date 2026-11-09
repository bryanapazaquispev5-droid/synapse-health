import {test} from 'node:test';
import assert from 'node:assert/strict';
import {fixture, request, seedQuiz, quiz} from './aws-fixtures.mjs';
const payload = result => JSON.parse(result.body);
test('AWS health does not initialize credentials and accepts HTTP API v2', async () => {
  const {handler} = fixture();
  const output = await handler({rawPath: '/health', requestContext: {http: {method: 'GET'}}});
  assert.equal(output.statusCode, 200); assert.equal(payload(output).data.provider, 'aws');
});
test('protected API rejects missing/invalid identity and exposes no token', async () => {
  const {handler} = fixture();
  const output = await handler({...request('/v1/me/profile'), headers: {}});
  assert.equal(output.statusCode, 401);
  const invalid = await handler(request('/v1/me/profile', 'GET', undefined, 'private-invalid-token'));
  assert.equal(invalid.statusCode, 401); assert.ok(!invalid.body.includes('private-invalid-token'));
});
test('former administrator catalog routes are not part of the student API', async () => {
  const {handler} = fixture();
  const response = await handler(request('/api/v1/admin/areas', 'POST', {name: 'No write route'}));
  assert.equal(response.statusCode, 404);
});
test('profile starts empty, stores English enum values and isolates owners', async () => {
  const {handler, store} = fixture();
  assert.deepEqual(payload(await handler(request('/v1/me/profile'))).data, {});
  const created = await handler(request('/v1/me/profile', 'PUT', {name: 'Synthetic owner', career: 'Medicina Humana', gender: 'Mujer'}));
  assert.equal(created.statusCode, 200); assert.equal(payload(created).data.uid, 'owner-a');
  assert.equal(payload(created).data.email, 'owner-a@example.invalid');
  assert.equal(payload(created).data.gender, 'Female');
  assert.equal(payload(created).data.career, 'General Medicine');
  assert.equal((await store.get('USER#owner-a', 'PROFILE')).data.gender, 'Female');
  assert.equal((await store.get('USER#owner-a', 'PROFILE')).data.career, 'General Medicine');
  assert.deepEqual(payload(await handler(request('/v1/me/profile', 'GET', undefined, 'owner-b'))).data, {});
  const forbidden = await handler(request('/v1/me/profile', 'PATCH', {uid: 'owner-b'}));
  assert.equal(forbidden.statusCode, 400);
});
test('empty catalog has valid pages and synthetic study notes/quizzes work', async () => {
  const {handler, store} = fixture();
  assert.deepEqual(payload(await handler(request('/api/v1/areas'))).data, {items: [], nextCursor: null});
  store.seed('AREA#synthetic-area', 'TOPIC#synthetic-topic#STUDY_NOTE#sheet-1', {title: 'Synthetic', contentMarkdown: 'Test only'});
  seedQuiz(store);
  const sheet = await handler(request('/api/v1/areas/synthetic-area/topics/synthetic-topic/study-notes'));
  assert.equal(payload(sheet).data.items[0].id, 'sheet-1');
  const quizzes = await handler(request('/api/v1/areas/synthetic-area/topics/synthetic-topic/quizzes'));
  assert.equal(payload(quizzes).data.items[0].question, quiz.question);
});
test('invalid query, unsupported methods and oversized writes fail closed', async () => {
  const {handler} = fixture();
  assert.equal((await handler({...request('/api/v1/areas'), queryStringParameters: {limit: '999'}})).statusCode, 400);
  assert.equal((await handler(request('/api/v1/leaderboard', 'POST', {}))).statusCode, 405);
  assert.equal((await handler(request('/api/v1/progress/synthetic-topic/answer', 'POST', {answer: 'a'.repeat(40000)}))).statusCode, 413);
});
test('history remains owner scoped and uses existing entry/retention contract', async () => {
  const {handler, store} = fixture(); seedQuiz(store);
  const answer = {areaId: quiz.areaId, quizId: 'question-1', expectedAttemptNumber: 1, answer: {selectedOptionText: 'Option B'}};
  assert.equal((await handler(request('/api/v1/progress/synthetic-topic/answer', 'POST', answer))).statusCode, 200);
  const history = payload(await handler(request('/api/v1/history'))).data;
  assert.equal(history.items.length, 1); assert.equal(history.items[0].earnedStars, 1);
  const detail = await handler(request(`/api/v1/history/${history.items[0].id}`));
  assert.equal(detail.statusCode, 200);
  assert.equal((await handler(request(`/api/v1/history/${history.items[0].id}`, 'GET', undefined, 'owner-b'))).statusCode, 404);
});
test('server failures log safe operation and exception class without private error details', async () => {
  const {handler, store, logs} = fixture(); store.consume = async () => {throw Object.assign(new Error('private-token-health-value'), {name: 'AccessDeniedException'});};
  const output = await handler(request('/v1/me/profile'));
  assert.equal(output.statusCode, 500); assert.ok(!output.body.includes('private-token'));
  assert.deepEqual(logs, [{requestId: 'synthetic-request', code: 'internal_error', stage: 'rate_limit', errorType: 'AccessDeniedException'}]);
});
