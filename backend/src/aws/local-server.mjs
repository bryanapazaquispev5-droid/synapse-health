import {createServer} from 'node:http';
import {randomUUID} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {ApiError, response} from '../http.mjs';
import {withCors} from '../cors.mjs';
import {createAwsHandler} from './handler.mjs';
import {createAwsRuntime} from './runtime.mjs';
export function createAwsServer({env = process.env, runtime = createAwsRuntime({env})} = {}) {
  const handler = withCors(createAwsHandler(runtime), env.ALLOWED_ORIGIN ?? 'https://synapse.invalid');
  return createServer(async (request, output) => {
    const requestId = randomUUID();
    try {
      const url = new URL(request.url ?? '/', 'http://localhost');
      const chunks = [];
      let bytes = 0;
      for await (const chunk of request) {
        bytes += chunk.length;
        if (bytes > 32768) throw new ApiError(413, 'payload_too_large', 'Request body is too large.');
        chunks.push(chunk);
      }
      const result = await handler({path: url.pathname, httpMethod: request.method, headers: request.headers,
        queryStringParameters: Object.fromEntries(url.searchParams),
        body: chunks.length ? Buffer.concat(chunks).toString() : null, requestContext: {requestId}});
      output.writeHead(result.statusCode, result.headers); output.end(result.body);
    } catch (error) {
      const known = error instanceof ApiError;
      const result = response(known ? error.status : 500,
        {error: {code: known ? error.code : 'internal_error', message: 'The request could not be completed.'}, requestId});
      output.writeHead(result.statusCode, result.headers); output.end(result.body);
    }
  });
}
if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  createAwsServer().listen(Number(process.env.PORT ?? 8080), process.env.HOST ?? '127.0.0.1');
}
