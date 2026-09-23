// Script para randomizar las opciones y correctIndex de quizzes en Firestore
// synapse_health - Randomización de alternativas A, B y C

const BASE_URL = 'https://firestore.googleapis.com/v1/projects/synapse-health/databases/(default)/documents';

// Algoritmo de Fisher-Yates para barajar arreglos de forma uniforme
function shuffleWithCorrectTracking(options, currentCorrectIndex) {
  const items = options.map((text, idx) => ({
    text,
    isCorrect: idx === currentCorrectIndex,
  }));

  for (let i = items.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [items[i], items[j]] = [items[j], items[i]];
  }

  const shuffledOptions = items.map(item => item.text);
  const newCorrectIndex = items.findIndex(item => item.isCorrect);

  return { shuffledOptions, newCorrectIndex };
}

// Obtener todos los documentos de una colección con paginación
async function getAllDocuments(collectionPath) {
  let docs = [];
  let pageToken = null;

  do {
    let url = `${BASE_URL}/${collectionPath}?pageSize=300`;
    if (pageToken) {
      url += `&pageToken=${encodeURIComponent(pageToken)}`;
    }

    let success = false;
    for (let attempt = 1; attempt <= 5; attempt++) {
      try {
        const res = await fetch(url);
        if (!res.ok) {
          const errText = await res.text();
          throw new Error(`HTTP ${res.status}: ${errText}`);
        }
        const data = await res.json();
        if (data.documents) {
          docs = docs.concat(data.documents);
        }
        pageToken = data.nextPageToken;
        success = true;
        break;
      } catch (err) {
        if (attempt === 5) throw err;
        const waitMs = attempt * 800;
        console.warn(`[Reintento ${attempt}/5] Error leyendo ${collectionPath}: ${err.message}. Esperando ${waitMs}ms...`);
        await new Promise(r => setTimeout(r, waitMs));
      }
    }
  } while (pageToken);

  return docs;
}

// Actualizar un quiz en Firestore con reintentos y retroceso exponencial
async function patchQuizOptions(docName, shuffledOptions, newCorrectIndex) {
  const url = `https://firestore.googleapis.com/v1/${docName}?updateMask.fieldPaths=options&updateMask.fieldPaths=correctIndex`;
  const body = {
    fields: {
      options: {
        arrayValue: {
          values: shuffledOptions.map(opt => ({ stringValue: String(opt) })),
        },
      },
      correctIndex: {
        integerValue: String(newCorrectIndex),
      },
    },
  };

  for (let attempt = 1; attempt <= 5; attempt++) {
    try {
      const res = await fetch(url, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });

      if (!res.ok) {
        const errText = await res.text();
        throw new Error(`HTTP ${res.status}: ${errText}`);
      }
      return;
    } catch (err) {
      if (attempt === 5) throw err;
      const waitMs = attempt * 1000;
      console.warn(`[Reintento ${attempt}/5] Error actualizando ${docName}: ${err.message}. Esperando ${waitMs}ms...`);
      await new Promise(r => setTimeout(r, waitMs));
    }
  }
}

// Ejecutar tareas con límite de concurrencia
async function mapConcurrent(items, concurrency, fn) {
  const results = [];
  let index = 0;

  async function worker() {
    while (index < items.length) {
      const currentIndex = index++;
      results[currentIndex] = await fn(items[currentIndex], currentIndex);
    }
  }

  const workers = Array.from({ length: Math.min(concurrency, items.length) }, () => worker());
  await Promise.all(workers);
  return results;
}

async function main() {
  console.log('=== RANDOMIZACIÓN DE OPCIONES DE QUIZZES EN FIRESTORE ===\n');

  const collections = [
    'medical_areas/anatomia/quizzes',
    'quizzes',
  ];

  const distribution = { 0: 0, 1: 0, 2: 0, other: 0 };
  let totalProcessed = 0;
  let totalSkipped = 0;

  for (const collectionPath of collections) {
    console.log(`Buscando quizzes en colección: ${collectionPath}`);
    const docs = await getAllDocuments(collectionPath);
    console.log(`Documentos encontrados en ${collectionPath}: ${docs.length}`);

    if (docs.length === 0) continue;

    const quizzesToUpdate = [];

    for (const doc of docs) {
      const rawOptions = doc.fields?.options?.arrayValue?.values || [];
      const options = rawOptions.map(v => v.stringValue ?? '');

      if (options.length > 1) {
        const rawIndex = doc.fields?.correctIndex?.integerValue ?? '0';
        const currentCorrectIndex = parseInt(rawIndex, 10);
        const validIndex = isNaN(currentCorrectIndex) ? 0 : currentCorrectIndex;

        const { shuffledOptions, newCorrectIndex } = shuffleWithCorrectTracking(options, validIndex);

        quizzesToUpdate.push({
          docName: doc.name,
          shuffledOptions,
          newCorrectIndex,
        });
      } else {
        totalSkipped++;
      }
    }

    console.log(`Quizzes elegibles para randomizar: ${quizzesToUpdate.length}`);

    if (quizzesToUpdate.length > 0) {
      let completed = 0;

      await mapConcurrent(quizzesToUpdate, 8, async (item) => {
        await patchQuizOptions(item.docName, item.shuffledOptions, item.newCorrectIndex);

        if (item.newCorrectIndex === 0) distribution[0]++;
        else if (item.newCorrectIndex === 1) distribution[1]++;
        else if (item.newCorrectIndex === 2) distribution[2]++;
        else distribution.other++;

        completed++;
        totalProcessed++;

        if (completed % 50 === 0 || completed === quizzesToUpdate.length) {
          console.log(`Progreso [${collectionPath}]: ${completed}/${quizzesToUpdate.length} quizzes actualizados...`);
        }
      });

      console.log(`Finalizada actualización para ${collectionPath}.\n`);
    }
  }

  console.log('======================================================');
  console.log('RESUMEN FINAL DE RANDOMIZACIÓN');
  console.log('======================================================');
  console.log(`Total quizzes actualizados: ${totalProcessed}`);
  console.log(`Total quizzes omitidos (matching/ordering/sin opciones > 1): ${totalSkipped}`);
  console.log('Distribución de Respuestas Correctas:');
  const pA = totalProcessed > 0 ? ((distribution[0] / totalProcessed) * 100).toFixed(1) : '0';
  const pB = totalProcessed > 0 ? ((distribution[1] / totalProcessed) * 100).toFixed(1) : '0';
  const pC = totalProcessed > 0 ? ((distribution[2] / totalProcessed) * 100).toFixed(1) : '0';
  console.log(`- Opción A (Índice 0): ${distribution[0]} (${pA}%)`);
  console.log(`- Opción B (Índice 1): ${distribution[1]} (${pB}%)`);
  console.log(`- Opción C (Índice 2): ${distribution[2]} (${pC}%)`);
  if (distribution.other > 0) {
    console.log(`- Otros Índices: ${distribution.other}`);
  }
  console.log('======================================================\n');
}

main().catch(err => {
  console.error('Error fatal durante la randomización:', err);
  process.exit(1);
});
