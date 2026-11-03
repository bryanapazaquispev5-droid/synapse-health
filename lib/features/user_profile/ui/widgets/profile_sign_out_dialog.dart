// ============================================================================
// File: profile_sign_out_dialog.dart
// Purpose: Modular interface component [profile_sign_out_dialog] for managing and presenting profile options.
// ============================================================================

import 'package:flutter/cupertino.dart';

/// Interactive modal component [ProfileSignOutDialog] presented as a sheet or dialog.
class ProfileSignOutDialog {
  static Future<bool?> show(BuildContext context) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0x33000000),
      transitionDuration: const Duration(milliseconds: 520),
      pageBuilder: (context, animation, secondaryAnimation) => Opacity(
        opacity: 0.90,
        child: CupertinoAlertDialog(
          title: const Text(
            'Sign Out',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text(
              'Are you sure you want to sign out of your medical account?',
              style: TextStyle(fontSize: 13),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(fontSize: 15)),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Sign Out',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.90, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );
      },
    );
  }
}
