// ============================================================================
// Archivo: recaptcha_card.dart
// Propósito: Módulo de verificación humana con Captcha interactivo para mitigar accesos automatizados no autorizados.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import 'captcha_challenge_dialog.dart';

/// Componente de interfaz de usuario reutilizable [RecaptchaCard].
class RecaptchaCard extends StatefulWidget {
  final ValueChanged<bool> onVerified;
  final bool isVerified;

  const RecaptchaCard({
    super.key,
    required this.onVerified,
    this.isVerified = false,
  });

  @override
  State<RecaptchaCard> createState() => _RecaptchaCardState();
}

/// Estado mutable y controlador del ciclo de vida reactivo para [RecaptchaCard].
class _RecaptchaCardState extends State<RecaptchaCard> {
  bool _isChecking = false;
  late bool _isVerified;

  // Bloque: Inicialización de controladores, listeners y estado local
  @override
  void initState() {
    super.initState();
    _isVerified = widget.isVerified;
  }

  @override
  void didUpdateWidget(covariant RecaptchaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVerified != _isVerified) {
      // Bloque: Notificación reactiva y redibujado de la interfaz
      setState(() => _isVerified = widget.isVerified);
    }
  }

  Future<void> _handleTriggerCaptcha() async {
    if (_isVerified || _isChecking) return;

    // Bloque: Notificación reactiva y redibujado de la interfaz
    setState(() => _isChecking = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CaptchaChallengeDialog(),
    );

    if (!mounted) return;

    if (result == true) {
      HapticFeedback.mediumImpact();
      // Bloque: Notificación reactiva y redibujado de la interfaz
      setState(() {
        _isChecking = false;
        _isVerified = true;
      });
      widget.onVerified(true);
    } else {
      // Bloque: Notificación reactiva y redibujado de la interfaz
      setState(() {
        _isChecking = false;
        _isVerified = false;
      });
      widget.onVerified(false);
    }
  }

  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14.0, bottom: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isVerified ? const Color(0xFF10B981) : AppColors.border,
          width: _isVerified ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleTriggerCaptcha,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _isVerified ? const Color(0xFF10B981) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _isVerified
                      ? const Color(0xFF10B981)
                      : (_isChecking ? const Color(0xFF4285F4) : const Color(0xFFCBD5E1)),
                  width: 2,
                ),
              ),
              child: Center(
                child: _isChecking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Color(0xFF4285F4),
                        ),
                      )
                    : _isVerified
                        ? const Icon(Icons.check_rounded, size: 22, color: Colors.white)
                        : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _handleTriggerCaptcha,
              child: const Text(
                'No soy un robot',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://www.gstatic.com/recaptcha/api2/logo_48.png',
                width: 26,
                height: 26,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.shield_outlined,
                  size: 24,
                  color: Color(0xFF4285F4),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'reCAPTCHA',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.2),
              ),
              const Text(
                'Privacidad',
                style: TextStyle(fontSize: 7, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
