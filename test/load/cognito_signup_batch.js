import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter } from 'k6/metrics';
import exec from 'k6/execution';

const userCount = Number(__ENV.VUS || 200);
const batchSize = Number(__ENV.BATCH_SIZE || 2);
const intervalSeconds = Number(__ENV.INTERVAL_SECONDS || 150);
const region = __ENV.AWS_REGION || 'us-east-2';
const clientId = __ENV.COGNITO_CLIENT_ID || '7uag8qk06emq2j4ld1o0rsj034';
const runId = __ENV.RUN_ID || '20261027-001';
const endpoint = __ENV.COGNITO_ENDPOINT || `https://cognito-idp.${region}.amazonaws.com/`;
const accountPrefix = `synapse-load-${runId}-`;
const batchCount = Math.ceil(userCount / batchSize);
const maxDurationSeconds = Math.max(60, batchCount * intervalSeconds + 60);

http.setResponseCallback(http.expectedStatuses(200));
const createdAccounts = new Counter('created_cognito_accounts');
const failedSignups = new Counter('failed_cognito_signups');

export const options = {
  scenarios: {
    signup_batches: {
      executor: 'per-vu-iterations',
      vus: userCount,
      iterations: 1,
      maxDuration: `${maxDurationSeconds}s`,
    },
  },
  thresholds: {
    checks: ['rate>0.99'],
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<5000'],
  },
};

export function setup() {
  if (!Number.isSafeInteger(userCount) || userCount < 1) {
    throw new Error('VUS must be a positive safe integer.');
  }
  if (!Number.isInteger(batchSize) || batchSize < 1 || batchSize > userCount) {
    throw new Error('BATCH_SIZE must be between 1 and VUS.');
  }
  if (!Number.isFinite(intervalSeconds) || intervalSeconds < 0) {
    throw new Error('INTERVAL_SECONDS must be a non-negative number of seconds.');
  }
  if (!/^[a-zA-Z0-9-]{1,40}$/.test(runId)) {
    throw new Error('RUN_ID may contain only letters, numbers and hyphens (1–40 chars).');
  }
  if (!/^https:\/\//.test(endpoint) && !/^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?\//.test(endpoint)) {
    throw new Error('COGNITO_ENDPOINT must use HTTPS, except for a local mock.');
  }
  console.log(
    `Cognito signup test: ${userCount} accounts; ${batchSize} per group; `
      + `${intervalSeconds}s between groups; run ID ${runId}.`,
  );
  console.log('Created Cognito accounts remain in the user pool; this test never deletes them.');
}

export default function () {
  const groupNumber = Math.floor((__VU - 1) / batchSize);
  if (groupNumber > 0 && intervalSeconds > 0) sleep(groupNumber * intervalSeconds);

  const sequence = String(__VU).padStart(4, '0');
  const email = `${accountPrefix}${sequence}@example.invalid`;
  const password = `Synapse!Load${runId}${sequence}a7`;
  const response = http.post(
    endpoint,
    JSON.stringify({
      ClientId: clientId,
      Username: email,
      Password: password,
      UserAttributes: [
        { Name: 'email', Value: email },
        { Name: 'name', Value: `Synapse Load Test ${sequence}` },
      ],
    }),
    {
      headers: {
        'Content-Type': 'application/x-amz-json-1.1',
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.SignUp',
      },
      tags: { operation: 'cognito_signup' },
      timeout: '30s',
    },
  );

  let result = {};
  try {
    const parsed = JSON.parse(response.body || 'null');
    result = parsed && typeof parsed === 'object' ? parsed : {};
  } catch (_) {
    // Si Cognito no devuelve JSON, el alta se registra como fallida.
  }

  const created = response.status === 200
    && typeof result.UserSub === 'string'
    && result.UserConfirmed === true;
  if (created) createdAccounts.add(1);
  else failedSignups.add(1);

  const checksPassed = check(response, {
    'Cognito accepts the SignUp request': (res) => res.status === 200,
    'Cognito returns a confirmed user record': () => created,
  });

  if (!created || !checksPassed) {
    const errorType = String(result.__type || result.code || 'unknown_error');
    console.error(`Signup stopped at account ${sequence}: HTTP ${response.status}, ${errorType}.`);
    exec.test.abort('Stopping to avoid creating more accounts after the first unexpected result.');
  }
}

export function handleSummary(data) {
  const metric = (name, key) => data.metrics[name]?.values?.[key] ?? 0;
  const requests = metric('http_reqs', 'count');
  const successes = metric('created_cognito_accounts', 'count');
  const failures = metric('failed_cognito_signups', 'count');
  const passed = metric('checks', 'passes');
  const failed = metric('checks', 'fails');
  const status = successes === userCount && failures === 0 && failed === 0
    ? 'CORRECTO'
    : 'REVISAR';
  return {
    stdout: [
      '',
      '========== INFORME DE REGISTRO COGNITO ==========',
      `Resultado: ${status}`,
      `Run ID para identificar y borrar luego (solo cuando Bryan lo indique): ${runId}`,
      `Prefijo de correo de prueba: ${accountPrefix}`,
      `Usuarios solicitados: ${userCount}`,
      `Grupo: ${batchSize} cuentas cada ${intervalSeconds} segundos`,
      `Solicitudes SignUp enviadas: ${requests}`,
      `Cuentas confirmadas creadas: ${successes}`,
      `Registros fallidos: ${failures}`,
      `Comprobaciones correctas: ${passed}`,
      `Comprobaciones fallidas: ${failed}`,
      `Tiempo promedio: ${metric('http_req_duration', 'avg').toFixed(2)} ms`,
      `Tiempo p95: ${metric('http_req_duration', 'p(95)').toFixed(2)} ms`,
      'Las cuentas creadas permanecen en Cognito; no se borran al terminar.',
      'No se guardan contraseñas ni se envían mensajes de verificación a estas direcciones.',
      '===================================================',
      '',
    ].join('\n'),
  };
}
