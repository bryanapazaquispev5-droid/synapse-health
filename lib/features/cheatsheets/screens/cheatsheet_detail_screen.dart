import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/cheatsheet_model.dart';
import '../models/medical_area_model.dart';

class CheatsheetDetailScreen extends StatelessWidget {
  final CheatsheetModel cheatsheet;
  final MedicalAreaModel area;

  const CheatsheetDetailScreen({
    super.key,
    required this.cheatsheet,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior estilo Apple Navigation Bar
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

            // Contenido clínico estilo Apple Notes / Books
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                children: [
                  // Título principal estilo Large Title
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

                  // Resumen
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

                  // Referencia Bibliográfica
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

                  // Puntos Clave de Alto Rendimiento (High-Yield Apple Callout Card)
                  if (cheatsheet.keyPoints.isNotEmpty) ...[
                    Container(
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
                          ...cheatsheet.keyPoints.map((kp) => Padding(
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
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Mnemotécnicas clínicas (Apple Amber Callout Card)
                  if (cheatsheet.mnemonics.isNotEmpty) ...[
                    Container(
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
                          ...cheatsheet.mnemonics.map((m) => Text(
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
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Contenido Markdown estructurado
                  _formatMarkdownContent(cheatsheet.contentMarkdown),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formatMarkdownContent(String markdownContent) {
    final sections = markdownContent.split('\n');
    final List<Widget> widgets = [];

    for (final line in sections) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else if (trimmed.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            trimmed.replaceFirst('### ', ''),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.4,
            ),
          ),
        ));
      } else if (trimmed.startsWith('#### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            trimmed.replaceFirst('#### ', ''),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ));
      } else if (trimmed.startsWith('* ') || trimmed.startsWith('- ')) {
        final text = trimmed.substring(2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  ', style: TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  _sanitizeMarkdownText(text),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ));
      } else if (trimmed.startsWith('---')) {
        widgets.add(const Divider(height: 24, color: AppColors.border));
      } else if (trimmed.startsWith('|')) {
        // Filas de tablas simples
        if (!trimmed.contains('---')) {
          final cells = trimmed.split('|').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
          if (cells.isNotEmpty) {
            widgets.add(Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cells.map((cell) => Text(_sanitizeMarkdownText(cell), style: const TextStyle(fontSize: 13, color: AppColors.primary, height: 1.3))).toList(),
              ),
            ));
          }
        }
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            _sanitizeMarkdownText(trimmed),
            style: const TextStyle(
              fontSize: 14.5,
              color: AppColors.primary,
              height: 1.45,
            ),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  String _sanitizeMarkdownText(String rawText) {
    return rawText
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('`', '')
        .replaceAll(r'$', '');
  }
}
