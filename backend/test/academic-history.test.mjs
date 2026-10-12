import test from 'node:test';
import { ApiError } from '../dist/http.mjs';
import assert from 'node:assert/strict';
import { DynamoHistoryRepository } from '../dist/academic-history/repository.js';
import { DynamoQuizRepository } from '../dist/quizzes/repository.js';
import { buildQuestionSnapshot, scoreAnswer } from '../dist/quizzes/scoring.js';
import { MemoryAcademicClient, fixtureQuiz, contentItem, uuid } from './quiz-repository-fixtures.mjs';
function setup() {
  const client = new MemoryAcademicClient(); let index = 100; let now = new Date('2026-10-14T10:00:00Z');
  for (let i = 1; i <= 3; i++) client.seed('content', contentItem(fixtureQuiz(i)));
  const quiz = new DynamoQuizRepository(client, 'content', 'private', buildQuestionSnapshot, () => now, () => uuid(index++));
  const history = new DynamoHistoryRepository(client, 'private');
  return { client, quiz, history, advance: seconds => { now = new Date(now.getTime() + seconds * 1000); } };
}
async function submit(quiz, attempt) {
  const scored = scoreAnswer(attempt.snapshot, { choiceId: attempt.snapshot.presentation.choiceIds[0] });
  return quiz.submit('student-a', attempt.quizId, attempt.id, scored.answer, scored.fingerprint, scored.result);
}
test('history projects real submissions once and never invents pending results', async () => {
  const { quiz, history, advance, client } = setup();
  const started = await quiz.start('student-a', fixtureQuiz().id, uuid(1));
  assert.deepEqual(await history.list('student-a'), { items: [], nextCursor: null });
  await assert.rejects(history.get('student-a', started.id), error => error.status === 404);
  advance(12); await submit(quiz, started); await submit(quiz, started);
  const page = await history.list('student-a'); assert.equal(page.items.length, 1);
  const entry = page.items[0]; assert.equal(entry.id, started.id); assert.equal(entry.durationSeconds, 12);
  assert.equal(entry.score, 1); assert.equal(entry.earnedStars, 1); assert.equal(entry.status, 'submitted');
  assert.equal(entry.quizTitle, 'Local test fixture'); assert.equal(entry.selectedOptionIndex, null);
  assert.ok(!JSON.stringify(entry).includes('correctIndex')); assert.ok(!JSON.stringify(entry).includes('rationale'));
  assert.deepEqual(await history.get('student-a', started.id), entry);
  assert.ok(client.calls.filter(call => call.constructor.name === 'QueryCommand').every(call => !call.input.IndexName));
});
test('history chronology, deterministic date ties, paging and owner-bound cursors', async () => {
  const { quiz, history, advance } = setup(); const attempts = [];
  for (let i = 1; i <= 3; i++) {
    const started = await quiz.start('student-a', fixtureQuiz(i).id, uuid(i)); await submit(quiz, started); attempts.push(started.id);
    if (i === 1) advance(10);
  }
  const page = await history.list('student-a', { limit: 1 }); assert.equal(page.items[0].id, attempts[2]); assert.ok(page.nextCursor);
  const second = await history.list('student-a', { limit: 1, cursor: page.nextCursor }); assert.equal(second.items[0].id, attempts[1]);
  const third = await history.list('student-a', { limit: 1, cursor: second.nextCursor }); assert.equal(third.items[0].id, attempts[0]); assert.equal(third.nextCursor, null);
  await assert.rejects(history.list('student-b', { cursor: page.nextCursor }), error => error.status === 400);
  await assert.rejects(history.get('student-b', attempts[0]), error => error.status === 404);
  assert.deepEqual(await history.list('student-b'), { items: [], nextCursor: null });
});
test('existing unprojected canonical attempts remain directly readable without backfill', async () => {
  const { quiz, history, client } = setup(); const started = await quiz.start('student-a', fixtureQuiz().id, uuid(1)); await submit(quiz, started);
  for (const [key, item] of client.records) if (item.entryKey?.startsWith('HISTORY#')) client.records.delete(key);
  assert.deepEqual(await history.list('student-a'), { items: [], nextCursor: null });
  assert.equal((await history.get('student-a', started.id)).earnedStars, 1);
});
test('history fails closed on invalid parameters and unavailable storage', async () => {
  const { history, client } = setup();
  await assert.rejects(history.list('student-a', { limit: 51 }), error => error.status === 400);
  await assert.rejects(history.list('student-a', { cursor: 'invalid' }), error => error.status === 400);
  await assert.rejects(history.get('student-a', '../student-b'), error => error.status === 400);
  await assert.rejects(new DynamoHistoryRepository(client, '').list('student-a'), error => error.status === 503);
});
test('completion projection happens once only after whole pinned topic and uses first actual server start', async () => {
  const client = new MemoryAcademicClient(); const quiz = fixtureQuiz(); client.seed('content', contentItem(quiz));
  let now = new Date('2026-10-14T10:00:00Z'); let sequence = 100; const completions = [];
  const repo = new DynamoQuizRepository(client, 'content', 'private', buildQuestionSnapshot, () => now, () => uuid(sequence++),
    async (subject, topic, date) => { completions.push({ subject, topic, date }); return []; });
  await repo.retry('student-a', quiz.areaId, quiz.topicId, uuid(1), 1); now = new Date(now.getTime() + 86_400_000);
  const started = await repo.start('student-a', quiz.id, uuid(2)); now = new Date(now.getTime() + 9000);
  await submit(repo, started); await submit(repo, started);
  assert.equal(completions.length, 1); assert.equal(completions[0].topic.catalogQuestionCount, 1);
  assert.equal(new Date(completions[0].topic.activeAttempt.completedAt) - new Date(completions[0].topic.activeAttempt.startedAt), 9000);
  now = new Date(now.getTime() + 20_000); const retry = await repo.retry('student-a', quiz.areaId, quiz.topicId, uuid(3), 1);
  assert.equal(retry.history[0].completedAt, completions[0].topic.activeAttempt.completedAt);
  assert.ok(!('catalogQuestionCount' in retry));
});
test('transient ranking projection collisions retry atomically without partial history or double awards', async () => {
  const client = new MemoryAcademicClient(); const quiz = fixtureQuiz(); client.seed('content', contentItem(quiz));
  const original = client.send.bind(client); let rejected = 0; let prepared = 0;
  client.send = async command => {
    if (command.constructor.name === 'TransactWriteCommand' && command.input.TransactItems.some(item => item.Put?.Item.entityType === 'ACADEMIC_HISTORY') && rejected++ < 2) {
      const error = new Error('Projection CAS changed'); error.name = 'TransactionCanceledException'; error.CancellationReasons = [{ Code: 'ConditionalCheckFailed' }]; throw error;
    }
    return original(command);
  };
  const repo = new DynamoQuizRepository(client, 'content', 'private', buildQuestionSnapshot, () => new Date('2026-10-14T10:00:00Z'), () => uuid(100),
    async () => { prepared++; return []; });
  const started = await repo.start('student-a', quiz.id, uuid(1)); await submit(repo, started); await submit(repo, started);
  assert.equal(prepared, 3); const history = new DynamoHistoryRepository(client, 'private');
  assert.equal((await history.list('student-a')).items.length, 1);
});

