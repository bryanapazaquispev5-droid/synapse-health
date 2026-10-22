import { test } from 'node:test';
import assert from 'node:assert/strict';
import { DynamoFlashcardRepository } from '../dist/flashcards/repository.js';
import { encodeLocator, flashcardKey } from '../dist/flashcards/model.js';

const uuid = '01020304-0506-4708-890a-0b0c0d0e0f10';
const id = encodeLocator(['test-area', uuid]);
const input = { areaId: 'test-area', topicId: 'test-topic', title: 'Test fixture', summary: '', contentMarkdown: 'Fixture only',
  keyPoints: [], mnemonics: [], readDurationInMinutes: 2, isPremium: false, sourceBook: '' };
const record = { ...input, id, version: 1, createdAt: '2026-01-01T00:00:00.000Z', updatedAt: '2026-01-01T00:00:00.000Z' };
const stored = { ...record, ...flashcardKey(id), entityType: 'FLASHCARD' };
function repository(responses = [], table = 'test-content') {
  const calls = [];
  const client = { async send(command) {
    calls.push(command);
    const next = responses.shift() ?? {};
    if (next instanceof Error) throw next;
    return next;
  } };
  return { repo: new DynamoFlashcardRepository(client, table, () => new Date('2026-01-02T00:00:00Z'), () => uuid), calls };
}
const errorWithStatus = status => error => error.status === status;
const conflict = () => Object.assign(new Error('Internal conditional detail'), { name: 'ConditionalCheckFailedException' });

test('create stores real model fields with server metadata and no index dependency', async () => {
  const { repo, calls } = repository();
  const result = await repo.create(input);
  assert.equal(result.id, id);
  assert.equal(result.version, 1);
  assert.equal(result.createdAt, '2026-01-02T00:00:00.000Z');
  assert.deepEqual(calls[0].input.Item, { ...result, ...flashcardKey(id), entityType: 'FLASHCARD' });
  assert.equal(calls[0].input.ConditionExpression, 'attribute_not_exists(#pk)');
});
test('get uses strongly consistent direct key and omits internal keys', async () => {
  const { repo, calls } = repository([{ Item: stored }]);
  assert.deepEqual(await repo.get(id), record);
  assert.deepEqual(calls[0].input.Key, flashcardKey(id));
  assert.equal(calls[0].input.ConsistentRead, true);
});
test('get missing record reports 404', async () => {
  await assert.rejects(repository().repo.get(id), errorWithStatus(404));
});
test('invalid opaque locator is rejected before reading', async () => {
  const { repo, calls } = repository();
  for (const invalid of ['bad', `${id}=`, encodeLocator(['area']), encodeLocator(['area', 'not-uuid'])]) {
    await assert.rejects(repo.get(invalid), errorWithStatus(400));
  }
  assert.equal(calls.length, 0);
});
test('list queries bounded area partition instead of scanning', async () => {
  const { repo, calls } = repository([{ Items: [stored] }]);
  assert.deepEqual(await repo.list('test-area', { limit: 10 }), { items: [record], nextCursor: null });
  assert.equal(calls[0].constructor.name, 'QueryCommand');
  assert.equal(calls[0].input.Limit, 10);
  assert.equal(calls[0].input.ExpressionAttributeValues[':area'], 'AREA#test-area');
});
test('filtered empty pages preserve continuation and topic binding', async () => {
  const { repo, calls } = repository([{ Items: [], LastEvaluatedKey: flashcardKey(id) }, {}]);
  const first = await repo.list('test-area', { topicId: 'test-topic', limit: 1 });
  assert.deepEqual(first.items, []);
  assert.ok(first.nextCursor);
  await repo.list('test-area', { topicId: 'test-topic', cursor: first.nextCursor });
  assert.deepEqual(calls[1].input.ExclusiveStartKey, flashcardKey(id));
  await assert.rejects(repo.list('test-area', { topicId: 'different', cursor: first.nextCursor }), errorWithStatus(400));
  await assert.rejects(repo.list('different', { topicId: 'test-topic', cursor: first.nextCursor }), errorWithStatus(400));
});
test('list rejects unbounded limits and invalid catalog/cursor values', async () => {
  const { repo, calls } = repository();
  for (const limit of [0, 51, 1.5, NaN]) await assert.rejects(repo.list('test-area', { limit }), errorWithStatus(400));
  await assert.rejects(repo.list('area/path'), errorWithStatus(400));
  await assert.rejects(repo.list('test-area', { cursor: encodeLocator(['test-area', null, 'AREA#other', 'FLASHCARD#bad']) }), errorWithStatus(400));
  assert.equal(calls.length, 0);
});
test('update preserves identity and created date and conditions expected version', async () => {
  const { repo, calls } = repository([{ Item: stored }, {}]);
  const result = await repo.update(id, { title: 'Updated fixture' }, 1);
  assert.equal(result.title, 'Updated fixture');
  assert.equal(result.createdAt, record.createdAt);
  assert.equal(result.updatedAt, '2026-01-02T00:00:00.000Z');
  assert.equal(result.version, 2);
  assert.equal(calls[1].input.ExpressionAttributeValues[':version'], 1);
});
test('stale update fails with 409 before writing', async () => {
  const { repo, calls } = repository([{ Item: { ...stored, version: 2 } }]);
  await assert.rejects(repo.update(id, { title: 'Updated' }, 1), errorWithStatus(409));
  assert.equal(calls.length, 1);
});
test('concurrent update conflict remains 409 and concurrent deletion becomes 404', async () => {
  const first = repository([{ Item: stored }, conflict(), { Item: { ...stored, version: 2 } }]);
  await assert.rejects(first.repo.update(id, { title: 'Updated' }, 1), errorWithStatus(409));
  const second = repository([{ Item: stored }, conflict(), {}]);
  await assert.rejects(second.repo.update(id, { title: 'Updated' }, 1), errorWithStatus(404));
});
test('delete conditions version and separates absent record from stale version', async () => {
  const { repo, calls } = repository();
  await repo.delete(id, 1);
  assert.equal(calls[0].constructor.name, 'DeleteCommand');
  assert.equal(calls[0].input.ExpressionAttributeValues[':version'], 1);
  await assert.rejects(repository([conflict(), { Item: stored }]).repo.delete(id, 2), errorWithStatus(409));
  await assert.rejects(repository([conflict(), {}]).repo.delete(id, 1), errorWithStatus(404));
});
test('invalid versions and missing configuration fail closed', async () => {
  const { repo, calls } = repository();
  for (const version of [0, 1.5, Number.MAX_SAFE_INTEGER]) {
    await assert.rejects(repo.update(id, {}, version), errorWithStatus(400));
    await assert.rejects(repo.delete(id, version), errorWithStatus(400));
  }
  assert.equal(calls.length, 0);
  await assert.rejects(repository([], '').repo.get(id), errorWithStatus(503));
});
test('DynamoDB errors propagate to centralized error handling', async () => {
  const internal = new Error('Do not expose this SDK detail');
  await assert.rejects(repository([internal]).repo.get(id), error => error === internal);
  await assert.rejects(repository([{ Item: stored }, internal]).repo.update(id, {}, 1), error => error === internal);
});

test('create maps a conditional UUID collision to409 without overwriting', async () => {
  const { repo, calls } = repository([conflict()]);
  await assert.rejects(repo.create(input), errorWithStatus(409));
  assert.equal(calls.length, 1);
});
