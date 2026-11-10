import {DynamoDBClient} from '@aws-sdk/client-dynamodb';
import {DynamoDBDocumentClient, ScanCommand, UpdateCommand} from '@aws-sdk/lib-dynamodb';

const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({
  region: 'us-east-2',
  maxAttempts: 10
}));

const areaCareersMap = {
  human_physiology: [
    'Medicine', 'Nursing', 'Dentistry', 'Pharmacy and Biochemistry',
    'Nutrition', 'Physical Therapy', 'Obstetrics'
  ],
  clinical_semiology: [
    'Medicine', 'Nursing', 'Dentistry', 'Obstetrics'
  ],
  first_aid_bls: [
    'Medicine', 'Nursing', 'Dentistry', 'Pharmacy and Biochemistry',
    'Nutrition', 'Physical Therapy', 'Obstetrics'
  ],
  pharmacology: [
    'Pharmacy and Biochemistry', 'Medicine', 'Nursing', 'Dentistry'
  ],
  microbiology_immunology: [
    'Pharmacy and Biochemistry', 'Medicine', 'Dentistry', 'Nursing'
  ],
  pathology_pathophysiology: [
    'Medicine', 'Dentistry', 'Nursing', 'Pharmacy and Biochemistry'
  ],
  histology: [
    'Medicine', 'Dentistry', 'Obstetrics'
  ],
  public_health_epidemiology: [
    'Medicine', 'Nursing', 'Nutrition', 'Obstetrics'
  ]
};

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

async function updateTableWithCareers(tableName, getAreaId) {
  let updated = 0;
  let skipped = 0;
  let lastKey;
  do {
    const scan = await dynamo.send(new ScanCommand({
      TableName: tableName,
      ExclusiveStartKey: lastKey
    }));
    for (const item of (scan.Items || [])) {
      if (item.careers && item.careers.length > 0) {
        skipped++;
        continue;
      }
      const areaId = getAreaId(item);
      const careers = areaCareersMap[areaId] || ['Medicine', 'Nursing'];
      await dynamo.send(new UpdateCommand({
        TableName: tableName,
        Key: {PK: item.PK, SK: item.SK},
        UpdateExpression: 'SET #c = :c, #d.#c = :c',
        ExpressionAttributeNames: {'#c': 'careers', '#d': 'data'},
        ExpressionAttributeValues: {':c': careers}
      }));
      updated++;
      await sleep(150);
    }
    lastKey = scan.LastEvaluatedKey;
  } while (lastKey);
  console.log(`Table ${tableName}: updated ${updated}, skipped ${skipped} already set.`);
}

async function run() {
  await updateTableWithCareers('synapse-health-backend-quizzes', item => item.areaId || item.data?.areaId || item.PK.replace('AREA#', ''));
  await updateTableWithCareers('synapse-health-backend-study-notes', item => item.areaId || item.data?.areaId || item.PK.replace('AREA#', ''));
  console.log('ALL TABLES 100% POPULATED WITH CAREERS!');
}

run().catch(console.error);
