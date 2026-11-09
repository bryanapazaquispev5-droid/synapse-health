import {test} from 'node:test';
import assert from 'node:assert/strict';
import {handleCognitoTrigger} from '../src/aws/cognito-triggers.mjs';

test('new Cognito sign-ups are confirmed without verifying email ownership', () => {
  const event = {triggerSource: 'PreSignUp_SignUp', response: {}};
  assert.equal(handleCognitoTrigger(event), event);
  assert.equal(event.response.autoConfirmUser, true);
  assert.equal(event.response.autoVerifyEmail, false);
});

test('token generation gives regular accounts the student role', () => {
  const event = {triggerSource: 'TokenGeneration_Authentication', request: {groupConfiguration: {}}, response: {}};
  handleCognitoTrigger(event);
  assert.deepEqual(event.response.claimsOverrideDetails.groupOverrideDetails.groupsToOverride, ['student']);
});

test('token generation keeps registered accounts in the student group only', () => {
  const event = {triggerSource: 'TokenGeneration_RefreshTokens', request: {
    groupConfiguration: {groupsToOverride: ['student', 'administrator'], preferredRole: 'old-role'},
  }, response: {}};
  handleCognitoTrigger(event);
  assert.deepEqual(event.response.claimsOverrideDetails.groupOverrideDetails, {
    groupsToOverride: ['student'],
  });
});

test('unrelated Cognito trigger events are left to the API handler', () => {
  assert.equal(handleCognitoTrigger({triggerSource: 'PostConfirmation_ConfirmSignUp'}), null);
});
