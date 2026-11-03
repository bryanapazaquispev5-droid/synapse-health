import {readdirSync, readFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import {join, dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
const root = join(dirname(fileURLToPath(import.meta.url)), '..');
function walk(directory) {
  return readdirSync(directory, {withFileTypes: true}).flatMap(entry => entry.isDirectory()
    ? walk(join(directory, entry.name)) : entry.name.endsWith('.mjs') ? [join(directory, entry.name)] : []);
}
for (const path of [...walk(join(root, 'src')), ...walk(join(root, 'infra')), ...walk(join(root, 'admin'))]) {
  if (readFileSync(path, 'utf8').split('\n').length > 251) throw new Error(`Source exceeds 250 lines: ${path}`);
  const result = spawnSync(process.execPath, ['--check', path], {encoding: 'utf8'});
  if (result.status !== 0) throw new Error(result.stderr);
}
console.log('Backend sources pass syntax and 250-line checks.');
