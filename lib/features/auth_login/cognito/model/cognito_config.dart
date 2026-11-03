class CognitoConfig {
  const CognitoConfig({
    required this.region,
    required this.userPoolId,
    required this.clientId,
  });
  /// Carga la región y los identificadores públicos de Cognito desde la configuración de compilación.
  factory CognitoConfig.fromEnvironment() => const CognitoConfig(
    region: String.fromEnvironment(
      'SYNAPSE_COGNITO_REGION',
      defaultValue: 'us-east-2',
    ),
    userPoolId: String.fromEnvironment(
      'SYNAPSE_COGNITO_USER_POOL_ID',
      defaultValue: 'us-east-2_p48zTpxun',
    ),
    clientId: String.fromEnvironment(
      'SYNAPSE_COGNITO_CLIENT_ID',
      defaultValue: '7uag8qk06emq2j4ld1o0rsj034',
    ),
  );
  final String region;
  final String userPoolId;
  final String clientId;
  bool get isValid =>
      RegExp(r'^[a-z]{2}(?:-[a-z]+)+-\d$').hasMatch(region) &&
      RegExp('^${RegExp.escape(region)}_[A-Za-z0-9]+\$').hasMatch(userPoolId) &&
      RegExp(r'^[a-z0-9]{1,128}$').hasMatch(clientId);
  String get _dnsSuffix =>
      region.startsWith('cn-') ? 'amazonaws.com.cn' : 'amazonaws.com';
  // Construye el endpoint HTTPS regional del User Pool.
  Uri get endpoint => Uri.https('cognito-idp.$region.$_dnsSuffix', '/');
  String get issuer => 'https://cognito-idp.$region.$_dnsSuffix/$userPoolId';
}
