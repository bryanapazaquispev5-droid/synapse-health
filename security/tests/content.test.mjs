import { before, after, beforeEach, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, collection, getDoc, getDocs, setDoc, updateDoc, deleteDoc } from 'firebase/firestore';
import { setup, seed, db } from './setup.mjs';
let env;
before(async () => { env = await setup(); });
after(async () => { await env?.cleanup(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
const paths = ['medical_areas/a', 'medical_areas/a/topics/t',
  'medical_areas/a/topics/t/cheatsheets/c', 'medical_areas/a/topics/t/quizzes/q', 'medical_areas/a/quizzes/q'];
test('academic paths permit authenticated reads including Firebase anonymous accounts', async () => {
  for (const path of paths) {
    await assertSucceeds(getDoc(doc(db(env), path)));
    await assertSucceeds(getDoc(doc(db(env, 'guest', { firebase: { sign_in_provider: 'anonymous' } }), path)));
    await assertFails(getDoc(doc(db(env, null), path)));
  }
  await assertSucceeds(getDocs(collection(db(env), 'medical_areas/a/topics/t/quizzes')));
});
test('content requires trusted boolean admin claim, never profile role', async () => {
  await env.withSecurityRulesDisabled(async context => {
    await updateDoc(doc(context.firestore(), 'users/alice'), { role: 'admin', contentAdmin: true });
  });
  for (const path of paths) {
    await assertFails(setDoc(doc(db(env), path), { malicious: true }));
    await assertFails(updateDoc(doc(db(env, 'string', { contentAdmin: 'true' }), path), { malicious: true }));
    await assertSucceeds(updateDoc(doc(db(env, 'admin', { contentAdmin: true }), path), { reviewed: true }));
    await assertSucceeds(deleteDoc(doc(db(env, 'admin', { contentAdmin: true }), path)));
  }
});
test('ranking reads authenticated; forged scores forbidden for every client', async () => {
  await assertSucceeds(getDocs(collection(db(env), 'leaderboard')));
  await assertSucceeds(getDoc(doc(db(env, 'bob'), 'leaderboard/alice')));
  await assertFails(getDocs(collection(db(env, null), 'leaderboard')));
  for (const store of [db(env), db(env, 'bob'), db(env, 'admin', { contentAdmin: true }), db(env, null)]) {
    await assertFails(setDoc(doc(store, 'leaderboard/new'), { userId: 'new', totalStars: 999 }));
    await assertFails(updateDoc(doc(store, 'leaderboard/alice'), { totalStars: 999 }));
    await assertFails(deleteDoc(doc(store, 'leaderboard/alice')));
  }
});
test('unknown paths and subcollections deny even admins', async () => {
  for (const store of [db(env), db(env, 'admin', { contentAdmin: true })]) {
    for (const path of ['unknown/x', 'users/alice/private/x', 'medical_areas/a/secrets/x']) {
      await assertFails(getDoc(doc(store, path)));
      await assertFails(setDoc(doc(store, path), { value: true }));
    }
  }
});
