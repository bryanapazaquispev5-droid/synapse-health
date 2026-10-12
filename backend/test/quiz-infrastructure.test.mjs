import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const read = path => readFileSync(new URL(path, import.meta.url), 'utf8');
const template = read('../template.yaml');
const runtime = read('../src/quizzes/runtime.ts');
const example = read('../.env.example');
test('quiz infrastructure is disabled by default and requires Cognito independently of flashcards', () => {
  assert.match(template, /EnableQuizBackend: \{Type: String, Default: 'false'/);
  assert.match(template, /QuizzesRequireCognito:/);
  assert.match(template, /CreateQuizBackend: !And .*EnableQuizBackend.*EnableCognitoAuth/);
  assert.match(template, /CreateAcademicContent: !Or .*CreateFlashcardContent.*CreateQuizBackend/);
  assert.match(template, /CreateFutureHistoryTable: !Or .*EnableDynamoHistory.*CreateQuizBackend/);
});
test('quiz runtime and SAM share exact table names, bounded quota and no production endpoint override', () => {
  for (const name of ['QUIZZES_TABLE_NAME', 'QUIZ_RESULTS_TABLE_NAME', 'QUIZZES_RATE_LIMIT']) {
    assert.ok(runtime.includes(`env.${name}`));
    assert.match(template, new RegExp(`^          ${name}:`, 'm'));
    assert.match(example, new RegExp(`^${name}=`, 'm'));
  }
  assert.match(template, /QUIZZES_TABLE_NAME: !If \[CreateQuizBackend, !Ref FlashcardContentTable, ''\]/);
  assert.match(template, /QUIZ_RESULTS_TABLE_NAME: !If \[CreateQuizBackend, !Ref FutureHistoryTable, ''\]/);
  assert.doesNotMatch(runtime, /endpoint:/);
});
test('quiz IAM uses only underlying DynamoDB actions on exact tables and introduces no resources', () => {
  const privatePolicy = template.split('\n').find(line => line.includes('Resource: !GetAtt FutureHistoryTable.Arn'));
  assert.ok(privatePolicy);
  assert.ok(privatePolicy.includes("['dynamodb:GetItem', 'dynamodb:Query', 'dynamodb:PutItem']"));
  assert.doesNotMatch(template, /dynamodb:Scan|dynamodb:\*|dynamodb:TransactWriteItems/);
  assert.equal((template.match(/Type: AWS::DynamoDB::Table/g) ?? []).length, 2);
  assert.equal((template.match(/Type: AWS::Serverless::Function/g) ?? []).length, 1);
});
test('API Gateway forwards quiz auxiliary routes and permits the idempotency header', () => {
  assert.match(template, /Path: '\/api\/v1\/quizzes\/\{proxy\+\}', Method: ANY/);
  assert.match(template, /Path: \/api\/v1\/progress\/me, Method: GET/);
  assert.match(template, /AllowHeaders:.*Idempotency-Key/);
});
