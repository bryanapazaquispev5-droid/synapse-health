import {readFileSync} from 'node:fs';
const baseline = JSON.parse(readFileSync(new URL('./iam-baseline.json', import.meta.url)));
const ref = name => ({Ref: name});
const arn = name => ({'Fn::GetAtt': [name, 'Arn']});
const sub = value => ({'Fn::Sub': value});
const catalogTables = ['MedicalAreasTable', 'TopicsTable', 'QuizzesTable', 'StudyNotesTable'];
const actions = names => baseline.runtimeActions.filter(action => names.includes(action));
const leadingKeys = keys => ({'ForAllValues:StringLike': {'dynamodb:LeadingKeys': keys}, Null: {'dynamodb:LeadingKeys': 'false'}});
const context = why => ({'com.aws.cloudformation.Context': {why,
  must: ['No external identity-provider credentials or legacy database access.', 'No provisioned concurrency, NAT, WAF or paid account-plan change.']}});
export const apiResources = {
  LambdaRole: {Type: 'AWS::IAM::Role', Condition: 'Approved', Metadata: context('Separate table permissions follow catalog, owner state, ranking, and rate-limit access patterns.'),
    Properties: {AssumeRolePolicyDocument: {Version: '2012-10-17', Statement: [{Effect: 'Allow',
      Principal: {Service: 'lambda.amazonaws.com'}, Action: 'sts:AssumeRole'}]},
      Policies: [{PolicyName: 'OwnerDataAndLogs', PolicyDocument: {Version: '2012-10-17', Statement: [
        {Effect: 'Allow', Action: actions(['dynamodb:GetItem', 'dynamodb:Query']), Resource: catalogTables.map(arn)},
        {Effect: 'Allow', Action: actions(['dynamodb:GetItem', 'dynamodb:PutItem']), Resource: arn('UserProfilesTable'), Condition: leadingKeys(['USER#*'])},
        {Effect: 'Allow', Action: actions(['dynamodb:GetItem', 'dynamodb:Query', 'dynamodb:PutItem']), Resource: arn('UserProgressTable'), Condition: leadingKeys(['USER#*'])},
        {Effect: 'Allow', Action: actions(['dynamodb:GetItem', 'dynamodb:Query']), Resource: arn('LeaderboardTable'), Condition: leadingKeys(['LEADERBOARD'])},
        {Effect: 'Allow', Action: actions(['dynamodb:PutItem']), Resource: [arn('UserProgressTable'), arn('LeaderboardTable')],
          Condition: {...leadingKeys(['USER#*', 'LEADERBOARD']), 'ForAnyValue:StringEquals': {'dynamodb:EnclosingOperation': ['TransactWriteItems']}}},
        {Effect: 'Allow', Action: actions(['dynamodb:UpdateItem']), Resource: arn('RateLimitsTable'), Condition: leadingKeys(['RATE#*'])},
        {Effect: 'Allow', Action: ['logs:CreateLogStream', 'logs:PutLogEvents'],
          Resource: sub('arn:${AWS::Partition}:logs:${AWS::Region}:${AWS::AccountId}:log-group:/aws/lambda/${AWS::StackName}-api:*')},
      ]}}]}},
  LambdaLogs: {Type: 'AWS::Logs::LogGroup', Condition: 'Approved', DeletionPolicy: 'Retain', UpdateReplacePolicy: 'Retain',
    Metadata: context('Bound log retention; handler emits request ID and safe error code only.'),
    Properties: {LogGroupName: sub('/aws/lambda/${AWS::StackName}-api'), RetentionInDays: 7}},
  ApiFunction: {Type: 'AWS::Lambda::Function', Condition: 'Approved', DependsOn: ['LambdaLogs'],
    Metadata: context('AWS-only API with role-based credentials and short bounded execution time.'),
    Properties: {FunctionName: sub('${AWS::StackName}-api'), Runtime: 'nodejs22.x', Handler: 'src/aws/index.handler',
      Architectures: ['arm64'], MemorySize: 256, Timeout: 15, Role: arn('LambdaRole'),
      Code: {S3Bucket: ref('ArtifactBucket'), S3Key: ref('ArtifactKey')},
      // CloudFormation resuelve las referencias del stack y las entrega a Lambda como variables de entorno.
      Environment: {Variables: {MEDICAL_AREAS_TABLE_NAME: ref('MedicalAreasTable'), TOPICS_TABLE_NAME: ref('TopicsTable'),
        QUIZZES_TABLE_NAME: ref('QuizzesTable'), STUDY_NOTES_TABLE_NAME: ref('StudyNotesTable'),
        USER_PROFILES_TABLE_NAME: ref('UserProfilesTable'), USER_PROGRESS_TABLE_NAME: ref('UserProgressTable'),
        LEADERBOARD_TABLE_NAME: ref('LeaderboardTable'),
        RATE_LIMITS_TABLE_NAME: ref('RateLimitsTable'), COGNITO_USER_POOL_ID: ref('UserPool'),
        COGNITO_CLIENT_ID: ref('MobileClient'), ALLOWED_ORIGIN: ref('AllowedOrigin')}}}},
  HttpApi: {Type: 'AWS::ApiGatewayV2::Api', Condition: 'Approved', Metadata: context('HTTP API routes only to the AWS handler, which verifies Cognito and revocation.'),
    Properties: {Name: sub('${AWS::StackName}-api'), ProtocolType: 'HTTP'}},
  ApiIntegration: {Type: 'AWS::ApiGatewayV2::Integration', Condition: 'Approved',
    Metadata: context('HTTP API v2 payload normalized inside the shared AWS handler.'),
    Properties: {ApiId: ref('HttpApi'), IntegrationType: 'AWS_PROXY', IntegrationUri: arn('ApiFunction'), PayloadFormatVersion: '2.0', TimeoutInMillis: 15000}},
  DefaultRoute: {Type: 'AWS::ApiGatewayV2::Route', Condition: 'Approved', Metadata: context('Preserve app route contracts while authorization stays in the backend.'),
    Properties: {ApiId: ref('HttpApi'), RouteKey: '$default', Target: {'Fn::Join': ['/', ['integrations', ref('ApiIntegration')]]}}},
  ApiLogs: {Type: 'AWS::Logs::LogGroup', Condition: 'Approved', DeletionPolicy: 'Retain', UpdateReplacePolicy: 'Retain',
    Metadata: context('Operational status logs without authorization headers, request bodies or health data.'),
    Properties: {RetentionInDays: 7}},
  ApiStage: {Type: 'AWS::ApiGatewayV2::Stage', Condition: 'Approved', Metadata: context('Conservative throttling reduces accidental usage; this is not a hard spending cap.'),
    Properties: {ApiId: ref('HttpApi'), StageName: '$default', AutoDeploy: true,
      DefaultRouteSettings: {ThrottlingBurstLimit: 10, ThrottlingRateLimit: 5, DetailedMetricsEnabled: false},
      AccessLogSettings: {DestinationArn: arn('ApiLogs'), Format: '{"requestId":"$context.requestId","status":"$context.status","latencyMs":"$context.responseLatency"}'}}},
  InvokePermission: {Type: 'AWS::Lambda::Permission', Condition: 'Approved', Metadata: context('Only this account and API may invoke the function through API Gateway.'),
    Properties: {Action: 'lambda:InvokeFunction', FunctionName: ref('ApiFunction'), Principal: 'apigateway.amazonaws.com',
      SourceAccount: ref('AWS::AccountId'), SourceArn: sub('arn:${AWS::Partition}:execute-api:${AWS::Region}:${AWS::AccountId}:${HttpApi}/*/*')}},
  CognitoPreSignUpPermission: {Type: 'AWS::Lambda::Permission', Condition: 'Approved', Metadata: context('Cognito may invoke the existing API function for pre-sign-up auto-confirmation.'),
    Properties: {Action: 'lambda:InvokeFunction', FunctionName: ref('ApiFunction'), Principal: 'cognito-idp.amazonaws.com',
      SourceAccount: ref('AWS::AccountId'), SourceArn: sub('arn:${AWS::Partition}:cognito-idp:${AWS::Region}:${AWS::AccountId}:userpool/*')}},
};
export const apiOutputs = {ApiBaseUrl: {Condition: 'Approved', Value: {'Fn::GetAtt': ['HttpApi', 'ApiEndpoint']}},
  FunctionName: {Condition: 'Approved', Value: ref('ApiFunction')}};
