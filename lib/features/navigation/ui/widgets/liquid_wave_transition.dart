import 'package:flutter/material.dart';
import '../../../../core/services/app_settings_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'liquid_wave_clipper.dart';

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

class _LiquidWaveTransitionState extends State<LiquidWaveTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _previousIndex = 0;
  int _targetIndex = 0;
  bool _isForward = true;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _targetIndex = widget.currentIndex;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _previousIndex = _targetIndex;
          });
        }
      });
  }

  @override
  void didUpdateWidget(covariant LiquidWaveTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      if (!AppSettingsService().isLiquidWaveEnabled.value) {
        _previousIndex = widget.currentIndex;
        _targetIndex = widget.currentIndex;
        return;
      }
      _isForward = widget.currentIndex > _previousIndex;
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

  @override
  Widget build(BuildContext context) {
    final effectiveWaveColor = widget.waveColor ?? AppColors.accent;

    return ValueListenableBuilder<bool>(
      valueListenable: AppSettingsService().isLiquidWaveEnabled,
      builder: (context, isWaveEnabled, _) {
        if (!isWaveEnabled) {
          return widget.children[widget.currentIndex];
        }

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final bool isAnimating = _controller.isAnimating;

            if (!isAnimating && _previousIndex == _targetIndex) {
              return widget.children[_targetIndex];
            }

            final double progress = _controller.value;
            final Widget outgoingWidget = widget.children[_previousIndex];
            final Widget incomingWidget = widget.children[_targetIndex];

        // Parallax suave para que el contenido de la pantalla entrante se aprecie dentro de la ola
        final double screenWidth = MediaQuery.of(context).size.width;
        final double incomingSlide = _isForward
            ? (1.0 - progress) * (screenWidth * 0.35)
            : -(1.0 - progress) * (screenWidth * 0.35);
        final double outgoingSlide = _isForward
            ? -progress * (screenWidth * 0.12)
            : progress * (screenWidth * 0.12);

        return Stack(
          fit: StackFit.expand,
          children: [
            // CAPA 1: Pantalla saliente con parallax sutil
            Transform.translate(
              offset: Offset(outgoingSlide, 0),
              child: Material(
                color: AppColors.background,
                child: outgoingWidget,
              ),
            ),

            // CAPA 2: Pantalla entrante con máscara de ola líquida y deslizamiento coordinado
            ClipPath(
              clipper: LiquidWaveClipper(
                progress: progress,
                fromRight: _isForward,
              ),
              child: Material(
                color: AppColors.background,
                child: Transform.translate(
                  offset: Offset(incomingSlide, 0),
                  child: incomingWidget,
                ),
              ),
            ),

            // CAPA 3: Resplandor LED, sombra de elevación y cresta de ola líquida
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
