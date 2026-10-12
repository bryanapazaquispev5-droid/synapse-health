import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/auth_login/cognito/api/cognito_auth_service.dart';
import 'package:synapse_health/features/auth_login/cognito/model/cognito_auth_exception.dart';
import 'package:synapse_health/features/auth_login/cognito/model/cognito_config.dart';

import 'cognito_test_fakes.dart';

void main() {
  late RecordingTransport transport;
  late MemoryTokens store;
  late CognitoAuthService service;
  setUp(() {
    transport = RecordingTransport();
    store = MemoryTokens();
    service = CognitoAuthService(
      config: config,
      transport: transport,
      tokenStore: store,
      clock: () => now,
    );
  });
  tearDown(() => service.dispose());
  test('default remains Firebase and invalid endpoint config rejected', () {
    expect(CognitoConfig.provider, 'firebase');
    expect(config.isValid, true);
    expect(
      const CognitoConfig(region: 'evil.example', userPoolId: 'x', clientId: 'x').isValid,
      false,
    );
  });
  test('registration confirmation resend and reset use public client operations', () async {
    await service.register(email: ' a@example.test ', password: 'Private!9', name: 'Local');
    await service.confirmRegistration(email: 'a@example.test', code: ' 123456 ');
    await service.resendConfirmation('a@example.test');
    await service.forgotPassword('a@example.test');
    await service.confirmPasswordReset(
      email: 'a@example.test',
      code: '123456',
      newPassword: 'NewPrivate!9',
    );
    expect(transport.calls.map((c) => c.$1), [
      'SignUp',
      'ConfirmSignUp',
      'ResendConfirmationCode',
      'ForgotPassword',
      'ConfirmForgotPassword',
    ]);
    expect(transport.calls.every((c) => c.$2['ClientId'] == config.clientId), true);
    expect(transport.calls.first.$2.containsKey('SecretHash'), false);
    expect(store.value, null);
  });
  test('recovery and errors do not disclose user existence', () async {
    transport.respond = (_, _) async =>
        throw CognitoAuthException.fromService('UserNotFoundException');
    await service.forgotPassword('missing@example.test');
    expect(
      CognitoAuthException.fromService('UserNotFoundException').message,
      CognitoAuthException.fromService('NotAuthorizedException').message,
    );
    expect(
      CognitoAuthException.fromService('UserNotConfirmedException').code,
      'confirmation_required',
    );
  });
  test('login persists tokens and emits session but never password', () async {
    transport.respond = (_, _) async => {'AuthenticationResult': tokens()};
    final next = service.sessionChanges.first;
    final session = await service.signIn(email: 'a@example.test', password: 'Private!9');
    expect((await next)?.sub, 'student');
    expect(session.email, 'local@example.test');
    expect(transport.calls.single.$2['AuthFlow'], 'USER_PASSWORD_AUTH');
    expect(store.value, isNot(contains('Private!9')));
  });
  for (final invalid in ['issuer', 'client', 'expired', 'subject']) {
    test('rejects invalid $invalid tokens', () async {
      transport.respond = (_, _) async => {
        'AuthenticationResult': tokens(
          issuer: invalid == 'issuer' ? 'https://wrong.test' : null,
          client: invalid == 'client' ? 'wrong' : null,
          expired: invalid == 'expired',
          sub: invalid == 'subject' ? '' : 'student',
        ),
      };
      await expectLater(
        service.signIn(email: 'x', password: 'y'),
        throwsA(isA<CognitoAuthException>()),
      );
      expect(store.value, null);
    });
  }
  test('challenge response never creates session', () async {
    transport.respond = (_, _) async => {'ChallengeName': 'SMS_MFA'};
    await expectLater(
      service.signIn(email: 'x', password: 'y'),
      throwsA(isA<CognitoAuthException>()),
    );
    expect(store.value, null);
  });
  test('restore valid session uses no network', () async {
    store.value = jsonEncode(tokens());
    expect((await service.restoreSession())?.sub, 'student');
    expect(transport.calls, isEmpty);
  });
  test('empty malformed storage clears invalid session', () async {
    expect(await service.restoreSession(), null);
    store.value = 'invalid';
    expect(await service.restoreSession(), null);
    expect(store.value, null);
  });
  test('expired restore rotates refresh token', () async {
    store.value = jsonEncode(tokens(expired: true));
    transport.respond = (_, _) async => {'AuthenticationResult': tokens(refresh: 'rotated')};
    expect((await service.restoreSession())?.refreshToken, 'rotated');
    expect(transport.calls.single.$1, 'GetTokensFromRefreshToken');
    expect(store.value, contains('rotated'));
  });
  test('refresh response without rotation keeps old refresh token', () async {
    store.value = jsonEncode(tokens(expired: true));
    final updated = tokens()..remove('RefreshToken');
    transport.respond = (_, _) async => {'AuthenticationResult': updated};
    expect((await service.restoreSession())?.refreshToken, 'refresh-fixture');
  });
  test('offline restore preserves encrypted token for retry', () async {
    store.value = jsonEncode(tokens(expired: true));
    final before = store.value;
    transport.respond = (_, _) async => throw const CognitoAuthException('offline', 'Sin conexión');
    await expectLater(service.restoreSession(), throwsA(isA<CognitoAuthException>()));
    expect(store.value, before);
    expect(service.currentSession, null);
  });
  test('revoked refresh clears session', () async {
    store.value = jsonEncode(tokens(expired: true));
    transport.respond = (_, _) async =>
        throw CognitoAuthException.fromService('NotAuthorizedException');
    expect(await service.restoreSession(), null);
    expect(store.value, null);
  });
  test('offline global logout clears local session and reports uncertainty', () async {
    transport.respond = (_, _) async => {'AuthenticationResult': tokens()};
    await service.signIn(email: 'x', password: 'y');
    transport.respond = (_, _) async => throw const CognitoAuthException('offline', 'Sin conexión');
    expect((await service.signOut()).remoteRevoked, false);
    expect(store.value, null);
    expect(service.currentSession, null);
    expect(transport.calls.last.$1, 'GlobalSignOut');
    expect(transport.calls.last.$2.containsKey('ClientId'), false);
  });
  test('global logout confirms remote success', () async {
    transport.respond = (_, _) async => {'AuthenticationResult': tokens()};
    await service.signIn(email: 'x', password: 'y');
    transport.respond = (_, _) async => {};
    expect((await service.signOut()).remoteRevoked, true);
  });
  test('logout cannot be undone by in-flight login', () async {
    final pending = Completer<Map<String, dynamic>>();
    transport.respond = (_, _) => pending.future;
    final login = service.signIn(email: 'x', password: 'y');
    final checked = expectLater(login, throwsA(isA<CognitoAuthException>()));
    await service.signOut();
    pending.complete({'AuthenticationResult': tokens()});
    await checked;
    expect(store.value, null);
    expect(service.currentSession, null);
  });
  test('forced concurrent renewal uses one rotated request', () async {
    transport.respond = (_, _) async => {'AuthenticationResult': tokens()};
    await service.signIn(email: 'x', password: 'y');
    final pending = Completer<Map<String, dynamic>>();
    transport.respond = (_, _) => pending.future;
    final a = service.validSession(forceRefresh: true),
        b = service.validSession(forceRefresh: true);
    pending.complete({'AuthenticationResult': tokens(refresh: 'rotated')});
    expect((await a)?.refreshToken, 'rotated');
    expect((await b)?.refreshToken, 'rotated');
    expect(transport.calls.where((c) => c.$1 == 'GetTokensFromRefreshToken').length, 1);
  });
  test('logout cancels in-flight renewal without restoring session', () async {
    transport.respond = (_, _) async => {'AuthenticationResult': tokens()};
    await service.signIn(email: 'x', password: 'y');
    final pending = Completer<Map<String, dynamic>>();
    transport.respond = (op, _) => op == 'GlobalSignOut' ? Future.value({}) : pending.future;
    final renewal = service.validSession(forceRefresh: true);
    final checked = expectLater(renewal, throwsA(isA<CognitoAuthException>()));
    await service.signOut();
    pending.complete({'AuthenticationResult': tokens(refresh: 'rotated')});
    await checked;
    expect(store.value, null);
    expect(service.currentSession, null);
  });
  test('dispose cancels pending login without persisting or restoring session', () async {
    final pending = Completer<Map<String, dynamic>>();
    transport.respond = (_, _) => pending.future;
    final login = service.signIn(email: 'x', password: 'y');
    final checked = expectLater(login, throwsA(isA<CognitoAuthException>()));
    await service.dispose();
    pending.complete({'AuthenticationResult': tokens()});
    await checked;
    expect(store.value, null);
    expect(service.currentSession, null);
    expect(await service.restoreSession(), null);
  });
  test('China region endpoint and issuer use partition suffix', () {
    const china = CognitoConfig(
      region: 'cn-north-1',
      userPoolId: 'cn-north-1_Test',
      clientId: 'test123',
    );
    expect(china.isValid, true);
    expect(china.endpoint.host, 'cognito-idp.cn-north-1.amazonaws.com.cn');
    expect(china.issuer, 'https://cognito-idp.cn-north-1.amazonaws.com.cn/cn-north-1_Test');
  });
}
