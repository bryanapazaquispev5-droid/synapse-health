// ============================================================================
// Archivo: matching_submit_button.dart
// Propósito: Componente interactivo [matching_submit_button] para la resolucion de preguntas de opcion multiple, relacion o secuencia.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Definicion principal de la clase [MatchingSubmitButton]
class MatchingSubmitButton extends StatelessWidget {
  final bool isAllPaired;
  final int pairedCount;
  final int totalCount;
  final VoidCallback onCheckAnswers;

  const MatchingSubmitButton({
    super.key,
    required this.isAllPaired,
    required this.pairedCount,
    required this.totalCount,
    required this.onCheckAnswers,
  });

  // Renderizado reactivo del arbol de widgets
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: CupertinoButton(
          color: isAllPaired ? AppColors.accent : const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(14),
          onPressed: isAllPaired ? onCheckAnswers : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isAllPaired ? CupertinoIcons.checkmark_alt_circle_fill : CupertinoIcons.link,
                size: 18,
                color: isAllPaired ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                isAllPaired
                    ? 'Comprobar Relaciones'
                    : 'Conecta todas las parejas ($pairedCount/$totalCount)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isAllPaired ? Colors.white : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
