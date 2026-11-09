import {test} from 'node:test';
import assert from 'node:assert/strict';
import {ListTablesCommand} from '@aws-sdk/client-dynamodb';
import {ScanCommand} from '@aws-sdk/lib-dynamodb';
import {ListUsersCommand} from '@aws-sdk/client-cognito-identity-provider';
import {createAwsReader} from '../admin/aws-reader.mjs';
import {createAdminServer} from '../admin/server.mjs';

function cursorFor(value) {
  return Buffer.from(JSON.stringify(value)).toString('base64url');
}

test('lists every DynamoDB table through SDK pagination', async () => {
  const dynamo = {async send(command) {
    assert.ok(command instanceof ListTablesCommand);
    return command.input.ExclusiveStartTableName
      ? {TableNames: ['table-b']}
      : {TableNames: ['table-a'], LastEvaluatedTableName: 'table-a'};
  }};
  const reader = createAwsReader({region: 'us-east-2', dynamo, cognito: {}});
  assert.deepEqual(await reader.listTables(), ['table-a', 'table-b']);
});

test('scans one bounded page, returns a cursor, and rejects unknown tables', async () => {
  let scanInput;
  const dynamo = {async send(command) {
    if (command instanceof ListTablesCommand) return {TableNames: ['app-table']};
    assert.ok(command instanceof ScanCommand);
    scanInput = command.input;
    return {Items: [{PK: 'COLLECTION#leaderboard', SK: 'DOC#user'}],
      LastEvaluatedKey: {PK: 'next'}, ConsumedCapacity: {CapacityUnits: 1.5}};
  }};
  const reader = createAwsReader({dynamo, cognito: {}});
  const page = await reader.scanTable('app-table', cursorFor({PK: 'previous'}));
  assert.equal(scanInput.Limit, 25);
  assert.deepEqual(scanInput.ExclusiveStartKey, {PK: 'previous'});
  assert.equal(scanInput.ReturnConsumedCapacity, 'TOTAL');
  assert.equal(page.consumedCapacity, 1.5);
  assert.deepEqual(JSON.parse(Buffer.from(page.nextCursor, 'base64url')), {PK: 'next'});
  await assert.rejects(reader.scanTable('other-table'), error => error.statusCode === 404);
});

test('lists users across pages and returns only minimal account fields', async () => {
  let page = 0;
  const cognito = {async send(command) {
    assert.ok(command instanceof ListUsersCommand);
    assert.equal(command.input.Limit, 60);
    page++;
    if (page === 1) return {Users: [{Username: 'u1', UserStatus: 'CONFIRMED', Enabled: true,
      UserCreateDate: new Date('2026-01-01'), Attributes: [
        {Name: 'sub', Value: 'subject-1'}, {Name: 'email', Value: 'user@example.test'},
        {Name: 'phone_number', Value: '+100000000'}, {Name: 'email_verified', Value: 'true'},
      ]}], PaginationToken: 'next'};
    return {Users: [{Username: 'u2', Attributes: [{Name: 'sub', Value: 'subject-2'}]}]};
  }};
  const reader = createAwsReader({dynamo: {}, cognito});
  const result = await reader.listUsers();
  assert.equal(page, 2);
  assert.equal(result.users.length, 2);
  assert.equal(result.users[0].email, 'user@example.test');
  assert.equal(result.users[0].emailVerified, true);
  assert.equal(JSON.stringify(result).includes('phone_number'), false);
});

test('local server serves the panel read-only and rejects cross-origin access', async t => {
  const calls = [];
  const server = createAdminServer({reader: {
    region: 'us-east-2',
    async listTables() { calls.push('tables'); return ['app-table']; },
    async listUsers() { calls.push('users'); return {users: [], hasMore: false}; },
    async scanTable(name) { calls.push(`scan:${name}`); return {tableName: name, items: [], nextCursor: null, consumedCapacity: 0}; },
  }});
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  t.after(() => new Promise(resolve => server.close(resolve)));
  const address = server.address();
  const baseUrl = `http://127.0.0.1:${address.port}`;
  const panel = await fetch(baseUrl);
  assert.equal(panel.status, 200);
  assert.match(panel.headers.get('content-security-policy'), /frame-ancestors 'none'/);
  const markup = await panel.text();
  assert.match(markup, /id="table-menu-toggle"[^>]*>Tablas/);
  assert.match(markup, /id="selected-table-name"/);
  assert.equal((await fetch(`${baseUrl}/api/tables`)).status, 200);
  assert.equal((await fetch(`${baseUrl}/api/users`)).status, 200);
  assert.equal((await fetch(`${baseUrl}/api/tables/app-table/items`)).status, 200);
  const denied = await fetch(`${baseUrl}/api/users`, {headers: {Origin: 'https://outside.example'}});
  assert.equal(denied.status, 403);
  assert.equal((await fetch(`${baseUrl}/api/anything`, {method: 'POST'})).status, 405);
  assert.deepEqual(calls, ['tables', 'users', 'scan:app-table']);
});
