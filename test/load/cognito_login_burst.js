import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter } from 'k6/metrics';

const virtualUsers = Number(__ENV.VUS || 100);
const batchSize = Number(__ENV.BATCH_SIZE || virtualUsers);
const intervalSeconds = Number(__ENV.INTERVAL_SECONDS || 0);
const region = __ENV.AWS_REGION || 'us-east-2';
const clientId = __ENV.COGNITO_CLIENT_ID || '5jl0g7fb5hhec0qgjo03fnsv12';
const endpoint = __ENV.COGNITO_ENDPOINT || `https://cognito-idp.${region}.amazonaws.com/`;
const isLocalMock = /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?\//.test(endpoint);
const safeVirtualUsers = Number.isSafeInteger(virtualUsers) && virtualUsers > 0
  ? virtualUsers
  : 1;
const safeBatchSize = Number.isInteger(batchSize) && batchSize > 0 ? batchSize : 1;
const safeInterval = Number.isFinite(intervalSeconds) && intervalSeconds >= 0 ? intervalSeconds : 0;
const batchCount = Math.ceil(safeVirtualUsers / safeBatchSize);
const maxDurationSeconds = Math.max(60, batchCount * safeInterval + 30);

// Cognito devuelve HTTP 400 cuando rechaza un login; en esta prueba ese es el resultado esperado.
const expectedResponse = http.expectedStatuses(400);
http.setResponseCallback(expectedResponse);
const expectedLoginRejections = new Counter('expected_login_rejections');
const unexpectedLoginResponses = new Counter('unexpected_login_responses');
const returnedLoginTokens = new Counter('returned_login_tokens');
const throttledLoginResponses = new Counter('throttled_login_responses');
const loginRequestFailures = new Counter('login_request_failures');

export const options = {
  scenarios: {
    login_burst: {
      executor: 'per-vu-iterations',
      vus: safeVirtualUsers,
      iterations: 1,
      maxDuration: `${maxDurationSeconds}s`,
    },
  },
  thresholds: {
    checks: ['rate>0.95'],
    http_req_failed: ['rate<0.05'],
    http_req_duration: ['p(95)<5000'],
  },
};

export function setup() {
  if (!isLocalMock && __ENV.RUN_LIVE_TEST !== 'YES') {
    throw new Error('Set RUN_LIVE_TEST=YES to confirm requests to AWS.');
  }
  if (!Number.isSafeInteger(virtualUsers) || virtualUsers < 1) {
    throw new Error('VUS must be a positive safe integer.');
  }
  if (!Number.isInteger(batchSize) || batchSize < 1 || batchSize > virtualUsers) {
    throw new Error('BATCH_SIZE must be between 1 and VUS.');
  }
  if (!Number.isFinite(intervalSeconds) || intervalSeconds < 0) {
    throw new Error('INTERVAL_SECONDS must be a non-negative number of seconds.');
  }
  console.log(
    `Login test: ${virtualUsers} users; ${batchSize} per batch; ${intervalSeconds}s between batches.`,
  );
}

