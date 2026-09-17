// ============================================================================
// Archivo: bottom_pill_item.dart
// Propósito: Componente transversal reutilizable [bottom_pill_item] para la barra de navegacion inferior flotante y elementos comunes.
// ============================================================================

import 'package:flutter/widgets.dart';

// Definicion principal de la clase [BottomPillItem]
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
