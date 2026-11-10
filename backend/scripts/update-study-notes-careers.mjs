import {DynamoDBClient} from '@aws-sdk/client-dynamodb';
import {DynamoDBDocumentClient, ScanCommand, UpdateCommand} from '@aws-sdk/lib-dynamodb';

const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({region: 'us-east-2'}));

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

async function run() {
  let updated = 0;
  let lastKey;
  do {
    const scan = await dynamo.send(new ScanCommand({
      TableName: 'synapse-health-backend-study-notes',
      ExclusiveStartKey: lastKey
    }));
    for (const item of (scan.Items || [])) {
      if (item.careers && item.careers.length > 0) continue;
      const areaId = item.areaId || item.data?.areaId || item.PK.replace('AREA#', '');
      const careers = areaCareersMap[areaId] || ['Medicine', 'Nursing'];
      let done = false;
      while (!done) {
        try {
          await dynamo.send(new UpdateCommand({
            TableName: 'synapse-health-backend-study-notes',
            Key: {PK: item.PK, SK: item.SK},
            UpdateExpression: 'SET #c = :c, #d.#c = :c',
            ExpressionAttributeNames: {'#c': 'careers', '#d': 'data'},
            ExpressionAttributeValues: {':c': careers}
          }));
          done = true;
          updated++;
          await sleep(60);
        } catch (err) {
          if (err.name === 'ProvisionedThroughputExceededException') {
            await sleep(300);
          } else {
            throw err;
          }
        }
      }
    }
    lastKey = scan.LastEvaluatedKey;
  } while (lastKey);
  console.log('STUDY NOTES UPDATED COUNT:', updated);
}

run().catch(console.error);
