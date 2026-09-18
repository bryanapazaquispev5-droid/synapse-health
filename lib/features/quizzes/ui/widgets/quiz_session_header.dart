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
  final int earnedStars;
  final int elapsedSeconds;
  final VoidCallback onExit;

  const QuizSessionHeader({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    this.earnedStars = 0,
    this.elapsedSeconds = 0,
    required this.onExit,
  });

  String _formatTime(int totalSecs) {
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

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
              // Bloque: Chip de estrellas acumuladas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.star_fill, size: 13, color: Color(0xFFFFA000)),
                    const SizedBox(width: 4),
                    Text(
                      '$earnedStars',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB78103),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Bloque: Chip de tiempo transcurrido
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.stopwatch, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(elapsedSeconds),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Bloque: Chip de progreso numérico
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${currentIndex + 1}/$totalQuestions',
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
