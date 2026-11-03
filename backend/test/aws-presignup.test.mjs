import {test} from 'node:test';
import assert from 'node:assert/strict';
import {handler} from '../src/aws/index.mjs';

test('pre-sign-up auto-confirms the account but leaves email unverified', async () => {
  const event = {triggerSource: 'PreSignUp_SignUp', response: {existing: true}};
  const result = await handler(event);
  assert.deepEqual(result.response, {
    existing: true,
    autoConfirmUser: true,
    autoVerifyEmail: false,
  });
});
