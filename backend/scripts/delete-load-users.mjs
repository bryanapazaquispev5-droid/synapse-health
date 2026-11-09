import {DynamoDBClient, ScanCommand, BatchWriteItemCommand} from '@aws-sdk/client-dynamodb';

const region = process.env.AWS_REGION || 'us-east-2';
const tableName = process.env.USER_PROFILES_TABLE_NAME || 'synapse-health-backend-user-profiles';
const targetRunId = process.argv[2] || '';

const client = new DynamoDBClient({region});

async function findLoadUsers() {
  const users = [];
  let lastEvaluatedKey = undefined;

  do {
    const res = await client.send(new ScanCommand({
      TableName: tableName,
      ProjectionExpression: 'PK, SK, #subAttr, email',
      ExpressionAttributeNames: {'#subAttr': 'sub'},
      ExclusiveStartKey: lastEvaluatedKey,
    }));

    for (const item of res.Items || []) {
      const pk = item.PK?.S || '';
      const sk = item.SK?.S || '';
      const isTestEmail = pk.startsWith('USER#EMAIL#load-') ||
                          pk.startsWith('USER#EMAIL#prueba-') ||
                          pk.startsWith('USER#EMAIL#ondemand_') ||
                          pk.startsWith('USER#EMAIL#dbg_') ||
                          pk.startsWith('USER#EMAIL#testlive_');
      if (isTestEmail && sk === 'ACCOUNT') {
        const email = item.email?.S || pk.replace('USER#EMAIL#', '');
        const sub = item.sub?.S || '';
        if (!targetRunId || email.includes(targetRunId)) {
          users.push({email, sub});
        }
      }
    }
    lastEvaluatedKey = res.LastEvaluatedKey;
  } while (lastEvaluatedKey);

  return users;
}

async function batchDelete(deleteRequests) {
  const chunks = [];
  for (let i = 0; i < deleteRequests.length; i += 25) {
    chunks.push(deleteRequests.slice(i, i + 25));
  }

  const concurrency = 25;
  let completed = 0;

  for (let i = 0; i < chunks.length; i += concurrency) {
    const slice = chunks.slice(i, i + concurrency);
    await Promise.all(slice.map(async chunk => {
      let reqs = chunk;
      while (reqs.length > 0) {
        const res = await client.send(new BatchWriteItemCommand({
          RequestItems: {[tableName]: reqs}
        }));
        const unprocessed = res.UnprocessedItems?.[tableName] || [];
        reqs = unprocessed;
        if (reqs.length > 0) await new Promise(r => setTimeout(r, 100));
      }
      completed += chunk.length;
    }));
  }
  return completed;
}

async function run() {
  console.log(`[DynamoDB Cleanup] Scanning table "${tableName}" in ${region}...`);
  if (targetRunId) console.log(`[DynamoDB Cleanup] Filtering by Run ID: "${targetRunId}"`);

  const startTime = Date.now();
  const users = await findLoadUsers();
  console.log(`[DynamoDB Cleanup] Found ${users.length} load test accounts to delete.`);

  if (users.length === 0) {
    console.log('[DynamoDB Cleanup] No matching accounts found.');
    return;
  }

  const deleteRequests = [];
  for (const u of users) {
    deleteRequests.push({DeleteRequest: {Key: {PK: {S: `USER#EMAIL#${u.email}`}, SK: {S: 'ACCOUNT'}}}});
    if (u.sub) {
      deleteRequests.push({DeleteRequest: {Key: {PK: {S: `USER#${u.sub}`}, SK: {S: 'AUTH'}}}});
      deleteRequests.push({DeleteRequest: {Key: {PK: {S: `USER#${u.sub}`}, SK: {S: 'PROFILE'}}}});
    }
  }

  console.log(`[DynamoDB Cleanup] Deleting ${deleteRequests.length} total items in DynamoDB...`);
  const deletedCount = await batchDelete(deleteRequests);
  const elapsed = ((Date.now() - startTime) / 1000).toFixed(2);
  console.log(`[DynamoDB Cleanup] Successfully deleted ${deletedCount} items (${users.length} accounts) in ${elapsed}s.`);
}

run().catch(err => {
  console.error('[DynamoDB Cleanup Error]', err);
  process.exit(1);
});
