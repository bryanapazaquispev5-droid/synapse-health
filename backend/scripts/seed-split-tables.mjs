import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { BatchWriteCommand, DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';
import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const region = process.env.AWS_REGION || 'us-east-2';
const tables = {
  areas: process.env.MEDICAL_AREAS_TABLE_NAME || 'synapse-health-backend-medical-areas',
  topics: process.env.TOPICS_TABLE_NAME || 'synapse-health-backend-topics',
  quizzes: process.env.QUIZZES_TABLE_NAME || 'synapse-health-backend-quizzes',
  studyNotes: process.env.STUDY_NOTES_TABLE_NAME || 'synapse-health-backend-study-notes',
};

const client = new DynamoDBClient({ region });
const ddb = DynamoDBDocumentClient.from(client, {
  marshallOptions: { removeUndefinedValues: true },
});

const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function batchWrite(tableName, items) {
  const chunkSize = 25;
  for (let i = 0; i < items.length; i += chunkSize) {
    const chunk = items.slice(i, i + chunkSize);
    let requestItems = {
      [tableName]: chunk.map((item) => ({ PutRequest: { Item: item } })),
    };
    for (let attempt = 0; Object.keys(requestItems).length > 0 && attempt < 8; attempt++) {
      try {
        const result = await ddb.send(new BatchWriteCommand({ RequestItems: requestItems }));
        requestItems = result.UnprocessedItems || {};
      } catch (err) {
        if (!/ProvisionedThroughputExceeded|Throttling/i.test(err.name || '') || attempt === 7) {
          throw err;
        }
      }
      if (Object.keys(requestItems).length > 0) {
        await delay(100 * Math.pow(2, attempt));
      }
    }
    if (Object.keys(requestItems).length > 0) {
      throw new Error(`Failed to write all items to ${tableName} due to prolonged throttling.`);
    }
  }
}

async function run() {
  const contentDir = join(process.cwd(), 'course-content');
  const files = readdirSync(contentDir).filter((file) => file.endsWith('.jsonl'));

  const areas = [];
  const topics = [];
  const quizzes = [];
  const studyNotes = [];

  for (const file of files) {
    const lines = readFileSync(join(contentDir, file), 'utf8')
      .split('\n')
      .map((line) => line.trim())
      .filter(Boolean);

    for (const line of lines) {
      const obj = JSON.parse(line);
      if (obj.kind === 'area') {
        const { kind, ...areaAttrs } = obj;
        areas.push({
          PK: 'AREAS',
          SK: `AREA#${obj.id}`,
          ...areaAttrs,
          data: areaAttrs,
        });
      } else if (obj.kind === 'topic') {
        const { kind, quizzes: topicQuizzes = [], studyNotes: topicNotes = [], ...topicAttrs } = obj;
        const areaId = obj.areaId;
        const topicId = obj.id;

        topics.push({
          PK: `AREA#${areaId}`,
          SK: `TOPIC#${topicId}`,
          ...topicAttrs,
          data: topicAttrs,
        });

        for (const quiz of topicQuizzes) {
          const qAreaId = quiz.areaId || areaId;
          const qTopicId = quiz.topicId || topicId;
          quizzes.push({
            PK: `AREA#${qAreaId}`,
            SK: `TOPIC#${qTopicId}#QUIZ#${quiz.id}`,
            ...quiz,
            data: quiz,
          });
        }

        for (const note of topicNotes) {
          const nAreaId = note.areaId || areaId;
          const nTopicId = note.topicId || topicId;
          studyNotes.push({
            PK: `AREA#${nAreaId}`,
            SK: `TOPIC#${nTopicId}#STUDY_NOTE#${note.id}`,
            ...note,
            data: note,
          });
        }
      }
    }
  }

  console.log(`Parsed: ${areas.length} areas, ${topics.length} topics, ${quizzes.length} quizzes, ${studyNotes.length} notes.`);

  console.log(`Writing to ${tables.areas}...`);
  await batchWrite(tables.areas, areas);
  console.log(`Seeded ${areas.length} areas.`);

  console.log(`Writing to ${tables.topics}...`);
  await batchWrite(tables.topics, topics);
  console.log(`Seeded ${topics.length} topics.`);

  console.log(`Writing to ${tables.quizzes}...`);
  await batchWrite(tables.quizzes, quizzes);
  console.log(`Seeded ${quizzes.length} quizzes.`);

  console.log(`Writing to ${tables.studyNotes}...`);
  await batchWrite(tables.studyNotes, studyNotes);
  console.log(`Seeded ${studyNotes.length} study notes.`);

  console.log('Successfully completed seeding all tables!');
}

run().catch((err) => {
  console.error('Seeding failed:', err);
  process.exit(1);
});
