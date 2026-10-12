import { randomUUID } from 'node:crypto';
import { ApiError } from '../http.mjs';
import { DynamoQuizCatalog, type AcademicClient } from './catalog.js';
import { AcademicPrivateStore, publicTopic, notFoundAttempt, type StoredTopic, type RequestRecord } from './private-store.js';
import { conditionalFailure, conflict, invalidQuiz, topicKey, validCatalogId, validUuid } from './keys.js';
import type { QuizRepository, QuizRecord, QuestionSnapshot, StoredAttempt, QuizAnswer, ScoredResult,
  AttemptResult, TopicProgress, ProgressListOptions, ProgressPage } from './model.js';

function initialTopic(quiz: Pick<QuizRecord, 'areaId' | 'topicId'>, now: string, maxStars: number, catalogFingerprint: string): StoredTopic {
  return { areaId: quiz.areaId, topicId: quiz.topicId, currentAttemptNumber: 1, version: 0,
    activeAttempt: { attemptNumber: 1, startedAt: now, completedAt: null, totalEarnedStars: 0, totalMaxStars: maxStars, questionAnswers: {} },
    history: [], inFlight: {}, catalogFingerprint, updatedAt: now };
}
export class DynamoQuizRepository extends DynamoQuizCatalog implements QuizRepository {
  private readonly store: AcademicPrivateStore;
  constructor(client: AcademicClient, contentTable: string, privateTable: string,
    private readonly buildSnapshot: (quiz: QuizRecord) => QuestionSnapshot,
    private readonly clock: () => Date = () => new Date(), private readonly makeUuid: () => string = randomUUID) {
    super(client, contentTable); this.store = new AcademicPrivateStore(client, privateTable);
  }
  private async request(subject: string, id: string, operation: string): Promise<RequestRecord | null> {
    if (!validUuid(id)) throw invalidQuiz();
    const record = await this.store.read<RequestRecord>(subject, `REQUEST#${id}`);
    if (record && record.operation !== operation) throw conflict(); return record;
  }
  async start(subject: string, quizId: string, idempotencyKey: string): Promise<StoredAttempt> {
    const operation = `start:${quizId}`;
    const prior = await this.request(subject, idempotencyKey, operation);
    if (prior?.attemptId) return this.getAttempt(subject, quizId, prior.attemptId);
    let quiz = await this.get(quizId); const now = this.clock().toISOString();
    const existing = await this.store.topic(subject, quiz.areaId, quiz.topicId);
    const catalog = await this.topicCatalog(quiz.areaId, quiz.topicId);
    const currentQuiz = catalog.quizzes.find(item => item.id === quizId); if (!currentQuiz) throw conflict(); quiz = currentQuiz;
    const { maxStars, fingerprint } = catalog;
    const topic = existing ?? initialTopic(quiz, now, maxStars, fingerprint);
    if (topic.catalogFingerprint !== fingerprint) throw conflict();
    if (topic.activeAttempt.questionAnswers[quizId]) throw conflict();
    if (topic.inFlight[quizId]) {
      const resumed = await this.getAttempt(subject, quizId, topic.inFlight[quizId]);
      if (resumed.status !== 'started' || resumed.topicAttemptNumber !== topic.currentAttemptNumber) throw conflict();
      try {
        await this.store.transact([
          this.store.put(subject, topicKey(quiz.areaId, quiz.topicId), { ...topic, version: topic.version + 1 }, '#version = :version', topic.version),
          this.store.put(subject, `REQUEST#${idempotencyKey}`, { operation, attemptId: resumed.id }),
        ]);
        return resumed;
      } catch (error) {
        if (!conditionalFailure(error)) throw error;
        const replay = await this.request(subject, idempotencyKey, operation);
        if (replay?.attemptId) return this.getAttempt(subject, quizId, replay.attemptId); throw conflict();
      }
    }
    const id = this.makeUuid();
    const attempt: StoredAttempt = { id, quizId, areaId: quiz.areaId, topicId: quiz.topicId,
      topicAttemptNumber: topic.currentAttemptNumber, startedAt: now, status: 'started', snapshot: this.buildSnapshot(quiz) };
    const updated = { ...topic, version: topic.version + 1, updatedAt: now,
      activeAttempt: { ...topic.activeAttempt, totalMaxStars: maxStars }, inFlight: { ...topic.inFlight, [quizId]: id } };
    try {
      await this.store.transact([
        this.store.put(subject, topicKey(quiz.areaId, quiz.topicId), updated, existing ? '#version = :version' : undefined, existing?.version),
        this.store.put(subject, `ATTEMPT#${id}`, attempt),
        this.store.put(subject, `REQUEST#${idempotencyKey}`, { operation, attemptId: id }),
      ]);
      return attempt;
    } catch (error) {
      if (!conditionalFailure(error)) throw error;
      const replay = await this.request(subject, idempotencyKey, operation);
      if (replay?.attemptId) return this.getAttempt(subject, quizId, replay.attemptId); throw conflict();
    }
  }
  async getAttempt(subject: string, quizId: string, attemptId: string): Promise<StoredAttempt> {
    if (!validUuid(attemptId)) throw invalidQuiz();
    const attempt = await this.store.read<StoredAttempt>(subject, `ATTEMPT#${attemptId}`);
    if (!attempt || attempt.quizId !== quizId) throw notFoundAttempt(); return attempt;
  }
  async submit(subject: string, quizId: string, attemptId: string, answer: QuizAnswer, fingerprint: string,
    score: ScoredResult): Promise<{ result: AttemptResult; isReplay: boolean }> {
    const attempt = await this.getAttempt(subject, quizId, attemptId);
    if (attempt.status === 'submitted') {
      if (attempt.answerFingerprint !== fingerprint || !attempt.result) throw conflict();
      return { result: attempt.result, isReplay: true };
    }
    const topic = await this.store.topic(subject, attempt.areaId, attempt.topicId);
    if (!topic || topic.currentAttemptNumber !== attempt.topicAttemptNumber || topic.inFlight[quizId] !== attemptId || topic.activeAttempt.questionAnswers[quizId]) throw conflict();
    const now = this.clock(); const durationSeconds = Math.floor((now.getTime() - Date.parse(attempt.startedAt)) / 1000);
    if (!Number.isSafeInteger(durationSeconds) || durationSeconds < 0) throw new ApiError(503, 'clock_unavailable', 'Attempt service is unavailable.');
    const result: AttemptResult = { ...score, isAnswered: true, attemptId, quizId, answeredAt: now.toISOString(), durationSeconds, topicAttemptNumber: attempt.topicAttemptNumber };
    const questionAnswers = { ...topic.activeAttempt.questionAnswers, [quizId]: result };
    const inFlight = { ...topic.inFlight }; delete inFlight[quizId];
    const updated = { ...topic, inFlight, version: topic.version + 1, updatedAt: now.toISOString(),
      activeAttempt: { ...topic.activeAttempt, questionAnswers,
        totalEarnedStars: Object.values(questionAnswers).reduce((total, entry) => total + entry.earnedStars, 0) } };
    try {
      await this.store.transact([
        this.store.put(subject, topicKey(attempt.areaId, attempt.topicId), updated, '#version = :version', topic.version),
        this.store.put(subject, `ATTEMPT#${attemptId}`, { ...attempt, answer, answerFingerprint: fingerprint, result, status: 'submitted' }, '#status = :status'),
      ].map(item => {
        if (item.Put?.ConditionExpression === '#status = :status') {
          item.Put.ExpressionAttributeNames = { '#status': 'status' }; item.Put.ExpressionAttributeValues = { ':status': 'started' };
        }
        return item;
      }));
      return { result, isReplay: false };
    } catch (error) {
      if (!conditionalFailure(error)) throw error;
      const replay = await this.getAttempt(subject, quizId, attemptId);
      if (replay.status === 'submitted' && replay.answerFingerprint === fingerprint && replay.result) return { result: replay.result, isReplay: true };
      throw conflict();
    }
  }
  async retry(subject: string, areaId: string, topicId: string, idempotencyKey: string, expectedAttemptNumber: number): Promise<TopicProgress> {
    if (!validCatalogId(areaId) || !validCatalogId(topicId) || !Number.isSafeInteger(expectedAttemptNumber) || expectedAttemptNumber < 1) throw invalidQuiz();
    const operation = `retry:${areaId}:${topicId}:${expectedAttemptNumber}`;
    const prior = await this.request(subject, idempotencyKey, operation); if (prior?.progress) return prior.progress;
    const { maxStars, fingerprint } = await this.topicCatalog(areaId, topicId); const now = this.clock().toISOString();
    const existing = await this.store.topic(subject, areaId, topicId);
    const topic = existing ?? initialTopic({ areaId, topicId }, now, maxStars, fingerprint);
    if (topic.currentAttemptNumber !== expectedAttemptNumber) throw conflict();
    const hasAnswers = Object.keys(topic.activeAttempt.questionAnswers).length > 0;
    const hasCatalogChanged = topic.catalogFingerprint !== fingerprint;
    const next = hasAnswers ? topic.currentAttemptNumber + 1 : topic.currentAttemptNumber;
    if (!Number.isSafeInteger(next)) throw conflict();
    const updated: StoredTopic = { ...topic, version: topic.version + 1, updatedAt: now, currentAttemptNumber: next, catalogFingerprint: fingerprint,
      history: hasAnswers ? [...topic.history, { ...topic.activeAttempt, completedAt: now }].slice(-3) : topic.history,
      inFlight: hasAnswers || hasCatalogChanged ? {} : topic.inFlight,
      activeAttempt: hasAnswers ? { attemptNumber: next, startedAt: now, completedAt: null, totalEarnedStars: 0, totalMaxStars: maxStars, questionAnswers: {} }
        : { ...topic.activeAttempt, totalMaxStars: maxStars } };
    const progress = publicTopic(updated);
    try {
      await this.store.transact([
        this.store.put(subject, topicKey(areaId, topicId), updated, existing ? '#version = :version' : undefined, existing?.version),
        this.store.put(subject, `REQUEST#${idempotencyKey}`, { operation, progress }),
      ]);
      return progress;
    } catch (error) {
      if (!conditionalFailure(error)) throw error;
      const replay = await this.request(subject, idempotencyKey, operation); if (replay?.progress) return replay.progress; throw conflict();
    }
  }
  progress(subject: string, options: ProgressListOptions = {}): Promise<ProgressPage> { return this.store.progress(subject, options); }
}
