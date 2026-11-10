import {createHash} from 'node:crypto';
import {ApiError} from '../http.mjs';
import {identifier, integer, invalid, object} from './validation.mjs';
import {mutate} from './store.mjs';
import {score, maxStars} from './scoring.mjs';
import {rankingWrite} from './ranking-projection.mjs';
const emptyAttempt = (attemptNumber, totalMaxStars, now) => ({attemptNumber, startedAt: now,
  completedAt: null, totalEarnedStars: 0, totalMaxStars, questionAnswers: {}});
const result = record => ({progress: record.data, version: record.version});

export function createProgress(store, catalog, now = () => new Date().toISOString(),
  {profilesStore = store, leaderboardStore = store} = {}) {
  async function total(area, topic) {
    return (await catalog.quizzes(area, topic)).reduce((sum, quiz) => sum + maxStars(quiz), 0);
  }
  return {
    async list(subject, options) {
      const output = await store.list(`USER#${subject}`, 'TOPIC#', options);
      return {items: output.items.map(record => ({...record.data, id: record.SK.slice(6), version: record.version})), nextCursor: output.nextCursor};
    },
    async clear(subject) {
      const output = await store.list(`USER#${subject}`, 'TOPIC#');
      for (const item of output.items) {
        await store.remove(`USER#${subject}`, item.SK);
      }
      return {cleared: true, count: output.items.length};
    },
    async answer(subject, topicId, input) {
      identifier(topicId);
      object(input, ['areaId', 'quizId', 'answer', 'expectedAttemptNumber', 'topicTotalMaxStars'], ['areaId', 'quizId', 'answer', 'expectedAttemptNumber']);
      const areaId = identifier(input.areaId);
      const quizId = identifier(input.quizId);
      const attemptNumber = integer(input.expectedAttemptNumber, 1);
      const canonical = await catalog.quiz(areaId, topicId, quizId);
      const scored = score(canonical, input.answer);
      const maximum = await total(areaId, topicId);
      const answerHash = createHash('sha256').update(JSON.stringify(input.answer)).digest('hex');
      const record = await mutate(store, `USER#${subject}`, `TOPIC#${topicId}`, async current => {
        const time = now();
        const data = current?.data ?? {topicId, areaId, currentAttemptNumber: 1,
          activeAttempt: emptyAttempt(1, maximum, time), history: [], updatedAt: time};
        if (data.areaId !== areaId || data.currentAttemptNumber !== attemptNumber) throw new ApiError(409, 'attempt_changed', 'Reload this topic before answering.');
        if (data.activeAttempt.questionAnswers[quizId]) {
          if (current.answerHashes?.[quizId] !== answerHash) throw new ApiError(409, 'already_answered', 'This question is already answered.');
          return current;
        }
        const questionAnswers = {...data.activeAttempt.questionAnswers,
          [quizId]: {quizId, ...scored, answeredAt: time}};
        const totalEarnedStars = Object.values(questionAnswers).reduce((sum, answer) => sum + answer.earnedStars, 0);
        return {data: {...data, updatedAt: time,
          activeAttempt: {...data.activeAttempt, questionAnswers, totalEarnedStars, totalMaxStars: maximum}},
          answerHashes: {...current?.answerHashes, [quizId]: answerHash}, relatedWrites: [
            await rankingWrite(profilesStore, leaderboardStore, subject, scored, time),
          ]};
      });
      return result(record);
    },
    async retry(subject, topicId, input) {
      identifier(topicId);
      object(input, ['areaId', 'totalMaxStars', 'expectedAttemptNumber', 'idempotencyKey'], ['areaId', 'expectedAttemptNumber', 'idempotencyKey']);
      const areaId = identifier(input.areaId);
      const expected = integer(input.expectedAttemptNumber, 1);
      if (typeof input.idempotencyKey !== 'string' || !/^[A-Za-z0-9_-]{16,128}$/.test(input.idempotencyKey)) throw invalid();
      const maximum = await total(areaId, topicId);
      const record = await mutate(store, `USER#${subject}`, `TOPIC#${topicId}`, async current => {
        if (current?.lastRetry?.key === input.idempotencyKey) {
          if (current.lastRetry.expected !== expected) throw invalid();
          return current;
        }
        const time = now();
        const data = current?.data ?? {topicId, areaId, currentAttemptNumber: 1,
          activeAttempt: emptyAttempt(1, maximum, time), history: [], updatedAt: time};
        if (data.areaId !== areaId || data.currentAttemptNumber !== expected) throw new ApiError(409, 'attempt_changed', 'Reload this topic before retrying.');
        const hasAnswers = Object.keys(data.activeAttempt.questionAnswers).length > 0;
        const currentAttemptNumber = expected + (hasAnswers ? 1 : 0);
        const history = hasAnswers ? [...data.history, {...data.activeAttempt, completedAt: time}].slice(-3) : data.history;
        return {data: {...data, currentAttemptNumber, history, updatedAt: time,
          activeAttempt: hasAnswers ? emptyAttempt(currentAttemptNumber, maximum, time) : {...data.activeAttempt, totalMaxStars: maximum}},
          answerHashes: hasAnswers ? {} : current?.answerHashes ?? {}, lastRetry: {key: input.idempotencyKey, expected}};
      });
      return result(record);
    },
  };
}
