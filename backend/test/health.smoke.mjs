import {test, after} from 'node:test';
import assert from 'node:assert/strict';
import {createServer} from 'node:http';

// Compiled Lambda smoke test: no server credentials or remote dependencies.
process.env.FIREBASE_PROJECT_ID = '';
process.env.FIREBASE_CREDENTIAL_SECRET_ARN = '';
process.env.ALLOWED_ORIGIN = 'https://synapse.invalid';
const {handler} = await import('../dist/index.js');
const server = createServer(async (request, response) => {
  try {
    const url = new URL(request.url, 'http://127.0.0.1');
    const result = await handler({
      httpMethod: request.method, path: url.pathname, headers: request.headers,
      queryStringParameters: Object.fromEntries(url.searchParams),
      requestContext: {requestId: 'health-smoke'}, body: null,
    }, {}, () => {});
    response.writeHead(result.statusCode, result.headers);
    response.end(result.body);
  } catch {
    response.writeHead(500);
    response.end();
  }
});
await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
after(async () => {
  server.closeAllConnections();
  await new Promise((resolve, reject) => server.close(error => error ? reject(error) : resolve()));
});
const baseUrl = `http://127.0.0.1:${server.address().port}`;

test('compiled health serves HTTP200 JSON without Firebase or AWS credentials', async () => {
  const response = await fetch(`${baseUrl}/api/v1/health`);
  assert.equal(response.status, 200);
  assert.match(response.headers.get('content-type'), /^application\/json/);
  assert.equal(response.headers.get('cache-control'), 'no-store');
  assert.deepEqual(await response.json(), {data: {status: 'ok'}, requestId: 'health-smoke'});
});
test('compiled health rejects unsupported HTTP methods', async () => {
  const response = await fetch(`${baseUrl}/api/v1/health`, {method: 'POST'});
  assert.equal(response.status, 405);
  assert.equal(response.headers.get('allow'), 'GET');
  assert.equal((await response.json()).error.code, 'method_not_allowed');
});
test('compiled health rejects query parameters consistently', async () => {
  const response = await fetch(`${baseUrl}/api/v1/health?userId=untrusted`);
  assert.equal(response.status, 400);
  assert.equal((await response.json()).error.code, 'invalid_query');
});
test('compiled health preserves exact-origin CORS policy', async () => {
  const response = await fetch(`${baseUrl}/api/v1/health`, {headers: {Origin: 'https://other.invalid'}});
  assert.equal(response.status, 403);
  assert.equal(response.headers.get('access-control-allow-origin'), null);
  assert.equal((await response.json()).error.code, 'origin_forbidden');
});
