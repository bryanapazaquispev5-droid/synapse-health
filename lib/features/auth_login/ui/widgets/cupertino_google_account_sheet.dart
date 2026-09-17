// ============================================================================
// Archivo: cupertino_google_account_sheet.dart
// Propósito: Widget visual modular [cupertino_google_account_sheet] para el flujo y los formularios de inicio de sesión y registro.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/google_accounts_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'google_account_tile.dart';
import 'google_logo_icon.dart';

/// Componente modal interactivo [CupertinoGoogleAccountSheet] presentado como hoja o diálogo.
class CupertinoGoogleAccountSheet extends StatefulWidget {
  final void Function(String email) onSelectAccount;
  final VoidCallback onSelectOtherAccount;

  const CupertinoGoogleAccountSheet({
    super.key,
    required this.onSelectAccount,
    required this.onSelectOtherAccount,
  });

  static Future<void> show({
    required BuildContext context,
    required void Function(String email) onSelectAccount,
    required VoidCallback onSelectOtherAccount,
  }) {
    return showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (BuildContext sheetContext) {
        return CupertinoGoogleAccountSheet(
          onSelectAccount: (email) {
            Navigator.pop(sheetContext);
            onSelectAccount(email);
          },
          onSelectOtherAccount: () {
            Navigator.pop(sheetContext);
            onSelectOtherAccount();
          },
        );
      },
    );
  }

  @override
  State<CupertinoGoogleAccountSheet> createState() => _CupertinoGoogleAccountSheetState();
}

/// Estado mutable y controlador del ciclo de vida reactivo para [CupertinoGoogleAccountSheet].
class _CupertinoGoogleAccountSheetState extends State<CupertinoGoogleAccountSheet> {
  List<String> _accounts = [];
  bool _isLoading = true;

  // Bloque: Inicialización de controladores, listeners y estado local
  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await GoogleAccountsService.getDeviceGoogleAccounts();
    if (mounted) {
      // Bloque: Notificación reactiva y redibujado de la interfaz
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    }
  }

  String _initials(String email) => email.isNotEmpty ? email[0].toUpperCase() : 'G';

  static const List<Color> _avatarColors = [
    Color(0xFF1A73E8),
    Color(0xFF34A853),
    Color(0xFFEA4335),
    Color(0xFFFBBC05),
    Color(0xFF9C27B0),
    Color(0xFF00ACC1),
  ];

  Color _avatarColor(int index) => _avatarColors[index % _avatarColors.length];

  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return DefaultTextStyle(
      style: const TextStyle(
        decoration: TextDecoration.none,
        fontFamily: '.SF Pro Text',
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: bottomPadding + 16),
        child: SafeArea(
          top: false,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  GoogleLogoIcon(size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Acceder con Google',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecciona una cuenta registrada en tu dispositivo:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CupertinoActivityIndicator()),
                )
              else ...[
                for (int i = 0; i < _accounts.length; i++)
                  GoogleAccountTile(
                    email: _accounts[i],
                    initials: _initials(_accounts[i]),
                    avatarColor: _avatarColor(i),
                    onTap: () => widget.onSelectAccount(_accounts[i]),
                  ),
                OtherGoogleAccountTile(onTap: widget.onSelectOtherAccount),
              ],
              const SizedBox(height: 12),
              CupertinoButton(
                padding: EdgeInsets.zero,
                color: const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(14),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    decoration: TextDecoration.none,
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
