import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { DynamoDBClient, CreateTableCommand, DeleteTableCommand } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';
import { DynamoFlashcardRepository } from '../dist/flashcards/repository.js';

const endpoint = process.env.DYNAMODB_LOCAL_ENDPOINT;
if (!endpoint || !/^http:\/\/127\.0\.0\.1:\d+$/.test(endpoint)) {
  throw new Error('Set DYNAMODB_LOCAL_ENDPOINT to the loopback DynamoDB Local server.');
}
const client = new DynamoDBClient({ endpoint, region: 'us-east-1', credentials: { accessKeyId: 'local', secretAccessKey: 'local' } });
const tableName = `synapse-local-flashcards-${process.pid}`;
const repository = new DynamoFlashcardRepository(DynamoDBDocumentClient.from(client), tableName);
let created = false;
after(async () => {
  if (created) await client.send(new DeleteTableCommand({ TableName: tableName }));
  client.destroy();
});
const input = { areaId: 'fixture-area', topicId: 'fixture-topic', title: 'Local fixture', summary: '',
  contentMarkdown: 'Integration fixture only', keyPoints: [], mnemonics: [],
  readDurationInMinutes: 2, isPremium: false, sourceBook: '' };
test('actual DynamoDB Local supports CRUD, filtered paging and conditional concurrent writes', async () => {
  await client.send(new CreateTableCommand({ TableName: tableName, BillingMode: 'PAY_PER_REQUEST',
    AttributeDefinitions: [{ AttributeName: 'PK', AttributeType: 'S' }, { AttributeName: 'SK', AttributeType: 'S' }],
    KeySchema: [{ AttributeName: 'PK', KeyType: 'HASH' }, { AttributeName: 'SK', KeyType: 'RANGE' }] }));
  created = true;
  const first = await repository.create(input);
  const second = await repository.create({ ...input, topicId: 'other-topic' });
  assert.deepEqual(await repository.get(first.id), first);
  let cursor = null;
  const selected = [];
  do {
    const page = await repository.list(input.areaId, { limit: 1, topicId: input.topicId, cursor });
    selected.push(...page.items);
    cursor = page.nextCursor;
  } while (cursor);
  assert.deepEqual(selected.map(item => item.id), [first.id]);
  const writes = await Promise.allSettled([
    repository.update(first.id, { title: 'First writer' }, 1),
    repository.update(first.id, { title: 'Second writer' }, 1),
  ]);
  assert.equal(writes.filter(result => result.status === 'fulfilled').length, 1);
  assert.equal(writes.find(result => result.status === 'rejected').reason.status, 409);
  const updated = await repository.get(first.id);
  assert.equal(updated.version, 2);
  await assert.rejects(repository.delete(first.id, 1), error => error.status === 409);
  await repository.delete(first.id, 2);
  await assert.rejects(repository.get(first.id), error => error.status === 404);
  await assert.rejects(repository.delete(first.id, 2), error => error.status === 404);
  await repository.delete(second.id, 1);
  assert.deepEqual((await repository.list(input.areaId)).items, []);
});
