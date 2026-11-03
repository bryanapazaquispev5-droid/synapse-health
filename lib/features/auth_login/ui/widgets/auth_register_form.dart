// ============================================================================
// File: auth_register_form.dart
// Purpose: Supporting visual widget [auth_register_form] for the sign-in and registration form flow.
// ============================================================================

import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';
import 'auth_text_field.dart';
import 'password_strength_bar.dart';
import 'recaptcha_card.dart';
import 'career_dropdown_field.dart';

// Main definition of class [AuthRegisterForm]
class AuthRegisterForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController careerController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;
  final bool requireCaptcha;
  final bool isCaptchaVerified;
  final ValueChanged<bool> onCaptchaVerified;
  final VoidCallback onStateUpdate;

  const AuthRegisterForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.careerController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.requireCaptcha,
    required this.isCaptchaVerified,
    required this.onCaptchaVerified,
    required this.onStateUpdate,
  });

  @override
  State<AuthRegisterForm> createState() => _AuthRegisterFormState();
}

// Reactive state and lifecycle management for [AuthRegisterForm]
class _AuthRegisterFormState extends State<AuthRegisterForm> {
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  // Reactive widget tree rendering
  // Section: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          controller: widget.nameController,
          label: 'Full Name',
          hint: 'ej. Bryan Apaza',
          prefixIcon: CupertinoIcons.person,
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: widget.emailController,
          label: 'Email',
          hint: 'e.g., student@gmail.com',
          prefixIcon: CupertinoIcons.mail,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => widget.onStateUpdate(),
        ),
        const SizedBox(height: 14),
        CareerDropdownField(
          controller: widget.careerController,
          onChanged: widget.onStateUpdate,
        ),
        const SizedBox(height: 14),
        // Gender Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 2, bottom: 8),
                child: Text(
                  'Student Gender',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<String>(
                  groupValue: widget.selectedGender,
                  backgroundColor: const Color(0xFFF1F5F9),
                  thumbColor: AppColors.surface,
                  padding: const EdgeInsets.all(4),
                  children: const {
                    'Hombre': Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.person_fill,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Hombre',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    'Mujer': Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.person_alt,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Mujer',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  },
                  onValueChanged: (val) {
                    if (val != null) widget.onGenderChanged(val);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: widget.passwordController,
          label: 'Crear Password',
          hint: '12 characters, uppercase letter, number, and symbol',
          prefixIcon: CupertinoIcons.lock,
          obscureText: _isPasswordObscured,
          onChanged: (_) => widget.onStateUpdate(),
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
        PasswordStrengthBar(
          password: widget.passwordController.text,
          email: widget.emailController.text,
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: widget.confirmPasswordController,
          label: 'Confirm password',
          hint: 'Re-enter your password',
          prefixIcon: CupertinoIcons.lock_shield,
          obscureText: _isConfirmPasswordObscured,
          suffixIcon: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              _isConfirmPasswordObscured
                  ? CupertinoIcons.eye_slash
                  : CupertinoIcons.eye,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => setState(
              () => _isConfirmPasswordObscured = !_isConfirmPasswordObscured,
            ),
          ),
        ),
        if (widget.requireCaptcha) ...[
          RecaptchaCard(
            isVerified: widget.isCaptchaVerified,
            onVerified: widget.onCaptchaVerified,
          ),
        ],
      ],
    );
  }
}
