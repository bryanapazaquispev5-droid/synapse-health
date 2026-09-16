import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import 'auth_text_field.dart';

class AuthLoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onForgotPassword;

  const AuthLoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onForgotPassword,
  });

  @override
  State<AuthLoginForm> createState() => _AuthLoginFormState();
}

class _AuthLoginFormState extends State<AuthLoginForm> {
  bool _isPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          controller: widget.emailController,
          label: 'Correo Electrónico',
          hint: 'ej. estudiante@gmail.com',
          prefixIcon: CupertinoIcons.mail,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: widget.passwordController,
          label: 'Contraseña',
          hint: '••••••••',
          prefixIcon: CupertinoIcons.lock,
          obscureText: _isPasswordObscured,
          suffixIcon: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              _isPasswordObscured ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            onPressed: widget.onForgotPassword,
            child: const Text(
              '¿Olvidaste tu contraseña?',
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
