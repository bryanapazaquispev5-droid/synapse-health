import {DynamoDBClient} from '@aws-sdk/client-dynamodb';
import {BatchWriteCommand, DynamoDBDocumentClient, QueryCommand} from '@aws-sdk/lib-dynamodb';
import {createHash} from 'node:crypto';
import {readFile, unlink, writeFile} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {translateCatalogData} from './local-catalog-translation.mjs';

const region = process.env.AWS_REGION ?? 'us-east-2';
const sourceTable = process.env.LEGACY_CATALOG_TABLE_NAME ?? 'synapse-health-backend-AppTable-1GTPC1EHUU9N5';
const targetTables = {
  areas: process.env.MEDICAL_AREAS_TABLE_NAME, topics: process.env.TOPICS_TABLE_NAME,
  quizzes: process.env.QUIZZES_TABLE_NAME, studyNotes: process.env.STUDY_NOTES_TABLE_NAME,
};
const writeCapacity = {areas: 1, topics: 1, quizzes: 2, studyNotes: 1};
const apply = process.argv.includes('--apply');
const cacheFile = join(tmpdir(), 'synapse-health-catalog-english.json');
const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({region}), {marshallOptions: {removeUndefinedValues: true}});

assertConfiguration();
const documents = await loadCatalog();
const sourceDigest = digest(documents);
const translated = apply ? await readPrepared(sourceDigest) : await translateDocuments(documents);
console.log(JSON.stringify({mode: apply ? 'apply' : 'dry-run', sourceTable, targetTables,
  records: translated.length, groups: groupCounts(translated),
  inputCharacters: textLength(documents), outputCharacters: textLength(translated)}));
if (apply) { await writeDocuments(translated); await unlink(cacheFile).catch(() => {}); }
else await writeFile(cacheFile, JSON.stringify({sourceDigest, translated}));

function assertConfiguration() {
  if (!sourceTable || Object.values(targetTables).some(name => !name || name === sourceTable)) {
    throw new Error('Set the source table and all four target table names; source and target must differ.');
  }
}

function digest(value) { return createHash('sha256').update(JSON.stringify(value)).digest('hex'); }

async function readPrepared(sourceDigest) {
  let prepared;
  try { prepared = JSON.parse(await readFile(cacheFile, 'utf8')); }
  catch { throw new Error('Run the dry-run first to translate and locally prepare the current catalog.'); }
  if (prepared.sourceDigest !== sourceDigest || !Array.isArray(prepared.translated)) {
    throw new Error('Prepared catalog no longer matches the legacy source; run the dry-run again.');
  }
  return prepared.translated;
}

async function queryPath(path) {
  const rows = [];
  let cursor;
  do {
    const result = await ddb.send(new QueryCommand({TableName: sourceTable,
      KeyConditionExpression: 'PK = :pk', ExpressionAttributeNames: {'#data': 'data'},
      ExpressionAttributeValues: {':pk': `COLLECTION#${path}`}, ProjectionExpression: 'PK, SK, #data',
      ExclusiveStartKey: cursor}));
    rows.push(...(result.Items ?? [])); cursor = result.LastEvaluatedKey;
  } while (cursor);
  return rows;
}

async function loadCatalog() {
  const areas = await queryPath('medical_areas');
  const rows = [];
  for (const area of areas) {
    const areaId = area.SK.slice(4);
    rows.push({kind: 'areas', id: areaId, data: area.data});
    const topics = await queryPath(`medical_areas/${areaId}/topics`);
    const areaQuizzes = await queryPath(`medical_areas/${areaId}/quizzes`);
    const byQuizId = new Map(areaQuizzes.map(row => [row.SK.slice(4), row]));
    for (const topic of topics) {
      const topicId = topic.SK.slice(4);
      rows.push({kind: 'topics', areaId, id: topicId, data: {...topic.data, areaId}});
      const [nestedQuizzes, sheets] = await Promise.all([
        queryPath(`medical_areas/${areaId}/topics/${topicId}/quizzes`),
        queryPath(`medical_areas/${areaId}/topics/${topicId}/cheatsheets`),
      ]);
      nestedQuizzes.forEach(row => byQuizId.set(row.SK.slice(4), {...row, topicId}));
      sheets.forEach(row => rows.push({kind: 'studyNotes', areaId, topicId, id: row.SK.slice(4), data: {...row.data, areaId, topicId}}));
    }
    for (const [id, row] of byQuizId) {
      const topicId = row.topicId ?? row.data.topicId;
      if (!topicId) throw new Error(`Quiz ${id} has no topic owner; refusing an unlinked record.`);
      rows.push({kind: 'quizzes', areaId, topicId, id, data: {...row.data, areaId, topicId}});
    }
  }
  return rows;
}

async function translateDocuments(documents) {
  const output = [];
  for (let offset = 0; offset < documents.length; offset += 10) {
    const group = documents.slice(offset, offset + 10);
    const translatedData = await translateCatalogData(group.map(row => row.data));
    group.forEach((row, index) => {
      const {kind, id, areaId, topicId} = row;
      const keys = kind === 'areas' ? {PK: 'AREAS', SK: `AREA#${id}`}
        : kind === 'topics' ? {PK: `AREA#${areaId}`, SK: `TOPIC#${id}`}
          : kind === 'quizzes' ? {PK: `AREA#${areaId}`, SK: `TOPIC#${topicId}#QUIZ#${id}`}
            : {PK: `AREA#${areaId}`, SK: `TOPIC#${topicId}#STUDY_NOTE#${id}`};
      output.push({kind, table: targetTables[kind], Item: {...keys, id, ...translatedData[index]}});
    });
    console.log(`Translated ${Math.min(offset + group.length, documents.length)}/${documents.length} catalog records locally.`);
  }
  return output;
}

async function writeDocuments(rows) {
  for (const kind of Object.keys(targetTables)) {
    const tableRows = rows.filter(row => row.kind === kind);
    for (const row of tableRows) {
      const request = {PutRequest: {Item: row.Item}};
      let pending = {[targetTables[kind]]: [request]};
      for (let attempt = 0; Object.values(pending).some(items => items.length) && attempt < 8; attempt++) {
        try {
          const result = await ddb.send(new BatchWriteCommand({RequestItems: pending}));
          pending = result.UnprocessedItems ?? {};
        } catch (error) {
          if (!/ProvisionedThroughputExceeded|Throttling/i.test(error.name ?? '') || attempt === 7) throw error;
        }
        if (Object.values(pending).some(items => items.length)) await delay(250 * 2 ** attempt);
      }
      if (Object.values(pending).some(items => items.length)) throw new Error(`DynamoDB kept throttling ${kind}; rerun safely after capacity recovers.`);
      const units = Math.ceil(Buffer.byteLength(JSON.stringify(row.Item)) / 1024);
      await delay(Math.ceil(units / writeCapacity[kind] * 1000));
    }
    console.log(`Stored ${tableRows.length} English ${kind} records.`);
  }
}

function delay(milliseconds) { return new Promise(resolve => setTimeout(resolve, milliseconds)); }

function groupCounts(rows) {
  return Object.fromEntries(Object.keys(targetTables).map(kind => [kind, rows.filter(row => row.kind === kind).length]));
}
function textLength(rows) {
  const count = value => typeof value === 'string' ? value.length
    : Array.isArray(value) ? value.reduce((sum, item) => sum + count(item), 0)
      : value && typeof value === 'object' ? Object.values(value).reduce((sum, item) => sum + count(item), 0) : 0;
  return rows.reduce((sum, row) => sum + count(row.data ?? row.Item), 0);
}
