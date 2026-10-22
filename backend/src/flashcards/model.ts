import { ApiError } from '../http.mjs';

export interface FlashcardInput {
  areaId: string;
  topicId: string;
  title: string;
  summary: string;
  contentMarkdown: string;
  keyPoints: string[];
  mnemonics: string[];
  readDurationInMinutes: number;
  isPremium: boolean;
  sourceBook: string;
}
export type FlashcardPatch = Partial<Omit<FlashcardInput, 'areaId'>>;
export interface Flashcard extends FlashcardInput {
  id: string;
  version: number;
  createdAt: string;
  updatedAt: string;
}
export interface FlashcardListOptions { topicId?: string; limit?: number; cursor?: string | null }
export interface FlashcardPage { items: Flashcard[]; nextCursor: string | null }
export interface FlashcardRepository {
  list(areaId: string, options?: FlashcardListOptions): Promise<FlashcardPage>;
  get(id: string): Promise<Flashcard>;
  create(input: FlashcardInput): Promise<Flashcard>;
  update(id: string, patch: FlashcardPatch, version: number): Promise<Flashcard>;
  delete(id: string, version: number): Promise<void>;
}
export const invalidFlashcard = (): ApiError => new ApiError(400, 'invalid_flashcard', 'Provide valid flashcard parameters.');
export const encodeLocator = (value: unknown): string => Buffer.from(JSON.stringify(value)).toString('base64url');
export function decodeLocator(value: string): unknown {
  if (typeof value !== 'string' || !/^[A-Za-z0-9_-]{1,2048}$/.test(value)) throw invalidFlashcard();
  try {
    const parsed: unknown = JSON.parse(Buffer.from(value, 'base64url').toString('utf8'));
    if (encodeLocator(parsed) !== value) throw invalidFlashcard();
    return parsed;
  } catch { throw invalidFlashcard(); }
}
export function validCatalogId(value: unknown): value is string {
  return typeof value === 'string' && /^[A-Za-z0-9_-]{1,128}$/.test(value);
}
export function flashcardKey(id: string): { PK: string; SK: string } {
  const parts = decodeLocator(id);
  if (!Array.isArray(parts) || parts.length !== 2 || !validCatalogId(parts[0]) ||
      typeof parts[1] !== 'string' || !/^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$/.test(parts[1])) {
    throw invalidFlashcard();
  }
  return { PK: `AREA#${parts[0]}`, SK: `FLASHCARD#${parts[1]}` };
}
