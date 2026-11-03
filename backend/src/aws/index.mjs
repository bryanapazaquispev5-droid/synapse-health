import {withCors} from '../cors.mjs';
import {createAwsHandler} from './handler.mjs';
import {createAwsRuntime} from './runtime.mjs';
// Clients are reused between invocations; credentials come from the Lambda execution role.
const handleApi = withCors(createAwsHandler(createAwsRuntime()), process.env.ALLOWED_ORIGIN ?? 'https://synapse.invalid');
export const handler = async event => {
  if (event.triggerSource === 'PreSignUp_SignUp') {
    event.response = {...event.response, autoConfirmUser: true, autoVerifyEmail: false};
    return event;
  }
  return handleApi(event);
};
