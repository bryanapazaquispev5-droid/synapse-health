import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../api/auth_service.dart';
import '../../utils/auth_validators.dart';
import 'auth_text_field.dart';

class AuthForgotPasswordSheet extends StatefulWidget {
  final String initialEmail;
  final ValueChanged<String> onSuccess;

  const AuthForgotPasswordSheet({
    super.key,
    required this.initialEmail,
    required this.onSuccess,
  });

  static Future<void> show({
    required BuildContext context,
    required String initialEmail,
    required ValueChanged<String> onSuccess,
  }) {
    return showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AuthForgotPasswordSheet(
        initialEmail: initialEmail,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<AuthForgotPasswordSheet> createState() => _AuthForgotPasswordSheetState();
}

class _AuthForgotPasswordSheetState extends State<AuthForgotPasswordSheet> {
  late final TextEditingController _resetEmailController;
  final AuthService _authService = AuthService();
  String? _localError;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _resetEmailController = TextEditingController(text: widget.initialEmail.trim());
  }

  @override
  void dispose() {
    _resetEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    final email = _resetEmailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      setState(() => _localError = 'Ingresa un correo electrónico.');
      return;
    }
    if (!AuthValidators.isValidEmail(email)) {
      setState(() => _localError = 'Formato de correo no válido.');
      return;
    }

    setState(() {
      _isChecking = true;
      _localError = null;
    });

    try {
      final exists = await _authService.isEmailRegisteredInFirestore(email);
      if (!exists) {
        if (mounted) {
          setState(() {
            _isChecking = false;
            _localError = 'Este correo no está registrado en el sistema.';
          });
        }
        return;
      }

      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess('¡Enlace enviado a $email! Revisa tu bandeja o spam.');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _localError = AuthValidators.getFirebaseAuthErrorMessage(e.code);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _localError = 'Ocurrió un error al verificar: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Recuperar Contraseña',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ingresa tu correo registrado y verificaremos tu cuenta antes de enviarte el enlace.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 18),
              AuthTextField(
                controller: _resetEmailController,
                label: 'Correo Electrónico',
                hint: 'ej. estudiante@gmail.com',
                prefixIcon: CupertinoIcons.mail,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (_localError != null) {
                    setState(() => _localError = null);
                  }
                },
              ),
              if (_localError != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.exclamationmark_circle_fill, color: Color(0xFFDC2626), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _localError!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF991B1B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: CupertinoButton.filled(
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(14),
                  onPressed: _isChecking ? null : _handleSendReset,
                  child: _isChecking
                      ? const CupertinoActivityIndicator(color: AppColors.surface)
                      : const Text(
                          'Enviar Enlace de Recuperación',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.surface),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(14),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
