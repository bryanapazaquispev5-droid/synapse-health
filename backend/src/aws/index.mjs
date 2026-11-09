import {withCors} from '../cors.mjs';
import {createAwsHandler} from './handler.mjs';
import {createAwsRuntime} from './runtime.mjs';
import {handleCognitoTrigger} from './cognito-triggers.mjs';
// Clients are reused between invocations; credentials come from the Lambda execution role.
const handleApi = withCors(createAwsHandler(createAwsRuntime()), process.env.ALLOWED_ORIGIN ?? 'https://synapse.invalid');
export const handler = async event => {
  const triggerResult = handleCognitoTrigger(event, process.env.COGNITO_STUDENT_GROUP_NAME ?? 'student');
  if (triggerResult) return triggerResult;
  return handleApi(event);
};
