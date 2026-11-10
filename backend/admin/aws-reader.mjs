import {DynamoDBClient, ListTablesCommand} from '@aws-sdk/client-dynamodb';
import {DynamoDBDocumentClient, ScanCommand} from '@aws-sdk/lib-dynamodb';

const tablePageSize = 100;
const itemPageSize = 25;
const displayedUserLimit = 2000;

function decodeCursor(cursor) {
  if (!cursor) return undefined;
  if (cursor.length > 8192) throw new Error('Invalid cursor');
  const value = JSON.parse(Buffer.from(cursor, 'base64url').toString('utf8'));
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error('Invalid cursor');
  }
  return value;
}

function encodeCursor(key) {
  return key ? Buffer.from(JSON.stringify(key)).toString('base64url') : null;
}

export function createAwsReader({
  region = process.env.AWS_REGION || 'us-east-2',
  userProfilesTableName = process.env.USER_PROFILES_TABLE_NAME || 'synapse-health-backend-user-profiles',
  dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({region})),
} = {}) {
  async function listTables() {
    const tableNames = [];
    let startTableName;
    do {
      const page = await dynamo.send(new ListTablesCommand({
        ExclusiveStartTableName: startTableName,
        Limit: tablePageSize,
      }));
      tableNames.push(...(page.TableNames ?? []));
      startTableName = page.LastEvaluatedTableName;
    } while (startTableName);
    return tableNames.sort((left, right) => left.localeCompare(right));
  }

  async function scanTable(tableName, cursor) {
    if (!(await listTables()).includes(tableName)) {
      const error = new Error('Unknown table');
      error.statusCode = 404;
      throw error;
    }
    const page = await dynamo.send(new ScanCommand({
      TableName: tableName,
      Limit: itemPageSize,
      ExclusiveStartKey: decodeCursor(cursor),
      ReturnConsumedCapacity: 'TOTAL',
    }));
    return {
      tableName,
      items: page.Items ?? [],
      nextCursor: encodeCursor(page.LastEvaluatedKey),
      consumedCapacity: page.ConsumedCapacity?.CapacityUnits ?? 0,
    };
  }

  async function listUsers() {
    const users = [];
    let hasMore = false;
    if (typeof dynamo?.send === 'function') {
      try {
        let lastEvaluatedKey;
        do {
          const scan = await dynamo.send(new ScanCommand({
            TableName: userProfilesTableName,
            FilterExpression: 'SK = :sk',
            ExpressionAttributeValues: {':sk': 'PROFILE'},
            ExclusiveStartKey: lastEvaluatedKey,
            Limit: 1000,
          }));
          for (const item of scan.Items ?? []) {
            users.push({
              id: item.uid || item.sub || (typeof item.PK === 'string' ? item.PK.replace('USER#', '') : ''),
              email: item.email || '',
              name: item.name || '',
              career: item.career || 'General Medicine',
              gender: item.gender || 'Male',
              status: 'ACTIVE',
              createdAt: item.createdAt || null,
              provider: 'DynamoDB',
            });
            if (users.length >= displayedUserLimit) break;
          }
          lastEvaluatedKey = scan.LastEvaluatedKey;
        } while (lastEvaluatedKey && users.length < displayedUserLimit);
        hasMore = Boolean(lastEvaluatedKey);
      } catch (_) {}
    }
    users.sort((a, b) => new Date(b.createdAt ?? 0) - new Date(a.createdAt ?? 0));
    return {users, totalCount: users.length, hasMore};
  }

  return {region, listTables, scanTable, listUsers};
}
