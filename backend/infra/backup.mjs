const approvedBackup = 'ScheduledBackupsEnabled';

const backupTables = [
  'AppTable',
  'MedicalAreasTable',
  'TopicsTable',
  'QuizzesTable',
  'StudyNotesTable',
  'UserProfilesTable',
  'UserProgressTable',
  'LeaderboardTable',
  'RateLimitsTable',
  'UserDevicesTable',
];

const context = why => ({'com.aws.cloudformation.Context': {why,
  must: ['Back up only the application DynamoDB tables.', 'Keep deployment disabled until backup storage costs are approved.']}});

export const backupResources = {
  DynamoBackupVault: {
    Type: 'AWS::Backup::BackupVault',
    Condition: approvedBackup,
    DeletionPolicy: 'Retain',
    UpdateReplacePolicy: 'Retain',
    Metadata: context('Stores scheduled, encrypted recovery points for Synapse Health DynamoDB tables.'),
    Properties: {BackupVaultName: {'Fn::Sub': '${AWS::StackName}-dynamodb-backups'}},
  },
  DynamoBackupRole: {
    Type: 'AWS::IAM::Role',
    Condition: approvedBackup,
    Metadata: context('Allows AWS Backup to create and manage backups for the explicitly selected DynamoDB tables.'),
    Properties: {
      AssumeRolePolicyDocument: {Version: '2012-10-17', Statement: [{Effect: 'Allow', Principal: {Service: 'backup.amazonaws.com'}, Action: 'sts:AssumeRole'}]},
      ManagedPolicyArns: [{'Fn::Sub': 'arn:${AWS::Partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup'}],
    },
  },
  DynamoBackupPlan: {
    Type: 'AWS::Backup::BackupPlan',
    Condition: approvedBackup,
    Metadata: context('Creates one daily recovery point per selected table and expires it after seven days.'),
    Properties: {BackupPlan: {
      BackupPlanName: {'Fn::Sub': '${AWS::StackName}-daily-dynamodb'},
      BackupPlanRule: [{
        RuleName: 'DailyDynamoDbBackup',
        TargetBackupVault: {Ref: 'DynamoBackupVault'},
        ScheduleExpression: 'cron(0 5 * * ? *)',
        StartWindowMinutes: 60,
        CompletionWindowMinutes: 180,
        Lifecycle: {DeleteAfterDays: 7},
        RecoveryPointTags: {Application: 'SynapseHealth', BackupType: 'Daily'},
      }],
    }},
  },
  DynamoBackupSelection: {
    Type: 'AWS::Backup::BackupSelection',
    Condition: approvedBackup,
    Metadata: context('Selects only DynamoDB tables created or retained by the Synapse Health stack.'),
    Properties: {
      BackupPlanId: {Ref: 'DynamoBackupPlan'},
      BackupSelection: {
        SelectionName: 'SynapseHealthDynamoDbTables',
        IamRoleArn: {'Fn::GetAtt': ['DynamoBackupRole', 'Arn']},
        Resources: backupTables.map(table => ({'Fn::GetAtt': [table, 'Arn']})),
      },
    },
  },
};
