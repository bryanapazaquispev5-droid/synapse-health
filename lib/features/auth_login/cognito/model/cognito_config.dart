class CognitoConfig {
  const CognitoConfig({required this.region, required this.userPoolId, required this.clientId});
  factory CognitoConfig.fromEnvironment() => const CognitoConfig(
    region: String.fromEnvironment('SYNAPSE_COGNITO_REGION'),
    userPoolId: String.fromEnvironment('SYNAPSE_COGNITO_USER_POOL_ID'),
    clientId: String.fromEnvironment('SYNAPSE_COGNITO_CLIENT_ID'),
  );
  static const provider = String.fromEnvironment('SYNAPSE_AUTH_PROVIDER', defaultValue: 'firebase');
  final String region;
  final String userPoolId;
  final String clientId;
  bool get isValid =>
      RegExp(r'^[a-z]{2}(?:-[a-z]+)+-\d$').hasMatch(region) &&
      RegExp('^${RegExp.escape(region)}_[A-Za-z0-9]+\$').hasMatch(userPoolId) &&
      RegExp(r'^[a-z0-9]{1,128}$').hasMatch(clientId);
  String get _dnsSuffix => region.startsWith('cn-') ? 'amazonaws.com.cn' : 'amazonaws.com';
  Uri get endpoint => Uri.https('cognito-idp.$region.$_dnsSuffix', '/');
  String get issuer => 'https://cognito-idp.$region.$_dnsSuffix/$userPoolId';
}
