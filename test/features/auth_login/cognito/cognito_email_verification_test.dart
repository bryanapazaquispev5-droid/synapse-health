import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/auth/cognito_account_api.dart';
import 'package:synapse_health/features/auth_login/cognito/api/cognito_auth_service.dart';

import 'cognito_test_fakes.dart';

void main() {
  late RecordingTransport transport;
  late CognitoAuthService service;
  setUp(() {
    transport = RecordingTransport();
    service = CognitoAuthService(
      config: config,
      transport: transport,
      tokenStore: MemoryTokens(),
      clock: () => now,
    );
    transport.respond = (operation, _) async {
      if (operation == 'InitiateAuth' ||
          operation == 'GetTokensFromRefreshToken') {
        return {'AuthenticationResult': tokens(emailVerified: true)};
      }
      if (operation == 'GetUser') {
        return {
          'UserAttributes': [
            {'Name': 'email_verified', 'Value': 'true'},
          ],
        };
      }
      return {};
    };
  });
  tearDown(() => service.dispose());

  test('verification uses user-token operations and refreshes status', () async {
    await service.signIn(email: 'student@example.test', password: 'secret');
    final api = CognitoAccountApi(service);
    await api.requestEmailVerification();
    await api.verifyEmail(' 123456 ');
    expect(transport.calls[1].$1, 'GetUserAttributeVerificationCode');
    expect(transport.calls[1].$2['AttributeName'], 'email');
    expect(transport.calls[1].$2.containsKey('ClientId'), false);
    expect(transport.calls[2].$1, 'VerifyUserAttribute');
    expect(transport.calls[2].$2['Code'], '123456');
    expect(transport.calls.last.$1, 'GetUser');
    expect(service.currentSession?.emailVerified, true);
  });
}
