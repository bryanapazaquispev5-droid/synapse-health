import 'package:flutter/material.dart';

import '../../../core/auth/app_auth.dart';
import '../../auth_login/ui/widgets/auth_code_dialog.dart';

class ProfileEmailVerification {
  static String errorMessage(Object error) =>
      error is AppAuthException ? error.message : error.toString();

  static Future<bool> fetchStatus() async {
    try {
      return await AppAuth.instance.refreshEmailVerificationStatus();
    } catch (_) {
      return false;
    }
  }

  static Future<void> verifyFromProfile({
    required BuildContext context,
    required AppUser user,
    required ValueChanged<bool> onRequestStateChanged,
    required VoidCallback onVerified,
    required ValueChanged<Object> onError,
  }) async {
    onRequestStateChanged(true);
    try {
      if (await verify(context, user)) onVerified();
    } catch (error) {
      onError(error);
    } finally {
      onRequestStateChanged(false);
    }
  }

  static Future<bool> verify(BuildContext context, AppUser user) async {
    await user.sendEmailVerification();
    if (!context.mounted) return false;
    return AuthCodeDialog.show(
      context,
      email: user.email ?? '',
      isEmailVerification: true,
      onResend: user.sendEmailVerification,
      onSubmit: (code, _) async {
        final isVerifiedByAws = await user.verifyEmail(code);
        if (!isVerifiedByAws) {
          throw const AppAuthException(
            'email_not_verified',
            'AWS has not confirmed this email address yet.',
          );
        }
      },
    );
  }
}
