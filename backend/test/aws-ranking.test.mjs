import {test} from 'node:test';
import assert from 'node:assert/strict';
import {fixture, seedQuiz, quiz} from './aws-fixtures.mjs';
const input = number => ({areaId: quiz.areaId, quizId: 'question-1', expectedAttemptNumber: number, answer: {selectedOptionText: 'Option B'}});
test('server ranking is atomic with answer acceptance and retries never double-count', async () => {
  const {store, progress} = fixture(); seedQuiz(store);
  const one = input(1);
  await Promise.all([progress.answer('owner-a', quiz.topicId, one), progress.answer('owner-a', quiz.topicId, one)]);
  const rank = (await store.get('LEADERBOARD', 'USER#owner-a')).data;
  assert.equal(rank.totalStars, 1); assert.equal(rank.completedQuizzesCount, 1);
  assert.equal(rank.averageTimeSeconds, null); assert.equal(rank.totalQuizTimeSeconds, null);
  assert.equal(await store.get('LEADERBOARD', 'USER#owner-b'), null);
});
test('parallel topics accumulate the same owner ranking without lost updates', async () => {
  const {store, progress} = fixture(); seedQuiz(store);
  store.seed('AREA#synthetic-area', 'TOPIC#topic-2#QUIZ#question-1', {...quiz, topicId: 'topic-2'});
  await Promise.all([progress.answer('owner-a', quiz.topicId, input(1)), progress.answer('owner-a', 'topic-2', input(1))]);
  const rank = (await store.get('LEADERBOARD', 'USER#owner-a')).data;
  assert.equal(rank.totalStars, 2); assert.equal(rank.completedQuizzesCount, 2);
});
test('archiving FIFO3 does not erase cumulative server ranking and stale answers cannot inflate it', async () => {
  const {store, progress} = fixture(); seedQuiz(store);
  await progress.answer('owner-a', quiz.topicId, input(1));
  await progress.retry('owner-a', quiz.topicId, {areaId: quiz.areaId, expectedAttemptNumber: 1, idempotencyKey: '00000000-0000-4000-8000-000000000001'});
  await assert.rejects(progress.answer('owner-a', quiz.topicId, input(1)), error => error.code === 'attempt_changed');
  await progress.answer('owner-a', quiz.topicId, input(2));
  assert.equal((await store.get('LEADERBOARD', 'USER#owner-a')).data.totalStars, 2);
});
