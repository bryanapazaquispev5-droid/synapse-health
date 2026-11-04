import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synapse_health/core/api/own_profile_repository.dart';
import 'package:synapse_health/core/auth/app_auth.dart';
import 'package:synapse_health/features/auth_login/api/auth_lockout_manager.dart';
import 'package:synapse_health/features/auth_login/api/auth_service.dart';
import 'package:synapse_health/features/auth_login/cognito/api/cognito_auth_service.dart';
import 'package:synapse_health/features/auth_login/model/auth_flow_handler.dart';

import 'cognito/cognito_test_fakes.dart';

class FakeProfileRepo extends OwnProfileRepository {
  final savedProfiles = <String, Map<String, dynamic>>{};

  @override
  Future<Map<String, dynamic>> fetch(String uid) async =>
      savedProfiles[uid] ??
      {'name': 'Tester', 'career': 'Human Medicine', 'gender': 'Female'};

  @override
  Future<Map<String, dynamic>> save(
    String uid, {
    required String name,
    required String career,
    required String gender,
  }) async {
    final data = {'uid': uid, 'name': name, 'career': career, 'gender': gender};
    savedProfiles[uid] = data;
    return data;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RecordingTransport transport;
  late MemoryTokens store;
  late CognitoAuthService cognitoService;
  late AppAuth appAuth;
  late FakeProfileRepo profileRepo;
  late AuthService authService;
  late AuthLockoutManager lockoutManager;
  late AuthFlowHandler handler;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    transport = RecordingTransport();
    store = MemoryTokens();
    cognitoService = CognitoAuthService(
      config: config,
      transport: transport,
      tokenStore: store,
      clock: () => now,
    );
    appAuth = AppAuth(service: cognitoService);
    profileRepo = FakeProfileRepo();
    authService = AuthService(auth: appAuth, profiles: profileRepo);
    lockoutManager = AuthLockoutManager();
    handler = AuthFlowHandler(
      authService: authService,
      lockoutManager: lockoutManager,
    );
  });

  tearDown(() => cognitoService.dispose());

  group('Registration and confirmation security tests', () {
    test(
      'register calls SignUp and confirmRegistration calls ConfirmSignUp',
      () async {
        await authService.registerWithEmailAndPassword(
          name: 'Ana Gomez',
          email: 'ana@example.com',
          career: 'Human Medicine',
          gender: 'Mujer',
          password: 'Password123!',
        );
        expect(transport.calls.first.$1, 'SignUp');
        expect(transport.calls.first.$2['Username'], 'ana@example.com');

        await authService.confirmRegistration('ana@example.com', '654321');
        expect(transport.calls[1].$1, 'ConfirmSignUp');
        expect(transport.calls[1].$2['ConfirmationCode'], '654321');

        await authService.resendConfirmation('ana@example.com');
        expect(transport.calls[2].$1, 'ResendConfirmationCode');
      },
    );

    test(
      'unconfirmed user cannot sign in and receives confirmation_required',
      () async {
        transport.respond = (op, _) async {
          if (op == 'InitiateAuth') {
            throw CognitoAuthException.fromService('UserNotConfirmedException');
          }
          return {};
        };

        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'unconfirmed@example.com',
            password: 'Password123!',
          ),
          throwsA(
            isA<CognitoAuthException>().having(
              (e) => e.code,
              'code',
              'confirmation_required',
            ),
          ),
        );
      },
    );

    testWidgets('registration skips confirmation and signs in immediately', (
      tester,
    ) async {
      transport.respond = (op, _) async {
        if (op == 'SignUp') return {};
        if (op == 'InitiateAuth') {
          return {'AuthenticationResult': tokens()};
        }
        return {};
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await handler.handleRegister(
                    context: context,
                    name: 'Test Student',
                    email: 'test@example.com',
                    career: 'Human Medicine',
                    gender: 'Mujer',
                    password: 'Password123!',
                    confirmPassword: 'Password123!',
                    createdAccountsOnDevice: 0,
                    isCaptchaVerified: true,
                  );
                },
                child: const Text('Register'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm your email'), findsNothing);
      expect(transport.calls.any((c) => c.$1 == 'InitiateAuth'), true);
    });
  });
}
