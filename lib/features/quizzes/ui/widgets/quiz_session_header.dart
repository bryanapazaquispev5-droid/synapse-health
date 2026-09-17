// ============================================================================
// Archivo: quiz_session_header.dart
// Propósito: Controlador de estado y presentador de la sesion interactiva de evaluacion o examen medico.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Definicion principal de la clase [QuizSessionHeader]
class QuizSessionHeader extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final VoidCallback onExit;

  const QuizSessionHeader({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.onExit,
  });

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    final double progress = totalQuestions > 0 ? (currentIndex + 1) / totalQuestions : 0.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 16, top: 10, bottom: 6),
          child: Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                minimumSize: const Size(36, 36),
                onPressed: onExit,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.chevron_back, size: 24, color: AppColors.accent),
                    SizedBox(width: 2),
                    Text(
                      'Salir',
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
                child: Text(
                  '${currentIndex + 1} de $totalQuestions',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ),
      ],
    );
  }
}
