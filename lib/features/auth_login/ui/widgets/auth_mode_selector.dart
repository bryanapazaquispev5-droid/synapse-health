// ============================================================================
// File: auth_mode_selector.dart
// Purpose: Supporting visual widget [auth_mode_selector] for the sign-in and registration form flow.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';

// Main definition of class [AuthModeSelector]
class AuthModeSelector extends StatelessWidget {
  final bool isLogin;
  final ValueChanged<bool> onModeChanged;

  const AuthModeSelector({
    super.key,
    required this.isLogin,
    required this.onModeChanged,
  });

  // Reactive widget tree rendering
  // Section: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<bool>(
        groupValue: isLogin,
        backgroundColor: const Color(0xFFE5E5EA),
        thumbColor: AppColors.surface,
        padding: const EdgeInsets.all(3),
        children: const {
          true: Padding(
            padding: EdgeInsets.symmetric(vertical: 9),
            child: Text(
              'Sign In',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          false: Padding(
            padding: EdgeInsets.symmetric(vertical: 9),
            child: Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: -0.3,
              ),
            ),
          ),
        },
        onValueChanged: (val) {
          if (val != null) onModeChanged(val);
        },
      ),
    );
  }
}
