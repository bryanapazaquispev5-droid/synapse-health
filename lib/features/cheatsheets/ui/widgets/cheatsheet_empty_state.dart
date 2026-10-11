// ============================================================================
// Archivo: cheatsheet_empty_state.dart
// Propósito: Componente visual atómico [cheatsheet_empty_state] para la visualizacion estructurada de contenido medico y resumenes.
// ============================================================================

import 'package:flutter/cupertino.dart';

import '../../../../core/widgets/states/app_states.dart';

// Estado reactivo y control de ciclo de vida para [CheatsheetEmpty]
class CheatsheetEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const CheatsheetEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = CupertinoIcons.folder_badge_minus,
    this.actionLabel,
    this.onAction,
  });

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: title,
      message: subtitle,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
