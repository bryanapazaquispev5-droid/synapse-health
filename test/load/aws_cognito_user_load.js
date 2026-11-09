import http from 'k6/http';
import {check, sleep} from 'k6';
import {Counter, Trend} from 'k6/metrics';

const baseUrl = (__ENV.BASE_URL || '').replace(/\/+$/, '');
const region = __ENV.AWS_REGION || 'us-east-2';
const clientId = __ENV.COGNITO_CLIENT_ID || '5jl0g7fb5hhec0qgjo03fnsv12';
const accountsFile = __ENV.ACCOUNTS_FILE || '';
const accounts = accountsFile ? JSON.parse(open(accountsFile)) : [];
const userCount = accounts.length;
const workers = Math.min(Number(__ENV.WORKERS || 25), userCount);
const rate = Number(__ENV.SESSIONS_PER_SECOND || 3);
const iterationsPerWorker = Math.ceil(userCount / workers);
const durationSeconds = Math.ceil(userCount / rate) + 120;
const cognitoUrl = `https://cognito-idp.${region}.amazonaws.com/`;

const loginAttempts = new Counter('cognito_login_attempts');
const loginSuccesses = new Counter('cognito_login_successes');
const loginFailures = new Counter('cognito_login_failures');
const apiAttempts = new Counter('api_requests_attempted');
const apiSuccesses = new Counter('api_requests_successful');
const apiThrottles = new Counter('api_responses_429');
const apiUnexpected = new Counter('api_responses_unexpected');
const apiServerErrors = new Counter('api_responses_5xx');
const networkErrors = new Counter('load_network_errors');
const apiLatency = new Trend('load_api_latency_ms', true);
const loginLatency = new Trend('load_cognito_login_latency_ms', true);
const rowsRead = new Counter('load_rows_received');

if (!/^https:\/\/[A-Za-z0-9.-]+(?::[0-9]+)?$/.test(baseUrl)) {
  throw new Error('BASE_URL must be the HTTPS API Gateway base URL.');
}
if (!Array.isArray(accounts) || userCount < 1) {
  throw new Error('No Cognito test accounts were discovered; no requests were sent.');
}
if (!Number.isSafeInteger(workers) || workers < 1 || workers > 25 ||
    !Number.isSafeInteger(rate) || rate < 1 || rate > 3) {
  throw new Error('The safe profile allows up to 25 workers and 1-3 sessions per second.');
}

export const options = {
  scenarios: {
    cognito_api_users: {
      executor: 'per-vu-iterations',
      vus: workers,
      iterations: iterationsPerWorker,
      maxDuration: `${durationSeconds}s`,
      gracefulStop: '15s',
    },
  },
  thresholds: {
    checks: ['rate==1'],
    cognito_login_failures: ['count==0'],
    api_responses_429: ['count==0'],
    api_responses_unexpected: ['count==0'],
    api_responses_5xx: ['count==0'],
    load_network_errors: ['count==0'],
    load_api_latency_ms: ['p(95)<1500'],
    load_cognito_login_latency_ms: ['p(95)<2000'],
    dropped_iterations: ['count==0'],
  },
};

function accountFor(sequence) {
  const account = accounts[sequence];
  return {
    username: account.username,
    password: `Synapse!Load${account.runId}${account.sequence}a7`,
  };
}

