// ============================================================================
// Archivo: cheatsheet_empty_state.dart
// Propósito: Componente visual atómico [cheatsheet_empty_state] para la visualizacion estructurada de contenido medico y resumenes.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';

// Estado reactivo y control de ciclo de vida para [CheatsheetEmpty]
class CheatsheetEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const CheatsheetEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = CupertinoIcons.folder_badge_minus,
  });

  // Renderizado reactivo del arbol de widgets
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 32, color: AppColors.accent),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
