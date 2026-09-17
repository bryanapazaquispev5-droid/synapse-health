// ============================================================================
// Archivo: cheatsheet_mnemonics_card.dart
// Propósito: Componente visual atómico [cheatsheet_mnemonics_card] para la visualizacion estructurada de contenido medico y resumenes.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';

// Componente visual modular [CheatsheetMnemonicsCard]
class CheatsheetMnemonicsCard extends StatelessWidget {
  final List<String> mnemonics;

  const CheatsheetMnemonicsCard({super.key, required this.mnemonics});

  // Renderizado reactivo del arbol de widgets
  @override
  Widget build(BuildContext context) {
    if (mnemonics.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.systemOrange.withValues(alpha: 0.3), width: 0.8),
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
              Icon(CupertinoIcons.lightbulb_fill, size: 16, color: AppColors.systemOrange),
              SizedBox(width: 8),
              Text(
                'REGLA MNEMOTÉCNICA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.systemOrange,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...mnemonics.map((m) => Text(
                m,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF92400E),
                  height: 1.35,
                ),
              )),
        ],
      ),
    );
  }
}
