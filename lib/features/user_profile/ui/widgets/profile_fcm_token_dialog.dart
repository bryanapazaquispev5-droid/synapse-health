// ============================================================================
// Archivo: profile_fcm_token_dialog.dart
// Propósito: Componente de interfaz modular [profile_fcm_token_dialog] para la visualizacion de datos de usuario y ajustes.
// ============================================================================

import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/notifications/services/fcm_token_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Modal dialog Apple HIG para consultar y copiar el token FCM del dispositivo.
class ProfileFcmTokenDialog extends StatefulWidget {
  const ProfileFcmTokenDialog({super.key});

  static Future<void> show({required BuildContext context}) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0x66000000),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, _) => const ProfileFcmTokenDialog(),
      transitionBuilder: (context, anim, _, child) {
        final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curve),
          child: FadeTransition(opacity: curve, child: child),
        );
      },
    );
  }

  @override
  State<ProfileFcmTokenDialog> createState() => _ProfileFcmTokenDialogState();
}

// Estado reactivo y control de ciclo de vida para [ProfileFcmTokenDialog]
class _ProfileFcmTokenDialogState extends State<ProfileFcmTokenDialog> {
  bool _isLoading = true;
  String? _token;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await FcmTokenService().getFcmToken();
    if (mounted) setState(() { _token = token; _isLoading = false; });
  }

  Future<void> _copyToken() async {
    if (_token == null || _token!.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _token!));
    HapticFeedback.lightImpact();
    if (!mounted) return;

    setState(() => _isCopied = true);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(child: Text('Token FCM copiado al portapapeles', style: TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: AppColors.systemGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = min(MediaQuery.sizeOf(context).width - 36.0, 380.0);
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          margin: const EdgeInsets.symmetric(horizontal: 18),
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(CupertinoIcons.device_phone_portrait, color: AppColors.accent, size: 24),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Token FCM del Dispositivo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -0.4),
              ),
              const SizedBox(height: 6),
              const Text(
                'Identificador único del dispositivo para pruebas en Firebase Console (Cloud Messaging > Notification Composer).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.35),
              ),
              const SizedBox(height: 14),
              _buildContentBox(),
              const SizedBox(height: 16),
              _buildActionButton(),
              const SizedBox(height: 4),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 6),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar', style: TextStyle(color: AppColors.textMuted, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentBox() {
    if (_isLoading) {
      return Container(
        height: 76,
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border, width: 0.8)),
        alignment: Alignment.center,
        child: const CupertinoActivityIndicator(radius: 11),
      );
    }
    if (_token == null || _token!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border, width: 0.8)),
        child: const Text(
          'No se pudo obtener el token. Verifica la conexión a Internet o los servicios de Google Play.',
          style: TextStyle(fontSize: 12, color: AppColors.systemRed),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border, width: 0.8)),
      constraints: const BoxConstraints(maxHeight: 88),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SelectableText(
          _token!,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.primaryDark, height: 1.35),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final hasToken = _token != null && _token!.isNotEmpty;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: hasToken ? _copyToken : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: !hasToken ? AppColors.border : (_isCopied ? AppColors.systemGreen : AppColors.accent),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_isCopied ? CupertinoIcons.checkmark_alt : CupertinoIcons.doc_on_doc, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              _isCopied ? '¡Token Copiado!' : 'Copiar Token',
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
