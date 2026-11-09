import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createStore} from '../src/aws/store.mjs';
function fixture(result = {}) {
  const commands = [];
  const client = {async send(command) { commands.push(command); if (result instanceof Error) throw result; return result; }};
  return {commands, store: createStore({env: {SYNAPSE_TABLE_NAME: 'synthetic-table'}, client})};
}
test('DynamoDB stores owner progress and leaderboard in separate tables transactionally', async () => {
  const {store, commands} = fixture();
  const leaderboard = createStore({env: {SYNAPSE_TABLE_NAME: 'leaderboard-table'}, client: storeClient(commands)});
  await store.put({PK: 'USER#a', SK: 'TOPIC#t', data: {updatedAt: 'now'}}, 3,
    [{item: {PK: 'LEADERBOARD', SK: 'USER#a', data: {totalStars: 4}}, expectedVersion: 7, store: leaderboard}]);
  assert.equal(commands[0].constructor.name, 'TransactWriteCommand');
  const writes = commands[0].input.TransactItems;
  assert.equal(writes.length, 2);
  assert.equal(writes[0].Put.TableName, 'synthetic-table');
  assert.equal(writes[1].Put.TableName, 'leaderboard-table');
  assert.equal(writes[0].Put.Item.version, 4); assert.equal(writes[1].Put.Item.version, 8);
  assert.equal(writes[0].Put.Item.updatedAt, 'now');
  assert.equal(writes[0].Put.Item.data, undefined);
  assert.equal(writes[0].Put.ExpressionAttributeValues[':v'], 3);
  assert.equal(writes[1].Put.ExpressionAttributeValues[':v'], 7);
});
test('DynamoDB conditional transaction conflicts are retryable without leaking service errors', async () => {
  const failure = Object.assign(new Error('private service fields'), {name: 'TransactionCanceledException', CancellationReasons: [{Code: 'ConditionalCheckFailed'}]});
  const {store} = fixture(failure);
  await assert.rejects(store.put({PK: 'OWNER#a', SK: 'PROFILE'}, 2), error => error.status === 409 && !error.message.includes('private'));
});
test('query cursors cannot change the partition and rate limiting is server conditional', async () => {
  const {store, commands} = fixture({Items: []});
  await store.list('USER#a', 'TOPIC#', {});
  assert.equal(commands[0].input.ConsistentRead, true);
  assert.ok(!commands[0].input.IndexName);
  await store.consume('synthetic-subject', Date.parse('2026-10-22T12:00:00Z'));
  assert.equal(commands[1].constructor.name, 'UpdateCommand');
  assert.equal(commands[1].input.Key.SK, `WINDOW#${Math.floor(Date.parse('2026-10-22T12:00:00Z') / 60000)}`);
  assert.equal(commands[1].input.ConditionExpression, 'attribute_not_exists(#count) OR #count < :limit');
});
test('catalog queries can use eventual consistency while state queries stay strongly consistent by default', async () => {
  const {store, commands} = fixture({Items: []});
  await store.list('AREA#catalog', 'TOPIC#', {consistentRead: false});
  await store.list('USER#owner', 'TOPIC#');
  assert.equal(commands[0].input.ConsistentRead, false);
  assert.equal(commands[1].input.ConsistentRead, true);
});
test('catalog item reads can be eventually consistent while user state item reads stay strong', async () => {
  const {store, commands} = fixture({Item: {PK: 'AREA#catalog', SK: 'TOPIC#question'}});
  await store.get('AREA#catalog', 'TOPIC#question', {consistentRead: false});
  await store.get('USER#owner', 'PROFILE');
  assert.equal(commands[0].input.ConsistentRead, false);
  assert.equal(commands[1].input.ConsistentRead, true);
});
test('flat DynamoDB attributes are reconstructed as the API data object', async () => {
  const {store, commands} = fixture({Item: {PK: 'AREA#a', SK: 'AREA#a', name: 'Anatomy', version: 2}});
  const item = await store.get('AREA#a', 'AREA#a');
  assert.equal(item.data.name, 'Anatomy');
  assert.equal(item.version, 2);
  assert.equal(commands[0].input.TableName, 'synthetic-table');
});
test('catalog delete checks the current version before removing a record', async () => {
  const {store, commands} = fixture();
  await store.remove('AREA#a', 'TOPIC#t', 4);
  assert.equal(commands[0].constructor.name, 'DeleteCommand');
  assert.equal(commands[0].input.ConditionExpression, '#v = :v');
  assert.equal(commands[0].input.ExpressionAttributeValues[':v'], 4);
});
test('catalog delete reports a conflict when the record changed', async () => {
  const failure = Object.assign(new Error('private service fields'), {name: 'ConditionalCheckFailedException'});
  const {store} = fixture(failure);
  await assert.rejects(store.remove('AREA#a', 'TOPIC#t', 4), error => error.status === 409);
});
test('missing table configuration fails before credential resolution', async () => {
  await assert.rejects(createStore({env: {}}).get('OWNER#a', 'PROFILE'), error => error.status === 503);
  await assert.rejects(createStore({env: {SYNAPSE_TABLE_NAME: 'legacy'}, tableName: undefined}).get('USER#a', 'PROFILE'), error => error.status === 503);
});

function storeClient(commands) {
  return {async send(command) { commands.push(command); return {}; }};
}
