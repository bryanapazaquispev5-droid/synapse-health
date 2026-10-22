import type { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { ApiError, header, response } from '../http.mjs';
import { parseFlashcardBody, parseListQuery, parseVersion } from './validation.js';
import { flashcardKey } from './model.js';
import type { FlashcardRepository } from './model.js';
interface Dependencies {
  verifyCognitoToken(token: string): Promise<{ sub: string; groups?: string[] }>;
  repository: FlashcardRepository;
  limiter?: { consume(uid: string): Promise<void> };
  logger?: { error?(entry: { requestId: string; code: string }): void };
}
export function createFlashcardHandler({ verifyCognitoToken, repository, limiter, logger = console }: Dependencies) {
  return async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    const requestId = event.requestContext?.requestId ?? 'unavailable';
    try {
      const collection = event.path === '/api/v1/flashcards';
      const id = collection ? undefined : event.path.startsWith('/api/v1/flashcards/') ? event.path.slice(19) : undefined;
      if (id) flashcardKey(id);
      if (!collection && !id) throw new ApiError(404, 'not_found', 'Endpoint not found.');
      const allowed = collection ? ['GET', 'POST'] : ['GET', 'PATCH', 'DELETE'];
      if (!allowed.includes(event.httpMethod)) throw new ApiError(405, 'method_not_allowed', 'Method not allowed.', { Allow: allowed.join(', ') });
      const authorization = header(event.headers, 'authorization');
      const match = typeof authorization === 'string' && /^Bearer\s+([^\s]+)$/i.exec(authorization);
      if (!match) throw new ApiError(401, 'unauthenticated', 'Authentication is required.');
      const identity = await verifyCognitoToken(match[1]);
      if (typeof identity?.sub !== 'string' || !identity.sub.trim()) throw new ApiError(401, 'unauthenticated', 'Authentication is required.');
      if (event.httpMethod !== 'GET' && !identity.groups?.includes('admins')) throw new ApiError(403, 'forbidden', 'Administrator access is required.');
      await limiter?.consume(identity.sub);
      if (!collection || event.httpMethod !== 'GET') {
        if (Object.keys(event.queryStringParameters ?? {}).length) throw new ApiError(400, 'invalid_query', 'Query parameters are not supported.');
      }
      if (['GET', 'DELETE'].includes(event.httpMethod) && event.body != null && event.body !== '') {
        throw new ApiError(400, 'invalid_body', 'This request must not include a body.');
      }
      if (event.httpMethod === 'DELETE') {
        await repository.delete(id!, parseVersion(event.headers));
        return { statusCode: 204, headers: { 'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff' }, body: '' };
      }
      if (event.httpMethod === 'GET' && collection) {
        const { areaId, ...options } = parseListQuery(event.queryStringParameters);
        return response(200, { data: await repository.list(areaId, options), requestId });
      }
      const data = event.httpMethod === 'POST' ? await repository.create(parseFlashcardBody(event, true))
        : event.httpMethod === 'PATCH' ? await repository.update(id!, parseFlashcardBody(event, false), parseVersion(event.headers))
          : await repository.get(id!);
      return response(event.httpMethod === 'POST' ? 201 : 200, { data, requestId }, {
        ETag: `"${data.version}"`, ...(event.httpMethod === 'POST' ? { Location: `/api/v1/flashcards/${data.id}` } : {}),
      });
    } catch (error) {
      const known = error instanceof ApiError;
      const status = known ? error.status : 500;
      const code = known ? error.code : 'internal_error';
      if (status >= 500) logger.error?.({ requestId, code });
      return response(status, { error: { code, message: known ? error.message : 'The request could not be completed.' }, requestId }, known ? error.headers : {});
    }
  };
}
