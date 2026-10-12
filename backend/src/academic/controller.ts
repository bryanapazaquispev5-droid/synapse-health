import type { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { ApiError, header, response } from '../http.mjs';
import { pageQuery, uuid, invalidRequest } from '../quizzes/validation.js';
import type { ProgressListOptions } from '../quizzes/model.js';
import type { AcademicHistoryEntry, AcademicHistoryPage } from '../academic-history/repository.js';
import type { RankingEntry, RankingPage } from '../ranking/model.js';
interface Dependencies {
  enabled: boolean;
  verifyCognitoToken(token: string): Promise<{ sub: string }>;
  limiter: { consume(subject: string): Promise<void> };
  history: { list(subject: string, options: ProgressListOptions): Promise<AcademicHistoryPage>; get(subject: string, id: string): Promise<AcademicHistoryEntry> };
  ranking: { list(options: ProgressListOptions): Promise<RankingPage>; me(subject: string): Promise<{ entry: RankingEntry | null }> };
  logger?: { error?(entry: { requestId: string; code: string }): void };
}
/** Explicit deployment selection keeps Cognito subjects separate from Firebase UIDs. */
export function createAcademicHandler({ enabled, verifyCognitoToken, limiter, history, ranking, logger = console }: Dependencies): (event: APIGatewayProxyEvent) => Promise<APIGatewayProxyResult> {
  return async event => {
    const requestId = event.requestContext?.requestId ?? 'unavailable';
    try {
      const path = event.path ?? '';
      const isHistory = path === '/api/v1/history';
      const detail = /^\/api\/v1\/history\/([^/]+)$/.exec(path);
      const isRanking = path === '/api/v1/ranking';
      const isOwnRank = path === '/api/v1/ranking/me';
      if (!isHistory && !detail && !isRanking && !isOwnRank) throw new ApiError(404, 'not_found', 'Endpoint not found.');
      if (event.httpMethod !== 'GET') throw new ApiError(405, 'method_not_allowed', 'Method not allowed.', { Allow: 'GET' });
      if (!enabled) throw new ApiError(503, 'unavailable', 'Academic service is not enabled.');
      const authorization = header(event.headers, 'authorization');
      const match = typeof authorization === 'string' && /^Bearer\s+([^\s]+)$/i.exec(authorization);
      if (!match) throw new ApiError(401, 'unauthenticated', 'Authentication is required.');
      const identity = await verifyCognitoToken(match[1]);
      if (typeof identity?.sub !== 'string' || !identity.sub.trim()) throw new ApiError(401, 'unauthenticated', 'Authentication is required.');
      await limiter.consume(identity.sub);
      if (event.body != null && event.body !== '') throw invalidRequest();
      if ((detail || isOwnRank) && Object.keys(event.queryStringParameters ?? {}).length) throw invalidRequest();
      const data = isHistory ? await history.list(identity.sub, pageQuery(event.queryStringParameters))
        : detail ? await history.get(identity.sub, uuid(detail[1]))
          : isOwnRank ? await ranking.me(identity.sub) : await ranking.list(pageQuery(event.queryStringParameters));
      return response(200, { data, requestId });
    } catch (error) {
      const known = error instanceof ApiError;
      const status = known ? error.status : 500;
      const code = known ? error.code : 'internal_error';
      if (status >= 500) logger.error?.({ requestId, code });
      return response(status, { error: { code, message: known ? error.message : 'The request could not be completed.' }, requestId }, known ? error.headers : {});
    }
  };
}
