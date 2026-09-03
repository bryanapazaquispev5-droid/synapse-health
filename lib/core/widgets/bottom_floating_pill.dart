import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 440),
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
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
                blurRadius: 12,
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
                final double headT = const Interval(0.0, 0.50, curve: Curves.easeOutCubic).transform(t);
                final double tailT = const Interval(0.08, 0.58, curve: Curves.easeInOutCubic).transform(t);
                left = startLeft + (endLeft - startLeft) * tailT;
                right = startRight + (endRight - startRight) * headT;
              } else {
                final double headT = const Interval(0.0, 0.50, curve: Curves.easeOutCubic).transform(t);
                final double tailT = const Interval(0.08, 0.58, curve: Curves.easeInOutCubic).transform(t);
                left = startLeft + (endLeft - startLeft) * headT;
                right = startRight + (endRight - startRight) * tailT;
              }

              final double currentWidth = (right - left).abs();
              final double stretchRatio = (currentWidth / slotWidth).clamp(1.0, 1.9);
              final double verticalSquash = (1.0 - (stretchRatio - 1.0) * 0.20).clamp(0.82, 1.0);

              double scaleX = 1.0;
              double scaleY = 1.0;

              if (_controller.isAnimating && _targetIndex != _previousIndex) {
                if (t <= 0.58) {
                  // Fase 1: Desplazamiento y estiramiento líquido inicial
                  scaleX = 1.0;
                  scaleY = verticalSquash;
                } else {
                  // Fase 2: Rebote marcado tipo gelatina (deformación armónica elástica perceptible)
                  final double settleT = (t - 0.58) / 0.42;
                  final double decay = (1.0 - settleT) * (1.0 - settleT * 0.75);
                  final double wave = math.sin(settleT * math.pi * 3.5);
                  final double jelly = wave * decay * 0.16; // 16% de rebote elástico (más visible y jugoso)
                  scaleX = 1.0 + jelly;
                  scaleY = 1.0 - (jelly * 0.82);
                }
              }

              return Stack(
                children: [
                  // CAPA 1 (BASE): LOGOS GIFS, ICONOS Y TEXTOS
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
                              scale: isSelected ? 1.35 : 1.0,
                              duration: const Duration(milliseconds: 240),
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
                                      duration: const Duration(milliseconds: 180),
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 10.2,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
                  ),

                  // CAPA 2 (FRENTE): BORDE LED CELESTE CON 90% DE TRANSPARENCIA (CRISTALINO)
                  Positioned(
                    left: left + 3,
                    width: (right - left - 6).clamp(slotWidth * 0.6, totalWidth),
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: Transform.scale(
                          scaleX: scaleX,
                          scaleY: scaleY,
                          child: Container(
                            height: 53.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.03), // ~97% transparente (ultra cristalino)
                              borderRadius: BorderRadius.circular(27),
                              border: Border.all(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.85), // Borde LED celeste definido
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
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