import {CognitoJwtVerifier} from 'aws-jwt-verify';
import {JwtParseError, JwtInvalidClaimError, JwtInvalidSignatureError, JwtInvalidSignatureAlgorithmError,
  JwtWithoutValidKidError, KidNotFoundInJwksError, WaitPeriodNotYetEndedJwkError, ParameterValidationError} from 'aws-jwt-verify/error';
import {ApiError} from './http.mjs';
import {createCognitoUserStatus} from './cognito-user-status.mjs';

// This identity never becomes a Firebase UID without an explicit future mapping.
export function createCognitoRuntime({env = process.env, createVerifier = properties => CognitoJwtVerifier.create(properties),
  verifyUserStatus = createCognitoUserStatus()} = {}) {
  let verifier;
  function loadVerifier() {
    if (!env.COGNITO_USER_POOL_ID || !env.COGNITO_CLIENT_ID) {
      throw new ApiError(503, 'unavailable', 'Authentication service is not configured.');
    }
    if (!verifier) {
      try {
        verifier = createVerifier({userPoolId: env.COGNITO_USER_POOL_ID, clientId: env.COGNITO_CLIENT_ID, tokenUse: 'access'});
      } catch {
        throw new ApiError(503, 'unavailable', 'Authentication service is unavailable.');
      }
    }
    return verifier;
  }
  return {
    async verifyCognitoToken(token) {
      const activeVerifier = loadVerifier();
      let claims;
      try {
        claims = await activeVerifier.verify(token);
      } catch (error) {
        if ([JwtParseError, JwtInvalidClaimError, JwtInvalidSignatureError, JwtInvalidSignatureAlgorithmError,
          JwtWithoutValidKidError, KidNotFoundInJwksError, WaitPeriodNotYetEndedJwkError, ParameterValidationError].some(type => error instanceof type)) {
          throw new ApiError(401, 'unauthenticated', 'Sign in again.');
        }
        throw new ApiError(503, 'unavailable', 'Authentication service is unavailable.');
      }
      if (typeof claims.sub !== 'string' || !claims.sub.trim() || !Number.isFinite(claims.exp)) {
        throw new ApiError(401, 'unauthenticated', 'Sign in again.');
      }
      const activeSubject = await verifyUserStatus(token, env.COGNITO_USER_POOL_ID);
      if (activeSubject !== claims.sub) throw new ApiError(401, 'unauthenticated', 'Sign in again.');
      return {sub: claims.sub};
    },
  };
}
