import { createHash, randomInt, randomUUID } from 'node:crypto';
import { ApiError } from '../http.mjs';
import { validCatalogId } from '../flashcards/model.js';
import type { QuizRecord, QuestionSnapshot, QuizAnswer, ScoredResult } from './model.js';

const invalidAnswer = () => new ApiError(400, 'invalid_answer', 'Provide a valid answer for this question.');
function shuffle<T>(values: T[]): T[] {
  const result = [...values];
  for (let i = result.length - 1; i > 0; i--) {
    const j = randomInt(i + 1);
    [result[i], result[j]] = [result[j], result[i]];
  }
  return result;
}
export function buildQuestionSnapshot(quiz: QuizRecord): QuestionSnapshot {
  const unavailable = () => new ApiError(503, 'unavailable', 'This question is unavailable.');
  const strings = (value: unknown): value is string[] => Array.isArray(value) && value.length <= 100 && value.every(item => typeof item === 'string' && item.trim().length > 0);
  if (!quiz || typeof quiz.id !== 'string' || !/^[A-Za-z0-9_-]{1,2048}$/.test(quiz.id) || !validCatalogId(quiz.areaId) || !validCatalogId(quiz.topicId) || typeof quiz.sourceBook !== 'string' || !Number.isSafeInteger(quiz.orderIndex) || quiz.orderIndex < 0 || !Number.isSafeInteger(quiz.version) || quiz.version < 1 || typeof quiz.question !== 'string' || !quiz.question.trim() || !strings(quiz.options) || !strings(quiz.orderingItems) || !Array.isArray(quiz.matchingPairs)) throw unavailable();
  if (quiz.type === 'single_choice' && (quiz.options.length < 2 || !Number.isInteger(quiz.correctIndex) || quiz.correctIndex < 0 || quiz.correctIndex >= quiz.options.length)) throw unavailable();
  if (quiz.type === 'ordering' && quiz.orderingItems.length < 1) throw unavailable();
  if (quiz.type === 'matching' && (quiz.matchingPairs.length < 1 || quiz.matchingPairs.length > 100 || quiz.matchingPairs.some(pair => !pair || typeof pair.left !== 'string' || !pair.left.trim() || typeof pair.right !== 'string' || !pair.right.trim()) || new Set(quiz.matchingPairs.map(pair => pair.left)).size !== quiz.matchingPairs.length)) throw unavailable();
  if (!['single_choice', 'matching', 'ordering'].includes(quiz.type)) throw unavailable();
  return { quiz, presentation: {
    choiceIds: quiz.options.map(() => randomUUID()),
    leftIds: quiz.matchingPairs.map(() => randomUUID()),
    rightIds: quiz.matchingPairs.map(() => randomUUID()),
    itemIds: quiz.orderingItems.map(() => randomUUID()),
  } };
}
/** Keep correct indexes, pairing associations, ordering and rationale private. */
export function publicQuestion(snapshot: QuestionSnapshot): Record<string, unknown> {
  const { quiz, presentation: ids } = snapshot;
  const question = ['matching', 'ordering'].includes(quiz.type)
    ? quiz.question.split(/\n\s*1\./)[0].trim() : quiz.question;
  const data: Record<string, unknown> = {
    id: quiz.id, areaId: quiz.areaId, topicId: quiz.topicId, type: quiz.type,
    question, sourceBook: quiz.sourceBook, orderIndex: quiz.orderIndex,
  };
  if (quiz.type === 'single_choice') data.options = shuffle(quiz.options.map((text, i) => ({ id: ids.choiceIds[i], text })));
  if (quiz.type === 'matching') {
    data.leftItems = shuffle(quiz.matchingPairs.map((pair, i) => ({ id: ids.leftIds[i], text: pair.left })));
    data.rightItems = shuffle(quiz.matchingPairs.map((pair, i) => ({ id: ids.rightIds[i], text: pair.right })));
  }
  if (quiz.type === 'ordering') data.items = shuffle(quiz.orderingItems.map((text, i) => ({ id: ids.itemIds[i], text })));
  return data;
}
function object(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw invalidAnswer();
  return value as Record<string, unknown>;
}
function exact(value: Record<string, unknown>, names: string[]): void {
  if (Object.keys(value).length !== names.length || names.some(name => !Object.hasOwn(value, name))) throw invalidAnswer();
}
function permutation(value: unknown, ids: string[]): string[] {
  if (!Array.isArray(value) || value.length !== ids.length || value.some(item => typeof item !== 'string' || !ids.includes(item)) || new Set(value).size !== ids.length) throw invalidAnswer();
  return value as string[];
}
export function scoreAnswer(snapshot: QuestionSnapshot, raw: unknown): { answer: QuizAnswer; result: ScoredResult; fingerprint: string } {
  const input = object(raw);
  const { quiz, presentation: ids } = snapshot;
  let earnedStars = 0;
  let maxStars = 1;
  let answer: QuizAnswer;
  if (quiz.type === 'single_choice') {
    exact(input, ['choiceId']);
    if (typeof input.choiceId !== 'string' || !ids.choiceIds.includes(input.choiceId)) throw invalidAnswer();
    answer = { choiceId: input.choiceId };
    earnedStars = ids.choiceIds[quiz.correctIndex] === input.choiceId ? 1 : 0;
  } else if (quiz.type === 'matching') {
    exact(input, ['pairs']);
    if (!Array.isArray(input.pairs)) throw invalidAnswer();
    const pairs = input.pairs.map(rawPair => {
      const pair = object(rawPair);
      exact(pair, ['leftId', 'rightId']);
      if (typeof pair.leftId !== 'string' || typeof pair.rightId !== 'string') throw invalidAnswer();
      return { leftId: pair.leftId, rightId: pair.rightId };
    });
    permutation(pairs.map(pair => pair.leftId), ids.leftIds);
    permutation(pairs.map(pair => pair.rightId), ids.rightIds);
    maxStars = ids.leftIds.length;
    earnedStars = pairs.filter(pair => quiz.matchingPairs[ids.leftIds.indexOf(pair.leftId)].right === quiz.matchingPairs[ids.rightIds.indexOf(pair.rightId)].right).length;
    answer = { pairs: pairs.sort((a, b) => a.leftId.localeCompare(b.leftId)) };
  } else if (quiz.type === 'ordering') {
    exact(input, ['itemIds']);
    const itemIds = permutation(input.itemIds, ids.itemIds);
    maxStars = ids.itemIds.length;
    earnedStars = itemIds.filter((id, i) => quiz.orderingItems[ids.itemIds.indexOf(id)] === quiz.orderingItems[i]).length;
    answer = { itemIds };
  } else throw new ApiError(503, 'unavailable', 'This question is unavailable.');
  const isCorrect = earnedStars === maxStars;
  return { answer, result: { isCorrect, score: isCorrect ? 1 : 0, earnedStars, maxStars },
    fingerprint: createHash('sha256').update(JSON.stringify(answer)).digest('hex') };
}
