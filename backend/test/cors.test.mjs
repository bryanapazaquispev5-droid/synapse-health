import {test} from 'node:test';
import assert from 'node:assert/strict';
import {withCors} from '../src/cors.mjs';
const ok = async () => ({statusCode: 200, headers: {}, body: '{}'});
test('approved HTTPS origin receives exact CORS header', async () => {
  const result = await withCors(ok, 'https://app.example')({headers: {Origin: 'https://app.example'}});
  assert.equal(result.headers['Access-Control-Allow-Origin'], 'https://app.example');
  assert.equal(result.headers.Vary, 'Origin');
  assert.equal(result.headers['Access-Control-Expose-Headers'], 'ETag,Retry-After,Location');
});
test('unapproved origin is denied before backend work', async () => {
  let called = false;
  const result = await withCors(async () => {called = true; return ok();}, 'https://app.example')
    ({headers: {Origin: 'https://evil.example'}});
  assert.equal(result.statusCode, 403); assert.equal(called, false);
});
test('native clients without Origin remain supported', async () => {
  const result = await withCors(ok, 'https://app.example')({headers: {}});
  assert.equal(result.statusCode, 200);
  assert.equal(result.headers['Access-Control-Allow-Origin'], undefined);
});
test('wildcard and non-HTTPS CORS configurations rejected', () => {
  for (const origin of ['*', 'http://app.example', 'https://app.example/path']) {
    assert.throws(() => withCors(ok, origin));
  }
});
