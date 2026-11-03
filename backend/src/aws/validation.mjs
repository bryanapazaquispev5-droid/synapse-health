import {ApiError, header} from '../http.mjs';
export const invalid = (message = 'Provide valid request fields.') => new ApiError(400, 'invalid_request', message);
export function identifier(value) {
  if (typeof value !== 'string' || !/^[A-Za-z0-9_-]{1,200}$/.test(value)) throw invalid();
  return value;
}
export function object(value, allowed, required = []) {
  if (!value || typeof value !== 'object' || Array.isArray(value) ||
      Object.keys(value).some(key => !allowed.includes(key)) || required.some(key => !Object.hasOwn(value, key))) throw invalid();
  return value;
}
export function body(event, allowed, required = []) {
  if (!/^application\/json(?:\s*;.*)?$/i.test(header(event.headers, 'content-type') ?? '')) {
    throw new ApiError(415, 'unsupported_media_type', 'Use application/json.');
  }
  if (event.isBase64Encoded || typeof event.body !== 'string') throw invalid();
  if (Buffer.byteLength(event.body) > 32768) throw new ApiError(413, 'payload_too_large', 'Request body is too large.');
  let parsed;
  try { parsed = JSON.parse(event.body); } catch { throw invalid(); }
  return object(parsed, allowed, required);
}
export function integer(value, minimum = 0, maximum = 1000000) {
  if (!Number.isSafeInteger(value) || value < minimum || value > maximum) throw invalid();
  return value;
}
export function page(query = {}, extra = []) {
  if (Object.keys(query).some(key => !['limit', 'cursor', ...extra].includes(key))) throw invalid();
  const limit = query.limit ?? '100';
  if (typeof limit !== 'string' || !/^(?:[1-9]|[1-9]\d|100)$/.test(limit)) throw invalid();
  if (query.cursor != null && (typeof query.cursor !== 'string' || !/^[A-Za-z0-9_-]{1,4096}$/.test(query.cursor))) throw invalid();
  return {limit: Number(limit), cursor: query.cursor ?? null};
}
export function cursorKey(cursor, pk, prefix) {
  if (!cursor) return undefined;
  try {
    const decoded = JSON.parse(Buffer.from(cursor, 'base64url').toString());
    if (Object.keys(decoded).length !== 2 || decoded.PK !== pk || typeof decoded.SK !== 'string' || !decoded.SK.startsWith(prefix)) throw invalid();
    return decoded;
  } catch { throw invalid('Reload this list to continue.'); }
}
export const encodeCursor = key => key ? Buffer.from(JSON.stringify({PK: key.PK, SK: key.SK})).toString('base64url') : null;
