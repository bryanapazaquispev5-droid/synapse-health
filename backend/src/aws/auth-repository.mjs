import {randomBytes, scryptSync, timingSafeEqual, createHmac} from 'node:crypto';
import {ApiError} from '../http.mjs';
import {object, invalid} from './validation.mjs';

const JWT_DEFAULT_EXPIRY_SECONDS = 3600 * 24 * 7; // 7 days

export function hashPassword(password) {
  const salt = randomBytes(16);
  const derived = scryptSync(password, salt, 32, {N: 16384, r: 8, p: 1});
  return `scrypt$N=16384,r=8,p=1$${salt.toString('base64url')}$${derived.toString('base64url')}`;
}

export function verifyPassword(password, storedHash) {
  try {
    const parts = storedHash.split('$');
    if (parts.length !== 4 || parts[0] !== 'scrypt') return false;
    const salt = Buffer.from(parts[2], 'base64url');
    const expected = Buffer.from(parts[3], 'base64url');
    const actual = scryptSync(password, salt, 32, {N: 16384, r: 8, p: 1});
    return actual.length === expected.length && timingSafeEqual(actual, expected);
  } catch (_) {
    return false;
  }
}

export function createJwt({sub, email, name, role = 'student'}, secret, expiresInSeconds = JWT_DEFAULT_EXPIRY_SECONDS) {
  const header = Buffer.from(JSON.stringify({alg: 'HS256', typ: 'JWT'})).toString('base64url');
  const now = Math.floor(Date.now() / 1000);
  const payload = Buffer.from(JSON.stringify({sub, email, name, role, iat: now, exp: now + expiresInSeconds})).toString('base64url');
  const signature = createHmac('sha256', secret).update(`${header}.${payload}`).digest('base64url');
  return `${header}.${payload}.${signature}`;
}

export function verifyJwt(token, secret) {
  if (typeof token !== 'string') throw new ApiError(401, 'unauthenticated', 'Token required.');
  const parts = token.split('.');
  if (parts.length !== 3) throw new ApiError(401, 'unauthenticated', 'Malformed token.');
  const [header, payload, signature] = parts;
  const expected = createHmac('sha256', secret).update(`${header}.${payload}`).digest('base64url');
  const sigBuf = Buffer.from(signature);
  const expBuf = Buffer.from(expected);
  if (sigBuf.length !== expBuf.length || !timingSafeEqual(sigBuf, expBuf)) {
    throw new ApiError(401, 'unauthenticated', 'Invalid token signature.');
  }
  const claims = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8'));
  const now = Math.floor(Date.now() / 1000);
  if (claims.exp && now > claims.exp) throw new ApiError(401, 'unauthenticated', 'Token expired.');
  return claims;
}

export function createAuthRepository({profilesStore, secret, now = () => new Date().toISOString()}) {
  const jwtSecret = secret ?? process.env.JWT_SECRET ?? 'synapse-health-internal-jwt-token-key-2026';
  return {
    async register(input) {
      object(input, ['email', 'password', 'name', 'career', 'gender'], ['email', 'password']);
      const email = String(input.email ?? '').trim().toLowerCase();
      const password = String(input.password ?? '');
      if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw invalid('Invalid email format.');
      if (password.length < 8) throw invalid('Password must be at least 8 characters.');

      const emailPk = `USER#EMAIL#${email}`;
      const existingEmail = await profilesStore.get(emailPk, 'ACCOUNT');
      if (existingEmail) throw new ApiError(409, 'conflict', 'An account with this email already exists.');

      const sub = `user-${randomBytes(12).toString('hex')}`;
      const userPk = `USER#${sub}`;
      const passwordHash = hashPassword(password);
      const name = String(input.name ?? email.split('@')[0]).trim();
      const career = String(input.career ?? 'General Medicine').trim();
      const gender = input.gender ? String(input.gender).trim() : 'Male';

      await profilesStore.put({PK: emailPk, SK: 'ACCOUNT', sub, email, createdAt: now()}, null);
      await profilesStore.put({
        PK: userPk, SK: 'AUTH', sub, email, passwordHash, name, career, gender, createdAt: now(), updatedAt: now()
      }, null);
      await profilesStore.put({
        PK: userPk, SK: 'PROFILE', uid: sub, email, name, career, gender, authProvider: 'password', studyStreakDays: 0, createdAt: now(), updatedAt: now()
      }, null);

      const token = createJwt({sub, email, name, role: 'student'}, jwtSecret);
      return {token, user: {sub, email, name, career, gender}};
    },

    async login(input) {
      object(input, ['email', 'password'], ['email', 'password']);
      const email = String(input.email ?? '').trim().toLowerCase();
      const password = String(input.password ?? '');

      const emailMap = await profilesStore.get(`USER#EMAIL#${email}`, 'ACCOUNT');
      if (!emailMap?.data?.sub && !emailMap?.sub) {
        throw new ApiError(401, 'unauthorized', 'Invalid email or password.');
      }
      const sub = emailMap.data?.sub ?? emailMap.sub;
      const auth = await profilesStore.get(`USER#${sub}`, 'AUTH');
      const hash = auth?.data?.passwordHash ?? auth?.passwordHash;
      if (!hash || !verifyPassword(password, hash)) {
        throw new ApiError(401, 'unauthorized', 'Invalid email or password.');
      }
      const name = auth.data?.name ?? auth.name ?? email.split('@')[0];
      const token = createJwt({sub, email, name, role: 'student'}, jwtSecret);
      return {token, user: {sub, email, name}};
    },

    verifyToken(token) {
      return verifyJwt(token, jwtSecret);
    },

    async deleteUser(sub) {
      const auth = await profilesStore.get(`USER#${sub}`, 'AUTH');
      const email = auth?.data?.email ?? auth?.email;
      if (email) {
        await profilesStore.remove(`USER#EMAIL#${email}`, 'ACCOUNT');
      }
      await profilesStore.remove(`USER#${sub}`, 'AUTH');
      await profilesStore.remove(`USER#${sub}`, 'PROFILE');
      return {deleted: true};
    }
  };
}
