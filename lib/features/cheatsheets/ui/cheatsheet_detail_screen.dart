// ============================================================================
// Archivo: cheatsheet_detail_screen.dart
// Propósito: Pantalla de visualizacion y exploracion para las chuletas y resumenes medicos [cheatsheet_detail_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../model/cheatsheet_model.dart';
import '../model/medical_area_model.dart';
import 'widgets/cheatsheet_key_points_card.dart';
import 'widgets/cheatsheet_markdown_viewer.dart';
import 'widgets/cheatsheet_mnemonics_card.dart';

// Pantalla de interfaz de usuario [CheatsheetDetailScreen]
class CheatsheetDetailScreen extends StatelessWidget {
  final CheatsheetModel cheatsheet;
  final MedicalAreaModel area;

  const CheatsheetDetailScreen({
    super.key,
    required this.cheatsheet,
    required this.area,
  });

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 16, top: 10, bottom: 8),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    minimumSize: const Size(36, 36),
                    onPressed: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(CupertinoIcons.chevron_back, size: 24, color: AppColors.accent),
                        SizedBox(width: 2),
                        Text(
                          'Atrás',
                          style: TextStyle(
                            fontSize: 17,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.time, size: 13, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          '${cheatsheet.readMinutes} min',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                children: [
                  Text(
                    cheatsheet.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.6,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (cheatsheet.summary.isNotEmpty) ...[
                    Text(
                      cheatsheet.summary,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (cheatsheet.sourceBook.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 0.6),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.book_fill, size: 16, color: AppColors.accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Fuente oficial: ${cheatsheet.sourceBook}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  CheatsheetKeyPointsCard(keyPoints: cheatsheet.keyPoints),
                  CheatsheetMnemonicsCard(mnemonics: cheatsheet.mnemonics),
                  CheatsheetMarkdownViewer(markdownContent: cheatsheet.contentMarkdown),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
