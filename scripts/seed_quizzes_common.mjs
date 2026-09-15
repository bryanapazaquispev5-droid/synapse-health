// Helper común para la carga de Quizzes Clínicos en Firestore
const BASE_URL = 'https://firestore.googleapis.com/v1/projects/synapse-health/databases/(default)/documents';

export async function setDocument(path, fields, updateMaskFields = null) {
  let url = `${BASE_URL}/${path}`;
  if (updateMaskFields && updateMaskFields.length > 0) {
    const maskParams = updateMaskFields.map(f => `updateMask.fieldPaths=${encodeURIComponent(f)}`).join('&');
    url += `?${maskParams}`;
  }

  const formattedFields = {};

  for (const [key, value] of Object.entries(fields)) {
    if (value === undefined || value === null) continue;

    if (typeof value === 'string') {
      formattedFields[key] = { stringValue: value };
    } else if (typeof value === 'number') {
      formattedFields[key] = { integerValue: value.toString() };
    } else if (typeof value === 'boolean') {
      formattedFields[key] = { booleanValue: value };
    } else if (Array.isArray(value)) {
      formattedFields[key] = {
        arrayValue: {
          values: value.map(item => {
            if (typeof item === 'object' && item !== null) {
              const mapFields = {};
              for (const [k, v] of Object.entries(item)) {
                mapFields[k] = { stringValue: String(v) };
              }
              return { mapValue: { fields: mapFields } };
            }
            return { stringValue: String(item) };
          })
        }
      };
    }
  }

  for (let attempt = 1; attempt <= 5; attempt++) {
    try {
      const res = await fetch(url, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ fields: formattedFields })
      });

      if (!res.ok) {
        const errorText = await res.text();
        throw new Error(`Error al guardar ${path}: ${res.status} - ${errorText}`);
      }
      return; // Éxito
    } catch (err) {
      if (attempt === 5) {
        throw err;
      }
      const waitTime = attempt * 600;
      console.warn(`[Retry ${attempt}/5] Conexión inestable para ${path}. Reintentando en ${waitTime}ms...`);
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }
  }
}

export async function uploadQuizzesBatch(quizzesList, tomoName) {
  console.log(`\n======================================================`);
  console.log(`INICIANDO CARGA: ${tomoName} (${quizzesList.length} Quizzes Clínicos)`);
  console.log(`======================================================\n`);

  let count = 0;
  const topicCounts = {};

  for (const q of quizzesList) {
    count++;
    topicCounts[q.topicId] = (topicCounts[q.topicId] || 0) + 1;

    const docData = {
      areaId: q.areaId || 'anatomia',
      topicId: q.topicId,
      type: q.type || 'single_choice',
      question: q.question,
      options: q.options || [],
      correctIndex: q.correctIndex !== undefined ? q.correctIndex : 0,
      rationale: q.rationale,
      sourceBook: q.sourceBook,
      order: q.order || topicCounts[q.topicId],
      matchingPairs: q.matchingPairs || [],
      orderingItems: q.orderingItems || []
    };

    // 1. Guardar en la subcolección del tema (1:N estricto)
    await setDocument(`medical_areas/anatomia/topics/${q.topicId}/quizzes/${q.id}`, docData);
    // 2. Guardar en la colección global de anatomía para simulacro general
    await setDocument(`medical_areas/anatomia/quizzes/${q.id}`, docData);
    await new Promise(r => setTimeout(r, 30));

    if (count % 10 === 0 || count === quizzesList.length) {
      console.log(`[${tomoName}] Procesados ${count}/${quizzesList.length} quizzes...`);
    }
  }

  // Actualizar quizzesCount en cada tema
  for (const [topicId, total] of Object.entries(topicCounts)) {
    await setDocument(
      `medical_areas/anatomia/topics/${topicId}`,
      { quizzesCount: total },
      ['quizzesCount']
    );
    console.log(`✓ Tema '${topicId}' actualizado con quizzesCount = ${total}`);
  }

  console.log(`\n¡${tomoName} completado con éxito!\n`);
}
