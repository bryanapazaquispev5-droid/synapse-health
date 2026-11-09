import http from 'k6/http';
import {check, sleep} from 'k6';
import {Counter, Trend} from 'k6/metrics';

const baseUrl = (__ENV.BASE_URL || '').replace(/\/+$/, '');
const token = __ENV.ACCESS_TOKEN || '';
const pageLimit = Number(__ENV.PAGE_LIMIT || 1);
const maxPages = Number(__ENV.MAX_PAGES || 2);
const pacing = Number(__ENV.PAGE_PACING_SECONDS || 3);
const thinkTime = Number(__ENV.THINK_TIME_SECONDS || 1);
const vus = Number(__ENV.LOAD_VUS || 3);
let targets = [];
try { targets = JSON.parse(__ENV.TARGETS_JSON || '[]'); } catch { targets = []; }

const requests = new Counter('pagination_page_requests');
const successful = new Counter('pagination_successful_pages');
const throttled = new Counter('pagination_rate_limited_429');
const unexpected = new Counter('pagination_unexpected_responses');
const serverErrors = new Counter('pagination_server_errors');
const networkErrors = new Counter('pagination_network_errors');
const rows = new Counter('pagination_rows_received');
const cursors = new Counter('pagination_cursors_available');
const cursorPages = new Counter('pagination_cursor_page_requests');
const singlePageResponses = new Counter('pagination_single_page_responses');
const latency = new Trend('pagination_success_latency_ms', true);
const throttledLatency = new Trend('pagination_throttled_latency_ms', true);

if (!Number.isInteger(pageLimit) || pageLimit < 1 || pageLimit > 100) {
  throw new Error('PAGE_LIMIT must be an integer from 1 to 100.');
}
if (!Number.isInteger(maxPages) || maxPages < 1 || maxPages > 10) {
  throw new Error('MAX_PAGES must be an integer from 1 to 10.');
}
if (!Number.isInteger(pacing) || pacing < 1 || pacing > 30 ||
    !Number.isInteger(thinkTime) || thinkTime < 0 || thinkTime > 30) {
  throw new Error('Pacing values are outside the supported range.');
}
if (!Number.isInteger(vus) || vus < 1 || vus > 3) {
  throw new Error('Automatic load must use 1-3 VUs.');
}

export const options = {
  scenarios: {pagination_load: {executor: 'per-vu-iterations', vus, iterations: 1, maxDuration: '120s', gracefulStop: '10s'}},
  thresholds: {
    checks: ['rate==1'],
    pagination_success_latency_ms: ['p(95)<1500'],
    pagination_rate_limited_429: ['count==0'],
    pagination_server_errors: ['count==0'],
    pagination_unexpected_responses: ['count==0'],
    pagination_network_errors: ['count==0'],
    dropped_iterations: ['count==0'],
  },
};

function parsePage(response) {
  try {
    const data = JSON.parse(response.body)?.data;
    if (!data || !Array.isArray(data.items)) return null;
    return {items: data.items, nextCursor: typeof data.nextCursor === 'string' && data.nextCursor ? data.nextCursor : null};
  } catch { return null; }
}

function requestPage(target, cursor, pageNumber) {
  const query = 'limit=' + pageLimit + (cursor ? '&cursor=' + encodeURIComponent(cursor) : '');
  const response = http.get(baseUrl + target.path + '?' + query, {
    headers: {Authorization: 'Bearer ' + token, Accept: 'application/json'},
    tags: {endpoint: target.path, collection: target.label, page: pageNumber ? 'cursor' : 'first'},
    timeout: '15s',
  });
  requests.add(1);
  if (response.status === 429) {
    throttled.add(1);
    throttledLatency.add(response.timings.duration);
    check(response, {[target.label + ': no rate limiting']: value => value.status !== 429});
    sleep(pacing);
    return null;
  }
  if (response.status !== 200) {
    unexpected.add(1);
    if (response.status >= 500) serverErrors.add(1);
    if (response.status === 0) networkErrors.add(1);
    check(response, {[target.label + ': HTTP 200']: value => value.status === 200});
    sleep(pacing);
    return null;
  }
  const page = parsePage(response);
  if (!page) {
    unexpected.add(1);
    check(response, {[target.label + ': valid page body']: () => false});
    sleep(pacing);
    return null;
  }
  successful.add(1);
  latency.add(response.timings.duration);
  rows.add(page.items.length);
  if (page.nextCursor) cursors.add(1);
  else singlePageResponses.add(1);
  check(response, {[target.label + ': valid page body']: () => true});
  sleep(pacing);
  return page;
}

