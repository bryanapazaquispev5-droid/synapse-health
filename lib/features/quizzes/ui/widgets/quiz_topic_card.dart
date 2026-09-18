// ============================================================================
// Archivo: quiz_topic_card.dart
// Propósito: Componente interactivo [quiz_topic_card] para la resolucion de preguntas de opcion multiple, relacion o secuencia.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cheatsheets/model/medical_area_model.dart';
import '../../../cheatsheets/model/topic_model.dart';
import '../../model/quiz_topic_progress_model.dart';
import '../topic_quizzes_screen.dart';
import 'quiz_topic_progress_badge.dart';

// Bloque: Componente visual modular [QuizTopicCard]
class QuizTopicCard extends StatelessWidget {
  final MedicalAreaModel area;
  final TopicModel topic;
  final int number;
  final QuizTopicProgressModel? progress;

  const QuizTopicCard({
    super.key,
    required this.area,
    required this.topic,
    required this.number,
    this.progress,
  });

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    final int quizzesCount = topic.quizzesCount > 0 ? topic.quizzesCount : 20;

    return GestureDetector(
      onTap: () {
        // Bloque: Navegación y transición fluida hacia la siguiente pantalla
        Navigator.push(
          context,
          AppPageRoute(
            child: TopicQuizzesScreen(area: area, topic: topic),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      QuizTopicProgressBadge(
                        progress: progress,
                        fallbackCount: quizzesCount,
                      ),
                      if (topic.description.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            topic.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
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
