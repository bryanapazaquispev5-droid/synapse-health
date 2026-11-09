import {writeFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {authResources, authOutputs} from './auth.mjs';
import {dataResources, dataOutputs} from './data.mjs';
import {apiResources, apiOutputs} from './api.mjs';
import {networkResources} from './network.mjs';
import {backupResources} from './backup.mjs';
export const template = {
  AWSTemplateFormatVersion: '2010-09-09',
  Description: 'Synapse Health AWS backend. Imports only approved medical education catalog content; user data is never imported. No resources until DeploymentApproved=true after costs are verified.',
  Metadata: {AWSToolsMetrics: {AWSAgentToolkit: 'aws-cloudformation@3'}},
  Parameters: {
    DeploymentApproved: {Type: 'String', Default: 'false', AllowedValues: ['true', 'false']},
    ArtifactBucket: {Type: 'String', Default: 'synapse-artifacts-not-configured', Description: 'Existing private deployment-artifact bucket; never app data.'},
    ArtifactKey: {Type: 'String', Default: 'not-configured.zip', Description: 'Zip from npm run package:aws; no credentials or real data.'},
    AllowedOrigin: {Type: 'String', Default: '', AllowedPattern: '^(?:https://[A-Za-z0-9.-]+(?::[0-9]+)?)?$'},
    EnableFilesBucket: {Type: 'String', Default: 'false', AllowedValues: ['true', 'false']},
    EnableVpc: {Type: 'String', Default: 'false', AllowedValues: ['true', 'false']},
    EnableScheduledBackups: {Type: 'String', Default: 'false', AllowedValues: ['true', 'false'], Description: 'Creates a daily AWS Backup plan for DynamoDB. Adds backup storage charges.'},
    VpcCidr: {Type: 'String', Default: '10.40.0.0/16', AllowedPattern: '^10\\.(?:[0-9]{1,3})\\.(?:[0-9]{1,3})\\.0/16$'},
  },
  Conditions: {
    Approved: {'Fn::Equals': [{Ref: 'DeploymentApproved'}, 'true']},
    FilesEnabled: {'Fn::And': [{Condition: 'Approved'}, {'Fn::Equals': [{Ref: 'EnableFilesBucket'}, 'true']}]},
    VpcEnabled: {'Fn::And': [{Condition: 'Approved'}, {'Fn::Equals': [{Ref: 'EnableVpc'}, 'true']}]},
    ScheduledBackupsEnabled: {'Fn::And': [{Condition: 'Approved'}, {'Fn::Equals': [{Ref: 'EnableScheduledBackups'}, 'true']}]},
  },
  Resources: {...authResources, ...dataResources, ...networkResources, ...apiResources, ...backupResources},
  Outputs: {...authOutputs, ...dataOutputs, ...apiOutputs},
};
// Keep the reviewable source split by responsibility; generated resource entries stay below 250 lines.
const sections = Object.entries(template).map(([key, value]) => {
  if (!['Parameters', 'Conditions', 'Resources', 'Outputs'].includes(key)) return `  ${JSON.stringify(key)}: ${JSON.stringify(value)}`;
  return `  ${JSON.stringify(key)}: {\n${Object.entries(value).map(([name, item]) => `    ${JSON.stringify(name)}: ${JSON.stringify(item)}`).join(',\n')}\n  }`;
});
writeFileSync(fileURLToPath(new URL('../template.json', import.meta.url)), `{\n${sections.join(',\n')}\n}\n`);
console.log('Generated backend/template.json; deployment remains disabled by default.');