function signIn(account, reportPreflightError = false) {
  const response = http.post(cognitoUrl, JSON.stringify({
    AuthFlow: 'USER_PASSWORD_AUTH',
    ClientId: clientId,
    AuthParameters: {USERNAME: account.username, PASSWORD: account.password},
  }), {
    headers: {
      'Content-Type': 'application/x-amz-json-1.1',
      'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth',
    },
    tags: {service: 'cognito', operation: 'user_password_auth'},
    timeout: '15s',
  });
  const body = parseJson(response);
  const token = body?.AuthenticationResult?.AccessToken;
  loginLatency.add(response.timings.duration);
  loginAttempts.add(1);
  if (response.status === 200 && typeof token === 'string') {
    loginSuccesses.add(1);
    return token;
  }
  loginFailures.add(1);
  if (response.status === 0) networkErrors.add(1);
  if (reportPreflightError) {
    const rawCode = body?.__type || body?.code || body?.Code || 'UnknownCognitoError';
    const errorCode = String(rawCode).split('#').pop().split(':').pop()
      .replace(/[^A-Za-z0-9_.-]/g, '').slice(0, 80);
    console.error(`Cognito preflight rejected sign-in (HTTP ${response.status}; ${errorCode}). No API load was started.`);
  }
  check(response, {'Cognito login succeeds': () => false});
  return null;
}

function parseJson(response) {
  try { return JSON.parse(response.body || 'null'); } catch { return null; }
}

function listItems(response) {
  const items = parseJson(response)?.data?.items;
  return Array.isArray(items) ? items : [];
}

function getPage(path, token, label) {
  apiAttempts.add(1);
  const query = path === '/api/v1/auth/session' ? '' : '?limit=20';
  const response = http.get(`${baseUrl}${path}${query}`, {
    headers: {Authorization: `Bearer ${token}`, Accept: 'application/json'},
    tags: {service: 'api', endpoint: label},
    timeout: '15s',
  });
  const body = parseJson(response);
  if (response.status === 429) apiThrottles.add(1);
  else if (response.status >= 500) apiServerErrors.add(1);
  else if (response.status !== 200 || !body || typeof body !== 'object') apiUnexpected.add(1);
  else {
    apiSuccesses.add(1);
    apiLatency.add(response.timings.duration);
    rowsRead.add(listItems(response).length);
  }
  if (response.status === 0) networkErrors.add(1);
  check(response, {[`${label} returns valid HTTP 200 JSON`]: value =>
    value.status === 200 && parseJson(value) !== null});
}

export function setup() {
  const credentials = accountFor(0);
  const token = signIn(credentials, true);
  if (!token) throw new Error('The first saved Cognito test account could not sign in; load stopped.');
  const areaResponse = http.get(`${baseUrl}/api/v1/areas?limit=100`, {
    headers: {Authorization: `Bearer ${token}`, Accept: 'application/json'}, timeout: '15s',
  });
  const areas = listItems(areaResponse);
  if (areaResponse.status !== 200 || areas.length === 0) {
    throw new Error('Preflight could not read the area catalog; load stopped.');
  }
  let selected = null;
  for (const area of areas) {
    const areaId = encodeURIComponent(String(area.id || ''));
    if (!areaId) continue;
    const topicResponse = http.get(`${baseUrl}/api/v1/areas/${areaId}/topics?limit=100`, {
      headers: {Authorization: `Bearer ${token}`, Accept: 'application/json'}, timeout: '15s',
    });
    const topics = listItems(topicResponse);
    if (topicResponse.status === 200 && topics.length > 0) {
      selected = {areaId, topicId: encodeURIComponent(String(topics[0].id || '')),
        areaName: String(area.name || 'First available area'),
        topicName: String(topics[0].title || 'First available topic')};
      break;
    }
  }
  if (!selected?.areaId || !selected?.topicId) {
    throw new Error('Preflight found no area with topics; load stopped.');
  }
  console.log(`Preflight passed. First available area/topic selected automatically: ${selected.areaName} / ${selected.topicName}.`);
  return {startedAt: Date.now(), areaId: selected.areaId, topicId: selected.topicId};
}