test('ranking preparation races retry only the known conflict before committing exactly once', async () => {
  const client = new MemoryAcademicClient(); const record = fixtureQuiz(); client.seed('content', contentItem(record));
  let prepared = 0;
  const repo = new DynamoQuizRepository(client, 'content', 'private', buildQuestionSnapshot, () => new Date('2026-10-14T10:00:00Z'), () => uuid(100),
    async () => { if (++prepared <= 2) throw new ApiError(409, 'ranking_changed', 'Refresh ranking.'); return []; });
  const started = await repo.start('student-a', record.id, uuid(1));
  const first = await submit(repo, started); assert.equal(first.isReplay, false); assert.equal(prepared, 3);
  assert.equal((await submit(repo, started)).isReplay, true); assert.equal(prepared, 3);
  assert.equal((await new DynamoHistoryRepository(client, 'private').list('student-a')).items.length, 1);
});
test('ranking preparation exhaustion leaves result, progress and history uncommitted', async () => {
  const client = new MemoryAcademicClient(); const record = fixtureQuiz(); client.seed('content', contentItem(record));
  let prepared = 0;
  const repo = new DynamoQuizRepository(client, 'content', 'private', buildQuestionSnapshot, () => new Date('2026-10-14T10:00:00Z'), () => uuid(100),
    async () => { prepared++; throw new ApiError(409, 'ranking_changed', 'Refresh ranking.'); });
  const started = await repo.start('student-a', record.id, uuid(1));
  await assert.rejects(submit(repo, started), error => error.status === 409); assert.equal(prepared, 3);
  assert.equal((await repo.getAttempt('student-a', record.id, started.id)).status, 'started');
  assert.equal((await repo.progress('student-a')).items[0].activeAttempt.totalEarnedStars, 0);
  assert.deepEqual(await new DynamoHistoryRepository(client, 'private').list('student-a'), { items: [], nextCursor: null });
});
test('unknown ranking errors are not treated as concurrency conflicts', async () => {
  const client = new MemoryAcademicClient(); const record = fixtureQuiz(); client.seed('content', contentItem(record));
  let prepared = 0;
  const repo = new DynamoQuizRepository(client, 'content', 'private', buildQuestionSnapshot, () => new Date('2026-10-14T10:00:00Z'), () => uuid(100),
    async () => { prepared++; throw new ApiError(409, 'unrelated_conflict', 'Unavailable.'); });
  const started = await repo.start('student-a', record.id, uuid(1));
  await assert.rejects(submit(repo, started), error => error.code === 'unrelated_conflict'); assert.equal(prepared, 1);
});
