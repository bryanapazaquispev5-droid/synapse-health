// ============================================================================
// Archivo: quiz_general_exam_card.dart
// Propósito: Componente interactivo [quiz_general_exam_card] para la resolucion de preguntas de opcion multiple, relacion o secuencia.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cheatsheets/model/medical_area_model.dart';
import '../area_quizzes_screen.dart';

// Componente visual modular [QuizGeneralExamCard]
class QuizGeneralExamCard extends StatelessWidget {
  final MedicalAreaModel area;

  const QuizGeneralExamCard({super.key, required this.area});

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.square_stack_3d_up_fill,
              color: AppColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Banco General de Quizzes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Todas las preguntas acumuladas de ${area.name}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(10),
            minimumSize: const Size(60, 32),
            onPressed: () {
              // Bloque: Navegación y transición fluida hacia la siguiente pantalla
              Navigator.push(
                context,
                AppPageRoute(
                  child: AreaQuizzesScreen(area: area),
                ),
              );
            },
            child: const Text(
              'Ver Todo',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
