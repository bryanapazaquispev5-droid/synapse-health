// ============================================================================
// Archivo: quiz_topic_action_card.dart
// Propósito: Componente interactivo [quiz_topic_action_card] para la resolución táctil de preguntas médicas.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cheatsheets/model/medical_area_model.dart';
import '../../model/quiz_model.dart';
import '../quiz_session_screen.dart';

/// Componente de interfaz de usuario reutilizable [QuizTopicActionCard].
class QuizTopicActionCard extends StatelessWidget {
  final List<QuizModel> quizzes;
  final MedicalAreaModel area;

  const QuizTopicActionCard({
    super.key,
    required this.quizzes,
    required this.area,
  });

  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.play_circle_fill,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Iniciar Quiz del Tema',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '${quizzes.length} preguntas clínicas de alto rendimiento',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: CupertinoButton(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
              onPressed: () {
                // Bloque: Navegación y transición fluida hacia la siguiente pantalla
                Navigator.push(
                  context,
                  AppPageRoute(
                    child: QuizSessionScreen(
                      quizzes: quizzes,
                      areaTitle: area.name,
                      initialIndex: 0,
                    ),
                  ),
                );
              },
              child: const Text(
                'Comenzar Examen de Práctica',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
