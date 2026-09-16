import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CheatsheetMarkdownViewer extends StatelessWidget {
  final String markdownContent;

  const CheatsheetMarkdownViewer({super.key, required this.markdownContent});

  @override
  Widget build(BuildContext context) {
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
                children: cells
                    .map((cell) => Text(
                          _sanitizeMarkdownText(cell),
                          style: const TextStyle(fontSize: 13, color: AppColors.primary, height: 1.3),
                        ))
                    .toList(),
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
