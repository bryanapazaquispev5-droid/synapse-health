import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { DynamoDBClient, CreateTableCommand, DeleteTableCommand } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';
import { DynamoQuizRepository } from '../dist/quizzes/repository.js';
import { DynamoHistoryRepository } from '../dist/academic-history/repository.js';
import { buildQuestionSnapshot, scoreAnswer } from '../dist/quizzes/scoring.js';
import { fixtureQuiz, contentItem, uuid } from './quiz-repository-fixtures.mjs';
const endpoint = process.env.DYNAMODB_LOCAL_ENDPOINT;
if (!endpoint || !/^http:\/\/127\.0\.0\.1:\d+$/.test(endpoint)) throw new Error('DYNAMODB_LOCAL_ENDPOINT must be loopback DynamoDB Local.');
const sdk = new DynamoDBClient({ endpoint, region: 'us-east-1', credentials: { accessKeyId: 'local', secretAccessKey: 'local' } });
const client = DynamoDBDocumentClient.from(sdk); const content = `synapse-history-content-${process.pid}`; const privateTable = `synapse-history-private-${process.pid}`;
const tables = []; after(async () => { for (const TableName of tables) await sdk.send(new DeleteTableCommand({ TableName })); sdk.destroy(); });
let now = new Date('2026-10-14T10:00:00Z');
const quiz = new DynamoQuizRepository(client, content, privateTable, buildQuestionSnapshot, () => now);
const history = new DynamoHistoryRepository(client, privateTable);
async function submit(attempt) {
  const scored = scoreAnswer(attempt.snapshot, { choiceId: attempt.snapshot.presentation.choiceIds[0] });
  return quiz.submit('student-a', attempt.quizId, attempt.id, scored.answer, scored.fingerprint, scored.result);
}
test('actual DynamoDB atomically projects chronological history, stable pagination and authorized detail', async () => {
  for (const [TableName, pk, sk] of [[content, 'PK', 'SK'], [privateTable, 'userKey', 'entryKey']]) {
    await sdk.send(new CreateTableCommand({ TableName, BillingMode: 'PAY_PER_REQUEST',
      AttributeDefinitions: [{ AttributeName: pk, AttributeType: 'S' }, { AttributeName: sk, AttributeType: 'S' }],
      KeySchema: [{ AttributeName: pk, KeyType: 'HASH' }, { AttributeName: sk, KeyType: 'RANGE' }] })); tables.push(TableName);
  }
  const ids = [];
  for (let index = 1; index <= 3; index++) {
    const record = fixtureQuiz(index); await client.send(new PutCommand({ TableName: content, Item: contentItem(record) }));
  }
  for (let index = 1; index <= 3; index++) {
    const started = await quiz.start('student-a', fixtureQuiz(index).id, uuid(index)); ids.push(started.id);
    now = new Date(now.getTime() + index * 1000);
    const calls = await Promise.all([submit(started), submit(started)]);
    assert.equal(calls.filter(item => !item.isReplay).length, 1);
  }
  const entries = []; let cursor = null;
  do {
    const page = await history.list('student-a', { limit: 1, cursor }); entries.push(...page.items); cursor = page.nextCursor;
  } while (cursor);
  assert.deepEqual(entries.map(item => item.id), ids.reverse()); assert.equal(entries.length, 3);
  assert.deepEqual(entries.map(item => item.durationSeconds), [3, 2, 1]);
  assert.ok(entries.every(item => item.status === 'submitted' && item.score === 1 && item.earnedStars === 1));
  assert.deepEqual(await history.get('student-a', entries[0].id), entries[0]);
  await assert.rejects(history.get('student-b', entries[0].id), error => error.status === 404);
  const page = await history.list('student-a', { limit: 1 });
  await assert.rejects(history.list('student-b', { cursor: page.nextCursor }), error => error.status === 400);
  assert.deepEqual(await history.list('student-b'), { items: [], nextCursor: null });
});
