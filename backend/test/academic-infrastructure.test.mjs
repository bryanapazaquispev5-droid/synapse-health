import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const read = path => readFileSync(new URL(path, import.meta.url), 'utf8');
const template = read('../template.yaml'), runtime = read('../src/quizzes/runtime.ts'), routing = read('../src/index.ts');
test('academic views are explicitly disabled and require Cognito quiz storage', () => {
  assert.match(template, /EnableAcademicViews: \{Type: String, Default: 'false'/);
  assert.match(template, /AcademicViewsRequireQuizzes:/);
  assert.match(template, /CreateAcademicViews: !And .*EnableAcademicViews.*CreateQuizBackend/);
  assert.match(template, /ACADEMIC_VIEWS_ENABLED: !If \[CreateAcademicViews, 'true', 'false'\]/);
  assert.match(runtime, /env\.ACADEMIC_VIEWS_ENABLED === 'true'/);
  assert.match(read('../.env.example'), /^ACADEMIC_VIEWS_ENABLED=false$/m);
});
test('canonical history remains Firebase unless academic views are explicitly selected', () => {
  assert.match(routing, /quizRuntime\.views\.enabled && isHistory/);
  assert.match(routing, /existing\(event\)/);
  assert.equal((template.match(/Path: \/api\/v1\/history, Method: GET/g) ?? []).length, 1);
  assert.equal((template.match(/Path: '\/api\/v1\/history\/\{id\}', Method: GET/g) ?? []).length, 1);
});
test('ranking reuses existing storage and Lambda with conditional exact-table deletion permission', () => {
  assert.match(template, /!If \[CreateAcademicViews, \{Effect: Allow, Action: \['dynamodb:DeleteItem'\], Resource: !GetAtt FutureHistoryTable\.Arn\}/);
  assert.equal((template.match(/Type: AWS::DynamoDB::Table/g) ?? []).length, 2);
  assert.equal((template.match(/Type: AWS::Serverless::Function/g) ?? []).length, 1);
  assert.doesNotMatch(template, /dynamodb:Scan|dynamodb:\*|dynamodb:TransactWriteItems|dynamodb:TransactGetItems/);
});
test('ranking and current-user position are distinct read-only API resources', () => {
  assert.match(template, /Path: \/api\/v1\/ranking, Method: GET/);
  assert.match(template, /Path: \/api\/v1\/ranking\/me, Method: GET/);
  assert.match(runtime, /new DynamoHistoryRepository\(client, privateTable\)/);
  assert.match(runtime, /new DynamoRankingRepository\(client, privateTable\)/);
  assert.match(runtime, /views: \{ history, ranking, enabled \}/);
});
