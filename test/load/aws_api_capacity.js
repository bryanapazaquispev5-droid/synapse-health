import http from 'k6/http';
import {check} from 'k6';
import {Counter, Rate} from 'k6/metrics';

const users = Number(__ENV.VUS ?? 1000);
const baseUrl = (__ENV.BASE_URL ?? '').replace(/\/$/, '');
const token = __ENV.ACCESS_TOKEN ?? '';
const serverErrors = new Rate('server_error_rate');
const networkErrors = new Rate('network_error_rate');
const completed = new Counter('capacity_requests_completed');
const accepted = new Counter('capacity_requests_accepted');
const throttled = new Counter('capacity_requests_throttled');
const unexpected = new Counter('capacity_responses_unexpected');

if (!Number.isSafeInteger(users) || users < 1000 || users > 5000) {
  throw new Error('VUS must be an integer between 1000 and 5000.');
}

export const options = {
  discardResponseBodies: true,
  scenarios: {
    authenticated_api_capacity: {
      executor: 'per-vu-iterations',
      vus: users,
      iterations: 1,
      maxDuration: '5m',
      gracefulStop: '30s',
    },
  },
  thresholds: {
    capacity_requests_completed: [`count==${users}`],
    capacity_responses_unexpected: ['count==0'],
    checks: ['rate>0.99'],
    server_error_rate: ['rate<0.01'],
    network_error_rate: ['rate<0.01'],
  },
};

export function setup() {
  if (!/^https:\/\//.test(baseUrl) || !token) {
    throw new Error('Set BASE_URL and ACCESS_TOKEN for the deployed AWS API.');
  }
  const preflight = http.get(`${baseUrl}/api/v1/auth/session`, {
    headers: {Authorization: `Bearer ${token}`},
    tags: {endpoint: 'auth-session', phase: 'preflight'},
    timeout: '20s',
  });
  if (preflight.status !== 200) {
    throw new Error(`Preflight failed with HTTP ${preflight.status}; no load was started.`);
  }
  return {baseUrl, token};
}

export default function ({baseUrl: target, token: accessToken}) {
  const response = http.get(`${target}/api/v1/auth/session`, {
    headers: {Authorization: `Bearer ${accessToken}`},
    tags: {endpoint: 'auth-session'},
    timeout: '20s',
  });
  completed.add(1);
  accepted.add(response.status >= 200 && response.status < 300 ? 1 : 0);
  throttled.add(response.status === 429 ? 1 : 0);
  unexpected.add(response.status === 200 || response.status === 429 ? 0 : 1);
  check(response, {
    'API returns success or an intentional throttle response':
      result => result.status === 200 || result.status === 429,
  });
  serverErrors.add(response.status >= 500 ? 1 : 0);
  networkErrors.add(response.status === 0 ? 1 : 0);
}

export function handleSummary(data) {
  const values = name => data.metrics[name]?.values ?? {};
  const count = name => values(name).count ?? 0;
  const duration = values('http_req_duration');
  const unexpectedCount = count('capacity_responses_unexpected');
  const lines = [
    '',
    'AWS API CAPACITY TEST SUMMARY',
    `Virtual users configured: ${users}`,
    'Requests per virtual user: 1 (same existing Cognito identity)',
    `Requests completed: ${count('capacity_requests_completed')}`,
    `HTTP 2xx accepted: ${count('capacity_requests_accepted')}`,
    `HTTP 429 rate limited (expected at current API limits): ${count('capacity_requests_throttled')}`,
    `Unexpected responses: ${unexpectedCount}`,
    `HTTP 5xx rate: ${((values('server_error_rate').rate ?? 0) * 100).toFixed(2)}%`,
    `Network error rate: ${((values('network_error_rate').rate ?? 0) * 100).toFixed(2)}%`,
    `Latency avg / p95 / max: ${(duration.avg ?? 0).toFixed(1)} / ${(duration['p(95)'] ?? 0).toFixed(1)} / ${(duration.max ?? 0).toFixed(1)} ms`,
    unexpectedCount === 0
      ? 'Interpretation: API responses were successful or intentionally throttled; review 429 count against the configured quota.'
      : 'Interpretation: investigate unexpected status codes, server errors, or network failures.',
    'No report file is created; this summary is printed in the terminal.',
    '',
  ];
  return {stdout: lines.join('\n')};
}
