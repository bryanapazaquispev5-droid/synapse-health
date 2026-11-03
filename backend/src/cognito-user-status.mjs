import {ApiError} from './http.mjs';

function unavailable(stage) {
  const error = new ApiError(503, 'unavailable', 'Authentication service is unavailable.');
  error.stage = stage;
  return error;
}

// GetUser also checks revocation/disabled users, which offline JWT validation cannot establish.
export function createCognitoUserStatus({fetcher = globalThis.fetch, timeoutMs = 5000, includeProfile = false} = {}) {
  return async (token, userPoolId) => {
    const region = /^[a-z]{2}(?:-[a-z]+)+-\d+/.exec(userPoolId)?.[0];
    if (!region) throw unavailable('cognito_status_configuration');
    const suffix = region.startsWith('cn-') ? 'amazonaws.com.cn' : 'amazonaws.com';
    let result;
    try {
      result = await fetcher(`https://cognito-idp.${region}.${suffix}/`, {
        method: 'POST', headers: {'Content-Type': 'application/x-amz-json-1.1', 'X-Amz-Target': 'AWSCognitoIdentityProviderService.GetUser'},
        body: JSON.stringify({AccessToken: token}), signal: AbortSignal.timeout(timeoutMs), redirect: 'error',
      });
    } catch {
      throw unavailable('cognito_status_network');
    }
    let data;
    try { data = await result.json(); } catch {
      throw unavailable('cognito_status_response');
    }
    if (!result.ok) {
      const type = String(data?.__type ?? '').split('#').at(-1);
      if (['NotAuthorizedException', 'UserNotFoundException'].includes(type)) {
        throw new ApiError(401, 'unauthenticated', 'Sign in again.');
      }
      throw unavailable('cognito_status_rejected');
    }
    const sub = data?.UserAttributes?.find(attribute => attribute.Name === 'sub')?.Value;
    if (typeof sub !== 'string' || !sub.trim()) {
      throw unavailable('cognito_status_missing_subject');
    }
    if (!includeProfile) return sub;
    const attributes = Object.fromEntries(data.UserAttributes.map(attribute => [attribute.Name, attribute.Value]));
    return {sub, email: attributes.email ?? '', emailVerified: attributes.email_verified === 'true',
      name: attributes.name ?? '', provider: 'password',
      ...(typeof attributes.picture === 'string' && attributes.picture.startsWith('https://') ? {photoUrl: attributes.picture} : {})};
  };
}
