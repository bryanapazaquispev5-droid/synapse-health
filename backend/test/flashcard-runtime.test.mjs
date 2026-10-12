import test from 'node:test';
import assert from 'node:assert/strict';
import { createDynamoRateLimiter } from '../dist/flashcards/runtime.js';
const fixture = (failure, now = () => 61000) => {
  const calls = [];
  const limiter = createDynamoRateLimiter({ send: async command => { calls.push(command.input); if (failure) throw failure; return {}; } }, 'content-table', now);
  return { calls, limiter };
};
test('distributed limit uses atomic conditional increment with hashed subject and TTL', async () => {
  const { calls, limiter } = fixture(); await limiter.consume('private-subject');
  const command = calls[0]; assert.equal(command.TableName, 'content-table');
  assert.match(command.Key.PK, /^RATE#[a-f0-9]{64}$/); assert.equal(command.Key.SK, 'WINDOW#60');
  assert.equal(command.ExpressionAttributeValues[':limit'], 60); assert.equal(command.ExpressionAttributeValues[':expires'], 180);
  assert.equal(command.ExpressionAttributeValues[':one'], 1); assert.ok(!JSON.stringify(command).includes('private-subject'));
  assert.equal(command.ConditionExpression, 'attribute_not_exists(#count) OR #count < :limit');
});
test('window change selects independent atomic counter', async () => {
  let time = 59000; const { calls, limiter } = fixture(undefined, () => time);
  await limiter.consume('owner'); time = 60000; await limiter.consume('owner');
  assert.equal(calls[0].Key.SK, 'WINDOW#0'); assert.equal(calls[1].Key.SK, 'WINDOW#60');
});
test('conditional limit failure returns 429 and bounded retry delay', async () => {
  const error = Object.assign(new Error('sensitive'), { name: 'ConditionalCheckFailedException' });
  await assert.rejects(fixture(error).limiter.consume('owner'), failure => failure.status === 429 && failure.headers['Retry-After'] === '59' && !failure.message.includes('sensitive'));
});
test('Dynamo failure fails closed 503 without internals', async () => {
  await assert.rejects(fixture(new Error('sensitive')).limiter.consume('owner'), failure => failure.status === 503 && !failure.message.includes('sensitive'));
});
test('missing configuration prevents Dynamo requests', async () => {
  let calls = 0;
  const limiter = createDynamoRateLimiter({ send: async () => { calls++; } }, '');
  await assert.rejects(limiter.consume('owner'), error => error.status === 503); assert.equal(calls, 0);
});

test('custom limit is applied and invalid limits fail closed before SDK', async () => {
  const calls = []; const client = {send: async command => {calls.push(command.input);}};
  await createDynamoRateLimiter(client, 'table', () => 0, 5).consume('owner');
  assert.equal(calls[0].ExpressionAttributeValues[':limit'], 5);
  for (const quota of [0, -1, 1001, NaN, 1.5]) {
    await assert.rejects(createDynamoRateLimiter(client, 'table', () => 0, quota).consume('owner'), error => error.status === 503);
  }
  assert.equal(calls.length, 1);
});
