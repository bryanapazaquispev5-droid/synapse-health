import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';
import '../../ui/widgets/auth_login_form.dart';
import '../../ui/widgets/auth_mode_selector.dart';
import '../../ui/widgets/auth_text_field.dart';

enum CognitoFormStep { credentials, confirmation, resetRequest, resetCode }

class CognitoAuthForm extends StatelessWidget {
  const CognitoAuthForm({
    super.key,
    required this.step,
    required this.isLogin,
    required this.email,
    required this.password,
    required this.name,
    required this.code,
    required this.busy,
    required this.onMode,
    required this.onForgot,
    required this.onSubmit,
    required this.onBack,
    required this.onResend,
  });
  final CognitoFormStep step;
  final bool isLogin, busy;
  final TextEditingController email, password, name, code;
  final ValueChanged<bool> onMode;
  final VoidCallback onForgot, onSubmit, onBack, onResend;

  @override
  Widget build(BuildContext context) {
    final credentials = step == CognitoFormStep.credentials;
    final title = switch (step) {
      CognitoFormStep.credentials => isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
      CognitoFormStep.confirmation => 'Confirmar correo',
      CognitoFormStep.resetRequest => 'Recuperar contraseña',
      CognitoFormStep.resetCode => 'Restablecer contraseña',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Autenticación Cognito · entorno de transición',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 24),
        if (credentials) ...[
          AuthModeSelector(isLogin: isLogin, onModeChanged: onMode),
          const SizedBox(height: 20),
          if (!isLogin) ...[
            AuthTextField(
              controller: name,
              label: 'Nombre',
              hint: 'Tu nombre',
              prefixIcon: CupertinoIcons.person,
            ),
            const SizedBox(height: 14),
          ],
          AuthLoginForm(
            emailController: email,
            passwordController: password,
            onForgotPassword: onForgot,
          ),
        ] else ...[
          AuthTextField(
            controller: email,
            label: 'Correo Electrónico',
            hint: 'Tu correo',
            prefixIcon: CupertinoIcons.mail,
            keyboardType: TextInputType.emailAddress,
          ),
          if (step != CognitoFormStep.resetRequest) ...[
            const SizedBox(height: 14),
            AuthTextField(
              controller: code,
              label: 'Código de verificación',
              hint: 'Código recibido por correo',
              prefixIcon: CupertinoIcons.number,
              keyboardType: TextInputType.number,
            ),
          ],
          if (step == CognitoFormStep.resetCode) ...[
            const SizedBox(height: 14),
            AuthTextField(
              controller: password,
              label: 'Nueva contraseña',
              hint: 'Nueva contraseña',
              prefixIcon: CupertinoIcons.lock,
              obscureText: true,
            ),
          ],
        ],
        if ((!isLogin && credentials) || step == CognitoFormStep.resetCode) ...[
          const SizedBox(height: 8),
          const Text(
            'Usa al menos 12 caracteres, mayúsculas, minúsculas, números y símbolos.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
        const SizedBox(height: 20),
        CupertinoButton.filled(
          borderRadius: BorderRadius.circular(14),
          onPressed: busy ? null : onSubmit,
          child: busy ? const CupertinoActivityIndicator(color: AppColors.surface) : Text(title),
        ),
        if (step == CognitoFormStep.confirmation)
          CupertinoButton(
            onPressed: busy ? null : onResend,
            child: const Text('Enviar nuevo código'),
          ),
        if (!credentials)
          CupertinoButton(
            onPressed: busy ? null : onBack,
            child: const Text('Volver a iniciar sesión'),
          ),
      ],
    );
  }
}
