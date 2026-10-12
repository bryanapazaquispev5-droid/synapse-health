export class ApiError extends Error {
  constructor(status, code, message, headers = {}) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.code = code;
    this.headers = headers;
  }
}

export function response(statusCode, payload, headers = {}) {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store',
      'X-Content-Type-Options': 'nosniff',
      ...headers,
    },
    body: JSON.stringify(payload),
  };
}

export function header(headers, name) {
  const entry = Object.entries(headers ?? {}).find(([key]) => key.toLowerCase() === name);
  return entry?.[1];
}

export function parsePatch(event) {
  if (!/^application\/json(?:\s*;.*)?$/i.test(header(event.headers, 'content-type') ?? '')) {
    throw new ApiError(415, 'unsupported_media_type', 'Use application/json.');
  }
  if (typeof event.body !== 'string') {
    throw new ApiError(400, 'invalid_body', 'Provide a JSON object.');
  }
  let body = event.body;
  if (event.isBase64Encoded) {
    if (body.length > 5500) throw new ApiError(413, 'payload_too_large', 'Request body is too large.');
    if (!/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(body)) {
      throw new ApiError(400, 'invalid_body', 'Provide a valid request body.');
    }
    body = Buffer.from(body, 'base64').toString('utf8');
  }
  if (Buffer.byteLength(body, 'utf8') > 4096) {
    throw new ApiError(413, 'payload_too_large', 'Request body is too large.');
  }
  let patch;
  try { patch = JSON.parse(body); } catch {
    throw new ApiError(400, 'invalid_body', 'Provide valid JSON.');
  }
  if (!patch || typeof patch !== 'object' || Array.isArray(patch) || !Object.keys(patch).length) {
    throw new ApiError(400, 'invalid_body', 'Provide a nonempty JSON object.');
  }
  const validated = {};
  for (const [key, value] of Object.entries(patch)) {
    if (!['name', 'career', 'gender'].includes(key) || typeof value !== 'string') {
      throw new ApiError(400, 'invalid_profile', 'Only name, career and gender may be updated.');
    }
    const text = value.trim();
    if (key === 'gender' ? !['Hombre', 'Mujer'].includes(text) : !text.length || text.length > 100) {
      throw new ApiError(400, 'invalid_profile', 'Provide valid profile fields.');
    }
    validated[key] = text;
  }
  return validated;
}
