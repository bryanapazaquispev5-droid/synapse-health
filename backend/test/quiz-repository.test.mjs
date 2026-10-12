import test from 'node:test';
import assert from 'node:assert/strict';
import { DynamoQuizRepository } from '../dist/quizzes/repository.js';
import { buildQuestionSnapshot, scoreAnswer } from '../dist/quizzes/scoring.js';
import { fixtureQuiz, contentItem, MemoryAcademicClient, uuid } from './quiz-repository-fixtures.mjs';
function setup() {
  const client = new MemoryAcademicClient(); const quiz = fixtureQuiz(); client.seed('content', contentItem(quiz));
  let now = new Date('2026-10-12T10:00:00Z'); let index = 100;
  const repo = new DynamoQuizRepository(client, 'content', 'private', buildQuestionSnapshot, () => now, () => uuid(index++));
  return { repo, client, quiz, advance: seconds => { now = new Date(now.getTime() + seconds * 1000); } };
}
async function answer(repo, attempt, answer = { choiceId: attempt.snapshot.presentation.choiceIds[0] }) {
  const scored = scoreAnswer(attempt.snapshot, answer);
  return repo.submit('student-a', attempt.quizId, attempt.id, scored.answer, scored.fingerprint, scored.result);
}
test('catalog direct lookup and scope-bound filtered pagination use Query, not Scan', async () => {
  const { repo, client, quiz } = setup(); const other = fixtureQuiz(2, 'matching', 'other'); client.seed('content', contentItem(other));
  assert.deepEqual(await repo.get(quiz.id), quiz);
  const first = await repo.list('fixture-area', { limit: 1, topicId: 'other' }); assert.equal(first.items.length, 0); assert.ok(first.nextCursor);
  const second = await repo.list('fixture-area', { limit: 1, topicId: 'other', cursor: first.nextCursor }); assert.equal(second.items[0].id, other.id);
  await assert.rejects(repo.list('other-area', { cursor: first.nextCursor }), error => error.status === 400);
  assert.ok(!client.calls.some(command => command.constructor.name === 'ScanCommand'));
});
test('start snapshots private solutions, is idempotent and safely resumes without resetting timer', async () => {
  const { repo, quiz } = setup(); const attempt = await repo.start('student-a', quiz.id, uuid(1));
  assert.deepEqual(await repo.start('student-a', quiz.id, uuid(1)), attempt);
  assert.deepEqual(await repo.start('student-a', quiz.id, uuid(2)), attempt);
  assert.equal(attempt.snapshot.quiz.correctIndex, 0);
  await assert.rejects(repo.getAttempt('student-b', quiz.id, attempt.id), error => error.status === 404);
});
test('server timestamps, immutable response, duplicate submissions and tampered answers', async () => {
  const { repo, quiz, advance } = setup(); const attempt = await repo.start('student-a', quiz.id, uuid(1)); advance(19);
  const first = await answer(repo, attempt); assert.equal(first.isReplay, false); assert.equal(first.result.durationSeconds, 19);
  assert.equal(first.result.earnedStars, 1); assert.equal(first.result.isAnswered, true);
  advance(100); const second = await answer(repo, attempt); assert.equal(second.isReplay, true); assert.deepEqual(second.result, first.result);
  await assert.rejects(answer(repo, attempt, { choiceId: attempt.snapshot.presentation.choiceIds[1] }), error => error.status === 409);
  const progress = await repo.progress('student-a'); assert.equal(progress.items[0].activeAttempt.totalEarnedStars, 1);
  assert.equal(progress.items[0].activeAttempt.totalMaxStars, 1); assert.ok(!('inFlight' in progress.items[0]));
  assert.deepEqual(await repo.progress('student-b'), { items: [], nextCursor: null });
});
test('retry is FIFO three, never accumulates historical stars, and protects stale or duplicate resets', async () => {
  const { repo, quiz } = setup();
  for (let cycle = 1; cycle <= 5; cycle++) {
    const started = await repo.start('student-a', quiz.id, uuid(cycle)); await answer(repo, started);
    const progress = await repo.retry('student-a', quiz.areaId, quiz.topicId, uuid(20 + cycle), cycle);
    assert.equal(progress.currentAttemptNumber, cycle + 1); assert.equal(progress.activeAttempt.totalEarnedStars, 0);
    assert.equal(progress.history.length, Math.min(cycle, 3));
    assert.deepEqual(await repo.retry('student-a', quiz.areaId, quiz.topicId, uuid(20 + cycle), cycle), progress);
    await assert.rejects(repo.retry('student-a', quiz.areaId, quiz.topicId, uuid(40 + cycle), cycle), error => error.status === 409);
  }
  const progress = (await repo.progress('student-a')).items[0]; assert.deepEqual(progress.history.map(item => item.attemptNumber), [3, 4, 5]);
});
test('empty retry does not increment cycle or invalidate in-flight question', async () => {
  const { repo, quiz } = setup(); const started = await repo.start('student-a', quiz.id, uuid(1));
  const progress = await repo.retry('student-a', quiz.areaId, quiz.topicId, uuid(2), 1);
  assert.equal(progress.currentAttemptNumber, 1); assert.equal(progress.history.length, 0);
  assert.equal((await answer(repo, started)).result.earnedStars, 1);
});
test('real retry invalidates outstanding question and subject-bound cursors cannot cross users', async () => {
  const { repo, client, quiz } = setup(); const other = fixtureQuiz(2); client.seed('content', contentItem(other));
  const first = await repo.start('student-a', quiz.id, uuid(1)); const second = await repo.start('student-a', other.id, uuid(2));
  await answer(repo, first); await repo.retry('student-a', quiz.areaId, quiz.topicId, uuid(3), 1);
  await assert.rejects(answer(repo, second), error => error.status === 409);
  const otherTopic = fixtureQuiz(3, 'single_choice', 'other-topic'); client.seed('content', contentItem(otherTopic));
  await repo.start('student-a', otherTopic.id, uuid(4));
  const page = await repo.progress('student-a', { limit: 1 }); assert.ok(page.nextCursor);
  await assert.rejects(repo.progress('student-b', { cursor: page.nextCursor }), error => error.status === 400);
});
test('catalog changes after server start cannot change grading snapshot', async () => {
  const { repo, client, quiz } = setup(); const started = await repo.start('student-a', quiz.id, uuid(1));
  client.seed('content', contentItem({ ...quiz, version: 2, correctIndex: 1 }));
  assert.equal((await answer(repo, started)).result.isCorrect, true);
});
test('missing configuration fails closed and idempotency keys cannot switch operation', async () => {
  const { repo, client, quiz } = setup(); await repo.start('student-a', quiz.id, uuid(1));
  await assert.rejects(repo.retry('student-a', quiz.areaId, quiz.topicId, uuid(1), 1), error => error.status === 409);
  const unavailable = new DynamoQuizRepository(client, '', '', buildQuestionSnapshot);
  await assert.rejects(unavailable.get(quiz.id), error => error.status === 503);
  await assert.rejects(unavailable.progress('student-a'), error => error.status === 503);
});

