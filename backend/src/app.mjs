import { ApiError, header, parsePatch, response } from './http.mjs';
import { parseHistoryQuery, validateHistoryId } from './history-repository.mjs';

export function createHandler({ verifyToken, profiles, history, limiter, logger = console }) {
  return async (event) => {
    const requestId = event.requestContext?.requestId ?? 'unavailable';
    try {
      const path = event.path ?? '';
      const isProfile = path === '/v1/me/profile';
      const isHistory = path === '/api/v1/history';
      const historyId = path.startsWith('/api/v1/history/') ? path.slice(16) : null;
      const isHealth = path === '/api/v1/health';
      if (!isProfile && !isHistory && !historyId && !isHealth) {
        throw new ApiError(404, 'not_found', 'Endpoint not found.');
      }
      if (!(isProfile ? ['GET', 'PATCH'] : ['GET']).includes(event.httpMethod)) {
        throw new ApiError(405, 'method_not_allowed', 'Method not allowed.', { Allow: isProfile ? 'GET, PATCH' : 'GET' });
      }
      const query = isHistory ? parseHistoryQuery(event.queryStringParameters) : null;
      if (!isHistory && Object.keys(event.queryStringParameters ?? {}).length) {
        throw new ApiError(400, 'invalid_query', 'Query parameters are not supported.');
      }
      if (historyId) validateHistoryId(historyId);
      if (event.httpMethod === 'GET' && event.body != null && event.body !== '') {
        throw new ApiError(400, 'invalid_body', 'GET requests must not include a body.');
      }
      if (isHealth) return response(200, { data: { status: 'ok' }, requestId });
      const authorization = header(event.headers, 'authorization');
      const match = typeof authorization === 'string' && /^Bearer\s+([^\s]+)$/i.exec(authorization);
      if (!match) throw new ApiError(401, 'unauthenticated', 'Authentication is required.');
      const identity = await verifyToken(match[1]);
      if (typeof identity?.uid !== 'string' || !identity.uid.length) {
        throw new ApiError(401, 'unauthenticated', 'Authentication is required.');
      }
      await limiter.consume(identity.uid);
      let data;
      if (event.httpMethod === 'GET') {
        data = isHistory ? await history.list(identity.uid, query)
          : historyId ? await history.get(identity.uid, historyId)
            : await profiles.get(identity.uid);
      } else {
        data = await profiles.update(identity.uid, parsePatch(event));
      }
      return response(200, { data, requestId });
    } catch (error) {
      const known = error instanceof ApiError;
      const status = known ? error.status : 500;
      const code = known ? error.code : 'internal_error';
      if (status >= 500) logger.error?.({ requestId, code });
      return response(status, {
        error: { code, message: known ? error.message : 'The request could not be completed.' },
        requestId,
      }, known ? error.headers : {});
    }
  };
}
