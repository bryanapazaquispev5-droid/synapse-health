import assert from 'node:assert/strict';
import test from 'node:test';
import {createCognitoUserStatus} from '../src/cognito-user-status.mjs';

const pool = 'us-east-1_LocalPool';
const status = expected => error => error.status === expected && !error.message.includes('secret');
const response = (code, body) => new Response(JSON.stringify(body), {status: code});

test('GetUser uses TLS bounded timeout and returns only subject', async () => {
  const verify = createCognitoUserStatus({fetcher: async (url, options) => {
    assert.equal(url, 'https://cognito-idp.us-east-1.amazonaws.com/');
    assert.equal(options.method, 'POST');
    assert.equal(options.redirect, 'error');
    assert.equal(options.headers['X-Amz-Target'], 'AWSCognitoIdentityProviderService.GetUser');
    assert.deepEqual(JSON.parse(options.body), {AccessToken: 'secret-access-token'});
    assert.ok(options.signal instanceof AbortSignal);
    return response(200, {Username: 'private', UserAttributes: [{Name: 'sub', Value: 'verified-sub'}, {Name: 'email', Value: 'private@example.invalid'}]});
  }});
  assert.equal(await verify('secret-access-token', pool), 'verified-sub');
});
for (const type of ['NotAuthorizedException', 'UserNotFoundException', 'com.amazonaws.cognito#NotAuthorizedException']) {
  test(`${type} rejects revoked/disabled token`, async () => {
    const verify = createCognitoUserStatus({fetcher: async () => response(400, {__type: type, message: 'secret-reason'})});
    await assert.rejects(verify('token', pool), status(401));
  });
}
for (const type of ['TooManyRequestsException', 'InternalErrorException', 'ForbiddenException']) {
  test(`${type} is unavailable rather than false invalid credentials`, async () => {
    const verify = createCognitoUserStatus({fetcher: async () => response(400, {__type: type})});
    await assert.rejects(verify('token', pool), status(503));
  });
}
test('transport error never exposes tokens or network details', async () => {
  const verify = createCognitoUserStatus({fetcher: async () => {throw new Error('secret-network');}});
  await assert.rejects(verify('token', pool), status(503));
});
test('missing subject is an invalid provider response', async () => {
  const verify = createCognitoUserStatus({fetcher: async () => response(200, {UserAttributes: []})});
  await assert.rejects(verify('token', pool), status(503));
});
test('malformed provider JSON is unavailable', async () => {
  const verify = createCognitoUserStatus({fetcher: async () => new Response('not-json', {status: 200})});
  await assert.rejects(verify('token', pool), status(503));
});
test('invalid region configuration never sends token to another host', async () => {
  let called = false;
  const verify = createCognitoUserStatus({fetcher: async () => {called = true;}});
  await assert.rejects(verify('token', 'https://other.invalid'), status(503));
  assert.equal(called, false);
});
