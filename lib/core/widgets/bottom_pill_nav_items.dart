// ============================================================================
// Archivo: bottom_pill_nav_items.dart
// Propósito: Componente transversal reutilizable [bottom_pill_nav_items] para la barra de navegacion inferior flotante y elementos comunes.
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'bottom_pill_item.dart';

// Definicion principal de la clase [BottomPillNavItems]
class BottomPillNavItems extends StatelessWidget {
  final List<BottomPillItem> items;
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const BottomPillNavItems({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onItemTapped,
  });

  // Renderizado reactivo del arbol de widgets
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final bool isSelected = currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onItemTapped(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedScale(
                scale: isSelected ? 1.35 : 1.0,
                duration: const Duration(milliseconds: 550),
                curve: Curves.easeOutBack,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      item.assetPath != null
                          ? Image.asset(
                              item.assetPath!,
                              width: 23.5,
                              height: 23.5,
                              fit: BoxFit.contain,
                            )
                          : Icon(
                              item.icon ?? Icons.circle,
                              size: 20,
                              color: isSelected
                                  ? const Color(0xFF0284C7)
                                  : AppColors.textMuted,
                            ),
                      const SizedBox(height: 1.5),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 450),
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10.2,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF0284C7)
                              : AppColors.textMuted,
                          letterSpacing: -0.3,
                          height: 1.05,
                        ),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
