import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/auth_login/cognito/api/cognito_auth_service.dart';
import 'package:synapse_health/features/auth_login/cognito/model/cognito_auth_exception.dart';
import 'package:synapse_health/features/auth_login/cognito/model/cognito_session.dart';
import 'package:synapse_health/features/auth_login/cognito/ui/cognito_auth_screen.dart';

class ScreenAuth extends Fake implements CognitoAuthService {
  final changes = StreamController<CognitoSession?>.broadcast();
  final calls = <String>[];
  Completer<void>? pending;
  CognitoAuthException? failure;
  CognitoSession? session;
  Completer<CognitoSession?>? restoration;
  int restores = 0;
  @override
  CognitoSession? get currentSession => session;
  @override
  Stream<CognitoSession?> get sessionChanges => changes.stream;
  @override
  Future<CognitoSession?> restoreSession() async {
    restores++;
    if (restoration != null) {
      return await restoration!.future;
    }
    return session;
  }

  @override
  Future<CognitoSession?> validSession({bool forceRefresh = false}) async {
    await run('refresh');
    return session;
  }

  Future<void> run(String action) async {
    calls.add(action);
    if (pending != null) {
      await pending!.future;
    }
    if (failure != null) {
      throw failure!;
    }
  }

  @override
  Future<void> register({required String email, required String password, required String name}) => run('register');
  @override
  Future<void> confirmRegistration({required String email, required String code}) => run('confirm');
  @override
  Future<void> resendConfirmation(String email) => run('resend');
  @override
  Future<void> forgotPassword(String email) => run('forgot');
  @override
  Future<void> confirmPasswordReset({required String email, required String code, required String newPassword}) =>
      run('reset');
  @override
  Future<CognitoSession> signIn({required String email, required String password}) async {
    await run('signin');
    session = CognitoSession(
      sub: 'test-sub',
      accessToken: 'test-access',
      idToken: 'test-id',
      refreshToken: 'test-refresh',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
    changes.add(session);
    return session!;
  }

  @override
  Future<CognitoSignOutResult> signOut() async {
    await run('signout');
    session = null;
    changes.add(null);
    return const CognitoSignOutResult(remoteRevoked: true);
  }
}

void main() {
  late ScreenAuth auth;
  setUp(() => auth = ScreenAuth());
  tearDown(() async => auth.changes.close());
  Future<void> mount(WidgetTester tester, {VoidCallback? fallback}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CognitoAuthScreen(service: auth, onUseFirebase: fallback),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> press(WidgetTester tester, String label) async {
    final target = find.widgetWithText(CupertinoButton, label);
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pump();
    await tester.pump();
  }

  testWidgets('registration confirmation and resend retain separate flow', (tester) async {
    await mount(tester);
    await tester.tap(find.text('Registrarse'));
    await tester.pump();
    await press(tester, 'Crear Cuenta');
    expect(auth.calls, ['register']);
    expect(find.text('Código de verificación'), findsOneWidget);
    await press(tester, 'Enviar nuevo código');
    await press(tester, 'Confirmar correo');
    expect(auth.calls, ['register', 'resend', 'confirm']);
    expect(find.text('Correo confirmado. Ya puedes iniciar sesión.'), findsOneWidget);
  });
  testWidgets('password recovery uses code then returns to login', (tester) async {
    await mount(tester);
    await press(tester, '¿Olvidaste tu contraseña?');
    await press(tester, 'Recuperar contraseña');
    expect(find.text('Nueva contraseña'), findsWidgets);
    await press(tester, 'Restablecer contraseña');
    expect(auth.calls, ['forgot', 'reset']);
    expect(find.text('Contraseña restablecida. Inicia sesión nuevamente.'), findsOneWidget);
  });
  testWidgets('login creates isolated session and sign out removes it', (tester) async {
    await mount(tester);
    await press(tester, 'Iniciar Sesión');
    expect(find.text('Sesión Cognito'), findsOneWidget);
    expect(find.textContaining('test-access'), findsNothing);
    await press(tester, 'Cerrar sesión');
    expect(auth.calls, ['signin', 'signout']);
    expect(find.text('Sesión Cognito'), findsNothing);
  });
  testWidgets('pending operation shows spinner and blocks duplicate requests', (tester) async {
    auth.pending = Completer<void>();
    await mount(tester);
    await press(tester, 'Iniciar Sesión');
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    expect(auth.calls, ['signin']);
    auth.pending!.complete();
    await tester.pump();
    await tester.pump();
    expect(find.text('Sesión Cognito'), findsOneWidget);
  });
  testWidgets('safe service error renders without internal exception', (tester) async {
    auth.failure = const CognitoAuthException('offline', 'No hay conexión. Inténtalo nuevamente.');
    await mount(tester);
    await press(tester, 'Iniciar Sesión');
    expect(find.text('No hay conexión. Inténtalo nuevamente.'), findsOneWidget);
    expect(find.textContaining('CognitoAuthException'), findsNothing);
  });
  testWidgets('unconfirmed login opens verification form', (tester) async {
    auth.failure = const CognitoAuthException('confirmation_required', 'Confirma tu correo.');
    await mount(tester);
    await press(tester, 'Iniciar Sesión');
    expect(find.text('Código de verificación'), findsOneWidget);
  });
  testWidgets('fallback returns to Firebase without impersonating a user', (tester) async {
    var selected = false;
    await mount(tester, fallback: () => selected = true);
    await press(tester, 'Continuar con Firebase');
    expect(selected, isTrue);
    expect(auth.calls, isEmpty);
  });
  testWidgets('expired session event removes isolated session view', (tester) async {
    await mount(tester);
    await press(tester, 'Iniciar Sesión');
    auth.session = null;
    auth.changes.add(null);
    await tester.pump();
    await tester.pump();
    expect(find.text('Sesión Cognito'), findsNothing);
    expect(find.text('Correo Electrónico'), findsOneWidget);
  });
  testWidgets('pending login can finish after leaving without disposed controllers', (tester) async {
    auth.pending = Completer<void>();
    await mount(tester);
    await press(tester, 'Iniciar Sesión');
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    auth.pending!.complete();
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
  testWidgets('secure restoration blocks login flicker and restores session once', (tester) async {
    auth.restoration = Completer<CognitoSession?>();
    await mount(tester);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    expect(find.text('Correo Electrónico'), findsNothing);
    auth.restoration!.complete(
      CognitoSession(
        sub: 'restored-sub',
        accessToken: 'stored-access',
        idToken: 'stored-id',
        refreshToken: 'stored-refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Sesión Cognito'), findsOneWidget);
    expect(auth.restores, 1);
    expect(find.textContaining('stored-access'), findsNothing);
  });
  testWidgets('missing stored session returns login without academic data', (tester) async {
    await mount(tester);
    expect(auth.restores, 1);
    expect(find.text('Correo Electrónico'), findsOneWidget);
    expect(find.text('Sesión Cognito'), findsNothing);
  });
  testWidgets('failed restoration shows safe message and login', (tester) async {
    auth.restoration = Completer<CognitoSession?>();
    await mount(tester);
    auth.restoration!.completeError(const CognitoAuthException('invalid_session', 'Inicia sesión nuevamente.'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Inicia sesión nuevamente.'), findsOneWidget);
    expect(find.text('Correo Electrónico'), findsOneWidget);
  });
  testWidgets('offline refresh retires expired panel without deleting recovery cache', (tester) async {
    auth.session = CognitoSession(
      sub: 'expiring-sub',
      accessToken: 'access',
      idToken: 'id',
      refreshToken: 'refresh',
      expiresAt: DateTime.now().add(const Duration(milliseconds: 300)),
    );
    auth.failure = const CognitoAuthException('offline', 'No hay conexión. Inténtalo nuevamente.');
    await mount(tester);
    expect(find.text('Sesión Cognito'), findsOneWidget);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 350)));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    expect(auth.calls, contains('refresh'));
    expect(find.text('Sesión Cognito'), findsNothing);
    expect(find.text('No hay conexión. Inténtalo nuevamente.'), findsOneWidget);
    expect(auth.session, isNotNull);
  });
}
