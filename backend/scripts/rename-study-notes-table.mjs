import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {DynamoDBClient} from '@aws-sdk/client-dynamodb';
import {BatchWriteCommand, DynamoDBDocumentClient, ScanCommand} from '@aws-sdk/lib-dynamodb';

export function renameStudyNote(item) {
  if (typeof item.PK !== 'string' || !/^AREA#.+/.test(item.PK) ||
      typeof item.SK !== 'string' || !/^TOPIC#[^#]+#CHEATSHEET#[^#]+$/.test(item.SK)) {
    throw new Error('Source table contains a row outside the expected study-note key format.');
  }
  return {...item, SK: item.SK.replace('#CHEATSHEET#', '#STUDY_NOTE#')};
}

async function main() {
  const source = process.env.LEGACY_CHEATSHEETS_TABLE_NAME;
  const target = process.env.STUDY_NOTES_TABLE_NAME;
  if (!process.argv.includes('--apply') || !source || !target || source === target) {
    throw new Error('Set distinct source/target table names and pass --apply.');
  }
  const client = DynamoDBDocumentClient.from(new DynamoDBClient({region: process.env.AWS_REGION ?? 'us-east-2'}));
  const sourceRows = await scan(client, source);
  if (!sourceRows.length) throw new Error('Source table returned no records; refusing a no-op migration.');
  const migratedRows = sourceRows.map(renameStudyNote);
  const targetRows = await scan(client, target);
  const expected = new Map(migratedRows.map(row => [rowKey(row), canonicalJson(row)]));
  if (targetRows.some(row => expected.get(rowKey(row)) !== canonicalJson(row))) {
    throw new Error('Target table contains conflicting records; refusing to overwrite them.');
  }
  const copiedKeys = new Set(targetRows.map(rowKey));
  await write(client, target, migratedRows.filter(row => !copiedKeys.has(rowKey(row))));
  const copiedRows = await scan(client, target);
  const sourceHash = digest(migratedRows);
  const targetHash = digest(copiedRows);
  if (migratedRows.length !== copiedRows.length || sourceHash !== targetHash) {
    throw new Error('Study-note copy verification failed; keep the source table and do not cut over.');
  }
  console.log(JSON.stringify({records: copiedRows.length, sourceHash, targetHash, verified: true}));
}

async function scan(client, table) {
  const rows = [];
  let cursor;
  do {
    const page = await client.send(new ScanCommand({TableName: table, ExclusiveStartKey: cursor}));
    rows.push(...(page.Items ?? []));
    cursor = page.LastEvaluatedKey;
  } while (cursor);
  return rows;
}

async function write(client, table, rows) {
  for (let start = 0; start < rows.length; start += 25) {
    let pending = {[table]: rows.slice(start, start + 25).map(Item => ({PutRequest: {Item}}))};
    for (let attempt = 0; Object.values(pending).some(batch => batch.length) && attempt < 8; attempt++) {
      const result = await client.send(new BatchWriteCommand({RequestItems: pending}));
      pending = result.UnprocessedItems ?? {};
      if (Object.values(pending).some(batch => batch.length)) await delay(Math.min(1000 * 2 ** attempt, 8000));
    }
    if (Object.values(pending).some(batch => batch.length)) throw new Error('DynamoDB kept throttling; migration is safe to rerun after clearing the target.');
  }
}

function digest(rows) {
  const ordered = rows.map(canonicalJson).sort((left, right) => left.localeCompare(right));
  return createHash('sha256').update(JSON.stringify(ordered)).digest('hex');
}

function canonicalJson(value) {
  const canonical = input => Array.isArray(input) ? input.map(canonical)
    : input && typeof input === 'object' ? Object.fromEntries(Object.keys(input).sort().map(key => [key, canonical(input[key])])) : input;
  return JSON.stringify(canonical(value));
}

function rowKey(item) { return `${item.PK}|${item.SK}`; }

function delay(milliseconds) { return new Promise(resolve => setTimeout(resolve, milliseconds)); }

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch(error => { console.error(error.message); process.exitCode = 1; });
}