export function setup() {
  const https = /^https:\/\/[A-Za-z0-9.-]+(?::[0-9]+)?\/?$/.test(baseUrl);
  const local = __ENV.ALLOW_LOCAL_TEST === 'true' && /^http:\/\/(localhost|127\.0\.0\.1)(?::[0-9]+)?\/?$/.test(baseUrl);
  if ((!https && !local) || !token || !Array.isArray(targets) || targets.length !== 8 ||
      targets.some(item => !item || typeof item.label !== 'string' ||
        !/^\/api\/v1\/[A-Za-z0-9_-]+(?:\/[A-Za-z0-9_-]+)*$/.test(item.path))) {
    throw new Error('The automatic test needs the API, a Cognito access token, and eight valid collection routes.');
  }
  const response = http.get(baseUrl + targets[0].path + '?limit=' + pageLimit, {
    headers: {Authorization: 'Bearer ' + token, Accept: 'application/json'},
    tags: {endpoint: targets[0].path, phase: 'preflight'}, timeout: '15s',
  });
  if (response.status !== 200 || !parsePage(response)) throw new Error('Authentication or first-route preflight failed; load did not start.');
  console.log('Preflight passed: Cognito token accepted; the automatic suite will call all eight routes.');
  return {ready: true};
}

export default function (state) {
  if (!state.ready) return;
  for (const target of targets) {
    let cursor = null;
    for (let page = 0; page < maxPages; page++) {
      const result = requestPage(target, cursor, page);
      if (!result) break;
      if (!result.nextCursor || page + 1 >= maxPages) break;
      cursor = result.nextCursor;
      cursorPages.add(1);
    }
  }
  if (thinkTime) sleep(thinkTime);
}

function value(data, name, key) {
  return data.metrics[name]?.values?.[key] || 0;
}

export function handleSummary(data) {
  const failed = value(data, 'pagination_unexpected_responses', 'count') > 0 ||
    value(data, 'pagination_network_errors', 'count') > 0 ||
    value(data, 'pagination_rate_limited_429', 'count') > 0 ||
    value(data, 'pagination_server_errors', 'count') > 0 ||
    value(data, 'dropped_iterations', 'count') > 0 || value(data, 'checks', 'rate') !== 1;
  const duration = (data.state?.testRunDurationMs || 0) / 1000;
  const thresholds = Object.entries(data.metrics).flatMap(([name, metric]) =>
    Object.entries(metric.thresholds || {}).map(([rule, result]) =>
      '  ' + (result.ok ? 'APROBADO' : 'FALLIDO') + ': ' + name + ' (' + rule + ')'));
  const paths = targets.map(target => target.label + ' [' + target.path + ']').join('; ');
  const report = [
    '', '===== INFORME FINAL · PRUEBA AUTOMÁTICA DE PAGINACIÓN AWS =====',
    'Resultado: ' + (value(data, 'pagination_page_requests', 'count') === 0 ? 'NO EJECUTADA' : failed ? 'REVISAR' : 'SATISFACTORIA'),
    'Inicio Cognito y preflight: correcto (token aceptado por la API).',
    'Colecciones/rutas: ' + paths,
    'Carga: ' + vus + ' usuarios virtuales; cada uno completa un ciclo de las ocho categorías; pausa de ' + pacing + ' s por solicitud.',
    'Paginación: ' + pageLimit + ' fila por página; máximo ' + maxPages + ' páginas consecutivas por colección e iteración.',
    'Tiempo real: ' + duration.toFixed(1) + ' s; solicitudes: ' + value(data, 'pagination_page_requests', 'count') +
      ' (' + (duration ? (value(data, 'pagination_page_requests', 'count') / duration).toFixed(2) : '0.00') + ' solicitudes/s).',
    'Páginas HTTP 200: ' + value(data, 'pagination_successful_pages', 'count') + '; filas leídas: ' + value(data, 'pagination_rows_received', 'count'),
    'Páginas de cursor solicitadas: ' + value(data, 'pagination_cursor_page_requests', 'count') +
      '; respuestas sin página siguiente: ' + value(data, 'pagination_single_page_responses', 'count'),
    'HTTP 429: ' + value(data, 'pagination_rate_limited_429', 'count') + '; errores 5xx: ' +
      value(data, 'pagination_server_errors', 'count') + '; otros errores: ' + value(data, 'pagination_unexpected_responses', 'count'),
    'Errores de red: ' + value(data, 'pagination_network_errors', 'count') + '; iteraciones descartadas: ' + value(data, 'dropped_iterations', 'count'),
    'Latencia exitosa avg / p95 / máx: ' + value(data, 'pagination_success_latency_ms', 'avg').toFixed(1) + ' / ' +
      value(data, 'pagination_success_latency_ms', 'p(95)').toFixed(1) + ' / ' +
      value(data, 'pagination_success_latency_ms', 'max').toFixed(1) + ' ms.',
    'Checks correctos: ' + (value(data, 'checks', 'rate') * 100).toFixed(1) + '%; umbrales:',
    ...thresholds,
    'Solo GET autenticados; no crea usuarios, cursos, perfiles ni progreso. DynamoDB actualiza el contador temporal de límites del backend.',
    'Informe mostrado aquí; no se guarda en archivo.', '===============================================================', '',
  ];
  return {stdout: report.join('\n')};
}
