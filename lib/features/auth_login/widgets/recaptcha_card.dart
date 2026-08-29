import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

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

class _RecaptchaCardState extends State<RecaptchaCard> {
  bool _isChecking = false;
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    _verified = widget.isVerified;
  }

  @override
  void didUpdateWidget(covariant RecaptchaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVerified != _verified) {
      setState(() => _verified = widget.isVerified);
    }
  }

  void _triggerCaptcha() {
    if (_verified || _isChecking) return;

    setState(() => _isChecking = true);

    // Simula la verificación inteligente de reCAPTCHA (análisis de movimiento táctil)
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _verified = true;
        });
        widget.onVerified(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14.0, bottom: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _verified ? const Color(0xFF10B981) : AppColors.border,
          width: _verified ? 1.5 : 1.0,
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
          // Casilla de verificacion reCAPTCHA
          GestureDetector(
            onTap: _triggerCaptcha,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _verified ? const Color(0xFF10B981) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _verified
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
                    : _verified
                        ? const Icon(Icons.check_rounded, size: 22, color: Colors.white)
                        : null,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Texto "No soy un robot"
          Expanded(
            child: GestureDetector(
              onTap: _triggerCaptcha,
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

          // Logo e información de Google reCAPTCHA
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
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.2,
                ),
              ),
              const Text(
                'Privacidad',
                style: TextStyle(
                  fontSize: 7,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}