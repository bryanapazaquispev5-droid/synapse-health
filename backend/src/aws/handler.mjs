import {ApiError, header, response, parsePatch} from '../http.mjs';
import {parseHistoryQuery} from '../history-repository.mjs';
import {body, page, invalid} from './validation.mjs';
import {catalogRoute} from './routes.mjs';

function safeErrorType(error) {
  return typeof error?.name === 'string' && /^[A-Za-z][A-Za-z0-9]{0,79}$/.test(error.name)
    ? error.name : 'UnknownError';
}

export function createAwsHandler({identity, store, profiles, catalog, progress, history, leaderboard, logger = console}) {
  return async rawEvent => {
    const event = {...rawEvent, path: rawEvent.path ?? rawEvent.rawPath,
      httpMethod: rawEvent.httpMethod ?? rawEvent.requestContext?.http?.method};
    const requestId = event.requestContext?.requestId ?? 'unavailable';
    let stage = 'routing';
    try {
      const path = event.path ?? '';
      const method = event.httpMethod;
      if (method === 'OPTIONS') return response(204, null, {
        'Access-Control-Allow-Methods': 'GET,POST,PUT,PATCH,DELETE,OPTIONS',
        'Access-Control-Allow-Headers': 'Authorization,Content-Type', 'Access-Control-Max-Age': '600'});
      // GET /health and GET /api/v1/health stay public for AWS health probes.
      if (path === '/health' || path === '/api/v1/health') {
        if (method !== 'GET') throw new ApiError(405, 'method_not_allowed', 'Use GET.', {Allow: 'GET'});
        return response(200, {data: {status: 'ok', provider: 'aws'}, requestId});
      }
      if (method === 'GET' && event.body != null && event.body !== '') throw invalid();
      // API Gateway forwards through $default; authenticate all application routes in Lambda.
      const auth = header(event.headers, 'authorization');
      const bearer = typeof auth === 'string' && /^Bearer\s+([^\s]+)$/i.exec(auth);
      if (!bearer) throw new ApiError(401, 'unauthenticated', 'Authentication is required.');
      stage = 'identity';
      const user = await identity.verifyCognitoToken(bearer[1]);
      if (typeof user.sub !== 'string' || !user.sub.trim()) throw new ApiError(401, 'unauthenticated', 'Authentication is required.');
      stage = 'rate_limit';
      await store.consume(user.sub);
      const query = event.queryStringParameters ?? {};
      const catalogRequest = catalogRoute(path, query);
      // POST /api/v1/progress/{topicId}/answer and /retry; downstream writes use the authenticated subject.
      const answer = /^\/api\/v1\/progress\/([^/]+)\/(answer|retry)$/.exec(path);
      // GET /api/v1/history/{id}; the history service scopes the lookup to the authenticated subject.
      const historyId = /^\/api\/v1\/history\/([^/]+)$/.exec(path);
      const allowsQuery = catalogRequest || ['/api/v1/progress/me', '/api/v1/history', '/api/v1/leaderboard'].includes(path);
      if (!allowsQuery && Object.keys(query).length) throw invalid();
      let data;
      const requireMethod = allowed => {
        if (!allowed.includes(method)) throw new ApiError(405, 'method_not_allowed', 'Method not allowed.', {Allow: allowed.join(', ')});
      };
      if (path === '/api/v1/auth/session') { // GET /api/v1/auth/session
        stage = 'session';
        requireMethod(['GET']);
        const {groups, ...publicIdentity} = user;
        data = publicIdentity;
      } else if (path === '/v1/me/profile') { // GET consulta; PUT/PATCH crean o actualizan el perfil.
        stage = 'profile';
        requireMethod(['GET', 'PUT', 'PATCH']);
        data = method === 'GET' ? await profiles.get(user)
          : await profiles.save(user, parsePatch(event));
      } else if (catalogRequest) {
        // Lee el catálogo sin modificar sus áreas, temas, quizzes ni apuntes.
        stage = 'catalog';
        requireMethod(['GET']);
        data = await catalog.list(catalogRequest.path, catalogRequest.options, catalogRequest.topicId);
      } else if (path === '/api/v1/progress/me') { // Consulta el progreso guardado del usuario.
        stage = 'progress_read';
        requireMethod(['GET']); data = await progress.list(user.sub, page(query));
      } else if (answer) { // Guarda una respuesta o inicia un reintento del quiz.
        stage = answer[2] === 'answer' ? 'progress_answer' : 'progress_retry';
        requireMethod(['POST']);
        data = answer[2] === 'answer'
          ? await progress.answer(user.sub, answer[1], body(event,
            ['areaId', 'quizId', 'answer', 'expectedAttemptNumber', 'topicTotalMaxStars'],
            ['areaId', 'quizId', 'answer', 'expectedAttemptNumber']))
          : await progress.retry(user.sub, answer[1], body(event,
            ['areaId', 'totalMaxStars', 'expectedAttemptNumber', 'idempotencyKey'],
            ['areaId', 'expectedAttemptNumber', 'idempotencyKey']));
      } else if (path === '/api/v1/history') { // GET /api/v1/history
        stage = 'history_list';
        requireMethod(['GET']); data = await history.list(user.sub, parseHistoryQuery(query));
      } else if (historyId) { // GET /api/v1/history/{id}
        stage = 'history_entry';
        requireMethod(['GET']); data = await history.get(user.sub, historyId[1]);
      } else if (path === '/api/v1/leaderboard') { // GET /api/v1/leaderboard
        stage = 'leaderboard';
        requireMethod(['GET']); data = await leaderboard.list(page(query));
      } else throw new ApiError(404, 'not_found', 'Endpoint not found.');
      return response(200, {data, requestId});
    } catch (error) {
      const known = error instanceof ApiError;
      const status = known ? error.status : 500;
      const code = known ? error.code : 'internal_error';
      if (status >= 500) logger.error?.({requestId, code, stage: error.stage ?? stage, errorType: safeErrorType(error)});
      return response(status, {error: {code, message: known ? error.message : 'The request could not be completed.'}, requestId}, known ? error.headers : {});
    }
  };
}
