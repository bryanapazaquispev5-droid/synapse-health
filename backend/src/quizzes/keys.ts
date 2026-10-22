import { ApiError } from '../http.mjs';
import { encodeLocator, decodeLocator, validCatalogId } from '../flashcards/model.js';
export { encodeLocator, validCatalogId };
export const invalidQuiz = (): ApiError => new ApiError(400, 'invalid_quiz', 'Provide valid quiz parameters.');
export const conflict = (): ApiError => new ApiError(409, 'attempt_conflict', 'The attempt changed. Refresh and try again.');
export const unavailable = (): ApiError => new ApiError(503, 'academic_unavailable', 'Academic service is unavailable.');
export function decode(value: string): unknown {
  try { return decodeLocator(value); } catch { throw invalidQuiz(); }
}
export function quizKey(id: string): { PK: string; SK: string } {
  const parts = decode(id);
  if (!Array.isArray(parts) || parts.length !== 2 || !validCatalogId(parts[0]) || !validUuid(parts[1])) throw invalidQuiz();
  return { PK: `AREA#${parts[0]}`, SK: `QUIZ#${parts[1]}` };
}
export function validUuid(value: unknown): value is string {
  return typeof value === 'string' && /^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$/.test(value);
}
export function userKey(subject: string): string {
  if (!subject || subject.length > 256) throw new ApiError(401, 'unauthenticated', 'Sign in to continue.');
  return `USER#${subject}`;
}
export const topicKey = (areaId: string, topicId: string): string => `TOPIC#${areaId}#${topicId}`;
export function conditionalFailure(error: unknown): boolean {
  if (!(error instanceof Error)) return false;
  if (error.name === 'ConditionalCheckFailedException') return true;
  if (error.name !== 'TransactionCanceledException') return false;
  const reasons = (error as Error & { CancellationReasons?: Array<{ Code?: string }> }).CancellationReasons;
  return reasons?.some(reason => reason.Code === 'ConditionalCheckFailed') ?? false;
}
