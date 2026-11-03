import '../../features/auth_login/cognito/api/cognito_auth_service.dart';

class CognitoAccountApi {
  CognitoAccountApi(this.auth);
  final CognitoAuthService auth;

  Future<void> updateName(String name) => _send('UpdateUserAttributes', {
    'UserAttributes': [
      {'Name': 'name', 'Value': name.trim()},
    ],
  });

  Future<void> deleteAccount() => _send('DeleteUser', {});

  Future<void> requestEmailVerification() =>
      _send('GetUserAttributeVerificationCode', {'AttributeName': 'email'});

  Future<bool> verifyEmail(String code) async {
    await _send('VerifyUserAttribute', {
      'AttributeName': 'email',
      'Code': code.trim(),
    });
    await auth.refreshUserAttributes();
    return auth.currentSession?.emailVerified ?? false;
  }

  Future<void> _send(String operation, Map<String, dynamic> fields) async {
    await auth.sendUserOperation(operation, fields);
  }
}
