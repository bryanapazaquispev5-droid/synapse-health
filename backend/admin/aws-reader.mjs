import {CognitoIdentityProviderClient, ListUsersCommand} from '@aws-sdk/client-cognito-identity-provider';
import {DynamoDBClient, ListTablesCommand} from '@aws-sdk/client-dynamodb';
import {DynamoDBDocumentClient, ScanCommand} from '@aws-sdk/lib-dynamodb';

const tablePageSize = 100;
const itemPageSize = 25;
const userPageSize = 60;
const displayedUserLimit = 600;

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
  userPoolId = process.env.SYNAPSE_COGNITO_USER_POOL_ID || 'us-east-2_E0h8t6hhE',
  userProfilesTableName = process.env.USER_PROFILES_TABLE_NAME || 'synapse-health-backend-user-profiles',
  dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({region})),
  cognito = new CognitoIdentityProviderClient({region}),
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
    const dynamoUsers = [];
    try {
      if (typeof dynamo?.send === 'function') {
        const scan = await dynamo.send(new ScanCommand({
          TableName: userProfilesTableName,
          FilterExpression: 'SK = :sk',
          ExpressionAttributeValues: {':sk': 'PROFILE'},
          Limit: displayedUserLimit,
        }));
        for (const item of scan.Items ?? []) {
          dynamoUsers.push({
            id: item.uid || item.sub || (typeof item.PK === 'string' ? item.PK.replace('USER#', '') : ''),
            email: item.email || '',
            name: item.name || '',
            career: item.career || 'General Medicine',
            gender: item.gender || 'Male',
            emailVerified: true,
            status: 'CONFIRMED',
            enabled: true,
            createdAt: item.createdAt || null,
            provider: item.authProvider || 'dynamodb',
          });
        }
      }
    } catch (_) {}

    const cognitoUsers = [];
    if (/^us-east-\d_[A-Za-z0-9]+$/.test(userPoolId) && typeof cognito?.send === 'function') {
      try {
        let paginationToken;
        do {
          const page = await cognito.send(new ListUsersCommand({
            UserPoolId: userPoolId,
            Limit: userPageSize,
            PaginationToken: paginationToken,
          }));
          for (const user of page.Users ?? []) {
            const attrs = Object.fromEntries((user.Attributes ?? []).map(({Name, Value}) => [Name, Value]));
            cognitoUsers.push({
              id: attrs.sub ?? user.Username ?? '',
              email: attrs.email ?? '',
              name: attrs.name ?? '',
              emailVerified: attrs.email_verified === 'true',
              status: user.UserStatus ?? 'CONFIRMED',
              enabled: user.Enabled ?? true,
              createdAt: user.UserCreateDate ?? null,
              provider: 'cognito',
            });
          }
          paginationToken = page.PaginationToken;
        } while (paginationToken && cognitoUsers.length < displayedUserLimit);
      } catch (_) {}
    }

    const seen = new Set();
    const combined = [];
    for (const u of [...dynamoUsers, ...cognitoUsers]) {
      const key = u.email || u.id;
      if (key && !seen.has(key)) {
        seen.add(key);
        combined.push(u);
      }
    }
    combined.sort((a, b) => new Date(b.createdAt ?? 0) - new Date(a.createdAt ?? 0));
    return {users: combined, totalCount: combined.length, hasMore: false, userPoolId};
  }

  return {region, listTables, scanTable, listUsers};
}
