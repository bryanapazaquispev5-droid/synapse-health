import type { FlashcardListOptions } from '../flashcards/model.js';

export interface QuizRecord {
  id: string; areaId: string; topicId: string; version: number;
  type: 'single_choice' | 'matching' | 'ordering'; question: string;
  options: string[]; correctIndex: number; rationale: string; sourceBook: string;
  orderIndex: number; matchingPairs: Array<{ left: string; right: string }>; orderingItems: string[];
}
export interface QuestionPresentation {
  choiceIds: string[]; leftIds: string[]; rightIds: string[]; itemIds: string[];
}
export interface QuestionSnapshot { quiz: QuizRecord; presentation: QuestionPresentation }
export type QuizAnswer = { choiceId: string } | { pairs: Array<{ leftId: string; rightId: string }> } | { itemIds: string[] };
export interface ScoredResult { isCorrect: boolean; score: number; earnedStars: number; maxStars: number }
export interface AttemptResult extends ScoredResult {
  isAnswered: true; attemptId: string; quizId: string; answeredAt: string; durationSeconds: number; topicAttemptNumber: number;
}
export interface StoredAttempt {
  id: string; quizId: string; areaId: string; topicId: string; topicAttemptNumber: number;
  startedAt: string; status: 'started' | 'submitted'; snapshot: QuestionSnapshot;
  answer?: QuizAnswer; answerFingerprint?: string; result?: AttemptResult;
}
export interface TopicAttempt {
  attemptNumber: number; startedAt: string; completedAt: string | null;
  totalEarnedStars: number; totalMaxStars: number; questionAnswers: Record<string, AttemptResult>;
}
export interface TopicProgress {
  areaId: string; topicId: string; currentAttemptNumber: number; version: number;
  activeAttempt: TopicAttempt; history: TopicAttempt[]; updatedAt: string;
}
export interface QuizPage { items: QuizRecord[]; nextCursor: string | null }
export interface ProgressPage { items: TopicProgress[]; nextCursor: string | null }
export interface ProgressListOptions { limit?: number; cursor?: string | null }
export interface QuizRepository {
  list(areaId: string, options?: FlashcardListOptions): Promise<QuizPage>;
  get(id: string): Promise<QuizRecord>;
  start(subject: string, quizId: string, idempotencyKey: string): Promise<StoredAttempt>;
  getAttempt(subject: string, quizId: string, attemptId: string): Promise<StoredAttempt>;
  submit(subject: string, quizId: string, attemptId: string, answer: QuizAnswer,
    fingerprint: string, result: ScoredResult): Promise<{ result: AttemptResult; isReplay: boolean }>;
  retry(subject: string, areaId: string, topicId: string, idempotencyKey: string, expectedAttemptNumber: number): Promise<TopicProgress>;
  progress(subject: string, options?: ProgressListOptions): Promise<ProgressPage>;
}
