import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {template} from '../infra/build-template.mjs';
test('split tables are gated, retained, and bounded within DynamoDB always-free capacity', () => {
  assert.equal(template.Parameters.DeploymentApproved.Default, 'false');
  assert.equal(template.Parameters.EnableFilesBucket.Default, 'false');
  assert.equal(template.Resources.UserPool.Properties.UserPoolTier, 'LITE');
  assert.equal(template.Resources.UserDevicesTable, undefined);
  for (const resource of Object.values(template.Resources)) assert.ok(resource.Condition);
  const names = ['MedicalAreasTable', 'TopicsTable', 'QuizzesTable', 'StudyNotesTable', 'UserProfilesTable',
    'UserProgressTable', 'LeaderboardTable', 'RateLimitsTable'];
  for (const name of ['AppTable', ...names, 'UserPool', 'FilesBucket']) assert.equal(template.Resources[name].DeletionPolicy, 'Retain');
  assert.deepEqual(template.Resources.AppTable.Properties.ProvisionedThroughput, {ReadCapacityUnits: 5, WriteCapacityUnits: 5});
  const totals = names.reduce((sum, name) => {
    const capacity = template.Resources[name].Properties.ProvisionedThroughput;
    return {read: sum.read + capacity.ReadCapacityUnits, write: sum.write + capacity.WriteCapacityUnits};
  }, {read: 5, write: 5});
  assert.deepEqual(totals, {read: 20, write: 20});
  for (const name of names) assert.equal(template.Resources[name].Properties.BillingMode, 'PROVISIONED');
});
test('Cognito supports email/password, PKCE scopes and rotating refresh credentials', () => {
  const client = template.Resources.MobileClient.Properties;
  assert.equal(client.GenerateSecret, false);
  assert.deepEqual(client.AllowedOAuthFlows, ['code']);
  assert.ok(client.AllowedOAuthScopes.includes('aws.cognito.signin.user.admin'));
  assert.equal(client.EnableTokenRevocation, true);
  assert.deepEqual(client.CallbackURLs, ['com.synapsehealth.auth://callback']);
  assert.deepEqual(client.SupportedIdentityProviders, ['COGNITO']);
  assert.equal(template.Resources.GoogleProvider, undefined);
  assert.equal(template.Parameters.GoogleSecretArn, undefined);
});
test('new sign-ups are confirmed without marking email ownership verified', () => {
  const pool = template.Resources.UserPool;
  assert.equal(pool.Properties.AutoVerifiedAttributes, undefined);
  assert.match(pool.Properties.LambdaConfig.PreSignUp['Fn::Sub'], /AWS::StackName}-api/);
  assert.equal(pool.DependsOn, undefined);
  assert.equal(template.Resources.CognitoPreSignUpPermission.Properties.Principal, 'cognito-idp.amazonaws.com');
});
test('generated IAM scopes reads and writes to each dedicated table and owner key', () => {
  const policy = template.Resources.LambdaRole.Properties.Policies[0].PolicyDocument;
  const data = policy.Statement.filter(statement => Array.isArray(statement.Action) && statement.Action.some(action => action.startsWith('dynamodb:')));
  assert.equal(data.length, 6);
  assert.equal(template.Resources.ApiFunction.Properties.Environment.Variables.USER_DEVICES_TABLE_NAME, undefined);
  assert.ok(!JSON.stringify(data).includes('AppTable'));
  const catalogRead = data.find(statement => statement.Resource?.length === 4);
  assert.deepEqual(catalogRead.Resource.map(resource => resource['Fn::GetAtt'][0]),
    ['MedicalAreasTable', 'TopicsTable', 'QuizzesTable', 'StudyNotesTable']);
  const transaction = data.find(statement => statement.Condition?.['ForAnyValue:StringEquals']?.['dynamodb:EnclosingOperation']);
  assert.deepEqual(transaction.Action, ['dynamodb:PutItem']);
  assert.deepEqual(transaction.Resource.map(resource => resource['Fn::GetAtt'][0]), ['UserProgressTable', 'LeaderboardTable']);
  assert.deepEqual(transaction.Condition['ForAllValues:StringLike']['dynamodb:LeadingKeys'], ['USER#*', 'LEADERBOARD']);
  assert.deepEqual(transaction.Condition['ForAnyValue:StringEquals']['dynamodb:EnclosingOperation'], ['TransactWriteItems']);
  assert.ok(!JSON.stringify(data).includes('dynamodb:TransactWriteItems'));
  for (const statement of data.filter(entry => entry.Condition)) assert.equal(statement.Condition.Null['dynamodb:LeadingKeys'], 'false');
  assert.ok(!JSON.stringify(policy).includes('dynamodb:Scan'));
  assert.ok(!JSON.stringify(policy).includes('kms:Decrypt'));
});
test('production dependencies and Lambda entry do not require Firebase', () => {
  const pkg = JSON.parse(readFileSync(new URL('../package.json', import.meta.url)));
  assert.equal(pkg.dependencies['firebase-admin'], undefined);
  assert.equal(pkg.devDependencies?.['firebase-admin'], undefined);
  assert.equal(template.Resources.ApiFunction.Properties.Handler, 'src/aws/index.handler');
  assert.deepEqual(template.Resources.ApiFunction.Properties.Environment.Variables.MEDICAL_AREAS_TABLE_NAME, {Ref: 'MedicalAreasTable'});
  assert.deepEqual(template.Resources.ApiFunction.Properties.Environment.Variables.STUDY_NOTES_TABLE_NAME, {Ref: 'StudyNotesTable'});
  assert.equal(template.Resources.ApiFunction.Properties.Environment.Variables.SYNAPSE_TABLE_NAME, undefined);
  const source = readFileSync(new URL('../src/aws/runtime.mjs', import.meta.url), 'utf8');
  assert.ok(!source.includes('firebase'));
});
