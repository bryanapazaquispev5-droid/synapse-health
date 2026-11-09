import http from 'k6/http';
import {check} from 'k6';
import {Counter, Trend} from 'k6/metrics';
import exec from 'k6/execution';

const baseUrl = (__ENV.BASE_URL || 'https://tcpq1i1oxl.execute-api.us-east-2.amazonaws.com').replace(/\/+$/, '');
const safeRatePerSecond = 4;
const stages = [
  {target: 2, duration: '10s'},
  {target: 3, duration: '10s'},
  {target: 4, duration: '15s'},
  {target: 4, duration: '20s'},
  {target: 0, duration: '5s'},
];

const requests = new Counter('readiness_requests');
const healthy = new Counter('readiness_healthy_responses');
const rateLimited = new Counter('readiness_http_429');
const serverErrors = new Counter('readiness_http_5xx');
const unexpected = new Counter('readiness_unexpected_responses');
const latency = new Trend('readiness_latency_ms', true);

export const options = {
  discardResponseBodies: false,
  scenarios: {
    readiness_ramp: {
      executor: 'ramping-arrival-rate',
      startRate: 1,
      timeUnit: '1s',
      stages,
      preAllocatedVUs: 5,
      maxVUs: 10,
      gracefulStop: '5s',
    },
  },
  thresholds: {
    checks: ['rate==1'],
    readiness_http_429: ['count==0'],
    readiness_http_5xx: ['count==0'],
    readiness_unexpected_responses: ['count==0'],
    readiness_latency_ms: ['p(95)<1500'],
  },
};

function isHealthy(response) {
  if (response.status !== 200) return false;
  try {
    const body = JSON.parse(response.body);
    return body?.data?.status === 'ok' && body?.data?.provider === 'aws';
  } catch {
    return false;
  }
}

function getHealth(path, phase) {
  return http.get(baseUrl + path, {
    headers: {Accept: 'application/json'},
    tags: {endpoint: path, phase},
    timeout: '10s',
  });
}

export function setup() {
  if (!/^https:\/\/[A-Za-z0-9.-]+(?::[0-9]+)?$/.test(baseUrl)) {
    throw new Error('The configured API base URL must use HTTPS.');
  }
  for (const path of ['/health', '/api/v1/health']) {
    const response = getHealth(path, 'preflight');
    if (!isHealthy(response)) {
      throw new Error(`Preflight failed for ${path} (HTTP ${response.status}); no load was started.`);
    }
  }
  console.log('Preflight passed: both public AWS health endpoints returned status ok.');
  console.log(`Automatic safe ceiling: ${safeRatePerSecond} requests/second; API Gateway is configured for 5 requests/second.`);
  console.log('Read-only test: no login, accounts, profiles, progress, or catalog writes.');
  return {baseUrl};
}

export default function ({baseUrl: target}) {
  const path = __ITER % 2 === 0 ? '/health' : '/api/v1/health';
  const response = getHealth(path, 'load');
  requests.add(1);
  latency.add(response.timings.duration);

  if (response.status === 429) {
    rateLimited.add(1);
    exec.test.abort('API Gateway rate limit reached; stopping the load test immediately.');
  }
  if (response.status >= 500) {
    serverErrors.add(1);
    exec.test.abort('Server error detected; stopping the load test immediately.');
  }
  if (!isHealthy(response)) {
    unexpected.add(1);
    check(response, {'health endpoint returns HTTP 200 and status ok': () => false});
    exec.test.abort('Unexpected health response; stopping the load test immediately.');
  }

  healthy.add(1);
  check(response, {'health endpoint returns HTTP 200 and status ok': value => isHealthy(value)});
}

export function handleSummary(data) {
  const value = (name, key) => data.metrics[name]?.values?.[key] ?? 0;
  const thresholds = Object.entries(data.metrics)
    .flatMap(([metricName, metric]) => Object.entries(metric.thresholds ?? {}).map(([expression, result]) => ({
      metricName,
      expression,
      passed: result.ok,
    })));
  const count = value('readiness_requests', 'count');
  const failures = value('readiness_unexpected_responses', 'count');
  const throttles = value('readiness_http_429', 'count');
  const serverFailureCount = value('readiness_http_5xx', 'count');
  const dropped = value('dropped_iterations', 'count');
  const checkRate = value('checks', 'rate');
  const thresholdsPassed = thresholds.length > 0 && thresholds.every(threshold => threshold.passed);
  const passed = count > 0 && failures === 0 && throttles === 0 && serverFailureCount === 0
    && dropped === 0 && checkRate === 1 && thresholdsPassed;
  return {
    stdout: [
      '',
      '===== SYNAPSE HEALTH · PRUEBA PREVIA AWS =====',
      'Resultado: ' + (passed ? 'CORRECTO' : 'REVISAR'),
      'Límite de esta prueba: hasta 4 solicitudes por segundo (API Gateway: 5/s, ráfaga 10).',
      'Solicitudes completadas: ' + count,
      'Respuestas saludables: ' + value('readiness_healthy_responses', 'count'),
      'HTTP 429: ' + throttles,
      'Errores HTTP 5xx: ' + serverFailureCount,
      'Respuestas inesperadas: ' + failures,
      'Checks correctos: ' + (checkRate * 100).toFixed(1) + '%',
      'Iteraciones descartadas: ' + dropped,
      'Latencia promedio / p95 / máximo: ' + value('readiness_latency_ms', 'avg').toFixed(1) + ' / '
        + value('readiness_latency_ms', 'p(95)').toFixed(1) + ' / '
        + value('readiness_latency_ms', 'max').toFixed(1) + ' ms',
      'Umbrales de k6:',
      ...thresholds.map(threshold => `  ${threshold.passed ? 'APROBADO' : 'FALLIDO'}: ${threshold.metricName} (${threshold.expression})`),
      'Alcance: salud pública de API Gateway y Lambda; no valida login, DynamoDB ni rutas autenticadas.',
      'No se guardan datos ni se genera un archivo de informe.',
      '==============================================',
      '',
    ].join('\n'),
  };
}
