import type { QuizRecord } from './model.js';
import { quizKey, unavailable, validCatalogId } from './keys.js';
function texts(value: unknown): value is string[] {
  return Array.isArray(value) && value.length <= 100 && value.every(item => typeof item === 'string' && item.trim().length > 0);
}
/** Catalog corruption is a service failure; clients cannot choose the private scoring schema. */
export function catalogRecord(item: Record<string, unknown>): QuizRecord {
  const { PK, SK, entityType, ...quiz } = item;
  if (entityType !== 'QUIZ' || typeof quiz.id !== 'string' || !validCatalogId(quiz.areaId) || !validCatalogId(quiz.topicId) ||
    !Number.isSafeInteger(quiz.version) || Number(quiz.version) < 1 ||
    typeof quiz.question !== 'string' || !quiz.question.trim() || typeof quiz.rationale !== 'string' || typeof quiz.sourceBook !== 'string' ||
    !Number.isSafeInteger(quiz.orderIndex) || Number(quiz.orderIndex) < 0 || !texts(quiz.options) || !texts(quiz.orderingItems) ||
    !Array.isArray(quiz.matchingPairs) || quiz.matchingPairs.length > 100 || quiz.matchingPairs.some(pair => !pair || typeof pair !== 'object' ||
      typeof pair.left !== 'string' || !pair.left.trim() || typeof pair.right !== 'string' || !pair.right.trim())) throw unavailable();
  let key: { PK: string; SK: string };
  try { key = quizKey(quiz.id); } catch { throw unavailable(); }
  if (PK !== key.PK || SK !== key.SK || PK !== `AREA#${quiz.areaId}`) throw unavailable();
  if (quiz.type === 'single_choice') {
    if (quiz.options.length < 2 || !Number.isInteger(quiz.correctIndex) || Number(quiz.correctIndex) < 0 || Number(quiz.correctIndex) >= quiz.options.length) throw unavailable();
  } else if (quiz.type === 'matching') {
    if (!quiz.matchingPairs.length || new Set(quiz.matchingPairs.map(pair => pair.left)).size !== quiz.matchingPairs.length) throw unavailable();
  } else if (quiz.type === 'ordering') {
    if (!quiz.orderingItems.length) throw unavailable();
  } else throw unavailable();
  return quiz as unknown as QuizRecord;
}
