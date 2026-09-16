import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../api/auth_lockout_manager.dart';
import '../api/auth_oauth_helper.dart';
import '../api/auth_service.dart';
import '../utils/auth_snackbar_helper.dart';
import '../utils/auth_validators.dart';

class AuthFlowHandler {
  final AuthService authService;
  final AuthLockoutManager lockoutManager;

  const AuthFlowHandler({
    required this.authService,
    required this.lockoutManager,
  });

  Future<bool> handleLogin({
    required BuildContext context,
    required String email,
    required String password,
    required VoidCallback onLockoutTicked,
  }) async {
    FocusScope.of(context).unfocus();

    if (lockoutManager.lockoutSeconds > 0) {
      AuthSnackbarHelper.show(context, 'Acceso bloqueado. Espera ${lockoutManager.lockoutSeconds} s.', isError: true);
      return false;
    }

    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      AuthSnackbarHelper.show(context, 'Por favor ingresa correo y contraseña', isError: true);
      return false;
    }

    try {
      final creds = await authService.signInWithEmailAndPassword(email: cleanEmail, password: cleanPassword);
      await lockoutManager.clearLockout();
      if (context.mounted) {
        AuthSnackbarHelper.show(context, '¡Bienvenido de nuevo, ${creds.user?.email}!');
      }
      return true;
    } on FirebaseAuthException catch (e) {
      final lockDuration = await lockoutManager.recordFailedLogin((sec) => onLockoutTicked());
      if (context.mounted) {
        if (lockDuration != null) {
          AuthSnackbarHelper.show(context, 'Demasiados intentos fallidos. Espera $lockDuration segundos.', isError: true);
        }
        AuthSnackbarHelper.show(context, AuthValidators.getFirebaseAuthErrorMessage(e.code), isError: true);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        AuthSnackbarHelper.show(context, 'Error inesperado: $e', isError: true);
      }
      return false;
    }
  }

  Future<int?> handleRegister({
    required BuildContext context,
    required String name,
    required String email,
    required String career,
    required String gender,
    required String password,
    required String confirmPassword,
    required int createdAccountsOnDevice,
    required bool isCaptchaVerified,
  }) async {
    FocusScope.of(context).unfocus();

    if (createdAccountsOnDevice >= 1 && !isCaptchaVerified) {
      AuthSnackbarHelper.show(context, 'Por seguridad anti-bots, marca la casilla "No soy un robot".', isError: true);
      return null;
    }

    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanCareer = career.trim();
    final cleanPassword = password.trim();
    final cleanConfirm = confirmPassword.trim();

    if (cleanName.isEmpty || cleanEmail.isEmpty || cleanCareer.isEmpty || cleanPassword.isEmpty || cleanConfirm.isEmpty) {
      AuthSnackbarHelper.show(context, 'Por favor completa todos los campos', isError: true);
      return null;
    }

    if (!AuthValidators.isValidEmail(cleanEmail)) {
      AuthSnackbarHelper.show(context, 'Por favor ingresa un correo electrónico válido', isError: true);
      return null;
    }

    if (cleanPassword != cleanConfirm) {
      AuthSnackbarHelper.show(context, 'Las contraseñas no coinciden', isError: true);
      return null;
    }

    if (cleanPassword.length < 6) {
      AuthSnackbarHelper.show(context, 'La contraseña debe tener mínimo 6 caracteres', isError: true);
      return null;
    }

    if (AuthValidators.isPasswordEqualToEmail(cleanPassword, cleanEmail)) {
      AuthSnackbarHelper.show(context, 'Por seguridad, la contraseña no puede ser igual a tu correo.', isError: true);
      return null;
    }

    try {
      await authService.registerWithEmailAndPassword(
        name: cleanName,
        email: cleanEmail,
        career: cleanCareer,
        gender: gender,
        password: cleanPassword,
      );

      int updatedCount = createdAccountsOnDevice + 1;
      try {
        final prefs = await SharedPreferences.getInstance();
        final current = prefs.getInt(AppConstants.PREF_CREATED_ACCOUNTS) ?? 0;
        updatedCount = current + 1;
        await prefs.setInt(AppConstants.PREF_CREATED_ACCOUNTS, updatedCount);
      } catch (_) {}

      if (context.mounted) {
        AuthSnackbarHelper.show(context, '¡Cuenta médica creada! Te enviamos un correo de verificación.');
      }
      return updatedCount;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        AuthSnackbarHelper.show(context, AuthValidators.getFirebaseAuthErrorMessage(e.code), isError: true);
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        AuthSnackbarHelper.show(context, 'Error inesperado: $e', isError: true);
      }
      return null;
    }
  }

  Future<void> handleGoogleSignIn({
    required BuildContext context,
    String? hintEmail,
  }) async {
    try {
      final creds = await authService.signInWithGoogle(hintEmail: hintEmail);
      if (creds == null) return;

      await lockoutManager.clearLockout();
      final user = creds.user;

      if (context.mounted && user != null) {
        await AuthOAuthHelper.syncGoogleUserAndNavigate(
          context: context,
          authService: authService,
          user: user,
        );
      }

      if (context.mounted) {
        AuthSnackbarHelper.show(context, '¡Conectado con Google: ${user?.displayName ?? user?.email}!');
      }
    } catch (e) {
      if (context.mounted) {
        AuthSnackbarHelper.show(context, 'Error al acceder con Google: $e', isError: true);
      }
    }
  }

  Future<void> handleGuestSignIn({
    required BuildContext context,
  }) async {
    try {
      await authService.signInAnonymously();
      if (context.mounted) {
        AuthSnackbarHelper.show(context, '¡Acceso concedido como Invitado temporal!');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        AuthSnackbarHelper.show(context, AuthValidators.getFirebaseAuthErrorMessage(e.code), isError: true);
      }
    } catch (e) {
      if (context.mounted) {
        AuthSnackbarHelper.show(context, 'Error en modo invitado: $e', isError: true);
      }
    }
  }
}
