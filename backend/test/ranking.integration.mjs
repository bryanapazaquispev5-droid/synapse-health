import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { CreateTableCommand, DeleteTableCommand, DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';
import { DynamoQuizRepository } from '../dist/quizzes/repository.js';
import { DynamoRankingRepository } from '../dist/ranking/repository.js';
import { buildQuestionSnapshot, scoreAnswer } from '../dist/quizzes/scoring.js';
import { encodeLocator, decode } from '../dist/quizzes/keys.js';
import { fixtureQuiz, contentItem, uuid } from './quiz-repository-fixtures.mjs';
const endpoint = process.env.DYNAMODB_LOCAL_ENDPOINT;
if (!endpoint || !/^http:\/\/127\.0\.0\.1:\d+$/.test(endpoint)) throw new Error('Use loopback DynamoDB Local only.');
const sdk = new DynamoDBClient({ endpoint, region: 'us-east-1', credentials: { accessKeyId: 'local', secretAccessKey: 'local' } });
const raw = DynamoDBDocumentClient.from(sdk);
const calls = [];
const client = { async send(command) { calls.push(command); return raw.send(command); } };
const content = `synapse-ranking-content-${process.pid}`, privateTable = `synapse-ranking-private-${process.pid}`;
const created = [];
after(async () => { for (const TableName of created) await sdk.send(new DeleteTableCommand({ TableName })); sdk.destroy(); });
let now = new Date('2026-10-12T10:00:00Z');
let nextAlias = 100;
const ranking = new DynamoRankingRepository(client, privateTable, () => uuid(nextAlias++));
const repo = new DynamoQuizRepository(client, content, privateTable, buildQuestionSnapshot, () => now, undefined,
  (subject, topic, completedAt) => ranking.prepareCompletion(subject, topic, completedAt));
const quizzes = [fixtureQuiz(), fixtureQuiz(2)];
async function submit(subject, attempt, correct = true) {
  const scored = scoreAnswer(attempt.snapshot, { choiceId: attempt.snapshot.presentation.choiceIds[correct ? 0 : 1] });
  return repo.submit(subject, attempt.quizId, attempt.id, scored.answer, scored.fingerprint, scored.result);
}
let sequence = 1;
async function complete(subject, seconds = 10, correct = true) {
  const first = await repo.start(subject, quizzes[0].id, uuid(sequence++));
  const second = await repo.start(subject, quizzes[1].id, uuid(sequence++));
  now = new Date(now.getTime() + seconds * 1000);
  await submit(subject, first, correct);
  const before = await ranking.me(subject);
  const result = await submit(subject, second, correct);
  return { first, second, before, result };
}
test('DynamoDB Local global ranking is atomic on full cycles, pseudonymous and efficiently ordered', async () => {
  for (const [TableName, hash, range] of [[content, 'PK', 'SK'], [privateTable, 'userKey', 'entryKey']]) {
    await sdk.send(new CreateTableCommand({ TableName, BillingMode: 'PAY_PER_REQUEST',
      AttributeDefinitions: [{ AttributeName: hash, AttributeType: 'S' }, { AttributeName: range, AttributeType: 'S' }],
      KeySchema: [{ AttributeName: hash, KeyType: 'HASH' }, { AttributeName: range, KeyType: 'RANGE' }] })); created.push(TableName);
  }
  for (const quiz of quizzes) await raw.send(new PutCommand({ TableName: content, Item: contentItem(quiz) }));
  assert.deepEqual(await ranking.list(), { items: [], nextCursor: null });
  assert.deepEqual(await ranking.me('never-participated'), { entry: null });
  const a = await complete('private-student-a', 10);
  assert.deepEqual(a.before, { entry: null });
  await complete('private-student-b', 20);
  await complete('private-student-c', 10);
  await complete('private-student-d', 0, false);
  const page = await ranking.list();
  assert.equal(page.items.length, 4);
  assert.deepEqual(page.items.map(item => item.rank), [1, 2, 3, 4]);
  assert.deepEqual(page.items.map(item => item.publicId), [uuid(100), uuid(102), uuid(101), uuid(103)]);
  assert.equal(page.items[0].totalStars, 2);
  assert.equal(page.items[0].totalQuizTimeSeconds, 10);
  assert.equal(page.items[0].completedQuizzesCount, 1);
  assert.equal(page.items[0].averageTimeSeconds, 10);
  assert.equal(JSON.stringify(page).includes('private-student'), false);
  assert.equal(JSON.stringify(page).includes('USER#'), false);
  assert.equal((await ranking.me('private-student-b')).entry.rank, 3);
  assert.equal((await submit('private-student-a', a.second)).isReplay, true);
  assert.equal((await ranking.me('private-student-a')).entry.completedQuizzesCount, 1);
  assert.equal(calls.some(command => command.constructor.name === 'ScanCommand'), false);
  assert.ok(calls.filter(command => command.constructor.name === 'TransactWriteCommand').every(command => command.input.TransactItems.length <= 100));
});
test('DynamoDB Local ranking pagination rejects forged positions, keys and stale revisions', async () => {
  const first = await ranking.list({ limit: 2 });
  assert.ok(first.nextCursor);
  const second = await ranking.list({ limit: 2, cursor: first.nextCursor });
  assert.deepEqual(second.items.map(item => item.rank), [3, 4]);
  const forged = decode(first.nextCursor);
  await assert.rejects(ranking.list({ cursor: encodeLocator([forged[0], 1, forged[2]]) }), error => error.status === 400);
  await assert.rejects(ranking.list({ cursor: encodeLocator([forged[0], 2, `ENTRY#${'00'.repeat(41)}`]) }), error => error.status === 409);
  await repo.retry('private-student-a', quizzes[0].areaId, quizzes[0].topicId, uuid(sequence++), 1);
  assert.equal((await ranking.me('private-student-a')).entry.totalStars, 2);
  await complete('private-student-a', 5);
  await assert.rejects(ranking.list({ cursor: first.nextCursor }), error => error.status === 409);
  const mine = (await ranking.me('private-student-a')).entry;
  assert.equal(mine.rank, 1);
  assert.equal(mine.totalStars, 4);
  assert.equal(mine.totalQuizTimeSeconds, 15);
  assert.equal(mine.completedQuizzesCount, 2);
  assert.equal(mine.averageTimeSeconds, 7.5);
});
test('DynamoDB Local duplicate and concurrent final submissions award each cycle once', async () => {
  const starts = await Promise.all(['parallel-a', 'parallel-b'].map(async subject => {
    const first = await repo.start(subject, quizzes[0].id, uuid(sequence++));
    const second = await repo.start(subject, quizzes[1].id, uuid(sequence++));
    await submit(subject, first);
    return { subject, second };
  }));
  now = new Date(now.getTime() + 9_000);
  const submitted = await Promise.all(starts.flatMap(({ subject, second }) => [submit(subject, second), submit(subject, second)]));
  assert.equal(submitted.filter(result => !result.isReplay).length, 2);
  for (const { subject } of starts) assert.equal((await ranking.me(subject)).entry.completedQuizzesCount, 1);
  const page = await ranking.list();
  assert.equal(page.items.length, 6);
  assert.deepEqual(page.items.map(item => item.rank), [1, 2, 3, 4, 5, 6]);
  for (const { subject } of starts) {
    const mine = (await ranking.me(subject)).entry;
    assert.equal(page.items.find(item => item.publicId === mine.publicId).rank, mine.rank);
  }
});

test('DynamoDB Local ranking CAS failure rolls back the grade, history and projection together', async () => {
  const failing = new DynamoQuizRepository(client, content, privateTable, buildQuestionSnapshot, () => now, undefined,
    async (subject, topic, completedAt) => {
      const writes = await ranking.prepareCompletion(subject, topic, completedAt);
      const global = writes.find(write => write.Put?.Item?.entryKey === 'META');
      global.Put.ExpressionAttributeValues[':version'] = -1;
      return writes;
    });
  const subject = 'atomic-failure-student';
  const first = await failing.start(subject, quizzes[0].id, uuid(sequence++));
  const second = await failing.start(subject, quizzes[1].id, uuid(sequence++));
  await submit(subject, first);
  const scored = scoreAnswer(second.snapshot, { choiceId: second.snapshot.presentation.choiceIds[0] });
  await assert.rejects(failing.submit(subject, second.quizId, second.id, scored.answer, scored.fingerprint, scored.result), error => error.status === 409);
  assert.equal((await repo.getAttempt(subject, second.quizId, second.id)).status, 'started');
  assert.equal(Object.keys((await repo.progress(subject)).items[0].activeAttempt.questionAnswers).length, 1);
  assert.deepEqual(await ranking.me(subject), { entry: null });
  const committed = await submit(subject, second);
  assert.equal(committed.isReplay, false);
  assert.equal((await ranking.me(subject)).entry.completedQuizzesCount, 1);
});
test('DynamoDB Local page and own position reject updates interleaved with their read snapshot', async () => {
  const subject = 'interleaved-new-student';
  const first = await repo.start(subject, quizzes[0].id, uuid(sequence++));
  const second = await repo.start(subject, quizzes[1].id, uuid(sequence++));
  await submit(subject, first);
  let mutatePage = true;
  const pageClient = { async send(command) {
    if (mutatePage && command.constructor.name === 'QueryCommand' && command.input.ExpressionAttributeValues?.[':global']) {
      mutatePage = false;
      await submit(subject, second);
    }
    return client.send(command);
  } };
  await assert.rejects(new DynamoRankingRepository(pageClient, privateTable).list(), error => error.status === 409);
  let mutateMine = true;
  const mineClient = { async send(command) {
    if (mutateMine && command.constructor.name === 'TransactGetCommand') {
      mutateMine = false;
      await repo.retry(subject, quizzes[0].areaId, quizzes[0].topicId, uuid(sequence++), 1);
      await complete(subject, 2);
    }
    return client.send(command);
  } };
  await assert.rejects(new DynamoRankingRepository(mineClient, privateTable).me(subject), error => error.status === 409);
  const current = await ranking.me(subject);
  assert.equal(current.entry.completedQuizzesCount, 2);
  const page = await ranking.list();
  assert.equal(current.entry.rank, page.items.find(item => item.publicId === current.entry.publicId).rank);
});
