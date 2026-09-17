// ============================================================================
// Archivo: cheatsheet_offline_state.dart
// Propósito: Componente visual atómico [cheatsheet_offline_state] para la visualizacion estructurada de contenido medico y resumenes.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/theme/app_theme.dart';

// Estado reactivo y control de ciclo de vida para [CheatsheetOffline]
class CheatsheetOfflineState extends StatelessWidget {
  final String message;
  final ConnectivityService _connectivityService = ConnectivityService();

  CheatsheetOfflineState({
    super.key,
    this.message = 'Para proteger la seguridad médica y mantener la información actualizada, las chuletas se cargan exclusivamente en línea desde la nube.',
  });

  // Renderizado reactivo del arbol de widgets
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEB),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(CupertinoIcons.wifi_slash, size: 40, color: AppColors.systemRed),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sin conexión a internet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              borderRadius: BorderRadius.circular(14),
              onPressed: () async {
                final isConnected = await _connectivityService.checkConnection();
                if (!context.mounted) return;
                if (!isConnected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Aún no hay conexión a internet. Revisa tu Wi-Fi o datos móviles.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: AppColors.systemRed,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(CupertinoIcons.arrow_clockwise, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Reintentar conexión',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