test('malformed persisted catalog metadata and private answer keys fail closed', async () => {
  const { repo, client, quiz } = setup();
  for (const patch of [{ sourceBook: { secret: 'never-public' } }, { correctIndex: 100 }, { type: 'unknown' }, { areaId: 'other-area' }]) {
    const item = { ...contentItem(quiz), ...patch }; client.seed('content', item);
    await assert.rejects(repo.get(quiz.id), error => error.status === 503);
  }
});

test('unservable question schemas cannot inflate the topic star denominator', async () => {
  for (const patch of [
    { type: 'single_choice', options: ['Only choice'] },
    { type: 'ordering', orderingItems: Array(101).fill('Fixture') },
    { type: 'matching', matchingPairs: [{ left: 'Same', right: 'A' }, { left: 'Same', right: 'B' }] },
  ]) {
    const { repo, client, quiz } = setup();
    client.seed('content', contentItem({ ...fixtureQuiz(2), ...patch }));
    await assert.rejects(repo.start('student-a', quiz.id, uuid(100)), error => error.status === 503);
  }
});

test('active topic pins catalog and denominator until explicit retry establishes new bank', async () => {
  const { repo, client, quiz } = setup(); const started = await repo.start('student-a', quiz.id, uuid(1));
  client.seed('content', contentItem({ ...quiz, version: 2, type: 'matching' }));
  await assert.rejects(repo.start('student-a', quiz.id, uuid(2)), error => error.status === 409);
  const result = await answer(repo, started); assert.equal(result.result.maxStars, 1);
  const before = (await repo.progress('student-a')).items[0]; assert.equal(before.activeAttempt.totalMaxStars, 1);
  assert.equal(before.activeAttempt.totalEarnedStars, 1); assert.ok(!('catalogFingerprint' in before));
  const reset = await repo.retry('student-a', quiz.areaId, quiz.topicId, uuid(3), 1);
  assert.equal(reset.activeAttempt.totalMaxStars, 2); assert.equal(reset.history[0].totalMaxStars, 1);
  const next = await repo.start('student-a', quiz.id, uuid(4)); assert.equal(next.snapshot.quiz.type, 'matching');
});
test('changed catalog empty retry clears stale timers without increasing academic attempt number', async () => {
  const { repo, client, quiz } = setup(); const started = await repo.start('student-a', quiz.id, uuid(1));
  client.seed('content', contentItem({ ...quiz, version: 2, type: 'ordering' }));
  const reset = await repo.retry('student-a', quiz.areaId, quiz.topicId, uuid(2), 1);
  assert.equal(reset.currentAttemptNumber, 1); assert.equal(reset.activeAttempt.totalMaxStars, 2);
  await assert.rejects(answer(repo, started), error => error.status === 409);
  const next = await repo.start('student-a', quiz.id, uuid(3)); assert.notEqual(next.id, started.id);
  assert.equal(next.snapshot.quiz.version, 2);
});
