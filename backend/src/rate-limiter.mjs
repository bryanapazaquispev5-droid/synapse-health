import {createHash} from 'node:crypto';
import {ApiError} from './http.mjs';

export function createRateLimiter(db, {limit = 30, windowSeconds = 60, now = Date.now} = {}) {
  if (!Number.isInteger(limit) || limit < 1 || !Number.isInteger(windowSeconds) || windowSeconds < 1) {
    throw new Error('Invalid rate limiter configuration');
  }
  return {
    async consume(uid) {
      // One bounded server-only document per user; no tokens/PII in record IDs.
      const key = createHash('sha256').update(uid).digest('hex');
      const ref = db.collection('backend_rate_limits').doc(key);
      const time = now();
      const windowStart = Math.floor(time / (windowSeconds * 1000)) * windowSeconds * 1000;
      await db.runTransaction(async transaction => {
        const snapshot = await transaction.get(ref);
        const data = snapshot.data();
        const count = data?.windowStart === windowStart ? data.count : 0;
        if (!Number.isInteger(count) || count < 0) {
          throw new ApiError(503, 'unavailable', 'Servicio temporalmente no disponible.');
        }
        if (count >= limit) {
          const retryAfter = Math.max(1, Math.ceil((windowStart + windowSeconds * 1000 - time) / 1000));
          throw new ApiError(429, 'rate_limited', 'Espera un momento antes de reintentar.',
            {'Retry-After': String(retryAfter)});
        }
        transaction.set(ref, {windowStart, count: count + 1});
      });
    },
  };
}
