import { readFile } from 'node:fs/promises';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { doc, setDoc, serverTimestamp } from 'firebase/firestore';

export async function setup() {
  if (process.env.FIRESTORE_EMULATOR_HOST !== '127.0.0.1:8080') {
    throw new Error('Tests require FIRESTORE_EMULATOR_HOST=127.0.0.1:8080; live projects are forbidden.');
  }
  return initializeTestEnvironment({
    projectId: 'demo-synapse-health',
    firestore: {
      host: '127.0.0.1', port: 8080,
      rules: await readFile(new URL('../../firestore.rules', import.meta.url), 'utf8'),
    },
  });
}
export function db(env, uid = 'alice', claims = {}) {
  return uid === null ? env.unauthenticatedContext().firestore()
    : env.authenticatedContext(uid, {
      email: `${uid}@example.test`, firebase: { sign_in_provider: 'password' }, ...claims,
    }).firestore();
}
export function profile(uid = 'alice', overrides = {}) {
  return { uid, name: 'Student', email: `${uid}@example.test`, career: 'Medicina Humana',
    gender: 'Mujer', studyStreakDays: 0, authProvider: 'password',
    createdAt: serverTimestamp(), ...overrides };
}
export function attempt(overrides = {}) {
  return { attemptNumber: 1, startedAt: '2026-10-11T10:00:00.000', completedAt: null,
    totalEarnedStars: 0, totalMaxStars: 3, questionAnswers: {}, ...overrides };
}
export function progress(overrides = {}) {
  return { topicId: 't', areaId: 'a', currentAttemptNumber: 1,
    activeAttempt: attempt(), history: [], updatedAt: '2026-10-11T10:00:00.000', ...overrides };
}
export async function seed(env) {
  await env.withSecurityRulesDisabled(async context => {
    const store = context.firestore();
    await Promise.all([
      ['users/alice', profile()], ['users/bob', profile('bob')],
      ['medical_areas/a', { name: 'Area' }], ['medical_areas/a/topics/t', { name: 'Topic' }],
      ['medical_areas/a/topics/t/cheatsheets/c', { title: 'Content' }],
      ['medical_areas/a/topics/t/quizzes/q', { question: 'Question' }],
      ['medical_areas/a/quizzes/q', { question: 'Legacy' }],
      ['leaderboard/alice', { userId: 'alice', totalStars: 3 }],
      ['users/alice/quiz_topics_progress/t', progress()],
    ].map(([path, data]) => setDoc(doc(store, path), data)));
  });
}
