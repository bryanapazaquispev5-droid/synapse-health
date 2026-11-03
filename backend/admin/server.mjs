import {createServer} from 'node:http';
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {dirname, join} from 'node:path';
import {createAwsReader} from './aws-reader.mjs';

const port = Number(process.env.SYNAPSE_ADMIN_PORT || 4178);
const host = '127.0.0.1';
const publicDirectory = join(dirname(fileURLToPath(import.meta.url)), 'public');
const staticFiles = new Map([
  ['/', ['index.html', 'text/html; charset=utf-8']],
  ['/app.js', ['app.js', 'text/javascript; charset=utf-8']],
  ['/styles.css', ['styles.css', 'text/css; charset=utf-8']],
  ['/database', ['database.html', 'text/html; charset=utf-8']],
  ['/database.html', ['database.html', 'text/html; charset=utf-8']],
  ['/database.css', ['database.css', 'text/css; charset=utf-8']],
]);

function isLocalRequest(request) {
  const hostName = request.headers.host?.split(':')[0];
  if (!['localhost', '127.0.0.1'].includes(hostName)) return false;
  const origin = request.headers.origin;
  return !origin || origin === `http://${request.headers.host}`;
}

function sendJson(response, statusCode, value) {
  response.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Cache-Control': 'no-store',
    'X-Content-Type-Options': 'nosniff',
  });
  response.end(JSON.stringify(value));
}

function safeError(error) {
  if (error.statusCode === 404) return {statusCode: 404, message: 'No se encontró esa tabla.'};
  const name = String(error.name ?? 'AWS error');
  if (/CredentialsProvider|ExpiredToken|UnrecognizedClient|InvalidClientToken/i.test(name)) {
    return {statusCode: 503, message: 'La sesión de AWS expiró. Inicia sesión con aws login y vuelve a cargar.'};
  }
  if (/AccessDenied|Unauthorized/i.test(name)) {
    return {statusCode: 503, message: 'La identidad de AWS no tiene permiso de lectura para este recurso.'};
  }
  return {statusCode: 503, message: `AWS no pudo completar la consulta (${name}).`};
}

export function createAdminServer({reader = createAwsReader()} = {}) {
  return createServer(async (request, response) => {
    const headers = {
      'Content-Security-Policy': "default-src 'self'; script-src 'self'; style-src 'self'; connect-src 'self'; img-src 'self' data:; object-src 'none'; frame-ancestors 'none'",
      'Referrer-Policy': 'no-referrer',
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'Cache-Control': 'no-store',
    };
    if (!isLocalRequest(request)) {
      response.writeHead(403, headers).end('Acceso local únicamente.');
      return;
    }
    if (request.method !== 'GET' || (request.url?.length ?? 0) > 4096) {
      response.writeHead(405, headers).end('Método no disponible.');
      return;
    }
    const url = new URL(request.url, `http://${request.headers.host}`);
    try {
      if (url.pathname === '/api/tables') {
        return sendJson(response, 200, {region: reader.region, tables: await reader.listTables()});
      }
      if (url.pathname === '/api/users') {
        return sendJson(response, 200, await reader.listUsers());
      }
      const tableMatch = /^\/api\/tables\/([^/]+)\/items$/.exec(url.pathname);
      if (tableMatch) {
        const tableName = decodeURIComponent(tableMatch[1]);
        const page = await reader.scanTable(tableName, url.searchParams.get('cursor'));
        return sendJson(response, 200, page);
      }
      const file = staticFiles.get(url.pathname);
      if (!file) return sendJson(response, 404, {message: 'No se encontró la ruta.'});
      const body = await readFile(join(publicDirectory, file[0]));
      response.writeHead(200, {...headers, 'Content-Type': file[1]}).end(body);
    } catch (error) {
      const result = safeError(error);
      sendJson(response, result.statusCode, {message: result.message});
    }
  });
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const server = createAdminServer();
  server.listen(port, host, () => {
    console.log(`Synapse Health Control Center: http://${host}:${port}`);
    console.log('Panel local de solo lectura. No se envían credenciales al navegador.');
  });
}
