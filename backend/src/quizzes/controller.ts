import type { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { ApiError, header, response } from '../http.mjs';
import type { QuizRepository, StoredAttempt } from './model.js';
import { buildQuestionSnapshot, publicQuestion, scoreAnswer } from './scoring.js';
import { catalog, invalidRequest, listQuery, pageQuery, parseBody, uuid } from './validation.js';
interface Dependencies {
  verifyCognitoToken(token: string): Promise<{ sub: string }>;
  repository: QuizRepository;
  limiter?: { consume(subject: string): Promise<void> };
  logger?: { error?(entry: { requestId: string; code: string }): void };
}
function publicAttempt(attempt: StoredAttempt): Record<string, unknown> {
  return { attemptId: attempt.id, quizId: attempt.quizId, topicAttemptNumber: attempt.topicAttemptNumber,
    startedAt: attempt.startedAt, status: attempt.status,
    question: publicQuestion(attempt.snapshot), ...(attempt.result ? { result: attempt.result } : {}) };
}
export function createQuizHandler({ verifyCognitoToken, repository, limiter, logger = console }: Dependencies): (event: APIGatewayProxyEvent) => Promise<APIGatewayProxyResult> {
  return async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    const requestId = event.requestContext?.requestId ?? 'unavailable';
    try {
      const path = event.path ?? '';
      const collection = path === '/api/v1/quizzes';
      const progress = path === '/api/v1/progress/me';
      const retry = /^\/api\/v1\/quizzes\/topics\/([^/]+)\/retry$/.exec(path);
      const detail = /^\/api\/v1\/quizzes\/([^/]+)(?:\/attempts(?:\/(start|[^/]+))?)?$/.exec(path);
      if (!collection && !progress && !retry && !detail) throw new ApiError(404, 'not_found', 'Endpoint not found.');
      const attemptPath = detail && path.includes('/attempts');
      const expectedMethod = retry || (attemptPath && (!detail![2] || detail![2] === 'start')) ? 'POST' : 'GET';
      if (event.httpMethod !== expectedMethod) throw new ApiError(405, 'method_not_allowed', 'Method not allowed.', { Allow: expectedMethod });
      const authorization = header(event.headers, 'authorization');
      const bearer = typeof authorization === 'string' && /^Bearer\s+([^\s]+)$/i.exec(authorization);
      if (!bearer) throw new ApiError(401, 'unauthenticated', 'Authentication is required.');
      const identity = await verifyCognitoToken(bearer[1]);
      if (!identity?.sub || typeof identity.sub !== 'string') throw new ApiError(401, 'unauthenticated', 'Authentication is required.');
      await limiter?.consume(identity.sub);
      if (expectedMethod === 'GET' && event.body != null && event.body !== '') throw invalidRequest();
      if (!collection && !progress && Object.keys(event.queryStringParameters ?? {}).length) throw invalidRequest();
      let data: unknown;
      let status = 200;
      if (collection) {
        const { areaId, ...options } = listQuery(event.queryStringParameters);
        const page = await repository.list(areaId, options);
        data = { items: page.items.map(quiz => publicQuestion(buildQuestionSnapshot(quiz))), nextCursor: page.nextCursor };
      } else if (progress) data = await repository.progress(identity.sub, pageQuery(event.queryStringParameters));
      else if (retry) {
        const input = parseBody(event, ['areaId', 'expectedAttemptNumber']);
        if (!Number.isSafeInteger(input.expectedAttemptNumber) || Number(input.expectedAttemptNumber) < 1) throw invalidRequest();
        data = await repository.retry(identity.sub, catalog(input.areaId), catalog(retry[1]),
          uuid(header(event.headers, 'idempotency-key')), Number(input.expectedAttemptNumber));
      } else if (!attemptPath) data = publicQuestion(buildQuestionSnapshot(await repository.get(detail![1])));
      else if (detail![2] === 'start') {
        parseBody(event, []);
        data = publicAttempt(await repository.start(identity.sub, detail![1], uuid(header(event.headers, 'idempotency-key'))));
        status = 201;
      } else if (detail![2]) data = publicAttempt(await repository.getAttempt(identity.sub, detail![1], uuid(detail![2])));
      else {
        const input = parseBody(event, ['attemptId', 'answer']);
        const attemptId = uuid(input.attemptId);
        const attempt = await repository.getAttempt(identity.sub, detail![1], attemptId);
        const scored = scoreAnswer(attempt.snapshot, input.answer);
        const submitted = await repository.submit(identity.sub, detail![1], attemptId, scored.answer, scored.fingerprint, scored.result);
        data = submitted.result;
        status = submitted.isReplay ? 200 : 201;
      }
      return response(status, { data, requestId });
    } catch (error) {
      const known = error instanceof ApiError;
      const status = known ? error.status : 500;
      const code = known ? error.code : 'internal_error';
      if (status >= 500) logger.error?.({ requestId, code });
      return response(status, { error: { code, message: known ? error.message : 'The request could not be completed.' }, requestId }, known ? error.headers : {});
    }
  };
}
