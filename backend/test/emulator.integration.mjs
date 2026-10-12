import {test, after} from 'node:test';
import assert from 'node:assert/strict';
import {initializeApp, deleteApp} from 'firebase-admin/app';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore, FieldValue} from 'firebase-admin/firestore';
import {createHandler} from '../src/app.mjs';
import {createHistoryRepository} from '../src/history-repository.mjs';
import {createProfileRepository} from '../src/profile-repository.mjs';
import {createRateLimiter} from '../src/rate-limiter.mjs';

// Strict guard: these fixture writes can only target loopback demo emulators.
assert.equal(process.env.FIRESTORE_EMULATOR_HOST, '127.0.0.1:8080');
assert.equal(process.env.FIREBASE_AUTH_EMULATOR_HOST, '127.0.0.1:9099');
const app = initializeApp({projectId: 'demo-synapse-health'}, 'history-integration');
const db = getFirestore(app);
const auth = getAuth(app);
after(async () => {await db.terminate(); await deleteApp(app);});

async function signUp(email) {
  const response = await fetch('http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=local-test', {
    method: 'POST', headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({email, password: 'emulator-only-password', returnSecureToken: true}),
  });
  assert.equal(response.status, 200);
  return response.json();
}
async function seed(uid, quizId, answerDate) {
  await db.doc(`users/${uid}`).set({uid, name: 'Emulator fixture', career: 'Test'});
  await db.doc(`users/${uid}/quiz_topics_progress/topic`).set({areaId: 'area', topicId: 'topic',
    history: [], activeAttempt: {attemptNumber: 1, questionAnswers: {
      [quizId]: {isAnswered: true, isCorrect: true, earnedStars: 1, maxStars: 3,
        answeredAt: answerDate, selectedOptionIndex: 0},
    }}});
}
function request(path, token, query = null) {
  return {path, httpMethod: 'GET', queryStringParameters: query,
    headers: token ? {Authorization: `Bearer ${token}`} : {}, requestContext: {requestId: 'emulator-check'}};
}

test('real Firestore and Auth emulators: history ownership, pagination and detail', async () => {
  const alice = await signUp('history-alice@example.invalid');
  const bob = await signUp('history-bob@example.invalid');
  await seed(alice.localId, 'alice-answer', '2026-01-01T00:00:00Z');
  await seed(bob.localId, 'bob-private-answer', '2026-02-01T00:00:00Z');
  const handler = createHandler({verifyToken: token => auth.verifyIdToken(token, true),
    history: createHistoryRepository(db), profiles: createProfileRepository(db, () => FieldValue.serverTimestamp()),
    limiter: createRateLimiter(db)});
  const aliceResponse = await handler(request('/api/v1/history', alice.idToken, {limit: '1'}));
  assert.equal(aliceResponse.statusCode, 200);
  const aliceItems = JSON.parse(aliceResponse.body).data.items;
  assert.equal(aliceItems[0].quizId, 'alice-answer');
  assert.equal(aliceItems[0].durationSeconds, null);
  const bobResponse = await handler(request('/api/v1/history', bob.idToken));
  const bobId = JSON.parse(bobResponse.body).data.items[0].id;
  assert.equal((await handler(request(`/api/v1/history/${bobId}`, alice.idToken))).statusCode, 404);
  assert.equal((await handler(request(`/api/v1/history/${aliceItems[0].id}`, alice.idToken))).statusCode, 200);
  assert.equal((await handler(request('/api/v1/history'))).statusCode, 401);
  assert.equal((await handler(request('/api/v1/history', alice.idToken, {userId: bob.localId}))).statusCode, 400);
  const doc = db.doc(`users/${alice.localId}/quiz_topics_progress/topic`);
  const data = (await doc.get()).data();
  data.activeAttempt.questionAnswers['second-answer'] = {isAnswered: true, isCorrect: false,
    earnedStars: 0, maxStars: 3, answeredAt: '2026-03-01T00:00:00Z'};
  await doc.set(data);
  const first = JSON.parse((await handler(request('/api/v1/history', alice.idToken, {limit: '1'}))).body).data;
  const next = JSON.parse((await handler(request('/api/v1/history', alice.idToken,
    {limit: '1', cursor: first.nextCursor}))).body).data;
  assert.equal(first.items[0].quizId, 'second-answer');
  assert.equal(next.items[0].quizId, 'alice-answer');
});

test('Firestore rate limiter serializes real transactions', async () => {
  const limiter = createRateLimiter(db, {limit: 2, now: () => 1000});
  const results = await Promise.allSettled([limiter.consume('rate-test'), limiter.consume('rate-test'), limiter.consume('rate-test')]);
  assert.equal(results.filter(result => result.status === 'fulfilled').length, 2);
  assert.equal(results.find(result => result.status === 'rejected').reason.status, 429);
});
