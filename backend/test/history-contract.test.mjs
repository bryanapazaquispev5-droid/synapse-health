import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {deriveHistory} from '../src/history-repository.mjs';

test('Lambda and Flutter share canonical IDs and retained history DTO contract', () => {
  const fixture = JSON.parse(readFileSync(new URL('../../test/fixtures/history_contract.json', import.meta.url)));
  assert.deepEqual(deriveHistory([{data: () => fixture.progress}]), fixture.expected);
});
