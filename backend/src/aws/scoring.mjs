import {invalid, object, integer} from './validation.mjs';
import {ApiError} from '../http.mjs';
function values(input) {
  if (!Array.isArray(input) || input.length > 100 || input.some(value => typeof value !== 'string' || !value.length)) throw invalid();
  return input;
}
function permutation(input, expected) {
  const actual = values(input);
  if (JSON.stringify([...actual].sort()) !== JSON.stringify([...expected].sort())) throw invalid('Provide all question items exactly once.');
  return actual;
}
export function maxStars(quiz) {
  const type = quiz.type ?? 'single_choice';
  const maximum = type === 'matching' ? quiz.matchingPairs?.length : type === 'ordering' ? quiz.orderingItems?.length : 1;
  if (!Number.isSafeInteger(maximum) || maximum < 1 || maximum > 100) throw new ApiError(503, 'invalid_catalog', 'This question needs catalog normalization.');
  return maximum;
}
export function score(quiz, answer) {
  const type = quiz.type ?? 'single_choice';
  let earnedStars;
  let selectedOptionIndex = null;
  const maximum = maxStars(quiz);
  if (type === 'matching') {
    object(answer, ['pairs'], ['pairs']);
    if (!Array.isArray(answer.pairs) || answer.pairs.length > 100) throw invalid();
    const pairs = answer.pairs.map(pair => object(pair, ['left', 'right'], ['left', 'right']));
    permutation(pairs.map(pair => pair.left), quiz.matchingPairs.map(pair => pair.left));
    permutation(pairs.map(pair => pair.right), quiz.matchingPairs.map(pair => pair.right));
    earnedStars = pairs.filter(pair => quiz.matchingPairs.some(correct => correct.left === pair.left && correct.right === pair.right)).length;
  } else if (type === 'ordering') {
    object(answer, ['items'], ['items']);
    const ordered = permutation(answer.items, quiz.orderingItems);
    earnedStars = ordered.filter((item, index) => item === quiz.orderingItems[index]).length;
  } else if (type === 'single_choice' || type === 'case_study') {
    object(answer, ['selectedOptionText', 'selectedOptionIndex'], ['selectedOptionText']);
    const options = values(quiz.options);
    if (!options.includes(answer.selectedOptionText)) throw invalid();
    if (answer.selectedOptionIndex !== undefined) selectedOptionIndex = integer(answer.selectedOptionIndex, 0, options.length - 1);
    if (!Number.isInteger(quiz.correctIndex) || quiz.correctIndex < 0 || quiz.correctIndex >= options.length) {
      throw new ApiError(503, 'invalid_catalog', 'This question needs catalog normalization.');
    }
    earnedStars = answer.selectedOptionText === options[quiz.correctIndex] ? 1 : 0;
  } else throw new ApiError(503, 'invalid_catalog', 'Unsupported question type.');
  return {isAnswered: true, isCorrect: earnedStars === maximum, earnedStars, maxStars: maximum, selectedOptionIndex};
}
