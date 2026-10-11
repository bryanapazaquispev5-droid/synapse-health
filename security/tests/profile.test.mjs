import { before, after, beforeEach, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, collection, getDoc, getDocs, setDoc, updateDoc, deleteDoc, serverTimestamp, Timestamp } from 'firebase/firestore';
import { setup, seed, db, profile } from './setup.mjs';
let env;
before(async () => { env = await setup(); });
after(async () => { await env?.cleanup(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });

test('private profiles are owner-only; collections never list', async () => {
  await assertSucceeds(getDoc(doc(db(env), 'users/alice')));
  for (const store of [db(env, null), db(env, 'bob'), db(env, 'admin', { contentAdmin: true })]) {
    await assertFails(getDoc(doc(store, 'users/alice')));
  }
  for (const store of [db(env), db(env, 'admin', { contentAdmin: true }), db(env, null)]) {
    await assertFails(getDocs(collection(store, 'users')));
  }
});
test('valid profile creation with minimum fields and optional fields', async () => {
  const store = db(env, 'new');
  await assertSucceeds(setDoc(doc(store, 'users/new'), profile('new', { photoUrl: 'https://example.test/avatar.png', updatedAt: serverTimestamp() })));
  await assertSucceeds(setDoc(doc(db(env, 'minimal'), 'users/minimal'), {
    uid: 'minimal', name: 'Student', email: 'minimal@example.test', career: 'Nursing', createdAt: serverTimestamp(),
  }));
});
test('creation rejects spoofing, elevated privileges and invalid types', async () => {
  const mutations = [ { uid: 'victim' }, { email: 'victim@example.test' }, { role: 'admin' },
    { contentAdmin: true }, { name: 42 }, { career: '' }, { gender: 'invalid' },
    { studyStreakDays: 1 }, { studyStreakDays: '0' }, { studyStreakDays: -1 }, { authProvider: 'google.com' }, { photoUrl: 'http://example.test/a' },
    { createdAt: Timestamp.fromMillis(0) }, { updatedAt: Timestamp.fromMillis(0) } ];
  for (const mutation of mutations) {
    await assertFails(setDoc(doc(db(env, 'new'), 'users/new'), profile('new', mutation)));
  }
  await assertFails(setDoc(doc(db(env), 'users/new'), profile('new')));
  await assertFails(setDoc(doc(db(env, null), 'users/new'), profile('new')));
});
test('profile edits allow valid display fields and protect identity and metrics', async () => {
  const ref = doc(db(env), 'users/alice');
  await assertSucceeds(updateDoc(ref, { name: 'Updated', career: 'Nursing', gender: 'Hombre', updatedAt: serverTimestamp(), photoUrl: null }));
  for (const mutation of [ { uid: 'bob' }, { email: 'bob@example.test' }, { role: 'admin' },
    { authProvider: 'google.com' }, { studyStreakDays: 99 }, { createdAt: serverTimestamp() },
    { name: '' }, { gender: false }, { updatedAt: Timestamp.fromMillis(0) }, { totalStars: 99 } ]) {
    await assertFails(updateDoc(ref, mutation));
  }
  await assertFails(updateDoc(doc(db(env, 'bob'), 'users/alice'), { name: 'Attacker' }));
  await assertFails(deleteDoc(ref));
});
test('legacy profile can fill absent identity timestamp without bypassing ownership', async () => {
  await env.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), 'users/legacy'), { uid: 'legacy', name: 'Legacy', email: 'legacy@example.test', career: 'Nursing' });
  });
  await assertSucceeds(updateDoc(doc(db(env, 'legacy'), 'users/legacy'), { createdAt: serverTimestamp(), name: 'Updated' }));
});

test('anonymous profile uses its own UID and the existing guest email', async () => {
  const guest = db(env, 'guest', { email: undefined, firebase: { sign_in_provider: 'anonymous' } });
  await assertSucceeds(setDoc(doc(guest, 'users/guest'), profile('guest', {
    email: 'invitado@synapse.app', authProvider: 'anonymous',
  })));
  await assertFails(updateDoc(doc(guest, 'users/guest'), { email: 'alice@example.test' }));
  await assertFails(getDoc(doc(guest, 'users/alice')));
});

test('Google profile completion supports optional provider and zero initial streak', async () => {
  const google = db(env, 'google', { firebase: { sign_in_provider: 'google.com' } });
  await assertSucceeds(setDoc(doc(google, 'users/google'), {
    uid: 'google', name: 'Student', email: 'google@example.test', career: 'Nursing',
    gender: 'Mujer', createdAt: serverTimestamp(), updatedAt: serverTimestamp(),
  }, { merge: true }));
  await assertSucceeds(updateDoc(doc(google, 'users/google'), { name: 'Updated' }));
});

test('linked Google login preserves original provider and previous updatedAt', async () => {
  await updateDoc(doc(db(env), 'users/alice'), { updatedAt: serverTimestamp() });
  const google = db(env, 'alice', { firebase: { sign_in_provider: 'google.com' } });
  await assertSucceeds(updateDoc(doc(google, 'users/alice'), { name: 'Updated' }));
  await assertFails(updateDoc(doc(google, 'users/alice'), { authProvider: 'google.com' }));
});
