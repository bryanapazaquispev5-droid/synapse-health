part of 'cognito_auth_service.dart';

extension CognitoUserApi on CognitoAuthService {
  Future<Map<String, dynamic>> sendUserOperation(
    String operation,
    Map<String, dynamic> fields,
  ) async {
    final session = await validSession();
    if (session == null) {
      throw const CognitoAuthException('unauthenticated', 'Sign in.');
    }
    return _transport.send(operation, {
      'AccessToken': session.accessToken,
      ...fields,
    });
  }

  Future<void> refreshUserAttributes() async {
    final session = await validSession(forceRefresh: true);
    if (session == null) {
      throw const CognitoAuthException('unauthenticated', 'Sign in.');
    }
    final result = await _transport.send('GetUser', {
      'AccessToken': session.accessToken,
    });
    final attributes = Map.fromEntries(
      ((result['UserAttributes'] as List?) ?? const []).whereType<Map>().map(
        (attribute) => MapEntry(attribute['Name'], attribute['Value']),
      ),
    );
    await _save(
      session.copyWith(emailVerified: attributes['email_verified'] == 'true'),
      _generation,
    );
  }
}
