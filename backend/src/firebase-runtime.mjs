import {SecretsManagerClient, GetSecretValueCommand} from '@aws-sdk/client-secrets-manager';
import {initializeApp, cert} from 'firebase-admin/app';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore, FieldValue} from 'firebase-admin/firestore';
import {ApiError} from './http.mjs';
import {createProfileRepository} from './profile-repository.mjs';
import {createRateLimiter} from './rate-limiter.mjs';
import {createHistoryRepository} from './history-repository.mjs';

export function createRuntime({env = process.env, secretClient = new SecretsManagerClient({}),
  initialize = initializeApp, authFor = getAuth, firestoreFor = getFirestore, credentialFor = cert} = {}) {
  let cached;
  async function load() {
    if (!cached) cached = initializeRuntime().catch(error => {
      cached = undefined;
      throw error instanceof ApiError ? error
        : new ApiError(503, 'unavailable', 'Servicio temporalmente no disponible.');
    });
    return cached;
  }
  async function initializeRuntime() {
    const projectId = env.FIREBASE_PROJECT_ID;
    const secretArn = env.FIREBASE_CREDENTIAL_SECRET_ARN;
    if (!projectId || !secretArn || env.FIREBASE_AUTH_EMULATOR_HOST || env.FIRESTORE_EMULATOR_HOST) {
      throw new ApiError(503, 'unavailable', 'Servicio temporalmente no disponible.');
    }
    const response = await secretClient.send(new GetSecretValueCommand({SecretId: secretArn}));
    const credentials = JSON.parse(response.SecretString ?? '');
    if (credentials.type !== 'service_account' || credentials.project_id !== projectId ||
      !credentials.client_email || !credentials.private_key) {
      throw new ApiError(503, 'unavailable', 'Servicio temporalmente no disponible.');
    }
    const app = initialize({projectId, credential: credentialFor(credentials)});
    const db = firestoreFor(app);
    return {auth: authFor(app), history: createHistoryRepository(db), profiles: createProfileRepository(db, () => FieldValue.serverTimestamp()),
      limiter: createRateLimiter(db, {limit: Number(env.USER_RATE_LIMIT ?? 30), windowSeconds: 60})};
  }
  return {
    async verifyToken(token) {
      const {auth} = await load();
      try { return await auth.verifyIdToken(token, true); }
      catch (error) {
        const invalid = ['auth/id-token-expired', 'auth/id-token-revoked', 'auth/user-disabled',
          'auth/user-not-found', 'auth/argument-error', 'auth/invalid-id-token'];
        if (invalid.includes(error.code)) {
          throw new ApiError(401, 'unauthenticated', 'Inicia sesión nuevamente.');
        }
        throw new ApiError(503, 'unavailable', 'Servicio temporalmente no disponible.');
      }
    },
    profiles: {async get(uid) { return (await load()).profiles.get(uid); },
      async update(uid, patch) { return (await load()).profiles.update(uid, patch); }},
    history: {async list(uid, query) { return (await load()).history.list(uid, query); },
      async get(uid, id) { return (await load()).history.get(uid, id); }},
    limiter: {async consume(uid) { return (await load()).limiter.consume(uid); }},
  };
}
