// ============================================================================
// File: bottom_pill_item.dart
// Purpose: Reusable shared component [bottom_pill_item] for the floating bottom navigation bar and common elements.
// ============================================================================

import 'package:flutter/widgets.dart';

// Main definition of the [BottomPillItem] class
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
