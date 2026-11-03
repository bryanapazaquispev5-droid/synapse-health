import {DynamoDBClient} from '@aws-sdk/client-dynamodb';
import {DynamoDBDocumentClient, PutCommand} from '@aws-sdk/lib-dynamodb';

const tableName = process.env.SYNAPSE_TABLE_NAME || 'synapse-health-backend-AppTable-1GTPC1EHUU9N5';
const region = process.env.AWS_REGION || 'us-east-2';

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({region}));

async function putDoc(path, docId, data) {
  const item = {
    PK: `COLLECTION#${path}`,
    SK: `DOC#${docId}`,
    version: 1,
    data,
  };
  await ddb.send(new PutCommand({
    TableName: tableName,
    Item: item,
  }));
  console.log(`Seeded ${item.PK} / ${item.SK}`);
}

async function run() {
  console.log(`Seeding catalog into ${tableName}...`);

  // 1. Medical Area
  await putDoc('medical_areas', 'anatomia_humana', {
    name: 'Anatomía Humana',
    code: 'ANATOMIA',
    order: 1,
    topicsCount: 1,
    cheatsheetsCount: 1,
    quizzesCount: 1,
    isAvailable: true,
  });

  // 2. Topic
  await putDoc('medical_areas/anatomia_humana/topics', 'osteologia_craneo', {
    areaId: 'anatomia_humana',
    title: 'Osteología del Cráneo',
    description: 'Huesos de la cabeza y base de cráneo',
    order: 1,
    cheatsheetsCount: 1,
    quizzesCount: 1,
  });

  // 3. Cheatsheet
  await putDoc('medical_areas/anatomia_humana/topics/osteologia_craneo/cheatsheets', 'esfenoides_orificios', {
    areaId: 'anatomia_humana',
    topicId: 'osteologia_craneo',
    title: 'Hueso Esfenoides y sus Forámenes',
    summary: 'Orificios principales del esfenoides y estructuras que los atraviesan.',
    contentMarkdown: '### Hueso Esfenoides y Base de Cráneo\n\nEl esfenoides es un hueso impar y simétrico situado en la base del cráneo.\n\n- **Fisura orbitaria superior**: Nervios oculomotor (III), troclear (IV), abducens (VI) y ramas del oftálmico (V1).\n- **Foramen redondo**: Nervio maxilar (V2).\n- **Foramen oval**: Nervio mandibular (V3) y arteria meníngea accesoria.\n- **Foramen espinoso**: Arteria y vena meníngea media.',
    keyPoints: [
      'Fisura orbitaria superior: III, IV, VI, V1',
      'Foramen redondo: Nervio maxilar (V2)',
      'Foramen oval: Nervio mandibular (V3)',
      'Foramen espinoso: Arteria meníngea media',
    ],
    mnemonics: ['ROSE: Redondo (V2), Oval (V3), Spinosum (Arteria Meníngea Media)'],
    readDurationInMinutes: 3,
    isPremium: false,
    sourceBook: 'Rouvière Tomo 1: Anatomía Humana',
  });

  // 4. Quiz
  await putDoc('medical_areas/anatomia_humana/topics/osteologia_craneo/quizzes', 'quiz_esfenoides_1', {
    areaId: 'anatomia_humana',
    topicId: 'osteologia_craneo',
    title: 'Foramen Oval y Contenido',
    question: '¿Qué estructura nerviosa atraviesa el foramen oval del hueso esfenoides?',
    options: [
      'Nervio maxilar (V2)',
      'Nervio mandibular (V3)',
      'Nervio oftálmico (V1)',
      'Nervio oculomotor (III)',
    ],
    correctIndex: 1,
    type: 'single_choice',
    rationale: 'El nervio mandibular (V3) es la tercera rama del nervio trigémino y pasa a través del foramen oval hacia la fosa infratemporal.',
    orderIndex: 1,
    maxStars: 3,
  });

  console.log('Catalog seeding complete!');
}

run().catch(err => {
  console.error('Seed error:', err);
  process.exit(1);
});
