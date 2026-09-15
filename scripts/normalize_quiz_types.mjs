// Script to inspect and normalize all quiz types in Firestore to strictly 3 types:
// 1. 'single_choice' ("Selección simple")
// 2. 'matching' ("Para relacionar")
// 3. 'ordering' ("Para ordenar")
// Any legacy 'case_study' is converted to 'single_choice'.

const BASE_URL = 'https://firestore.googleapis.com/v1/projects/synapse-health/databases/(default)/documents';

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
      throw new Error(`Error listing ${collectionPath}: ${res.status} - ${errText}`);
    }

    const data = await res.json();
    if (data.documents) {
      docs = docs.concat(data.documents);
    }
    pageToken = data.nextPageToken;
  } while (pageToken);

  return docs;
}

async function updateQuizType(docPath, newType) {
  const url = `${BASE_URL}/${docPath}?updateMask.fieldPaths=type`;
  const body = {
    fields: {
      type: { stringValue: newType }
    }
  };

  const res = await fetch(url, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`Failed to update ${docPath}: ${res.status} - ${errText}`);
  }
}

async function main() {
  console.log('Fetching all quizzes from Firestore...');
  const collections = [
    'medical_areas/anatomia/quizzes',
    'quizzes'
  ];

  for (const col of collections) {
    console.log(`\nScanning collection: ${col}`);
    const docs = await getAllDocuments(col);
    console.log(`Found ${docs.length} documents.`);

    let caseStudyCount = 0;
    let singleChoiceCount = 0;
    let matchingCount = 0;
    let orderingCount = 0;
    let otherCount = 0;

    const toUpdate = [];

    for (const doc of docs) {
      const docId = doc.name.split('/').pop();
      const currentType = doc.fields?.type?.stringValue || 'single_choice';

      if (currentType === 'case_study') {
        caseStudyCount++;
        toUpdate.push({ id: docId, fullPath: `${col}/${docId}` });
      } else if (currentType === 'single_choice') {
        singleChoiceCount++;
      } else if (currentType === 'matching') {
        matchingCount++;
      } else if (currentType === 'ordering') {
        orderingCount++;
      } else {
        otherCount++;
        console.warn(`Unrecognized type "${currentType}" in doc ${docId}`);
        toUpdate.push({ id: docId, fullPath: `${col}/${docId}` });
      }
    }

    console.log(`Summary for ${col}:`);
    console.log(`- single_choice: ${singleChoiceCount}`);
    console.log(`- case_study (to convert): ${caseStudyCount}`);
    console.log(`- matching: ${matchingCount}`);
    console.log(`- ordering: ${orderingCount}`);
    console.log(`- other: ${otherCount}`);

    if (toUpdate.length > 0) {
      console.log(`Updating ${toUpdate.length} documents to 'single_choice'...`);
      let updated = 0;
      for (const item of toUpdate) {
        await updateQuizType(item.fullPath, 'single_choice');
        updated++;
        if (updated % 20 === 0 || updated === toUpdate.length) {
          console.log(`Updated ${updated}/${toUpdate.length}`);
        }
      }
      console.log(`Done updating ${col}.`);
    } else {
      console.log(`No documents need updating in ${col}.`);
    }
  }

  console.log('\nNormalization complete!');
}

main().catch(err => {
  console.error('Error running normalization:', err);
  process.exit(1);
});
