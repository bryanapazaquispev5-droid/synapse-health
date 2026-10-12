import type { APIGatewayProxyEvent } from 'aws-lambda';
import { ApiError, header } from '../http.mjs';
import { validCatalogId } from '../flashcards/model.js';
export const invalidRequest = (): ApiError => new ApiError(400, 'invalid_request', 'Provide valid quiz parameters.');
export function parseBody(event: APIGatewayProxyEvent, keys: string[]): Record<string, unknown> {
  if (!/^application\/json(?:\s*;.*)?$/i.test(header(event.headers, 'content-type') ?? '')) throw new ApiError(415, 'unsupported_media_type', 'Use application/json.');
  if (typeof event.body !== 'string') throw invalidRequest();
  let body = event.body;
  if (event.isBase64Encoded) {
    if (body.length > 22000 || !/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(body)) throw invalidRequest();
    body = Buffer.from(body, 'base64').toString('utf8');
  }
  if (Buffer.byteLength(body) > 16384) throw new ApiError(413, 'payload_too_large', 'Request body is too large.');
  let input: unknown;
  try { input = JSON.parse(body); } catch { throw invalidRequest(); }
  if (!input || typeof input !== 'object' || Array.isArray(input)) throw invalidRequest();
  const value = input as Record<string, unknown>;
  if (Object.keys(value).length !== keys.length || keys.some(key => !Object.hasOwn(value, key))) throw invalidRequest();
  return value;
}
export function uuid(value: unknown): string {
  if (typeof value !== 'string' || !/^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$/i.test(value)) throw invalidRequest();
  return value.toLowerCase();
}
export function catalog(value: unknown): string {
  if (!validCatalogId(value)) throw invalidRequest();
  return value;
}
export function pageQuery(raw: APIGatewayProxyEvent['queryStringParameters']): { limit?: number; cursor?: string } {
  const query = raw ?? {};
  if (Object.keys(query).some(key => !['limit', 'cursor'].includes(key))) throw invalidRequest();
  const options: { limit?: number; cursor?: string } = {};
  if (query.limit !== undefined) {
    if (!/^[1-9]\d?$/.test(query.limit ?? '') || Number(query.limit) > 50) throw invalidRequest();
    options.limit = Number(query.limit);
  }
  if (query.cursor !== undefined) {
    if (!query.cursor || !/^[A-Za-z0-9_-]{1,4096}$/.test(query.cursor)) throw invalidRequest();
    options.cursor = query.cursor;
  }
  return options;
}
export function listQuery(raw: APIGatewayProxyEvent['queryStringParameters']): { areaId: string; topicId?: string; limit?: number; cursor?: string } {
  const { areaId, topicId, ...page } = raw ?? {};
  return { areaId: catalog(areaId), ...pageQuery(page), ...(topicId !== undefined ? { topicId: catalog(topicId) } : {}) };
}
