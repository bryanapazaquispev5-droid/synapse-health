import {ApiError} from './http.mjs';

const fields = ['uid', 'name', 'email', 'career', 'gender', 'photoUrl',
  'studyStreakDays', 'createdAt', 'updatedAt', 'authProvider'];

function profile(data, uid) {
  if (data.uid !== uid) throw new ApiError(403, 'forbidden', 'Acceso no permitido.');
  return Object.fromEntries(fields.filter(key => data[key] !== undefined).map(key => {
    const value = data[key];
    return [key, typeof value?.toDate === 'function' ? value.toDate().toISOString() : value];
  }));
}

export function createProfileRepository(db, serverTimestamp) {
  function ref(uid) {
    // UID is obtained only from verified Firebase Auth claims, never a URL/body.
    if (typeof uid !== 'string' || !uid.length || uid.length > 128 || uid.includes('/')) {
      throw new ApiError(401, 'unauthenticated', 'Inicia sesión nuevamente.');
    }
    return db.collection('users').doc(uid);
  }
  return {
    async get(uid) {
      const snapshot = await ref(uid).get();
      if (!snapshot.exists) throw new ApiError(404, 'not_found', 'Perfil no disponible.');
      return profile(snapshot.data(), uid);
    },
    async update(uid, patch) {
      // Defense in depth: reject mass assignment even from an internal caller.
      if (!Object.keys(patch).length || Object.keys(patch).some(key =>
        !['name', 'career', 'gender'].includes(key))) {
        throw new ApiError(400, 'invalid_request', 'Campos de perfil no válidos.');
      }
      return db.runTransaction(async transaction => {
        const document = ref(uid);
        const snapshot = await transaction.get(document);
        if (!snapshot.exists) throw new ApiError(404, 'not_found', 'Perfil no disponible.');
        const current = profile(snapshot.data(), uid);
        transaction.update(document, {...patch, updatedAt: serverTimestamp()});
        // Server timestamp is unresolved until commit; omit stale updatedAt.
        const {updatedAt, ...unchanged} = current;
        return {...unchanged, ...patch};
      });
    },
  };
}
