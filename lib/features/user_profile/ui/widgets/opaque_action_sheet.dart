// ============================================================================
// Archivo: opaque_action_sheet.dart
// Propósito: Componente de interfaz modular [opaque_action_sheet] para la visualizacion de datos de usuario y ajustes.
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Componente visual modular [OpaqueActionSheetActionItem]
class OpaqueActionSheetActionItem {
  final Widget child;
  final VoidCallback onPressed;

  const OpaqueActionSheetActionItem({
    required this.child,
    required this.onPressed,
  });
}

// Componente visual modular [OpaqueActionSheet]
class OpaqueActionSheet extends StatelessWidget {
  final Widget? title;
  final Widget? message;
  final List<OpaqueActionSheetActionItem> actions;

  const OpaqueActionSheet({
    super.key,
    this.title,
    this.message,
    required this.actions,
  });

  // Renderizado reactivo del arbol de widgets
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final cardColor = const Color(0xFFFFFFFF).withValues(alpha: 0.90);
    const dividerColor = AppColors.border;

    return Material(
      type: MaterialType.transparency,
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: '.SF Pro Text',
          decoration: TextDecoration.none,
          color: AppColors.primary,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: bottomPadding > 0 ? 8 : 14,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: cardColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null || message != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ?title,
                                if (title != null && message != null) const SizedBox(height: 4),
                                ?message,
                              ],
                            ),
                          ),
                          const Divider(height: 0.5, thickness: 0.5, color: dividerColor),
                        ],
                        for (int i = 0; i < actions.length; i++) ...[
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: actions[i].onPressed,
                              highlightColor: const Color(0xFFE5E5EA).withValues(alpha: 0.5),
                              splashColor: Colors.transparent,
                              child: Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(minHeight: 52),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: actions[i].child,
                              ),
                            ),
                          ),
                          if (i < actions.length - 1)
                            const Divider(height: 0.5, thickness: 0.5, color: dividerColor),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Material(
                    color: cardColor,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      highlightColor: const Color(0xFFE5E5EA).withValues(alpha: 0.5),
                      splashColor: Colors.transparent,
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        alignment: Alignment.center,
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
