import test from 'node:test';
import assert from 'node:assert/strict';
import { createHash, randomUUID } from 'node:crypto';
import { DynamoDBClient, CreateTableCommand, DeleteTableCommand } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand } from '@aws-sdk/lib-dynamodb';
import { createDynamoRateLimiter } from '../dist/flashcards/runtime.js';

test('DynamoDB Local: distributed quota, isolated subjects, window reset and TTL', async () => {
  const endpoint = process.env.DYNAMODB_LOCAL_ENDPOINT ?? 'http://127.0.0.1:8000';
  const url = new URL(endpoint);
  assert.ok(['127.0.0.1', 'localhost'].includes(url.hostname) && url.protocol === 'http:', 'Local integration never contacts AWS');
  const raw = new DynamoDBClient({endpoint, region: 'us-east-1', credentials: {accessKeyId: 'local', secretAccessKey: 'local'}, maxAttempts: 1});
  const client = DynamoDBDocumentClient.from(raw);
  const table = `synapse-rate-test-${randomUUID()}`;
  let created = false;
  try {
    await raw.send(new CreateTableCommand({TableName: table, BillingMode: 'PAY_PER_REQUEST',
      KeySchema: [{AttributeName: 'PK', KeyType: 'HASH'}, {AttributeName: 'SK', KeyType: 'RANGE'}],
      AttributeDefinitions: [{AttributeName: 'PK', AttributeType: 'S'}, {AttributeName: 'SK', AttributeType: 'S'}]}));
    created = true;
    let now = 61000;
    const limiter = createDynamoRateLimiter(client, table, () => now);
    const results = await Promise.allSettled(Array.from({length: 61}, () => limiter.consume('local-owner')));
    assert.equal(results.filter(result => result.status === 'fulfilled').length, 60);
    const failure = results.find(result => result.status === 'rejected');
    assert.equal(failure.reason.status, 429); assert.equal(failure.reason.headers['Retry-After'], '59');
    await limiter.consume('other-local-owner');
    const PK = `RATE#${createHash('sha256').update('local-owner').digest('hex')}`;
    const saved = await client.send(new GetCommand({TableName: table, Key: {PK, SK: 'WINDOW#60'}, ConsistentRead: true}));
    assert.equal(saved.Item.count, 60); assert.equal(saved.Item.expiresAt, 180);
    now = 120000;
    await limiter.consume('local-owner');
    const reset = await client.send(new GetCommand({TableName: table, Key: {PK, SK: 'WINDOW#120'}, ConsistentRead: true}));
    assert.equal(reset.Item.count, 1); assert.equal(reset.Item.expiresAt, 240);
  } finally {
    if (created) await raw.send(new DeleteTableCommand({TableName: table}));
    raw.destroy();
  }
});
