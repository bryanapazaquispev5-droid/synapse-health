// ============================================================================
// Archivo: cheatsheet_item_card.dart
// Propósito: Componente visual atómico [cheatsheet_item_card] para la visualizacion estructurada de contenido medico y resumenes.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/cheatsheet_model.dart';
import '../../model/medical_area_model.dart';
import '../cheatsheet_detail_screen.dart';

// Componente visual modular [CheatsheetItemCard]
class CheatsheetItemCard extends StatelessWidget {
  final CheatsheetModel cheatsheet;
  final MedicalAreaModel area;
  final int index;

  const CheatsheetItemCard({
    super.key,
    required this.cheatsheet,
    required this.area,
    required this.index,
  });

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Bloque: Navegación y transición fluida hacia la siguiente pantalla
        Navigator.push(
          context,
          AppPageRoute(
            child: CheatsheetDetailScreen(cheatsheet: cheatsheet, area: area),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.6),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'CHULETA #$index',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(CupertinoIcons.time, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${cheatsheet.readMinutes} min',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              cheatsheet.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.4,
              ),
            ),
            if (cheatsheet.summary.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                cheatsheet.summary,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (cheatsheet.sourceBook.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(CupertinoIcons.book, size: 12, color: AppColors.accent),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      cheatsheet.sourceBook,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                if (cheatsheet.keyPoints.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${cheatsheet.keyPoints.length} Puntos clave',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (cheatsheet.mnemonics.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.systemOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Mnemotecnia',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.systemOrange),
                    ),
                  ),
                ],
                const Spacer(),
                const Icon(CupertinoIcons.chevron_forward, size: 14, color: Color(0xFFC7C7CC)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
