import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/app_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../api/auth_lockout_manager.dart';
import '../api/auth_service.dart';
import 'registration_flow_status.dart';
import '../ui/widgets/auth_code_dialog.dart';
import '../utils/auth_snackbar_helper.dart';
import '../utils/auth_validators.dart';

class AuthFlowHandler {
  const AuthFlowHandler({
    required this.authService,
    required this.lockoutManager,
  });
  final AuthService authService;
  final AuthLockoutManager lockoutManager;

  Future<bool> handleLogin({
    required BuildContext context,
    required String email,
    required String password,
    required VoidCallback onLockoutTicked,
  }) async {
    FocusScope.of(context).unfocus();
    if (lockoutManager.lockoutSeconds > 0) return false;
    if (email.trim().isEmpty || password.isEmpty) {
      AuthSnackbarHelper.show(
        context,
        'Please enter your email and password',
        isError: true,
      );
      return false;
    }
    try {
      try {
        await authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on AppAuthException catch (error) {
        if (error.code != 'confirmation_required' || !context.mounted) rethrow;
        final confirmed = await _confirm(context, email);
        if (!confirmed) return false;
        await authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      await lockoutManager.clearLockout();
      return true;
    } on AppAuthException catch (error) {
      if (error.code == 'authentication_failed') {
        await lockoutManager.recordFailedLogin((_) => onLockoutTicked());
      }
      if (context.mounted) {
        AuthSnackbarHelper.show(context, error.message, isError: true);
      }
      return false;
    } catch (_) {
      if (context.mounted) {
        AuthSnackbarHelper.show(
          context,
          'Could not sign in. Try again.',
          isError: true,
        );
      }
      return false;
    }
  }

  Future<bool> _confirm(BuildContext context, String email) =>
      AuthCodeDialog.show(
        context,
        email: email,
        onSubmit: (code, _) => authService.confirmRegistration(email, code),
        onResend: () => authService.resendConfirmation(email),
      );

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
    String? error;
    if (createdAccountsOnDevice >= 1 && !isCaptchaVerified) {
      error = 'For security, check the "I am not a robot" box.';
    } else if ([
      name,
      email,
      career,
      password,
      confirmPassword,
    ].any((v) => v.trim().isEmpty)) {
      error = 'Please complete all fields';
    } else if (!AuthValidators.isValidEmail(email.trim())) {
      error = 'Please enter a valid email address';
    } else if (password != confirmPassword) {
      error = 'Passwords do not match';
    } else if (!AuthValidators.meetsCognitoPasswordPolicy(password)) {
      error = 'Use 12 characters, including an uppercase letter, a lowercase letter, a number, and a symbol.';
    } else if (AuthValidators.isPasswordEqualToEmail(password, email)) {
      error = 'Your password cannot match your email address.';
    }
    if (error != null) {
      AuthSnackbarHelper.show(context, error, isError: true);
      return null;
    }
    final cleanEmail = email.trim().toLowerCase();
    RegistrationFlowStatus.isSavingProfile.value = true;
    try {
      final registered = await authService.registerWithEmailAndPassword(
        name: name,
        email: cleanEmail,
        career: career,
        gender: gender,
        password: password,
      );
      if (!context.mounted) return null;
      if (registered == null) {
        final credential = await authService.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        await authService.profiles.save(
          credential.user!.uid,
          name: name,
          career: career,
          gender: gender,
        );
      }
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt(AppConstants.PREF_CREATED_ACCOUNTS) ?? 0) + 1;
      await prefs.setInt(AppConstants.PREF_CREATED_ACCOUNTS, count);
      return count;
    } on AppAuthException catch (error) {
      if (context.mounted) {
        final message = (error.code == 'email_in_use' ||
                error.message.toLowerCase().contains('exists') ||
                error.message.toLowerCase().contains('already') ||
                error.message.toLowerCase().contains('email'))
            ? 'Ya existe un usuario registrado con este correo electrónico.'
            : error.message;
        AuthSnackbarHelper.show(context, message, isError: true);
      }
      return null;
    } catch (_) {
      if (context.mounted) {
        AuthSnackbarHelper.show(
          context,
          'Could not complete registration. Try again.',
          isError: true,
        );
      }
      return null;
    } finally {
      RegistrationFlowStatus.isSavingProfile.value = false;
    }
  }
}
