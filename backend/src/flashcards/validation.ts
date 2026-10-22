import { ApiError, header } from '../http.mjs';

import type { FlashcardInput, FlashcardPatch } from './model.js';
export interface ListQuery { areaId: string; topicId?: string; limit: number; cursor?: string }
interface BodyEvent { body?: string | null; isBase64Encoded?: boolean; headers?: Record<string, string | undefined> | null }
const idPattern = /^[A-Za-z0-9_-]{1,128}$/;
const fields = ['areaId', 'topicId', 'title', 'contentMarkdown', 'summary', 'keyPoints', 'mnemonics', 'readDurationInMinutes', 'isPremium', 'sourceBook'];
export function validateId(value: string): string {
  if (!idPattern.test(value)) throw new ApiError(400, 'invalid_id', 'Provide a valid identifier.');
  return value;
}
export function parseListQuery(raw: Record<string, string | undefined> | null | undefined): ListQuery {
  const query = raw ?? {};
  if (Object.keys(query).some(key => !['areaId', 'topicId', 'limit', 'cursor'].includes(key))) {
    throw new ApiError(400, 'invalid_query', 'Unsupported query parameter.');
  }
  const areaId = validateId(query.areaId ?? '');
  const topicId = query.topicId === undefined ? undefined : validateId(query.topicId);
  if (query.limit !== undefined && !/^[1-9]\d?$/.test(query.limit)) throw new ApiError(400, 'invalid_query', 'Limit must be between 1 and 50.');
  const limit = Number(query.limit ?? 20);
  if (limit > 50) throw new ApiError(400, 'invalid_query', 'Limit must be between 1 and 50.');
  if (query.cursor !== undefined && (!query.cursor.length || query.cursor.length > 2048 || !/^[A-Za-z0-9_-]+$/.test(query.cursor))) {
    throw new ApiError(400, 'invalid_cursor', 'Provide a valid cursor.');
  }
  return { areaId, ...(topicId ? { topicId } : {}), limit, ...(query.cursor ? { cursor: query.cursor } : {}) };
}
export function parseVersion(headers: BodyEvent['headers']): number {
  const raw = header(headers, 'if-match');
  if (typeof raw !== 'string' || !/^"[1-9]\d*"$/.test(raw)) {
    throw new ApiError(400, 'invalid_version', 'Provide the current strong ETag in If-Match.');
  }
  const value = Number(raw.slice(1, -1));
  if (!Number.isSafeInteger(value)) throw new ApiError(400, 'invalid_version', 'Provide a valid version.');
  return value;
}
export function parseFlashcardBody(event: BodyEvent, create: true): FlashcardInput;
export function parseFlashcardBody(event: BodyEvent, create: false): FlashcardPatch;
export function parseFlashcardBody(event: BodyEvent, create: boolean): FlashcardInput | FlashcardPatch {
  if (!/^application\/json(?:\s*;.*)?$/i.test(header(event.headers, 'content-type') ?? '')) {
    throw new ApiError(415, 'unsupported_media_type', 'Use application/json.');
  }
  if (typeof event.body !== 'string') throw new ApiError(400, 'invalid_body', 'Provide a JSON object.');
  let text = event.body;
  if (event.isBase64Encoded) {
    if (text.length > 21848) throw new ApiError(413, 'payload_too_large', 'Request body is too large.');
    if (!/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(text)) {
      throw new ApiError(400, 'invalid_body', 'Provide valid base64.');
    }
    text = Buffer.from(text, 'base64').toString('utf8');
  }
  if (Buffer.byteLength(text, 'utf8') > 16384) throw new ApiError(413, 'payload_too_large', 'Request body is too large.');
  let raw: unknown;
  try { raw = JSON.parse(text); } catch { throw new ApiError(400, 'invalid_body', 'Provide valid JSON.'); }
  if (!raw || typeof raw !== 'object' || Array.isArray(raw) || !Object.keys(raw).length) {
    throw new ApiError(400, 'invalid_body', 'Provide a nonempty JSON object.');
  }
  const input = raw as Record<string, unknown>;
  const output: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(input)) {
    if (!fields.includes(key) || (!create && key === 'areaId')) {
      throw new ApiError(400, 'invalid_flashcard', 'Unsupported flashcard field.');
    }
    if (['keyPoints', 'mnemonics'].includes(key)) {
      if (!Array.isArray(value) || value.length > 50 || value.some(item => typeof item !== 'string' || !item.trim() || item.length > 1000)) {
        throw new ApiError(400, 'invalid_flashcard', 'Provide valid text lists.');
      }
      output[key] = value.map(item => (item as string).trim());
    } else if (key === 'isPremium') {
      if (typeof value !== 'boolean') throw new ApiError(400, 'invalid_flashcard', 'Provide a boolean premium flag.');
      output[key] = value;
    } else if (key === 'readDurationInMinutes') {
      if (typeof value !== 'number' || !Number.isInteger(value) || value < 0 || value > 1440) {
        throw new ApiError(400, 'invalid_flashcard', 'Provide a valid reading duration.');
      }
      output[key] = value;
    } else {
      const maximum = key === 'contentMarkdown' ? 12000 : key === 'summary' ? 2000 : key === 'title' ? 200 : 500;
      if (typeof value !== 'string' || value.length > maximum || (['title', 'contentMarkdown', 'areaId', 'topicId'].includes(key) && !value.trim())) {
        throw new ApiError(400, 'invalid_flashcard', 'Provide valid text fields.');
      }
      output[key] = ['areaId', 'topicId'].includes(key) ? validateId(value) : value.trim();
    }
  }
  if (create && ['areaId', 'topicId', 'title', 'contentMarkdown'].some(key => output[key] === undefined)) {
    throw new ApiError(400, 'invalid_flashcard', 'Area, topic, title and content are required.');
  }
  return (create ? { summary: '', keyPoints: [], mnemonics: [], readDurationInMinutes: 0, isPremium: false, sourceBook: '', ...output } : output) as unknown as FlashcardInput | FlashcardPatch;
}
