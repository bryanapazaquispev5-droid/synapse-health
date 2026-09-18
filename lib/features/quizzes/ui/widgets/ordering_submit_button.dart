// ============================================================================
// Archivo: ordering_submit_button.dart
// Propósito: Botón de acción para comprobar la secuencia ordenada en quizzes de ordenamiento.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Definición principal de la clase [OrderingSubmitButton]
class OrderingSubmitButton extends StatelessWidget {
  final VoidCallback onCheckOrder;

  const OrderingSubmitButton({
    super.key,
    required this.onCheckOrder,
  });

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: CupertinoButton(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(14),
          onPressed: onCheckOrder,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                CupertinoIcons.checkmark_alt_circle_fill,
                size: 18,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Comprobar Secuencia',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
