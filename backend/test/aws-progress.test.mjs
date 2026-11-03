import {test} from 'node:test';
import assert from 'node:assert/strict';
import {fixture, seedQuiz, quiz} from './aws-fixtures.mjs';
import {score} from '../src/aws/scoring.mjs';
const answer = (quizId, number = 1) => ({areaId: quiz.areaId, quizId, expectedAttemptNumber: number,
  answer: {selectedOptionText: 'Option B', selectedOptionIndex: 0}});
const key = count => `00000000-0000-4000-8000-${String(count).padStart(12, '0')}`;
test('server derives stars from canonical text and ignores shuffled presentation index', () => {
  assert.deepEqual(score(quiz, {selectedOptionText: 'Option B', selectedOptionIndex: 0}),
    {isAnswered: true, isCorrect: true, earnedStars: 1, maxStars: 1, selectedOptionIndex: 0});
  assert.equal(score(quiz, {selectedOptionText: 'Option A'}).earnedStars, 0);
  assert.throws(() => score(quiz, {earnedStars: 999}), error => error.status === 400);
});
test('matching and ordering validate complete permutations and compute partial credit', () => {
  const matching = {...quiz, type: 'matching', matchingPairs: [{left: 'L1', right: 'R1'}, {left: 'L2', right: 'R2'}]};
  assert.equal(score(matching, {pairs: [{left: 'L2', right: 'R2'}, {left: 'L1', right: 'R1'}]}).earnedStars, 2);
  assert.throws(() => score(matching, {pairs: [{left: 'L1', right: 'R1'}]}), error => error.status === 400);
  const ordering = {...quiz, type: 'ordering', orderingItems: ['one', 'two', 'three']};
  assert.equal(score(ordering, {items: ['one', 'three', 'two']}).earnedStars, 1);
  assert.throws(() => score(ordering, {items: ['one', 'one', 'two']}), error => error.status === 400);
});
test('parallel answers preserve both records using conditional writes', async () => {
  const {store, progress} = fixture(); seedQuiz(store); seedQuiz(store, 'question-2');
  await Promise.all([progress.answer('owner-a', quiz.topicId, answer('question-1')), progress.answer('owner-a', quiz.topicId, answer('question-2'))]);
  const output = await progress.list('owner-a', {});
  assert.equal(output.items[0].activeAttempt.totalEarnedStars, 2);
  assert.equal(Object.keys(output.items[0].activeAttempt.questionAnswers).length, 2);
});
test('answer retries are idempotent and contradictory replays/stale cycles are rejected', async () => {
  const {store, progress} = fixture(); seedQuiz(store);
  const first = await progress.answer('owner-a', quiz.topicId, answer('question-1'));
  const replay = await progress.answer('owner-a', quiz.topicId, answer('question-1'));
  assert.equal(replay.version, first.version);
  await assert.rejects(progress.answer('owner-a', quiz.topicId, {...answer('question-1'), answer: {selectedOptionText: 'Option A'}}), error => error.code === 'already_answered');
  await progress.retry('owner-a', quiz.topicId, {areaId: quiz.areaId, expectedAttemptNumber: 1, idempotencyKey: key(1)});
  await assert.rejects(progress.answer('owner-a', quiz.topicId, answer('question-1')), error => error.code === 'attempt_changed');
});
test('retry archives only answered attempts, retains FIFO3, and supports request replay', async () => {
  const {store, progress} = fixture(); seedQuiz(store);
  let final;
  for (let number = 1; number <= 5; number++) {
    await progress.answer('owner-a', quiz.topicId, answer('question-1', number));
    const input = {areaId: quiz.areaId, expectedAttemptNumber: number, idempotencyKey: key(number)};
    final = await progress.retry('owner-a', quiz.topicId, input);
    assert.equal((await progress.retry('owner-a', quiz.topicId, input)).version, final.version);
  }
  assert.deepEqual(final.progress.history.map(attempt => attempt.attemptNumber), [3, 4, 5]);
  assert.equal(final.progress.currentAttemptNumber, 6);
  assert.equal(final.progress.activeAttempt.totalMaxStars, 1);
  assert.equal((await progress.list('owner-b', {})).items.length, 0);
});
test('pagination rejects cursors bound to another user or collection', async () => {
  const {store, progress} = fixture();
  for (const id of ['a', 'b']) store.seed('USER#owner-a', `TOPIC#${id}`, {topicId: id});
  const output = await progress.list('owner-a', {limit: 1});
  assert.ok(output.nextCursor);
  await assert.rejects(progress.list('owner-b', {limit: 1, cursor: output.nextCursor}), error => error.status === 400);
});
