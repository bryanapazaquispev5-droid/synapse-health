// ============================================================================
// Archivo: cheatsheet_key_points_card.dart
// Propósito: Componente visual atómico [cheatsheet_key_points_card] para la visualizacion estructurada de contenido medico y resumenes.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';

// Componente visual modular [CheatsheetKeyPointsCard]
class CheatsheetKeyPointsCard extends StatelessWidget {
  final List<String> keyPoints;

  const CheatsheetKeyPointsCard({super.key, required this.keyPoints});

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    if (keyPoints.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(CupertinoIcons.star_fill, size: 16, color: AppColors.accent),
              SizedBox(width: 8),
              Text(
                'PUNTOS CLAVE DE ALTO RENDIMIENTO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...keyPoints.map((kp) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accent)),
                    Expanded(
                      child: Text(
                        kp,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
