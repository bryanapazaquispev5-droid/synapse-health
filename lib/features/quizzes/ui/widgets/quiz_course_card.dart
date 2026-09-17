// ============================================================================
// Archivo: quiz_course_card.dart
// Propósito: Componente interactivo [quiz_course_card] para la resolucion de preguntas de opcion multiple, relacion o secuencia.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cheatsheets/model/medical_area_model.dart';
import '../quiz_topics_screen.dart';

// Componente visual modular [QuizCourseCard]
class QuizCourseCard extends StatelessWidget {
  final MedicalAreaModel area;

  const QuizCourseCard({super.key, required this.area});

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            // Bloque: Navegación y transición fluida hacia la siguiente pantalla
            Navigator.push(
              context,
              AppPageRoute(
                child: QuizTopicsScreen(area: area),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 0.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: area.hasImage
                        ? area.buildLogoWidget(size: 28)
                        : const Icon(CupertinoIcons.bolt_fill, color: AppColors.accent, size: 26),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${area.quizzesCount} Quizzes',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${area.topicsCount} Temas',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(CupertinoIcons.chevron_forward, size: 16, color: Color(0xFFC7C7CC)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
