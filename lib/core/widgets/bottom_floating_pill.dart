// ============================================================================
// Archivo: bottom_floating_pill.dart
// Propósito: Componente transversal reutilizable [bottom_floating_pill] para la barra de navegación flotante inferior.
// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'bottom_pill_indicator.dart';
import 'bottom_pill_item.dart';
import 'bottom_pill_nav_items.dart';

export 'bottom_pill_item.dart';

/// Componente de interfaz de usuario reutilizable [BottomFloatingPill].
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

/// Estado mutable y controlador del ciclo de vida reactivo para [BottomFloatingPill].
class _BottomFloatingPillState extends State<BottomFloatingPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _previousIndex = 0;
  int _targetIndex = 0;
  double _horizontalDragDistance = 0.0;

  // Bloque: Inicialización de controladores, listeners y estado local
  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _targetIndex = widget.currentIndex;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
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

  // Bloque: Liberación de recursos y controladores para evitar fugas de memoria
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index < 0 || index >= widget.items.length) return;
    if (index == _targetIndex && !_controller.isAnimating) return;
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _horizontalDragDistance = 0.0;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _horizontalDragDistance += details.primaryDelta ?? 0.0;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0.0;
    const double velocityThreshold = 100.0;
    const double distanceThreshold = 15.0;

    if (velocity > velocityThreshold || _horizontalDragDistance > distanceThreshold) {
      if (widget.currentIndex < widget.items.length - 1) {
        _onItemTapped(widget.currentIndex + 1);
      }
    } else if (velocity < -velocityThreshold || _horizontalDragDistance < -distanceThreshold) {
      if (widget.currentIndex > 0) {
        _onItemTapped(widget.currentIndex - 1);
      }
    }
    _horizontalDragDistance = 0.0;
  }

  void _onHorizontalDragCancel() {
    _horizontalDragDistance = 0.0;
  }

  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18, bottom: 16),
        child: GestureDetector(
          onHorizontalDragStart: _onHorizontalDragStart,
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          onHorizontalDragCancel: _onHorizontalDragCancel,
          behavior: HitTestBehavior.opaque,
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
                    scaleX = 1.0;
                    scaleY = verticalSquash;
                  } else {
                    final double settleT = (t - 0.58) / 0.42;
                    final double decay = (1.0 - settleT) * (1.0 - settleT * 0.75);
                    final double wave = math.sin(settleT * math.pi * 3.5);
                    final double jelly = wave * decay * 0.16;
                    scaleX = 1.0 + jelly;
                    scaleY = 1.0 - (jelly * 0.82);
                  }
                }

                return Stack(
                  children: [
                    BottomPillNavItems(
                      items: widget.items,
                      currentIndex: widget.currentIndex,
                      onItemTapped: _onItemTapped,
                    ),
                    BottomPillIndicator(
                      left: left,
                      right: right,
                      slotWidth: slotWidth,
                      totalWidth: totalWidth,
                      scaleX: scaleX,
                      scaleY: scaleY,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
