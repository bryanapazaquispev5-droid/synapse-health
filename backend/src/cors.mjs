import {header, response} from './http.mjs';

export function withCors(handler, allowedOrigin) {
  const url = new URL(allowedOrigin);
  if (url.protocol !== 'https:' || url.origin !== allowedOrigin || url.username || url.password) {
    throw new Error('CORS requires one HTTPS origin');
  }
  return async event => {
    const origin = header(event.headers, 'origin');
    if (origin != null && origin !== allowedOrigin) {
      return response(403, {error: {code: 'origin_forbidden', message: 'Origin is not allowed.'},
        requestId: event.requestContext?.requestId ?? 'unavailable'});
    }
    const result = await handler(event);
    if (origin === allowedOrigin) {
      result.headers = {...result.headers, 'Access-Control-Allow-Origin': allowedOrigin, Vary: 'Origin'};
    }
    return result;
  };
}
