import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/auth_login/utils/auth_validators.dart';

void main() {
  test('accepts passwords matching the Cognito user pool policy', () {
    expect(AuthValidators.meetsCognitoPasswordPolicy('Password123!'), isTrue);
  });

  test('rejects short passwords and missing required character classes', () {
    for (final password in [
      'Pass123!',
      'password123!',
      'PASSWORD123!',
      'PasswordOnly!',
      'Password1234',
    ]) {
      expect(AuthValidators.meetsCognitoPasswordPolicy(password), isFalse);
    }
  });
}
