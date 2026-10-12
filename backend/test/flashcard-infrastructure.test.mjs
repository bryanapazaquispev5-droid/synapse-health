import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const read = path => readFileSync(new URL(path, import.meta.url), 'utf8');
const template = read('../template.yaml');
const runtime = read('../src/flashcards/runtime.ts');
const controller = read('../src/flashcards/controller.ts');
const example = read('../.env.example');

test('SAM and environment example supply the exact flashcard runtime configuration', () => {
  for (const name of ['FLASHCARDS_TABLE_NAME', 'FLASHCARDS_RATE_LIMIT']) {
    assert.ok(runtime.includes(`env.${name}`), `${name} consumed by runtime`);
    assert.match(template, new RegExp(`^          ${name}:`, 'm'));
    assert.match(example, new RegExp(`^${name}=`, 'm'));
  }
  assert.match(template, /FLASHCARDS_RATE_LIMIT: '60'/);
});
test('SAM provisions the exact authorization group without assigning users', () => {
  assert.match(controller, /includes\('admins'\)/);
  assert.match(template, /GroupName: admins,/);
  assert.doesNotMatch(template, /AWS::Cognito::UserPoolUserToGroupAttachment/);
});
test('SAM grants table-scoped UpdateItem required by the distributed limiter, never Scan', () => {
  assert.match(runtime, /new UpdateCommand/);
  const statement = template.split('\n').find(line => line.includes('dynamodb:GetItem'));
  assert.ok(statement);
  assert.ok(statement.includes('dynamodb:UpdateItem'));
  assert.ok(statement.includes('Resource: !GetAtt FlashcardContentTable.Arn'));
  assert.doesNotMatch(template, /dynamodb:Scan|dynamodb:\*/);
});
test('content infrastructure is opt-in and requires Cognito with retained encrypted storage', () => {
  assert.match(template, /EnableFlashcardCrud: \{Type: String, Default: 'false'/);
  assert.match(template, /CreateFlashcardContent: !And .*EnableFlashcardCrud.*EnableCognitoAuth/);
  const table = template.split('  FlashcardContentTable:\n')[1].split('  FutureHistoryTable:')[0];
  for (const requirement of ['Condition: CreateAcademicContent', 'DeletionPolicy: Retain', 'UpdateReplacePolicy: Retain',
    'SSEEnabled: true', 'PointInTimeRecoveryEnabled: true', 'AttributeName: expiresAt, Enabled: true']) {
    assert.ok(table.includes(requirement), requirement);
  }
});
