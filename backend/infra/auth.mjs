const ref = name => ({Ref: name});
const sub = value => ({'Fn::Sub': value});
const context = why => ({'com.aws.cloudformation.Context': {why, must: ['Use Cognito identities for the AWS application.', 'Public mobile client has no secret.']}});
export const authResources = {
  UserPool: {Type: 'AWS::Cognito::UserPool', Condition: 'Approved', DeletionPolicy: 'Retain', UpdateReplacePolicy: 'Retain',
    Metadata: context('Email and password authentication for the AWS application.'),
    Properties: {UserPoolTier: 'LITE', UsernameAttributes: ['email'],
      LambdaConfig: {PreSignUp: sub('arn:${AWS::Partition}:lambda:${AWS::Region}:${AWS::AccountId}:function:${AWS::StackName}-api')},
      UsernameConfiguration: {CaseSensitive: false}, MfaConfiguration: 'OFF',
      AccountRecoverySetting: {RecoveryMechanisms: [{Name: 'verified_email', Priority: 1}]},
      Policies: {PasswordPolicy: {MinimumLength: 12, RequireLowercase: true, RequireUppercase: true,
        RequireNumbers: true, RequireSymbols: true, TemporaryPasswordValidityDays: 1}},
      Schema: [{Name: 'email', Required: true, Mutable: true}, {Name: 'name', Mutable: true}] }},
  MobileClient: {Type: 'AWS::Cognito::UserPoolClient', Condition: 'Approved',
    Metadata: context('Authorization code with PKCE and rotating refresh tokens; GetUser enforces online revocation checks.'),
    Properties: {UserPoolId: ref('UserPool'), GenerateSecret: false, PreventUserExistenceErrors: 'ENABLED',
      EnableTokenRevocation: true, AccessTokenValidity: 15, IdTokenValidity: 15, RefreshTokenValidity: 7,
      TokenValidityUnits: {AccessToken: 'minutes', IdToken: 'minutes', RefreshToken: 'days'},
      ExplicitAuthFlows: ['ALLOW_USER_PASSWORD_AUTH', 'ALLOW_USER_SRP_AUTH'],
      AllowedOAuthFlowsUserPoolClient: true, AllowedOAuthFlows: ['code'],
      AllowedOAuthScopes: ['openid', 'email', 'profile', 'aws.cognito.signin.user.admin'],
      CallbackURLs: ['com.synapsehealth.auth://callback'], LogoutURLs: ['com.synapsehealth.auth://logout'],
      SupportedIdentityProviders: ['COGNITO'],
      ReadAttributes: ['sub', 'email', 'email_verified', 'name', 'picture'], WriteAttributes: ['email', 'name', 'picture']}},
  HostedDomain: {Type: 'AWS::Cognito::UserPoolDomain', Condition: 'Approved',
    Metadata: context('Use classic hosted login supported by Lite; no paid managed-login upgrade.'),
    Properties: {UserPoolId: ref('UserPool'), Domain: sub('${AWS::StackName}-${AWS::AccountId}'), ManagedLoginVersion: 1}},
};
export const authOutputs = {
  CognitoUserPoolId: {Condition: 'Approved', Value: ref('UserPool')},
  CognitoClientId: {Condition: 'Approved', Value: ref('MobileClient')},
  CognitoRegion: {Condition: 'Approved', Value: ref('AWS::Region')},
  CognitoDomain: {Condition: 'Approved', Value: sub('https://${HostedDomain}.auth.${AWS::Region}.amazoncognito.com')},
};
