part of 'cognito_auth_service.dart';

extension CognitoRegistration on CognitoAuthService {
  // Delegamos a Cognito la creación de la cuenta y el manejo de la contraseña.
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await _send('SignUp', {
      'Username': email.trim(),
      'Password': password,
      'UserAttributes': [
        {'Name': 'email', 'Value': email.trim()},
        {'Name': 'name', 'Value': name.trim()},
      ],
    });
  }

  Future<void> confirmRegistration({
    required String email,
    required String code,
  }) async {
    await _send('ConfirmSignUp', {
      'Username': email.trim(),
      'ConfirmationCode': code.trim(),
    });
  }

  Future<void> resendConfirmation(String email) async {
    await _send('ResendConfirmationCode', {'Username': email.trim()});
  }

  Future<void> forgotPassword(String email) async {
    // Match service enumeration protection with a non-disclosing UI result.
    try {
      await _send('ForgotPassword', {'Username': email.trim()});
    } on CognitoAuthException catch (error) {
      if (error.code != 'authentication_failed') {
        rethrow;
      }
    }
  }

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _send('ConfirmForgotPassword', {
      'Username': email.trim(),
      'ConfirmationCode': code.trim(),
      'Password': newPassword,
    });
  }

}
