import http from 'k6/http';
import {check} from 'k6';
import {Counter, Rate, Trend} from 'k6/metrics';

// Configurable via environment variables:
// k6 run -e BASE_URL=https://... -e ACCOUNTS=10000 -e RATE=350 test/load/dynamo_burst_signup.js
const targetUrl = (__ENV.BASE_URL || 'https://tcpq1i1oxl.execute-api.us-east-2.amazonaws.com').replace(/\/$/, '');
const totalAccounts = Number(__ENV.ACCOUNTS || 10000);
const targetRps = Number(__ENV.RATE || 350);
const durationSec = Math.ceil(totalAccounts / targetRps) + 10;
const runId = __ENV.RUN_ID || `burst-${Date.now().toString(36)}`;

const successfulRegistrations = new Counter('dynamo_registered_accounts');
const failedRegistrations = new Counter('dynamo_failed_registrations');
const registrationLatency = new Trend('dynamo_registration_latency', true);
const errorRate = new Rate('dynamo_error_rate');

export const options = {
  scenarios: {
    dynamo_burst_creation: {
      executor: 'constant-arrival-rate',
      rate: targetRps,
      timeUnit: '1s',
      duration: `${durationSec}s`,
      preAllocatedVUs: Math.min(targetRps * 2, 2000),
      maxVUs: Math.min(targetRps * 5, 4000),
    },
  },
  thresholds: {
    http_req_failed: ['rate<0.02'],
    checks: ['rate>0.98'],
    http_req_duration: ['p(95)<2000'],
  },
};

export function setup() {
  console.log(`[DynamoDB Load Test] Target API: ${targetUrl}`);
  console.log(`[DynamoDB Load Test] Planning ${totalAccounts} accounts at ${targetRps} req/s (Est. Duration: ${durationSec}s). Run ID: ${runId}`);
  const probe = http.get(`${targetUrl}/health`, {timeout: '10s'});
  if (probe.status !== 200) {
    throw new Error(`API health check failed with status ${probe.status}: ${probe.body}`);
  }
  console.log('[DynamoDB Load Test] Health check passed (HTTP 200). Starting burst test...');
  return {runId};
}

export default function () {
  const accountId = `${__VU}-${__ITER}-${Date.now()}-${Math.floor(Math.random() * 1000000)}`;
  const email = `load-${runId}-${accountId}@example.invalid`;
  const password = `Pass!${accountId}987654`;

  const payload = JSON.stringify({
    email,
    password,
    name: `Load Test ${accountId}`,
    career: 'General Medicine',
    gender: 'Male',
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    tags: {operation: 'dynamo_register'},
    timeout: '15s',
  };

  const start = Date.now();
  const res = http.post(`${targetUrl}/api/v1/auth/register`, payload, params);
  const latency = Date.now() - start;
  registrationLatency.add(latency);

  const isSuccess = res.status === 200;
  if (isSuccess) {
    successfulRegistrations.add(1);
    errorRate.add(0);
  } else {
    failedRegistrations.add(1);
    errorRate.add(1);
    console.warn(`[Registration Failed] Status: ${res.status}, Body: ${res.body}`);
  }

  check(res, {
    'status is 200': (r) => r.status === 200,
    'has jwt token': (r) => {
      try {
        const body = JSON.parse(r.body || '{}');
        return Boolean(body?.data?.token);
      } catch (_) {
        return false;
      }
    },
  });
}

export function handleSummary(data) {
  const metric = (name, key) => data.metrics[name]?.values?.[key] ?? 0;
  const totalReqs = metric('http_reqs', 'count');
  const successes = metric('dynamo_registered_accounts', 'count');
  const failures = metric('dynamo_failed_registrations', 'count');
  const avgLatency = metric('http_req_duration', 'avg').toFixed(2);
  const p95Latency = metric('http_req_duration', 'p(95)').toFixed(2);

  return {
    stdout: [
      '',
      '==============================================================',
      '       SYNAPSE HEALTH - DYNAMODB BURST TEST REPORT            ',
      '==============================================================',
      `Target Endpoint:       ${targetUrl}`,
      `Total Requests Sent:   ${totalReqs}`,
      `Successful Accounts:   ${successes}`,
      `Failed Requests:       ${failures}`,
      `Average Latency:       ${avgLatency} ms`,
      `P95 Latency:           ${p95Latency} ms`,
      `Result Status:         ${failures === 0 && successes > 0 ? 'SUCCESS (100% OK)' : 'COMPLETED WITH WARNINGS'}`,
      '==============================================================',
      '',
    ].join('\n'),
  };
}
