import type {APIGatewayProxyHandler, APIGatewayProxyEvent} from 'aws-lambda';
import {createHandler} from './app.mjs';
import {createRuntime} from './firebase-runtime.mjs';
import {createCognitoRuntime} from './cognito-runtime.mjs';
import {withCors} from './cors.mjs';
import {createFlashcardHandler} from './flashcards/controller.js';
import {createFlashcardRuntime} from './flashcards/runtime.js';
import {createQuizHandler} from './quizzes/controller.js';
import {createQuizRuntime} from './quizzes/runtime.js';

// Existing Firebase endpoints remain separate from Cognito-authenticated content.
const cognito = createCognitoRuntime();
const existing = createHandler({...createRuntime(), ...cognito});
const flashcards = createFlashcardHandler({...createFlashcardRuntime(), ...cognito});
const quizzes = createQuizHandler({...createQuizRuntime(), ...cognito});
export const handler: APIGatewayProxyHandler = withCors(async (event: APIGatewayProxyEvent) => {
  if (event.path === '/api/v1/quizzes' || event.path?.startsWith('/api/v1/quizzes/') || event.path === '/api/v1/progress/me') return quizzes(event);
  return event.path === '/api/v1/flashcards' || event.path?.startsWith('/api/v1/flashcards/')
    ? flashcards(event) : existing(event);
}, process.env.ALLOWED_ORIGIN ?? 'https://synapse.invalid');
