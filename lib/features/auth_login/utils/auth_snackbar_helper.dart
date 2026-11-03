// ============================================================================
// File: auth_snackbar_helper.dart
// Purpose: Helper functions and text field validators (email, secure passwords, etc.).
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../core/widgets/ios_top_banner.dart';

// Main definition of class [AuthSnackbarHelper]
class AuthSnackbarHelper {
  static void show(BuildContext context, String message, {bool isError = false}) {
    if (isError) {
      IosTopBanner.error(context, message);
    } else {
      IosTopBanner.success(context, message);
    }
  }
}
