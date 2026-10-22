import test from 'node:test';
import assert from 'node:assert/strict';
import { buildQuestionSnapshot, publicQuestion, scoreAnswer } from '../dist/quizzes/scoring.js';
const quiz = { id: 'question', areaId: 'area', topicId: 'topic', version: 1, type: 'single_choice', question: 'Test prompt', options: ['A', 'B', 'C'], correctIndex: 1, rationale: 'PRIVATE', sourceBook: 'Test source', orderIndex: 1, matchingPairs: [], orderingItems: [] };
const result = (snapshot, answer) => scoreAnswer(snapshot, answer).result;
test('choice scoring trusts stored key, not submitted stars', () => {
  const snapshot = buildQuestionSnapshot(quiz);
  assert.deepEqual(result(snapshot, { choiceId: snapshot.presentation.choiceIds[1] }), { isCorrect: true, score: 1, earnedStars: 1, maxStars: 1 });
  assert.equal(result(snapshot, { choiceId: snapshot.presentation.choiceIds[0] }).earnedStars, 0);
  assert.throws(() => scoreAnswer(snapshot, { choiceId: snapshot.presentation.choiceIds[1], stars: 100 }), { status: 400 });
});
test('matching awards partial stars and one score only for full correctness', () => {
  const snapshot = buildQuestionSnapshot({ ...quiz, type: 'matching', matchingPairs: [{ left: 'A', right: '1' }, { left: 'B', right: '2' }, { left: 'C', right: '3' }] });
  const ids = snapshot.presentation;
  const pairs = ids.leftIds.map((leftId, i) => ({ leftId, rightId: ids.rightIds[i] }));
  assert.equal(result(snapshot, { pairs }).earnedStars, 3);
  const partial = { pairs: pairs.map((pair, i) => ({ ...pair, rightId: ids.rightIds[[0, 2, 1][i]] })) };
  assert.deepEqual(result(snapshot, partial), { isCorrect: false, score: 0, earnedStars: 1, maxStars: 3 });
  assert.equal(scoreAnswer(snapshot, { pairs }).fingerprint, scoreAnswer(snapshot, { pairs: [...pairs].reverse() }).fingerprint);
});
test('ordering awards one star per correct position', () => {
  const snapshot = buildQuestionSnapshot({ ...quiz, type: 'ordering', orderingItems: ['A', 'B', 'C'] });
  const ids = snapshot.presentation.itemIds;
  assert.deepEqual(result(snapshot, { itemIds: [ids[0], ids[2], ids[1]] }), { isCorrect: false, score: 0, earnedStars: 1, maxStars: 3 });
  assert.equal(result(snapshot, { itemIds: ids }).score, 1);
});
for (const type of ['single_choice', 'matching', 'ordering']) test(`public ${type} question omits private answer keys`, () => {
  const snapshot = buildQuestionSnapshot({ ...quiz, type, question: type === 'single_choice' ? 'Test prompt' : 'Test prompt\n1. PRIVATE solution', matchingPairs: [{ left: 'A', right: '1' }], orderingItems: ['A', 'B'] });
  const value = publicQuestion(snapshot);
  for (const key of ['correctIndex', 'rationale', 'matchingPairs', 'orderingItems', 'presentation', 'version']) assert.equal(Object.hasOwn(value, key), false);
  assert.equal(JSON.stringify(value).includes('PRIVATE'), false);
  assert.equal(value.question, 'Test prompt');
});
test('presentation ids are opaque and independently randomized per snapshot', () => {
  const first = buildQuestionSnapshot(quiz), second = buildQuestionSnapshot(quiz);
  assert.notDeepEqual(first.presentation.choiceIds, second.presentation.choiceIds);
  assert.equal(new Set(first.presentation.choiceIds).size, 3);
});
test('invalid choice payloads are rejected', () => {
  const snapshot = buildQuestionSnapshot(quiz);
  for (const input of [null, [], {}, { choiceId: 'alien' }, { choiceId: 0 }, { choiceId: snapshot.presentation.choiceIds[1], userId: 'other' }]) assert.throws(() => scoreAnswer(snapshot, input), { status: 400 });
});
test('matching requires all distinct left and right ids exactly once', () => {
  const snapshot = buildQuestionSnapshot({ ...quiz, type: 'matching', matchingPairs: [{ left: 'A', right: '1' }, { left: 'B', right: '2' }] });
  const { leftIds, rightIds } = snapshot.presentation;
  for (const pairs of [[], [{ leftId: leftIds[0], rightId: rightIds[0] }], [{ leftId: leftIds[0], rightId: rightIds[0] }, { leftId: leftIds[0], rightId: rightIds[1] }], [{ leftId: leftIds[0], rightId: rightIds[0] }, { leftId: leftIds[1], rightId: rightIds[0] }]]) assert.throws(() => scoreAnswer(snapshot, { pairs }), { status: 400 });
});
test('ordering rejects missing, extra, duplicate, unknown ids and wrong union', () => {
  const snapshot = buildQuestionSnapshot({ ...quiz, type: 'ordering', orderingItems: ['A', 'B'] });
  const ids = snapshot.presentation.itemIds;
  for (const input of [{ itemIds: [] }, { itemIds: [ids[0], ids[0]] }, { itemIds: [ids[0], 'alien'] }, { itemIds: [...ids, 'extra'] }, { choiceId: ids[0] }]) assert.throws(() => scoreAnswer(snapshot, input), { status: 400 });
});

test('equivalent duplicate text preserves Flutter matching and ordering comparisons', () => {
  const matching = buildQuestionSnapshot({ ...quiz, type: 'matching', matchingPairs: [{ left: 'A', right: 'same' }, { left: 'B', right: 'same' }] });
  const ids = matching.presentation;
  assert.equal(result(matching, { pairs: [{ leftId: ids.leftIds[0], rightId: ids.rightIds[1] }, { leftId: ids.leftIds[1], rightId: ids.rightIds[0] }] }).earnedStars, 2);
  const ordering = buildQuestionSnapshot({ ...quiz, type: 'ordering', orderingItems: ['same', 'same'] });
  assert.equal(result(ordering, { itemIds: [...ordering.presentation.itemIds].reverse() }).earnedStars, 2);
});
test('invalid private catalog data fails closed without exposing answers', () => {
  for (const invalid of [{ ...quiz, correctIndex: 99 }, { ...quiz, type: 'matching' }, { ...quiz, type: 'ordering' }, { ...quiz, type: 'unknown' }, { ...quiz, options: null }, { ...quiz, sourceBook: { secret: 'PRIVATE' } }, { ...quiz, orderIndex: '1' }, { ...quiz, version: 0 }, { ...quiz, areaId: '' }, { ...quiz, id: '/bad' }, { ...quiz, question: '' }]) assert.throws(() => buildQuestionSnapshot(invalid), { status: 503 });
});
