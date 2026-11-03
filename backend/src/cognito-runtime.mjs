import {CognitoJwtVerifier} from 'aws-jwt-verify';
import {JwtParseError, JwtInvalidClaimError, JwtInvalidSignatureError, JwtInvalidSignatureAlgorithmError,
  JwtWithoutValidKidError, KidNotFoundInJwksError, WaitPeriodNotYetEndedJwkError, ParameterValidationError} from 'aws-jwt-verify/error';
import {ApiError} from './http.mjs';
import {createCognitoUserStatus} from './cognito-user-status.mjs';

function unavailable(stage) {
  const error = new ApiError(503, 'unavailable', 'Authentication service is unavailable.');
  error.stage = stage;
  return error;
}

// This identity is the canonical user identifier for the AWS runtime.
export function createCognitoRuntime({env = process.env, createVerifier = properties => CognitoJwtVerifier.create(properties),
  verifyUserStatus = createCognitoUserStatus({includeProfile: true})} = {}) {
  let verifier;
  function loadVerifier() {
    if (!env.COGNITO_USER_POOL_ID || !env.COGNITO_CLIENT_ID) {
      throw unavailable('cognito_configuration');
    }
    if (!verifier) {
      try {
        verifier = createVerifier({userPoolId: env.COGNITO_USER_POOL_ID, clientId: env.COGNITO_CLIENT_ID, tokenUse: 'access'});
      } catch {
        throw unavailable('cognito_verifier_initialization');
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
        throw unavailable('cognito_jwks_verification');
      }
      if (typeof claims.sub !== 'string' || !claims.sub.trim() || !Number.isFinite(claims.exp)) {
        throw new ApiError(401, 'unauthenticated', 'Sign in again.');
      }
      const activeSubject = await verifyUserStatus(token, env.COGNITO_USER_POOL_ID);
      if ((typeof activeSubject === 'string' ? activeSubject : activeSubject?.sub) !== claims.sub) throw new ApiError(401, 'unauthenticated', 'Sign in again.');
      const groups = claims['cognito:groups'];
      if (groups !== undefined && (!Array.isArray(groups) || groups.some(group => typeof group !== 'string'))) {
        throw new ApiError(401, 'unauthenticated', 'Sign in again.');
      }
      return {...(typeof activeSubject === 'object' ? activeSubject : {}), sub: claims.sub, groups: groups ?? []};
    },
  };
}
