export function handleCognitoTrigger(event, studentGroup = 'student') {
  if (event.triggerSource === 'PreSignUp_SignUp') {
    event.response = {...event.response, autoConfirmUser: true, autoVerifyEmail: false};
    return event;
  }
  if (!event.triggerSource?.startsWith('TokenGeneration_')) return null;
  const groupConfiguration = event.request?.groupConfiguration ?? {};
  event.response = {...event.response, claimsOverrideDetails: {
    ...event.response?.claimsOverrideDetails,
    groupOverrideDetails: {groupsToOverride: [studentGroup]},
  }};
  return event;
}
