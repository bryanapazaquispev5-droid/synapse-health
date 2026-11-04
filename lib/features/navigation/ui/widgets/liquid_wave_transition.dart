// ============================================================================
// File: liquid_wave_transition.dart
// Purpose: Main navigation controller [liquid_wave_transition] con transiciones fluidas estilo liquid wave.
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../core/services/app_settings_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'liquid_wave_clipper.dart';

// Main definition of class [LiquidWaveTransition]
class LiquidWaveTransition extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;
  final Color? waveColor;

  const LiquidWaveTransition({
    super.key,
    required this.currentIndex,
    required this.children,
    this.waveColor,
  });

  @override
  State<LiquidWaveTransition> createState() => _LiquidWaveTransitionState();
}

// Reactive state and lifecycle management for [LiquidWaveTransition]
class _LiquidWaveTransitionState extends State<LiquidWaveTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _previousIndex = 0;
  int _targetIndex = 0;
  bool _isForward = true;
  late List<GlobalKey> _tabKeys;

  // Initialize component dependencies and local state
  // Section: Initialize controllers, listeners, and local state
  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _targetIndex = widget.currentIndex;
    _tabKeys = List.generate(
      widget.children.length,
      (i) => GlobalKey(debugLabel: 'liquid_wave_tab_$i'),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Section: Reactive notification and UI rebuild
          if (mounted) {
            setState(() {
              _previousIndex = _targetIndex;
            });
          }
        }
      });
  }

  @override
  void didUpdateWidget(covariant LiquidWaveTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != _tabKeys.length) {
      _tabKeys = List.generate(
        widget.children.length,
        (i) => GlobalKey(debugLabel: 'liquid_wave_tab_$i'),
      );
    }
    if (oldWidget.currentIndex != widget.currentIndex) {
      if (!AppSettingsService().isLiquidWaveEnabled.value) {
        _previousIndex = widget.currentIndex;
        _targetIndex = widget.currentIndex;
        return;
      }
      _isForward = widget.currentIndex > _targetIndex;
      _previousIndex = _targetIndex;
      _targetIndex = widget.currentIndex;
      _controller.forward(from: 0.0);
    }
  }

  // Release controllers and resources to prevent memory leaks
  // Section: Release resources and controllers to prevent memory leaks
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Reactive widget tree rendering
  // Section: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    final effectiveWaveColor = widget.waveColor ?? AppColors.accent;

    return ValueListenableBuilder<bool>(
      valueListenable: AppSettingsService().isLiquidWaveEnabled,
      builder: (context, isWaveEnabled, _) {
        if (!isWaveEnabled) {
          return IndexedStack(
            index: widget.currentIndex,
            children: List.generate(
              widget.children.length,
              (i) => KeyedSubtree(
                key: _tabKeys[i],
                child: widget.children[i],
              ),
            ),
          );
        }

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final bool isAnimating = _controller.isAnimating;
            final double progress = _controller.value;
            final double screenWidth = MediaQuery.of(context).size.width;

            final double incomingSlide = isAnimating
                ? (_isForward
                    ? (1.0 - progress) * (screenWidth * 0.35)
                    : -(1.0 - progress) * (screenWidth * 0.35))
                : 0.0;
            final double outgoingSlide = isAnimating
                ? (_isForward
                    ? -progress * (screenWidth * 0.12)
                    : progress * (screenWidth * 0.12))
                : 0.0;

            return Stack(
              fit: StackFit.expand,
              children: [
                // LAYER 0: Keep all other tabs Offstage to preserve their state and in-memory data
                for (int i = 0; i < widget.children.length; i++)
                  if (i != _targetIndex && (i != _previousIndex || !isAnimating))
                    Offstage(
                      offstage: true,
                      child: TickerMode(
                        enabled: false,
                        child: KeyedSubtree(
                          key: _tabKeys[i],
                          child: widget.children[i],
                        ),
                      ),
                    ),

                // LAYER 1: Outgoing screen with subtle parallax (visible only during animation)
                if (isAnimating && _previousIndex != _targetIndex)
                  Transform.translate(
                    offset: Offset(outgoingSlide, 0),
                    child: Material(
                      color: AppColors.background,
                      child: KeyedSubtree(
                        key: _tabKeys[_previousIndex],
                        child: widget.children[_previousIndex],
                      ),
                    ),
                  ),

                // LAYER 2: Incoming / active screen (kept at the same hierarchy position)
                ClipPath(
                  clipper: isAnimating
                      ? LiquidWaveClipper(
                          progress: progress,
                          fromRight: _isForward,
                        )
                      : null,
                  clipBehavior: isAnimating ? Clip.antiAlias : Clip.none,
                  child: Material(
                    color: AppColors.background,
                    child: Transform.translate(
                      offset: Offset(incomingSlide, 0),
                      child: KeyedSubtree(
                        key: _tabKeys[_targetIndex],
                        child: widget.children[_targetIndex],
                      ),
                    ),
                  ),
                ),

                // LAYER 3: LED glow, elevation shadow, and liquid wave crest
                if (isAnimating)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: LiquidWaveEdgePainter(
                          progress: progress,
                          fromRight: _isForward,
                          waveColor: effectiveWaveColor,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
