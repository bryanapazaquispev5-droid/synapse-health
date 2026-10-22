import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { createServer } from 'node:http';
import { DynamoDBClient, CreateTableCommand, DeleteTableCommand } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';
import { DynamoFlashcardRepository } from '../dist/flashcards/repository.js';
import { createFlashcardHandler } from '../dist/flashcards/controller.js';
import { ApiError } from '../dist/http.mjs';
const endpoint = process.env.DYNAMODB_LOCAL_ENDPOINT;
if (!endpoint || !/^http:\/\/127\.0\.0\.1:\d+$/.test(endpoint)) throw new Error('DynamoDB Local loopback endpoint required.');
const client = new DynamoDBClient({ endpoint, region: 'us-east-1', credentials: { accessKeyId: 'local', secretAccessKey: 'local' } });
const tableName = `synapse-local-http-${process.pid}`;
const handler = createFlashcardHandler({
  repository: new DynamoFlashcardRepository(DynamoDBDocumentClient.from(client), tableName),
  // Transport fixture only; real signed JWT validation is covered separately.
  verifyCognitoToken: async token => {
    if (!['admin-fixture', 'student-fixture'].includes(token)) throw new ApiError(401, 'unauthenticated', 'Authentication required.');
    return { sub: token, groups: token === 'admin-fixture' ? ['admins'] : [] };
  },
});
let created = false;
const server = createServer(async (request, reply) => {
  try {
    const chunks = [];
    for await (const chunk of request) chunks.push(chunk);
    const url = new URL(request.url, 'http://127.0.0.1');
    const result = await handler({ path: url.pathname, httpMethod: request.method, headers: request.headers,
      queryStringParameters: Object.fromEntries(url.searchParams), body: chunks.length ? Buffer.concat(chunks).toString() : null,
      requestContext: { requestId: 'local-http' } });
    reply.writeHead(result.statusCode, result.headers); reply.end(result.body);
  } catch { reply.writeHead(500); reply.end(); }
});
after(async () => {
  if (server.listening) await new Promise(resolve => server.close(resolve));
  if (created) await client.send(new DeleteTableCommand({ TableName: tableName }));
  client.destroy();
});
test('loopback REST CRUD persists to actual DynamoDB Local and enforces roles and versions', async () => {
  await client.send(new CreateTableCommand({ TableName: tableName, BillingMode: 'PAY_PER_REQUEST',
    AttributeDefinitions: [{ AttributeName: 'PK', AttributeType: 'S' }, { AttributeName: 'SK', AttributeType: 'S' }],
    KeySchema: [{ AttributeName: 'PK', KeyType: 'HASH' }, { AttributeName: 'SK', KeyType: 'RANGE' }] })); created = true;
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  const base = `http://127.0.0.1:${server.address().port}`;
  const send = (path, method = 'GET', token = 'student-fixture', body, version) => fetch(base + path, {
    method, headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json', ...(version ? { 'If-Match': `"${version}"` } : {}) },
    ...(body ? { body: JSON.stringify(body) } : {}),
  });
  const path = '/api/v1/flashcards';
  const input = { areaId: 'fixture-area', topicId: 'fixture-topic', title: 'Nonclinical fixture', contentMarkdown: 'Local test only' };
  assert.equal((await send(path, 'POST', 'student-fixture', input)).status, 403);
  assert.equal((await send(path + '?areaId=fixture-area', 'GET', 'invalid')).status, 401);
  assert.equal((await send(path, 'POST', 'admin-fixture', { ...input, role: 'admin' })).status, 400);
  const creation = await send(path, 'POST', 'admin-fixture', input); assert.equal(creation.status, 201);
  assert.equal(creation.headers.get('etag'), '"1"');
  const item = (await creation.json()).data; const detail = `${path}/${item.id}`;
  const list = await send(path + '?areaId=fixture-area&limit=1'); assert.equal(list.status, 200);
  assert.equal((await list.json()).data.items[0].id, item.id);
  assert.equal((await send(detail)).status, 200);
  assert.equal((await send(detail, 'PATCH', 'student-fixture', { title: 'Denied' }, 1)).status, 403);
  const update = await send(detail, 'PATCH', 'admin-fixture', { title: 'Updated fixture' }, 1);
  assert.equal(update.status, 200); assert.equal(update.headers.get('etag'), '"2"');
  assert.equal((await send(detail, 'PATCH', 'admin-fixture', { title: 'Stale' }, 1)).status, 409);
  assert.equal((await send(detail, 'DELETE', 'student-fixture', undefined, 2)).status, 403);
  assert.equal((await send(detail, 'DELETE', 'admin-fixture', undefined, 1)).status, 409);
  const deletion = await send(detail, 'DELETE', 'admin-fixture', undefined, 2);
  assert.equal(deletion.status, 204); assert.equal(await deletion.text(), '');
  assert.equal((await send(detail)).status, 404);
});
