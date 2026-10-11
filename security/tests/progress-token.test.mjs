import { before, after, beforeEach, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, collection, getDoc, getDocs, setDoc, updateDoc, deleteDoc, serverTimestamp, Timestamp } from 'firebase/firestore';
import { setup, seed, db, progress, attempt } from './setup.mjs';
let env;
before(async () => { env = await setup(); });
after(async () => { await env?.cleanup(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
test('progress is private and valid owner writes work', async () => {
  await assertSucceeds(getDocs(collection(db(env), 'users/alice/quiz_topics_progress')));
  await assertSucceeds(getDoc(doc(db(env), 'users/alice/quiz_topics_progress/t')));
  await assertSucceeds(setDoc(doc(db(env), 'users/alice/quiz_topics_progress/t'), progress()));
  for (const store of [db(env, 'bob'), db(env, null), db(env, 'admin', { contentAdmin: true })]) {
    await assertFails(getDoc(doc(store, 'users/alice/quiz_topics_progress/t')));
    await assertFails(getDocs(collection(store, 'users/alice/quiz_topics_progress')));
    await assertFails(setDoc(doc(store, 'users/alice/quiz_topics_progress/t'), progress()));
  }
});
test('progress rejects incorrect identities, aggregate types and attempt bounds', async () => {
  const ref = doc(db(env), 'users/alice/quiz_topics_progress/t');
  for (const mutation of [ { topicId: 'other' }, { areaId: 'other' }, { currentAttemptNumber: 0 },
    { currentAttemptNumber: '1' }, { admin: true }, { history: {} }, { updatedAt: 123 },
    { history: Array(4).fill(attempt()) }, { activeAttempt: attempt({ attemptNumber: 2 }) },
    { activeAttempt: attempt({ totalEarnedStars: -1 }) },
    { activeAttempt: attempt({ totalEarnedStars: 4 }) },
    { activeAttempt: attempt({ totalMaxStars: '3' }) },
    { activeAttempt: attempt({ questionAnswers: [] }) },
    { activeAttempt: attempt({ startedAt: false }) },
    { activeAttempt: attempt({ completedAt: 12 }) },
    { activeAttempt: attempt({ unexpected: true }) } ]) {
    await assertFails(setDoc(ref, progress(mutation)));
  }
});
test('all three historical slots validate aggregate schema', async () => {
  const ref = doc(db(env), 'users/alice/quiz_topics_progress/t');
  await assertSucceeds(setDoc(ref, progress({ history: [attempt(), attempt(), attempt()] })));
  for (let slot = 0; slot < 3; slot++) {
    const history = [attempt(), attempt(), attempt()];
    history[slot] = attempt({ totalEarnedStars: -1 });
    await assertFails(setDoc(ref, progress({ history })));
    history[slot] = 'invalid';
    await assertFails(setDoc(ref, progress({ history })));
  }
});
test('practice data is untrusted and cannot publish ranking', async () => {
  // questionAnswers has a variable-length shape; score verification is explicitly not claimed.
  await assertSucceeds(setDoc(doc(db(env), 'users/alice/quiz_topics_progress/t'), progress({
    activeAttempt: attempt({ totalEarnedStars: 3, questionAnswers: { q: {
      quizId: 'q', isAnswered: true, isCorrect: true, earnedStars: 3, maxStars: 3,
      selectedOptionIndex: null, answeredAt: '2026-10-11T10:00:00.000',
    } } }),
  })));
  await assertFails(updateDoc(doc(db(env), 'leaderboard/alice'), { totalStars: 3 }));
});
function token(overrides = {}) {
  return { token: 'device', platform: 'iOS', isWeb: false,
    createdAt: serverTimestamp(), updatedAt: serverTimestamp(), ...overrides };
}
test('FCM lifecycle permits owner only with valid token identity', async () => {
  const ref = doc(db(env), 'users/alice/fcm_tokens/device');
  await assertSucceeds(setDoc(ref, token()));
  await assertSucceeds(getDoc(ref));
  await assertSucceeds(getDocs(collection(db(env), 'users/alice/fcm_tokens')));
  await assertSucceeds(setDoc(ref, token({ platform: 'android', isWeb: true })));
  for (const store of [db(env, 'bob'), db(env, null), db(env, 'admin', { contentAdmin: true })]) {
    const other = doc(store, 'users/alice/fcm_tokens/device');
    await assertFails(getDoc(other));
    await assertFails(setDoc(other, token()));
    await assertFails(deleteDoc(other));
  }
  await assertSucceeds(deleteDoc(ref));
});
test('FCM rejects mismatched IDs, stale timestamps and unrecognized fields', async () => {
  for (const mutation of [ { token: 'other' }, { platform: 'unknown' }, { isWeb: 'false' },
    { createdAt: Timestamp.fromMillis(0) }, { updatedAt: Timestamp.fromMillis(0) }, { role: 'admin' } ]) {
    await assertFails(setDoc(doc(db(env), 'users/alice/fcm_tokens/device'), token(mutation)));
  }
  for (const platform of ['android', 'iOS', 'macOS', 'linux', 'windows', 'fuchsia']) {
    await assertSucceeds(setDoc(doc(db(env), 'users/alice/fcm_tokens/device'), token({ platform })));
  }
});

test('new practice, answer persistence and FIFO retry remain authorized', async () => {
  const ref = doc(db(env), 'users/alice/quiz_topics_progress/new-topic');
  const initial = progress({ topicId: 'new-topic' });
  await assertSucceeds(setDoc(ref, initial));
  const answered = attempt({ totalEarnedStars: 1, questionAnswers: { q: {
    quizId: 'q', isAnswered: true, isCorrect: true, earnedStars: 1, maxStars: 1,
    selectedOptionIndex: 0, answeredAt: '2026-10-11T10:00:00.000',
  } } });
  await assertSucceeds(setDoc(ref, { ...initial, activeAttempt: answered }, { merge: true }));
  let history = [];
  for (let number = 2; number <= 5; number++) {
    history = [...history, { ...answered, attemptNumber: number - 1 }].slice(-3);
    await assertSucceeds(setDoc(ref, { ...initial, currentAttemptNumber: number,
      activeAttempt: attempt({ attemptNumber: number }), history }));
  }
  await assertFails(deleteDoc(ref));
});
