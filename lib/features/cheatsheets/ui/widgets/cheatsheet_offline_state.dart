// ============================================================================
// Archivo: cheatsheet_offline_state.dart
// Propósito: Componente visual atómico [cheatsheet_offline_state] para la visualizacion estructurada de contenido medico y resumenes.
// ============================================================================

import 'package:flutter/cupertino.dart';

import '../../../../core/widgets/states/app_states.dart';

class CheatsheetOfflineState extends StatelessWidget {
  const CheatsheetOfflineState({
    super.key,
    this.message = 'Comprueba tu conexión a Internet para cargar las fichas.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) =>
      AppOfflineState(message: message, onRetry: onRetry);
}
