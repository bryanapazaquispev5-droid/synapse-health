import {CognitoIdentityProviderClient, ListUsersCommand} from '@aws-sdk/client-cognito-identity-provider';
import {DynamoDBClient, ListTablesCommand} from '@aws-sdk/client-dynamodb';
import {DynamoDBDocumentClient, ScanCommand} from '@aws-sdk/lib-dynamodb';

const tablePageSize = 100;
const itemPageSize = 25;
const userPageSize = 60;
const maxUserPages = 10;

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
  userPoolId = process.env.SYNAPSE_COGNITO_USER_POOL_ID || 'us-east-2_p48zTpxun',
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
    if (!/^us-east-\d_[A-Za-z0-9]+$/.test(userPoolId)) {
      throw new Error('Invalid Cognito user pool configuration');
    }
    const users = [];
    let paginationToken;
    let pageCount = 0;
    do {
      const page = await cognito.send(new ListUsersCommand({
        UserPoolId: userPoolId,
        Limit: userPageSize,
        PaginationToken: paginationToken,
      }));
      for (const user of page.Users ?? []) {
        const attributes = Object.fromEntries(
          (user.Attributes ?? []).map(({Name, Value}) => [Name, Value]),
        );
        users.push({
          id: attributes.sub ?? user.Username ?? '',
          email: attributes.email ?? '',
          name: attributes.name ?? '',
          emailVerified: attributes.email_verified === 'true',
          status: user.UserStatus ?? 'UNKNOWN',
          enabled: user.Enabled ?? false,
          createdAt: user.UserCreateDate ?? null,
        });
      }
      paginationToken = page.PaginationToken;
      pageCount++;
    } while (paginationToken && pageCount < maxUserPages);
    users.sort((left, right) =>
      new Date(right.createdAt ?? 0) - new Date(left.createdAt ?? 0),
    );
    return {users, hasMore: Boolean(paginationToken), userPoolId};
  }

  return {region, listTables, scanTable, listUsers};
}
