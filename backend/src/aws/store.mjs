import {DynamoDBClient} from '@aws-sdk/client-dynamodb';
import {DynamoDBDocumentClient, GetCommand, PutCommand, QueryCommand, DeleteCommand, UpdateCommand, TransactWriteCommand} from '@aws-sdk/lib-dynamodb';
import {ApiError} from '../http.mjs';
import {cursorKey, encodeCursor} from './validation.mjs';
const metadataFields = new Set(['PK', 'SK', 'version', 'answerHashes', 'lastRetry', 'expiresAt', 'count']);
const expandItem = item => {
  if (!item) return null;
  const data = Object.fromEntries(Object.entries(item).filter(([key]) => !metadataFields.has(key)));
  return {...item, data};
};
const flattenItem = item => {
  const {data = {}, ...metadata} = item;
  return {...metadata, ...data};
};

export function createStore(options = {}) {
  const {env = process.env, client} = options;
  let resolved = client;
  const table = Object.hasOwn(options, 'tableName') ? options.tableName : env.SYNAPSE_TABLE_NAME;
  function db() {
    if (!table) throw new ApiError(503, 'unavailable', 'AWS data service is not configured.');
    resolved ??= DynamoDBDocumentClient.from(new DynamoDBClient({region: env.AWS_REGION ?? 'us-east-2',
      maxAttempts: 3, requestHandler: {connectionTimeout: 2000, requestTimeout: 5000}}),
    {marshallOptions: {removeUndefinedValues: true}});
    return resolved;
  }
  const store = {
    // Busca un registro por sus claves de partición y ordenamiento.
    async get(PK, SK, {consistentRead = true} = {}) {
      return expandItem((await db().send(new GetCommand({TableName: table, Key: {PK, SK}, ConsistentRead: consistentRead}))).Item);
    },
    // Inserta o actualiza con control de versión para evitar sobrescribir cambios recientes.
    async put(item, expectedVersion = null, related = []) {
      if (Buffer.byteLength(JSON.stringify(item)) > 300000) throw new ApiError(413, 'record_too_large', 'This record exceeds the supported size.');
      try {
        const put = (value, version, targetTable = table) => ({TableName: targetTable, Item: {...flattenItem(value), version: (version ?? 0) + 1},
          ConditionExpression: version === null ? 'attribute_not_exists(PK)' : '#v = :v',
          ...(version === null ? {} : {ExpressionAttributeNames: {'#v': 'version'}, ExpressionAttributeValues: {':v': version}})});
        if (related.length) await db().send(new TransactWriteCommand({TransactItems: [
          {Put: put(item, expectedVersion)}, ...related.map(write => ({Put: put(write.item, write.expectedVersion, write.store?.tableName)})),
        ]}));
        else await db().send(new PutCommand(put(item, expectedVersion)));
      } catch (error) {
        if (error.name === 'ConditionalCheckFailedException' || (error.name === 'TransactionCanceledException' && error.CancellationReasons?.some(reason => reason.Code === 'ConditionalCheckFailed'))) throw new ApiError(409, 'conflict', 'The record changed. Reload and retry.');
        throw error;
      }
      return {...item, version: (expectedVersion ?? 0) + 1};
    },
    async list(PK, prefix, {limit = 100, cursor = null, consistentRead = true} = {}) {
      const output = await db().send(new QueryCommand({TableName: table,
        KeyConditionExpression: 'PK = :pk AND begins_with(SK, :prefix)',
        ExpressionAttributeValues: {':pk': PK, ':prefix': prefix},
        ExclusiveStartKey: cursorKey(cursor, PK, prefix), Limit: limit, ConsistentRead: consistentRead}));
      return {items: (output.Items ?? []).map(expandItem), nextCursor: encodeCursor(output.LastEvaluatedKey)};
    },
    async remove(PK, SK, expectedVersion = null) {
      try {
        await db().send(new DeleteCommand({TableName: table, Key: {PK, SK},
          ...(expectedVersion === null ? {} : {ConditionExpression: '#v = :v', ExpressionAttributeNames: {'#v': 'version'}, ExpressionAttributeValues: {':v': expectedVersion}})}));
      } catch (error) {
        if (error.name === 'ConditionalCheckFailedException') throw new ApiError(409, 'conflict', 'The record changed. Reload and retry.');
        throw error;
      }
    },
    async consume(subject, now = Date.now()) {
      const window = Math.floor(now / 60000);
      try {
        await db().send(new UpdateCommand({TableName: table,
          Key: {PK: `RATE#${subject}`, SK: `WINDOW#${window}`},
          UpdateExpression: 'SET expiresAt = :ttl ADD #count :one',
          ConditionExpression: 'attribute_not_exists(#count) OR #count < :limit',
          ExpressionAttributeNames: {'#count': 'count'},
          ExpressionAttributeValues: {':ttl': Math.floor(now / 1000) + 120, ':one': 1, ':limit': 120}}));
      } catch (error) {
        if (error.name === 'ConditionalCheckFailedException') throw new ApiError(429, 'rate_limited', 'Wait before trying again.', {'Retry-After': '60'});
        throw error;
      }
    },
  };
  store.tableName = table;
  return store;
}
export async function mutate(store, PK, SK, change) {
  for (let attempt = 0; attempt < 5; attempt++) {
    const current = await store.get(PK, SK);
    const next = await change(current);
    if (next === current) return current;
    const {relatedWrites = [], ...record} = next;
    try { return await store.put({...record, PK, SK}, current?.version ?? null, relatedWrites); }
    catch (error) { if (error.code !== 'conflict' || attempt === 4) throw error; }
  }
}
