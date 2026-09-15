// Script para eliminar quizzes huérfanos/antiguos de la base de datos de Firestore
// Deja exactamente los 500 Quizzes Clínicos actuales de Anatomía Humana
import fs from 'fs';
import path from 'path';

const BASE_URL = 'https://firestore.googleapis.com/v1/projects/synapse-health/databases/(default)/documents';

// 1. Extraer los 500 IDs válidos de los 8 archivos de seed
function getValidQuizIds() {
  const validIds = new Set();
  const seedFiles = [
    'seed_quizzes_tomo1_part1.mjs',
    'seed_quizzes_tomo1_part2.mjs',
    'seed_quizzes_tomo2_part1.mjs',
    'seed_quizzes_tomo2_part2.mjs',
    'seed_quizzes_tomo3_part1.mjs',
    'seed_quizzes_tomo3_part2.mjs',
    'seed_quizzes_tomo4_part1.mjs',
    'seed_quizzes_tomo4_part2.mjs'
  ];

  for (const file of seedFiles) {
    const filePath = path.join('scripts', file);
    const content = fs.readFileSync(filePath, 'utf8');
    const matches = content.matchAll(/id:\s*'([^']+)'/g);
    for (const match of matches) {
      validIds.add(match[1]);
    }
  }

  return validIds;
}

// 2. Obtener todos los documentos de una colección manejando paginación con nextPageToken
async function getAllDocuments(collectionPath) {
  let docs = [];
  let pageToken = null;

  do {
    let url = `${BASE_URL}/${collectionPath}?pageSize=300`;
    if (pageToken) {
      url += `&pageToken=${encodeURIComponent(pageToken)}`;
    }

    const res = await fetch(url);
    if (!res.ok) {
      const errText = await res.text();
      throw new Error(`Error al listar ${collectionPath}: ${res.status} - ${errText}`);
    }

    const data = await res.json();
    if (data.documents) {
      docs = docs.concat(data.documents);
    }
    pageToken = data.nextPageToken;
  } while (pageToken);

  return docs;
}

// 3. Eliminar un documento en Firestore
async function deleteDocument(docPath) {
  const url = `${BASE_URL}/${docPath}`;
  const res = await fetch(url, { method: 'DELETE' });
  if (!res.ok && res.status !== 404) {
    const errText = await res.text();
    console.warn(`No se pudo eliminar ${docPath}: ${res.status} - ${errText}`);
  }
}

async function main() {
  console.log('================================================================');
  console.log('LIMPIEZA DE DOCUMENTOS LEGACY / HUÉRFANOS EN FIRESTORE');
  console.log('================================================================\n');

  const validIds = getValidQuizIds();
  console.log(`Total de IDs válidos esperados según el código: ${validIds.size}`);

  console.log('\nListando todos los documentos en medical_areas/anatomia/quizzes...');
  const allDocs = await getAllDocuments('medical_areas/anatomia/quizzes');
  console.log(`Total de documentos encontrados en Firestore: ${allDocs.length}`);

  const toDelete = [];
  for (const doc of allDocs) {
    const docId = doc.name.split('/').pop();
    if (!validIds.has(docId)) {
      toDelete.push(docId);
    }
  }

  console.log(`\nDocumentos legacy/huérfanos a eliminar: ${toDelete.length}`);
  console.log('IDs a eliminar:', toDelete);

  let deletedCount = 0;
  for (const id of toDelete) {
    await deleteDocument(`medical_areas/anatomia/quizzes/${id}`);
    await deleteDocument(`quizzes/${id}`);
    deletedCount++;
    if (deletedCount % 10 === 0 || deletedCount === toDelete.length) {
      console.log(`Eliminados ${deletedCount}/${toDelete.length}...`);
    }
    await new Promise(r => setTimeout(r, 20));
  }

  // Verificar la cantidad final
  console.log('\nVerificando conteo final en Firestore...');
  const finalDocs = await getAllDocuments('medical_areas/anatomia/quizzes');
  console.log(`\n================================================================`);
  console.log(`✓ CONTEO FINAL: ${finalDocs.length} QUIZZES EXACTOS EN FIRESTORE.`);
  console.log('================================================================\n');

  if (finalDocs.length === 500) {
    console.log('¡Base de datos 100% limpia y sincronizada con los 500 quizzes!');
  } else {
    console.warn(`Atención: el conteo es ${finalDocs.length}, revisando discrepancias...`);
  }
}

main().catch(err => {
  console.error('Error fatal:', err);
  process.exit(1);
});
