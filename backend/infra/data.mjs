const context = why => ({'com.aws.cloudformation.Context': {why,
  must: ['Do not import user profiles or progress from a legacy data source.', 'Retain state on stack deletion and replacement.']}});
const table = (name, read, write, ttl = false) => ({Type: 'AWS::DynamoDB::Table', Condition: 'Approved',
  DeletionPolicy: 'Retain', UpdateReplacePolicy: 'Retain',
  Metadata: context(`Dedicated ${name} records with bounded provisioned capacity and English attribute names.`),
  Properties: {TableName: {'Fn::Sub': `\${AWS::StackName}-${name}`}, BillingMode: 'PROVISIONED',
    ProvisionedThroughput: {ReadCapacityUnits: read, WriteCapacityUnits: write},
    AttributeDefinitions: [{AttributeName: 'PK', AttributeType: 'S'}, {AttributeName: 'SK', AttributeType: 'S'}],
    KeySchema: [{AttributeName: 'PK', KeyType: 'HASH'}, {AttributeName: 'SK', KeyType: 'RANGE'}],
    SSESpecification: {SSEEnabled: true, SSEType: 'KMS'},
    ...(ttl ? {TimeToLiveSpecification: {AttributeName: 'expiresAt', Enabled: true}} : {}),
    PointInTimeRecoverySpecification: {PointInTimeRecoveryEnabled: false},
    Tags: [{Key: 'Application', Value: 'SynapseHealth'}, {Key: 'DataOrigin', Value: 'SynapseHealthApplication'}]}});
const logicalTables = {
  MedicalAreasTable: ['medical-areas', 1, 1], TopicsTable: ['topics', 2, 1],
  QuizzesTable: ['quizzes', 4, 2], StudyNotesTable: ['study-notes', 3, 1],
  UserProfilesTable: ['user-profiles', 1, 1], UserProgressTable: ['user-progress', 2, 2],
  LeaderboardTable: ['leaderboard', 1, 2],
  RateLimitsTable: ['rate-limits', 1, 5, true],
};
const splitTables = Object.fromEntries(Object.entries(logicalTables).map(([id, [name, read, write, ttl]]) =>
  [id, table(name, read, write, ttl)]));
export const dataResources = {
  AppTable: {Type: 'AWS::DynamoDB::Table', Condition: 'Approved', DeletionPolicy: 'Retain', UpdateReplacePolicy: 'Retain',
    Metadata: {'com.aws.cloudformation.Context': {why: 'New empty owner-scoped data and catalog table; fixed throughput bounds read/write capacity.',
      must: ['Do not import user profiles or progress from a legacy data source.', 'Retain state on stack deletion and replacement.']}},
    Properties: {BillingMode: 'PROVISIONED', ProvisionedThroughput: {ReadCapacityUnits: 5, WriteCapacityUnits: 5},
      AttributeDefinitions: [{AttributeName: 'PK', AttributeType: 'S'}, {AttributeName: 'SK', AttributeType: 'S'}],
      KeySchema: [{AttributeName: 'PK', KeyType: 'HASH'}, {AttributeName: 'SK', KeyType: 'RANGE'}],
      SSESpecification: {SSEEnabled: true, SSEType: 'KMS'},
      TimeToLiveSpecification: {AttributeName: 'expiresAt', Enabled: true},
      PointInTimeRecoverySpecification: {PointInTimeRecoveryEnabled: false},
      Tags: [{Key: 'Application', Value: 'SynapseHealth'}, {Key: 'DataOrigin', Value: 'NewEmptyAwsAccountData'}]}},
  ...splitTables,
  FilesBucket: {Type: 'AWS::S3::Bucket', Condition: 'FilesEnabled', DeletionPolicy: 'Retain', UpdateReplacePolicy: 'Retain',
    Metadata: context('Optional private files bucket; disabled because the current application has no file upload service.'),
    Properties: {PublicAccessBlockConfiguration: {BlockPublicAcls: true, BlockPublicPolicy: true, IgnorePublicAcls: true, RestrictPublicBuckets: true},
      OwnershipControls: {Rules: [{ObjectOwnership: 'BucketOwnerEnforced'}]},
      BucketEncryption: {ServerSideEncryptionConfiguration: [{ServerSideEncryptionByDefault: {SSEAlgorithm: 'AES256'}}]},
      VersioningConfiguration: {Status: 'Enabled'},
      LifecycleConfiguration: {Rules: [{Id: 'AbortIncompleteUploads', Status: 'Enabled', AbortIncompleteMultipartUpload: {DaysAfterInitiation: 1}}]}}},
  FilesBucketPolicy: {Type: 'AWS::S3::BucketPolicy', Condition: 'FilesEnabled',
    Metadata: context('Reject plaintext requests to the optional bucket and objects.'),
    Properties: {Bucket: {Ref: 'FilesBucket'}, PolicyDocument: {Version: '2012-10-17', Statement: [{Effect: 'Deny',
      Principal: '*', Action: 's3:*', Resource: [{'Fn::GetAtt': ['FilesBucket', 'Arn']}, {'Fn::Sub': '${FilesBucket.Arn}/*'}],
      Condition: {Bool: {'aws:SecureTransport': 'false'}}}]}}},
};
export const dataOutputs = {
  AppTableName: {Condition: 'Approved', Value: {Ref: 'AppTable'}},
  ...Object.fromEntries(Object.keys(logicalTables).map(id => [`${id}Name`, {Condition: 'Approved', Value: {Ref: id}}])),
  FilesBucketName: {Condition: 'FilesEnabled', Value: {Ref: 'FilesBucket'}},
};
