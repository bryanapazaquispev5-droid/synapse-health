// ============================================================================
// Archivo: topic_list_card.dart
// Propósito: Componente visual atómico [topic_list_card] para la visualizacion estructurada de contenido medico y resumenes.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/medical_area_model.dart';
import '../../model/topic_model.dart';
import '../topic_cheatsheets_screen.dart';

// Componente visual modular [TopicListCard]
class TopicListCard extends StatelessWidget {
  final MedicalAreaModel area;
  final TopicModel topic;
  final int number;

  const TopicListCard({
    super.key,
    required this.area,
    required this.topic,
    required this.number,
  });

  // Renderizado reactivo del arbol de widgets
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          AppPageRoute(
            child: TopicCheatsheetsScreen(area: area, topic: topic),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.6),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (topic.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      topic.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_forward, size: 14, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }
}
