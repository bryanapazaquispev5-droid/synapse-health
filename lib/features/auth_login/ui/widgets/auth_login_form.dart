// ============================================================================
// File: auth_login_form.dart
// Purpose: Supporting visual widget [auth_login_form] for the sign-in and registration form flow.
// ============================================================================

import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';
import 'auth_text_field.dart';

// Main definition of class [AuthLoginForm]
class AuthLoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onForgotPassword;
  final bool rememberEmail;
  final ValueChanged<bool> onRememberEmailChanged;
  final ValueChanged<String> onEmailChanged;

  const AuthLoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onForgotPassword,
    required this.rememberEmail,
    required this.onRememberEmailChanged,
    required this.onEmailChanged,
  });

  @override
  State<AuthLoginForm> createState() => _AuthLoginFormState();
}

// Reactive state and lifecycle management for [AuthLoginForm]
class _AuthLoginFormState extends State<AuthLoginForm> {
  bool _isPasswordObscured = true;

  // Reactive widget tree rendering
  // Section: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          controller: widget.emailController,
          label: 'Email',
          hint: 'e.g., student@gmail.com',
          prefixIcon: CupertinoIcons.mail,
          keyboardType: TextInputType.emailAddress,
          onChanged: widget.onEmailChanged,
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: widget.passwordController,
          label: 'Password',
          hint: '••••••••',
          prefixIcon: CupertinoIcons.lock,
          obscureText: _isPasswordObscured,
          suffixIcon: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              _isPasswordObscured
                  ? CupertinoIcons.eye_slash
                  : CupertinoIcons.eye,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _isPasswordObscured = !_isPasswordObscured),
          ),
        ),
        Row(
          children: [
            CupertinoSwitch(
              value: widget.rememberEmail,
              onChanged: widget.onRememberEmailChanged,
            ),
            const Text('Remember email'),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            onPressed: widget.onForgotPassword,
            child: const Text(
              'Forgot your password?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
