import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/services/google_accounts_service.dart';
import '../../../core/theme/app_theme.dart';
import 'google_logo_icon.dart';

/// Hoja modal estilo Cupertino (iOS) que lista TODAS las cuentas Google
/// registradas en el dispositivo usando el AccountManager nativo de Android.
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
  State<CupertinoGoogleAccountSheet> createState() =>
      _CupertinoGoogleAccountSheetState();
}

class _CupertinoGoogleAccountSheetState
    extends State<CupertinoGoogleAccountSheet> {
  List<String> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await GoogleAccountsService.getDeviceGoogleAccounts();
    if (mounted) {
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    }
  }

  String _initials(String email) =>
      email.isNotEmpty ? email[0].toUpperCase() : 'G';

  static const List<Color> _avatarColors = [
    Color(0xFF1A73E8),
    Color(0xFF34A853),
    Color(0xFFEA4335),
    Color(0xFFFBBC05),
    Color(0xFF9C27B0),
    Color(0xFF00ACC1),
  ];

  Color _avatarColor(int index) => _avatarColors[index % _avatarColors.length];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return DefaultTextStyle(
      // Eliminar cualquier subrayado heredado del contexto Material
      style: const TextStyle(
        decoration: TextDecoration.none,
        fontFamily: '.SF Pro Text',
      ),
      child: Container(
        decoration: BoxDecoration(
          // Fondo 10% transparente (90% de opacidad)
          color: AppColors.background.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: bottomInset + (bottomPadding > 0 ? bottomPadding : 24),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Handle iOS ────────────────────────────────────────────
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

              // ── Logo Google ───────────────────────────────────────────
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border, width: 0.8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const GoogleLogoIcon(size: 28),
                ),
              ),
              const SizedBox(height: 14),

              // ── Título ────────────────────────────────────────────────
              const Text(
                'Iniciar sesión con Google',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.4,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Elige la cuenta con la que deseas continuar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.3,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 20),

              // ── Lista de cuentas ──────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                clipBehavior: Clip.antiAlias,
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(child: CupertinoActivityIndicator()),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ..._accounts.asMap().entries.map((entry) {
                            final index = entry.key;
                            final email = entry.value;
                            final isLast = index == _accounts.length - 1;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _AccountTile(
                                  email: email,
                                  avatarColor: _avatarColor(index),
                                  initials: _initials(email),
                                  onTap: () => widget.onSelectAccount(email),
                                ),
                                if (!isLast)
                                  const Divider(
                                    height: 0.5,
                                    indent: 64,
                                    color: AppColors.border,
                                  ),
                              ],
                            );
                          }),
                          if (_accounts.isNotEmpty)
                            const Divider(
                                height: 0.5, color: AppColors.border),
                          _OtherAccountTile(
                              onTap: widget.onSelectOtherAccount),
                        ],
                      ),
              ),
              const SizedBox(height: 16),

              // ── Cancelar ──────────────────────────────────────────────
              SizedBox(
                height: 50,
                child: CupertinoButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tile de cuenta ───────────────────────────────────────────────────────────
class _AccountTile extends StatelessWidget {
  final String email;
  final Color avatarColor;
  final String initials;
  final VoidCallback onTap;

  const _AccountTile({
    required this.email,
    required this.avatarColor,
    required this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        letterSpacing: -0.2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Cuenta Google',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_forward,
                size: 15,
                color: Color(0xFFC7C7CC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tile "Usar otra cuenta" ──────────────────────────────────────────────────
class _OtherAccountTile extends StatelessWidget {
  final VoidCallback onTap;
  const _OtherAccountTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD1D1D6),
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.person_badge_plus,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usar otra cuenta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                        letterSpacing: -0.2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Agregar o cambiar cuenta',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_forward,
                size: 15,
                color: Color(0xFFC7C7CC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
