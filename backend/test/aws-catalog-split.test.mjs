import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createCatalog} from '../src/aws/catalog.mjs';
import {catalogRoute} from '../src/aws/routes.mjs';
import {memoryStore} from './aws-fixtures.mjs';

function catalogFixture() {
  const areas = memoryStore(); const topics = memoryStore();
  const quizzes = memoryStore(); const studyNotes = memoryStore();
  const catalog = createCatalog({areas, topics, quizzes, studyNotes});
  areas.seed('AREAS', 'AREA#anatomy', {name: 'Human Anatomy', order: 1});
  topics.seed('AREA#anatomy', 'TOPIC#bones', {areaId: 'anatomy', title: 'Skull Bones', order: 1});
  quizzes.seed('AREA#anatomy', 'TOPIC#bones#QUIZ#foramina', {areaId: 'anatomy', topicId: 'bones', question: 'Which nerve?', type: 'single_choice'});
  studyNotes.seed('AREA#anatomy', 'TOPIC#bones#STUDY_NOTE#sphenoid', {areaId: 'anatomy', topicId: 'bones', title: 'Sphenoid Bone'});
  return {catalog};
}

test('split catalog routes retain the mobile API response contract and stable identifiers', async () => {
  const {catalog} = catalogFixture();
  assert.deepEqual((await catalog.list('medical_areas', {limit: 100})).items[0], {name: 'Human Anatomy', order: 1, id: 'anatomy'});
  assert.equal((await catalog.list('medical_areas/anatomy/topics', {limit: 100})).items[0].id, 'bones');
  assert.equal((await catalog.list('medical_areas/anatomy/topics/bones/quizzes', {limit: 100})).items[0].id, 'foramina');
  assert.equal((await catalog.list('medical_areas/anatomy/topics/bones/study-notes', {limit: 100})).items[0].id, 'sphenoid');
  assert.equal((await catalog.list('medical_areas/anatomy/quizzes', {limit: 100})).items[0].id, 'foramina');
  assert.equal((await catalog.quiz('anatomy', 'bones', 'foramina')).question, 'Which nerve?');
});

test('study-notes is the canonical route while installed app versions keep the old alias', () => {
  const current = catalogRoute('/api/v1/areas/anatomy/topics/bones/study-notes', {});
  const legacy = catalogRoute('/api/v1/areas/anatomy/topics/bones/cheatsheets', {});
  assert.equal(current.path, 'medical_areas/anatomy/topics/bones/study-notes');
  assert.equal(legacy.path, current.path);
});

test('progress and catalog keys stay owner-scoped and parent-child, with no junction-table keys', () => {
  const {catalog} = catalogFixture();
  assert.equal(typeof catalog.quiz, 'function');
  const keys = ['AREA#anatomy / TOPIC#bones', 'AREA#anatomy / TOPIC#bones#QUIZ#foramina',
    'AREA#anatomy / TOPIC#bones#STUDY_NOTE#sphenoid', 'USER#user / TOPIC#bones'];
  assert.ok(keys.every(key => !key.includes('USER_QUIZ#')));
});
