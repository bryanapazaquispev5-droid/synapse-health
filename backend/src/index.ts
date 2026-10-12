import type {APIGatewayProxyHandler} from 'aws-lambda';
import {createHandler} from './app.mjs';
import {createRuntime} from './firebase-runtime.mjs';
import {createCognitoRuntime} from './cognito-runtime.mjs';
import {withCors} from './cors.mjs';

// Typed Lambda entry point; existing modular JavaScript is preserved during recovery.
export const handler: APIGatewayProxyHandler = withCors(createHandler({...createRuntime(), ...createCognitoRuntime()}), process.env.ALLOWED_ORIGIN ?? 'https://synapse.invalid');
