import {ApiError} from './http.mjs';

// GetUser also checks revocation/disabled users, which offline JWT validation cannot establish.
export function createCognitoUserStatus({fetcher = globalThis.fetch, timeoutMs = 5000} = {}) {
  return async (token, userPoolId) => {
    const region = /^[a-z]{2}(?:-[a-z]+)+-\d+/.exec(userPoolId)?.[0];
    if (!region) throw new ApiError(503, 'unavailable', 'Authentication service is unavailable.');
    const suffix = region.startsWith('cn-') ? 'amazonaws.com.cn' : 'amazonaws.com';
    let result;
    try {
      result = await fetcher(`https://cognito-idp.${region}.${suffix}/`, {
        method: 'POST', headers: {'Content-Type': 'application/x-amz-json-1.1', 'X-Amz-Target': 'AWSCognitoIdentityProviderService.GetUser'},
        body: JSON.stringify({AccessToken: token}), signal: AbortSignal.timeout(timeoutMs), redirect: 'error',
      });
    } catch {
      throw new ApiError(503, 'unavailable', 'Authentication service is unavailable.');
    }
    let data;
    try { data = await result.json(); } catch {
      throw new ApiError(503, 'unavailable', 'Authentication service is unavailable.');
    }
    if (!result.ok) {
      const type = String(data?.__type ?? '').split('#').at(-1);
      if (['NotAuthorizedException', 'UserNotFoundException'].includes(type)) {
        throw new ApiError(401, 'unauthenticated', 'Sign in again.');
      }
      throw new ApiError(503, 'unavailable', 'Authentication service is unavailable.');
    }
    const sub = data?.UserAttributes?.find(attribute => attribute.Name === 'sub')?.Value;
    if (typeof sub !== 'string' || !sub.trim()) {
      throw new ApiError(503, 'unavailable', 'Authentication service is unavailable.');
    }
    return sub;
  };
}
