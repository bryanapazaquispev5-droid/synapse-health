// ============================================================================
// Archivo: bottom_pill_item.dart
// Propósito: Componente transversal reutilizable [bottom_pill_item] para la barra de navegación flotante inferior.
// ============================================================================

import 'package:flutter/widgets.dart';

/// Componente de interfaz de usuario reutilizable [BottomPillItem].
class BottomPillItem {
  final IconData? icon;
  final String? assetPath;
  final String label;

  const BottomPillItem({
    this.icon,
    this.assetPath,
    required this.label,
  });
}
