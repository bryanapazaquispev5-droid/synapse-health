import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class BottomPillItem {
  final IconData icon;
  final String label;

  const BottomPillItem({required this.icon, required this.label});
}

class BottomFloatingPill extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomPillItem> items;

  const BottomFloatingPill({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<BottomFloatingPill> createState() => _BottomFloatingPillState();
}

class _BottomFloatingPillState extends State<BottomFloatingPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _previousIndex = 0;
  int _targetIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _targetIndex = widget.currentIndex;

    // Duración optimizada ~20% más rápida (300 ms en lugar de 380 ms)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(covariant BottomFloatingPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = _targetIndex;
      _targetIndex = widget.currentIndex;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _targetIndex && !_controller.isAnimating) return;
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18, bottom: 16),
        child: Container(
          height: 66,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: AppColors.border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double totalWidth = constraints.maxWidth;
              final double slotWidth = totalWidth / widget.items.length;
              final double t = _controller.value;

              final double startLeft = _previousIndex * slotWidth;
              final double startRight = startLeft + slotWidth;
              final double endLeft = _targetIndex * slotWidth;
              final double endRight = endLeft + slotWidth;

              double left;
              double right;

              if (_targetIndex == _previousIndex || !_controller.isAnimating) {
                left = endLeft;
                right = endRight;
              } else if (_targetIndex > _previousIndex) {
                // Movimiento a la derecha: La cabeza (derecha) se dispara primero, la cola (izquierda) la sigue
                final double headT = const Interval(0.0, 0.70, curve: Curves.easeOutCubic).transform(t);
                final double tailT = const Interval(0.20, 1.0, curve: Curves.easeInOutCubic).transform(t);
                left = startLeft + (endLeft - startLeft) * tailT;
                right = startRight + (endRight - startRight) * headT;
              } else {
                // Movimiento a la izquierda: La cabeza (izquierda) se dispara primero, la cola (derecha) la sigue
                final double headT = const Interval(0.0, 0.70, curve: Curves.easeOutCubic).transform(t);
                final double tailT = const Interval(0.20, 1.0, curve: Curves.easeInOutCubic).transform(t);
                left = startLeft + (endLeft - startLeft) * headT;
                right = startRight + (endRight - startRight) * tailT;
              }

              // Efecto Físico de Gota Líquida:
              // Al estirarse horizontalmente, la altura se contrae ligeramente (conservación de masa líquida)
              final double currentWidth = (right - left).abs();
              final double stretchRatio = (currentWidth / slotWidth).clamp(1.0, 2.2);
              final double verticalSquash = (1.0 - (stretchRatio - 1.0) * 0.18).clamp(0.82, 1.0);

              // Rebote elástico final al aterrizar en el botón
              double bounceScale = 1.0;
              if (t > 0.75) {
                final double bounceT = (t - 0.75) / 0.25;
                bounceScale = 1.0 + 0.05 * (1.0 - bounceT) * (bounceT < 0.5 ? 1.0 : -0.5);
              }

              return Stack(
                children: [
                  // GOTA DESLIZANTE QUE SE ESTIRA (Indicador líquido)
                  Positioned(
                    left: left + 3,
                    width: (right - left - 6).clamp(slotWidth * 0.6, totalWidth),
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Transform.scale(
                        scaleY: verticalSquash * bounceScale,
                        scaleX: bounceScale,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF0F172A),
                                Color(0xFF1E293B),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.20),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // BOTONES INTERACTIVOS PERFECTAMENTE CENTRADOS VERTICAL Y HORIZONTALMENTE
                  Positioned.fill(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(widget.items.length, (index) {
                        final item = widget.items[index];
                        final bool isSelected = widget.currentIndex == index;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _onItemTapped(index),
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedScale(
                              scale: isSelected ? 1.06 : 1.0,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutBack,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 2), // Corrección óptica para centrado vertical exacto
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 180),
                                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                      child: Icon(
                                        item.icon,
                                        key: ValueKey('${item.label}_$isSelected'),
                                        size: 21,
                                        color: isSelected ? AppColors.surface : AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 180),
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isSelected ? AppColors.surface : AppColors.textMuted,
                                        letterSpacing: -0.2,
                                        height: 1.1,
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
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}