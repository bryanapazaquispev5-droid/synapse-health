import 'package:synapse_health/core/auth/app_auth.dart';
import 'package:synapse_health/features/auth_login/cognito/api/cognito_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/auth_login/api/auth_service.dart';

import 'cognito/cognito_test_fakes.dart';

void main() {
  late RecordingTransport transport;
  late AuthService service;
  late CognitoAuthService cognito;

  setUp(() {
    transport = RecordingTransport();
    cognito = CognitoAuthService(
      config: config,
      transport: transport,
      tokenStore: MemoryTokens(),
    );
    service = AuthService(auth: AppAuth(service: cognito));
  });

  tearDown(() => cognito.dispose());

  test(
    'normalizes email and requests reset without reading profiles',
    () async {
      await service.sendPasswordResetEmail('  Student@Example.test  ');
      expect(transport.calls.single.$1, 'ForgotPassword');
      expect(transport.calls.single.$2, {
        'ClientId': config.clientId,
        'Username': 'student@example.test',
      });
    },
  );

  test(
    'unknown email receives the same completion as a known account',
    () async {
      transport.respond = (_, _) async =>
          throw CognitoAuthException.fromService('UserNotFoundException');
      await expectLater(
        service.sendPasswordResetEmail('absent@example.test'),
        completes,
      );
      expect(transport.calls.single.$2['Username'], 'absent@example.test');
    },
  );

  test('network and rate-limit failures are not hidden', () async {
    for (final code in ['offline', 'rate_limited']) {
      transport.respond = (_, _) async =>
          throw CognitoAuthException(code, 'Synthetic failure');
      await expectLater(
        service.sendPasswordResetEmail('student@example.test'),
        throwsA(
          isA<CognitoAuthException>().having((e) => e.code, 'code', code),
        ),
      );
    }
  });
}
