import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createRateLimiter} from '../src/rate-limiter.mjs';
import {createProfileRepository} from '../src/profile-repository.mjs';
import {MemoryFirestore} from './memory-firestore.mjs';

test('distributed limiter atomically counts concurrent requests', async () => {
  const db = new MemoryFirestore();
  const limiter = createRateLimiter(db, {limit: 2, now: () => 1000});
  const results = await Promise.allSettled(Array.from({length: 10}, () => limiter.consume('student')));
  assert.equal(results.filter(result => result.status === 'fulfilled').length, 2);
  for (const result of results.filter(result => result.status === 'rejected')) {
    assert.equal(result.reason.status, 429);
    assert.equal(result.reason.headers['Retry-After'], '59');
  }
  assert.equal(db.documents.size, 1);
  assert.ok(![...db.documents.keys()][0].includes('student'));
});
test('rate window resets and separate users are isolated', async () => {
  const db = new MemoryFirestore(); let time = 1000;
  const limiter = createRateLimiter(db, {limit: 1, now: () => time});
  await limiter.consume('alice'); await limiter.consume('bob');
  await assert.rejects(limiter.consume('alice'), error => error.status === 429);
  time = 61000; await limiter.consume('alice');
});
test('corrupt rate count fails closed', async () => {
  const db = new MemoryFirestore();
  const limiter = createRateLimiter(db, {limit: 1, now: () => 1000});
  await limiter.consume('alice');
  db.documents.values().next().value.count = -1;
  await assert.rejects(limiter.consume('alice'), error => error.status === 503);
});
test('invalid limiter configuration rejected', () => {
  for (const limit of [0, -1, 0.1, NaN]) assert.throws(() => createRateLimiter({}, {limit}));
});
test('profile reads owner document and excludes private extra fields', async () => {
  const db = new MemoryFirestore();
  db.documents.set('users/alice', {uid: 'alice', name: 'Test name', privateNote: 'test-only',
    createdAt: {toDate: () => new Date('2026-01-01T00:00:00Z')}});
  const profile = await createProfileRepository(db, () => 'timestamp').get('alice');
  assert.equal(profile.uid, 'alice'); assert.equal(profile.privateNote, undefined);
  assert.equal(profile.createdAt, '2026-01-01T00:00:00.000Z');
});
test('profile owner mismatch and missing profile denied', async () => {
  const db = new MemoryFirestore(); db.documents.set('users/alice', {uid: 'bob'});
  const repo = createProfileRepository(db, () => 'timestamp');
  await assert.rejects(repo.get('alice'), error => error.status === 403);
  await assert.rejects(repo.get('missing'), error => error.status === 404);
  await assert.rejects(repo.get('alice/secret'), error => error.status === 401);
});
test('profile update preserves existing fields and uses server timestamp', async () => {
  const db = new MemoryFirestore(); db.documents.set('users/alice', {uid: 'alice', name: 'Old', career: 'Existing'});
  const result = await createProfileRepository(db, () => 'server-timestamp').update('alice', {name: 'New'});
  assert.equal(result.name, 'New'); assert.equal(result.career, 'Existing');
  assert.equal(db.documents.get('users/alice').updatedAt, 'server-timestamp');
});
test('profile repository rejects mass assignment and sparse creation', async () => {
  const repo = createProfileRepository(new MemoryFirestore(), () => 'timestamp');
  await assert.rejects(repo.update('alice', {totalStars: 10}), error => error.status === 400);
  await assert.rejects(repo.update('alice', {name: 'New'}), error => error.status === 404);
});
