import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { DynamoDBClient, CreateTableCommand, DeleteTableCommand } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';
import { DynamoQuizRepository } from '../dist/quizzes/repository.js';
import { buildQuestionSnapshot, scoreAnswer } from '../dist/quizzes/scoring.js';
import { createQuizHandler } from '../dist/quizzes/controller.js';
import { fixtureQuiz, contentItem, uuid } from './quiz-repository-fixtures.mjs';
const endpoint = process.env.DYNAMODB_LOCAL_ENDPOINT;
if (!endpoint || !/^http:\/\/127\.0\.0\.1:\d+$/.test(endpoint)) throw new Error('Set DYNAMODB_LOCAL_ENDPOINT to loopback DynamoDB Local.');
const sdk = new DynamoDBClient({ endpoint, region: 'us-east-1', credentials: { accessKeyId: 'local', secretAccessKey: 'local' } });
const client = DynamoDBDocumentClient.from(sdk);
const content = `synapse-quiz-content-${process.pid}`; const privateTable = `synapse-quiz-results-${process.pid}`;
const created = [];
after(async () => { for (const TableName of created) await sdk.send(new DeleteTableCommand({ TableName })); sdk.destroy(); });
let now = new Date('2026-10-12T10:00:00Z');
const repo = new DynamoQuizRepository(client, content, privateTable, buildQuestionSnapshot, () => now);
const handler = createQuizHandler({ verifyCognitoToken: async token => ({ sub: token }), repository: repo, logger: { error() {} } });
function event(method, path, body, key, sub = 'student-a', query) {
  return { httpMethod: method, path, headers: { Authorization: `Bearer ${sub}`, 'Content-Type': 'application/json', ...(key ? { 'Idempotency-Key': key } : {}) },
    body: body === undefined ? null : JSON.stringify(body), queryStringParameters: query, requestContext: { requestId: 'local-integration' } };
}
async function answer(attempt, input = { choiceId: attempt.snapshot.presentation.choiceIds[0] }, subject = 'student-a') {
  const scored = scoreAnswer(attempt.snapshot, input);
  return repo.submit(subject, attempt.quizId, attempt.id, scored.answer, scored.fingerprint, scored.result);
}
test('DynamoDB Local persists secure quiz results and atomic idempotent submissions with actual conditional transactions', async () => {
  for (const [TableName, pk, sk] of [[content, 'PK', 'SK'], [privateTable, 'userKey', 'entryKey']]) {
    await sdk.send(new CreateTableCommand({ TableName, BillingMode: 'PAY_PER_REQUEST',
      AttributeDefinitions: [{ AttributeName: pk, AttributeType: 'S' }, { AttributeName: sk, AttributeType: 'S' }],
      KeySchema: [{ AttributeName: pk, KeyType: 'HASH' }, { AttributeName: sk, KeyType: 'RANGE' }] })); created.push(TableName);
  }
  for (const quiz of [fixtureQuiz(), fixtureQuiz(2, 'matching'), fixtureQuiz(3, 'ordering', 'other-topic')]) {
    await client.send(new PutCommand({ TableName: content, Item: contentItem(quiz) }));
  }
  const quiz = fixtureQuiz();
  const started = await repo.start('student-a', quiz.id, uuid(10));
  now = new Date(now.getTime() + 31_000);
  assert.deepEqual(await repo.start('student-a', quiz.id, uuid(11)), started);
  const concurrent = await Promise.all([answer(started), answer(started)]);
  assert.equal(concurrent.filter(item => !item.isReplay).length, 1); assert.deepEqual(concurrent[0].result, concurrent[1].result);
  assert.equal(concurrent[0].result.durationSeconds, 31);
  await assert.rejects(answer(started, { choiceId: started.snapshot.presentation.choiceIds[1] }), error => error.status === 409);
  await assert.rejects(repo.getAttempt('student-b', quiz.id, started.id), error => error.status === 404);
  const progress = await repo.progress('student-a'); assert.equal(progress.items[0].activeAttempt.totalEarnedStars, 1);
  assert.equal(progress.items[0].activeAttempt.totalMaxStars, 3);
  const firstPage = await repo.list('fixture-area', { limit: 1, topicId: 'other-topic' }); assert.deepEqual(firstPage.items, []); assert.ok(firstPage.nextCursor);
});
test('DynamoDB Local retry races archive once, invalidate pending starts, and retain only latest three topic cycles', async () => {
  const quiz = fixtureQuiz(); const matching = fixtureQuiz(2, 'matching');
  const pending = await repo.start('student-a', matching.id, uuid(20));
  const resets = await Promise.allSettled([
    repo.retry('student-a', quiz.areaId, quiz.topicId, uuid(21), 1), repo.retry('student-a', quiz.areaId, quiz.topicId, uuid(22), 1),
  ]);
  assert.equal(resets.filter(item => item.status === 'fulfilled').length, 1); assert.equal(resets.find(item => item.status === 'rejected').reason.status, 409);
  const matchingAnswer = { pairs: pending.snapshot.presentation.leftIds.map((leftId, i) => ({ leftId, rightId: pending.snapshot.presentation.rightIds[i] })) };
  await assert.rejects(answer(pending, matchingAnswer), error => error.status === 409);
  for (let cycle = 2; cycle <= 5; cycle++) {
    const started = await repo.start('student-a', quiz.id, uuid(30 + cycle)); await answer(started);
    await repo.retry('student-a', quiz.areaId, quiz.topicId, uuid(40 + cycle), cycle);
  }
  const final = (await repo.progress('student-a')).items[0]; assert.deepEqual(final.history.map(item => item.attemptNumber), [3, 4, 5]);
  assert.equal(final.activeAttempt.totalEarnedStars, 0); assert.equal(final.currentAttemptNumber, 6);
  assert.deepEqual(await repo.progress('student-b'), { items: [], nextCursor: null });
});
test('REST handler with actual DynamoDB enforces public question shape, signed subject ownership and server grading', async () => {
  const quiz = fixtureQuiz(3, 'ordering', 'other-topic');
  const listing = await handler(event('GET', '/api/v1/quizzes', undefined, undefined, 'student-c', { areaId: 'fixture-area' }));
  assert.equal(listing.statusCode, 200);
  const publicQuestions = JSON.parse(listing.body).data.items;
  for (const item of publicQuestions) {
    assert.ok(!('correctIndex' in item)); assert.ok(!('rationale' in item)); assert.ok(!('matchingPairs' in item)); assert.ok(!('orderingItems' in item));
  }
  const base = `/api/v1/quizzes/${quiz.id}`;
  const started = await handler(event('POST', `${base}/attempts/start`, {}, uuid(60), 'student-c'));
  assert.equal(started.statusCode, 201); const data = JSON.parse(started.body).data;
  assert.equal((await handler(event('GET', `${base}/attempts/${data.attemptId}`, undefined, undefined, 'student-b'))).statusCode, 404);
  const privateAttempt = await repo.getAttempt('student-c', quiz.id, data.attemptId);
  const body = { attemptId: data.attemptId, answer: { itemIds: privateAttempt.snapshot.presentation.itemIds } };
  const submitted = await handler(event('POST', `${base}/attempts`, body, undefined, 'student-c'));
  assert.equal(submitted.statusCode, 201); assert.equal(JSON.parse(submitted.body).data.earnedStars, 2);
  assert.equal((await handler(event('POST', `${base}/attempts`, body, undefined, 'student-c'))).statusCode, 200);
  assert.equal((await handler(event('POST', `${base}/attempts`, { ...body, earnedStars: 100 }, undefined, 'student-c'))).statusCode, 400);
  const tampered = { attemptId: data.attemptId, answer: { itemIds: [...privateAttempt.snapshot.presentation.itemIds].reverse() } };
  assert.equal((await handler(event('POST', `${base}/attempts`, tampered, undefined, 'student-c'))).statusCode, 409);
  const progress = await handler(event('GET', '/api/v1/progress/me', undefined, undefined, 'student-c'));
  assert.equal(progress.statusCode, 200); assert.equal(JSON.parse(progress.body).data.items[0].activeAttempt.totalEarnedStars, 2);
});
