const ref = name => ({Ref: name});
const sub = value => ({'Fn::Sub': value});
const cidr = index => ({'Fn::Select': [index, {'Fn::Cidr': [ref('VpcCidr'), 4, 8]}]});
const az = index => ({'Fn::Select': [index, {'Fn::GetAZs': ''}]});
const context = why => ({'com.aws.cloudformation.Context': {why,
  must: ['No NAT gateway or public subnet.', 'DynamoDB stays on its free gateway endpoint.', 'Only Cognito uses a billed interface endpoint.']}});

export const networkResources = {
  AppVpc: {Type: 'AWS::EC2::VPC', Condition: 'VpcEnabled', Metadata: context('Isolate the API Lambda in private subnets without Internet egress.'),
    Properties: {CidrBlock: ref('VpcCidr'), EnableDnsSupport: true, EnableDnsHostnames: true,
      Tags: [{Key: 'Application', Value: 'SynapseHealth'}]}},
  PrivateSubnetA: {Type: 'AWS::EC2::Subnet', Condition: 'VpcEnabled',
    Properties: {VpcId: ref('AppVpc'), AvailabilityZone: az(0), CidrBlock: cidr(0), MapPublicIpOnLaunch: false,
      Tags: [{Key: 'Name', Value: sub('${AWS::StackName}-private-a')}, {Key: 'Application', Value: 'SynapseHealth'}]}},
  PrivateSubnetB: {Type: 'AWS::EC2::Subnet', Condition: 'VpcEnabled',
    Properties: {VpcId: ref('AppVpc'), AvailabilityZone: az(1), CidrBlock: cidr(1), MapPublicIpOnLaunch: false,
      Tags: [{Key: 'Name', Value: sub('${AWS::StackName}-private-b')}, {Key: 'Application', Value: 'SynapseHealth'}]}},
  PrivateRouteTableA: {Type: 'AWS::EC2::RouteTable', Condition: 'VpcEnabled', Properties: {VpcId: ref('AppVpc')}},
  PrivateRouteTableB: {Type: 'AWS::EC2::RouteTable', Condition: 'VpcEnabled', Properties: {VpcId: ref('AppVpc')}},
  PrivateRouteAssociationA: {Type: 'AWS::EC2::SubnetRouteTableAssociation', Condition: 'VpcEnabled',
    Properties: {SubnetId: ref('PrivateSubnetA'), RouteTableId: ref('PrivateRouteTableA')}},
  PrivateRouteAssociationB: {Type: 'AWS::EC2::SubnetRouteTableAssociation', Condition: 'VpcEnabled',
    Properties: {SubnetId: ref('PrivateSubnetB'), RouteTableId: ref('PrivateRouteTableB')}},
  LambdaSecurityGroup: {Type: 'AWS::EC2::SecurityGroup', Condition: 'VpcEnabled', Properties: {
    GroupDescription: 'Outbound HTTPS only within the private VPC.', VpcId: ref('AppVpc'),
    SecurityGroupEgress: [{IpProtocol: 'tcp', FromPort: 443, ToPort: 443, CidrIp: ref('VpcCidr')}],
    Tags: [{Key: 'Application', Value: 'SynapseHealth'}]}},
  CognitoEndpointSecurityGroup: {Type: 'AWS::EC2::SecurityGroup', Condition: 'VpcEnabled', Properties: {
    GroupDescription: 'Allow HTTPS from the Synapse API Lambda only.', VpcId: ref('AppVpc'),
    SecurityGroupIngress: [{IpProtocol: 'tcp', FromPort: 443, ToPort: 443, SourceSecurityGroupId: ref('LambdaSecurityGroup')}],
    SecurityGroupEgress: [], Tags: [{Key: 'Application', Value: 'SynapseHealth'}]}},
  DynamoDbEndpoint: {Type: 'AWS::EC2::VPCEndpoint', Condition: 'VpcEnabled', Metadata: context('Use a free DynamoDB gateway endpoint for private database traffic.'),
    Properties: {VpcId: ref('AppVpc'), VpcEndpointType: 'Gateway', ServiceName: sub('com.amazonaws.${AWS::Region}.dynamodb'),
      RouteTableIds: [ref('PrivateRouteTableA'), ref('PrivateRouteTableB')]}},
  CognitoEndpoint: {Type: 'AWS::EC2::VPCEndpoint', Condition: 'VpcEnabled', Metadata: context('Keep Cognito token-status and JWKS requests private; this interface endpoint is billed per AZ.'),
    Properties: {VpcId: ref('AppVpc'), VpcEndpointType: 'Interface', ServiceName: sub('com.amazonaws.${AWS::Region}.cognito-idp'),
      PrivateDnsEnabled: true, SubnetIds: [ref('PrivateSubnetA'), ref('PrivateSubnetB')],
      SecurityGroupIds: [ref('CognitoEndpointSecurityGroup')]}},
};