export default function () {
  // Cada VU usa un correo ficticio único y una clave falsa; no se crean ni modifican cuentas.
  const batchNumber = Math.floor((__VU - 1) / batchSize);
  if (batchNumber > 0 && intervalSeconds > 0) sleep(batchNumber * intervalSeconds);
  const username = `load-test-${String(__VU).padStart(3, '0')}@example.invalid`;
  const response = http.post(
    endpoint,
    JSON.stringify({
      AuthFlow: 'USER_PASSWORD_AUTH',
      ClientId: clientId,
      AuthParameters: { USERNAME: username, PASSWORD: 'FakeLoadTestPassword2026!' },
    }),
    {
      headers: {
        'Content-Type': 'application/x-amz-json-1.1',
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth',
      },
      tags: { operation: 'cognito_login' },
      timeout: '30s',
    },
  );

  let result = {};
  try {
    const parsed = JSON.parse(response.body || 'null');
    result = parsed && typeof parsed === 'object' ? parsed : {};
  } catch (_) {
    // La respuesta no era JSON; los checks de abajo la marcarán como fallida.
  }

  const errorType = String(result.__type || result.code || '');
  const rejectedAsExpected = response.status === 400
    && errorType.includes('NotAuthorizedException');
  const throttled = response.status === 429
    || /TooManyRequests|Throttl|LimitExceeded/i.test(errorType);
  const requestFailed = response.status === 0 || Boolean(response.error);
  const receivedTokens = Boolean(
    result.AuthenticationResult?.AccessToken && result.AuthenticationResult?.IdToken,
  );
  if (rejectedAsExpected) expectedLoginRejections.add(1);
  else unexpectedLoginResponses.add(1);
  if (throttled) throttledLoginResponses.add(1);
  if (requestFailed) loginRequestFailures.add(1);
  if (receivedTokens) returnedLoginTokens.add(1);

  check(response, {
    'Cognito rejects the fake login with HTTP 400': (res) => res.status === 400,
    'Cognito returns the generic invalid-login response': () =>
      rejectedAsExpected,
  });
}

export function handleSummary(data) {
  const value = (name, key) => data.metrics[name]?.values?.[key] ?? 0;
  const total = value('http_reqs', 'count');
  const expectedRejected = value('expected_login_rejections', 'count');
  const unexpected = value('unexpected_login_responses', 'count');
  const throttled = value('throttled_login_responses', 'count');
  const requestFailures = value('login_request_failures', 'count');
  const successfulTokens = value('returned_login_tokens', 'count');
  const passedChecks = value('checks', 'passes');
  const failedChecks = value('checks', 'fails');
  if (total === 0) {
    return {
      stdout: [
        '',
        '========== INFORME DE PRUEBA DE LOGIN ==========',
        'Resultado: NO EJECUTADA',
        `Usuarios virtuales configurados: ${virtualUsers}`,
        `Intentos por grupo: ${batchSize}; intervalo: ${intervalSeconds} segundos`,
        'Intentos enviados: 0',
        'No se enviaron solicitudes. Revisa el error de configuración mostrado arriba.',
        '=================================================',
        '',
      ].join('\n'),
    };
  }
  const status = total === virtualUsers && unexpected === 0 && failedChecks === 0
    ? 'CORRECTO'
    : 'REVISAR';
  const report = [
    '',
    '========== INFORME DE PRUEBA DE LOGIN ==========',
    `Resultado: ${status}`,
    `Usuarios virtuales configurados: ${virtualUsers}`,
    `Intentos iniciados por grupo: ${batchSize}`,
    `Intervalo entre grupos: ${intervalSeconds} segundos`,
    `Intentos enviados: ${total}`,
    `Logins aceptados: ${successfulTokens} (se esperaban 0; las credenciales son ficticias)`,
    `Rechazos esperados de Cognito: ${expectedRejected}`,
    `Respuestas inesperadas: ${unexpected}`,
    `Respuestas por limite de solicitudes: ${throttled}`,
    `Solicitudes sin respuesta o con error de red: ${requestFailures}`,
    `Comprobaciones correctas: ${passedChecks}`,
    `Comprobaciones fallidas: ${failedChecks}`,
    `Solicitudes HTTP con error inesperado: ${Math.round(value('http_req_failed', 'rate') * total)}`,
    `Tiempo promedio: ${value('http_req_duration', 'avg').toFixed(2)} ms`,
    `Tiempo p90: ${value('http_req_duration', 'p(90)').toFixed(2)} ms`,
    `Tiempo p95: ${value('http_req_duration', 'p(95)').toFixed(2)} ms`,
    `Tiempo máximo: ${value('http_req_duration', 'max').toFixed(2)} ms`,
    'Nota: esta prueba verifica que Cognito rechace logins ficticios; no mide logins exitosos.',
    '=================================================',
    '',
  ].join('\n');

  return { stdout: report };
}
