// ============================================================================
// Archivo: quiz_prompt_card.dart
// Propósito: Componente interactivo [quiz_prompt_card] para la resolucion de preguntas de opcion multiple, relacion o secuencia.
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/quiz_model.dart';

// Componente visual modular [QuizPromptCard]
class QuizPromptCard extends StatelessWidget {
  final QuizModel quiz;

  const QuizPromptCard({super.key, required this.quiz});

  // Renderizado reactivo del arbol de widgets
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: quiz.typeBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: quiz.typeColor.withValues(alpha: 0.25)),
              ),
              child: Text(
                quiz.typeLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: quiz.typeColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                quiz.sourceBook,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
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
          child: Text(
            quiz.cleanQuestionPrompt,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1.4,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }
}
