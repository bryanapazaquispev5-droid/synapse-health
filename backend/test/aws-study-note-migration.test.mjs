import test from 'node:test';
import assert from 'node:assert/strict';
import {renameStudyNote} from '../scripts/rename-study-notes-table.mjs';

test('renames only the study-note sort-key prefix and preserves content', () => {
  const source = {PK: 'AREA#anatomy', SK: 'TOPIC#bones#CHEATSHEET#sphenoid', title: 'Sphenoid', content: 'Notes'};
  assert.deepEqual(renameStudyNote(source), {
    PK: 'AREA#anatomy', SK: 'TOPIC#bones#STUDY_NOTE#sphenoid', title: 'Sphenoid', content: 'Notes',
  });
  assert.equal(source.SK, 'TOPIC#bones#CHEATSHEET#sphenoid');
});

test('refuses keys outside the study-note catalog schema', () => {
  assert.throws(() => renameStudyNote({PK: 'USER#123', SK: 'PROFILE'}), /expected study-note key format/);
});
