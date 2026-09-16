import 'package:flutter/widgets.dart';

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