export default function (state) {
  const sequence = (__ITER * workers) + (__VU - 1);
  if (sequence >= userCount) return;
  const scheduledAt = state.startedAt + (sequence / rate) * 1000;
  const waitSeconds = (scheduledAt - Date.now()) / 1000;
  if (waitSeconds > 0) sleep(waitSeconds);

  const token = signIn(accountFor(sequence));
  if (!token) return;
  const area = `/api/v1/areas/${state.areaId}`;
  const topic = `${area}/topics/${state.topicId}`;
  const routes = [
    {label: 'areas', path: '/api/v1/areas'},
    {label: 'topics', path: `${area}/topics`},
    {label: 'area_quizzes', path: `${area}/quizzes`},
    {label: 'topic_quizzes', path: `${topic}/quizzes`},
    {label: 'study_notes', path: `${topic}/study-notes`},
    {label: 'my_progress', path: '/api/v1/progress/me'},
    {label: 'my_history', path: '/api/v1/history'},
    {label: 'leaderboard', path: '/api/v1/leaderboard'},
    {label: 'auth_session', path: '/api/v1/auth/session'},
  ];
  const target = routes[sequence % routes.length];
  getPage(target.path, token, target.label);
}

function metric(data, name, key) {
  return data.metrics[name]?.values?.[key] || 0;
}

export function handleSummary(data) {
  const failures = metric(data, 'cognito_login_failures', 'count') +
    metric(data, 'api_responses_429', 'count') + metric(data, 'api_responses_unexpected', 'count') +
    metric(data, 'api_responses_5xx', 'count') + metric(data, 'load_network_errors', 'count') +
    metric(data, 'dropped_iterations', 'count');
  const completed = metric(data, 'api_requests_successful', 'count');
  const thresholds = Object.entries(data.metrics).flatMap(([name, item]) =>
    Object.entries(item.thresholds || {}).map(([rule, result]) =>
      `  ${result.ok ? 'APROBADO' : 'FALLIDO'}: ${name} (${rule})`));
  const duration = (data.state?.testRunDurationMs || 0) / 1000;
  const report = [
    '', '===== INFORME · CARGA DE CUENTAS COGNITO Y API AWS =====',
    `Resultado: ${failures === 0 && completed === userCount ? 'SATISFACTORIO' : 'REVISAR'}`,
    `Cuentas únicas programadas: ${userCount}; workers k6 simultáneos: ${workers}.`,
    `Sesiones escalonadas: máximo ${rate} cuentas por segundo; duración estimada ${Math.ceil(userCount / rate / 60)} minutos.`,
    'Cada cuenta inicia sesión una vez y llama una ruta de solo lectura, distribuida entre las nueve categorías.',
    `Inicios Cognito: ${metric(data, 'cognito_login_attempts', 'count')}; correctos: ${metric(data, 'cognito_login_successes', 'count')}; fallidos: ${metric(data, 'cognito_login_failures', 'count')}.`,
    `Solicitudes API: ${metric(data, 'api_requests_attempted', 'count')}; HTTP 200: ${completed}; HTTP 429: ${metric(data, 'api_responses_429', 'count')}; HTTP 5xx: ${metric(data, 'api_responses_5xx', 'count')}.`,
    `Respuestas inesperadas: ${metric(data, 'api_responses_unexpected', 'count')}; errores de red: ${metric(data, 'load_network_errors', 'count')}; iteraciones descartadas: ${metric(data, 'dropped_iterations', 'count')}.`,
    `Filas recibidas: ${metric(data, 'load_rows_received', 'count')}; latencia API avg/p95/max: ${metric(data, 'load_api_latency_ms', 'avg').toFixed(1)} / ${metric(data, 'load_api_latency_ms', 'p(95)').toFixed(1)} / ${metric(data, 'load_api_latency_ms', 'max').toFixed(1)} ms.`,
    `Latencia de login p95: ${metric(data, 'load_cognito_login_latency_ms', 'p(95)').toFixed(1)} ms; duración real: ${duration.toFixed(1)} s.`,
    'Solo lecturas de API; no crea ni borra cuentas o datos. El backend sí actualiza su contador temporal de rate limit.',
    'No son 5,000 solicitudes simultáneas: se limita el envío para respetar API Gateway (5 solicitudes/s, ráfaga 10).',
    'Umbrales:', ...thresholds, '==========================================================', '',
  ];
  return {stdout: report.join('\n')};
}
