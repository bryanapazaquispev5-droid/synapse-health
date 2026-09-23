// ============================================================================
// Archivo: ios_top_banner.dart
// Propósito: Notificación tipo banner / cápsula superior estilo Apple HIG con animación suave y desenfoque translúcido.
// ============================================================================

import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Tipologías semánticas de notificación Apple HIG
enum IosBannerType { info, success, warning, error }

/// Orquestador para mostrar banners flotantes en la parte superior estilo iOS
class IosTopBanner {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String message,
    IosBannerType type = IosBannerType.info,
    IconData? icon,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    HapticFeedback.lightImpact();
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _IosTopBannerWidget(
        message: message,
        type: type,
        icon: icon,
        duration: duration,
        onDismiss: () {
          entry.remove();
          if (_currentEntry == entry) _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void info(BuildContext context, String msg, {IconData? icon}) =>
      show(context, message: msg, type: IosBannerType.info, icon: icon);
  static void success(BuildContext context, String msg, {IconData? icon}) =>
      show(context, message: msg, type: IosBannerType.success, icon: icon);
  static void warning(BuildContext context, String msg, {IconData? icon}) =>
      show(context, message: msg, type: IosBannerType.warning, icon: icon);
  static void error(BuildContext context, String msg, {IconData? icon}) =>
      show(context, message: msg, type: IosBannerType.error, icon: icon);

  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _IosTopBannerWidget extends StatefulWidget {
  final String message;
  final IosBannerType type;
  final IconData? icon;
  final Duration duration;
  final VoidCallback onDismiss;

  const _IosTopBannerWidget({
    required this.message,
    required this.type,
    required this.icon,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_IosTopBannerWidget> createState() => _IosTopBannerWidgetState();
}

class _IosTopBannerWidgetState extends State<_IosTopBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _offsetAnim;
  late Animation<double> _fadeAnim;
  final DateTime _createdAt = DateTime.now();
  Timer? _autoDismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
      reverseDuration: const Duration(milliseconds: 260),
    );

    final curve = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _offsetAnim = Tween<Offset>(
      begin: const Offset(0, -0.9),
      end: Offset.zero,
    ).animate(curve);

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _animController.forward();
    _autoDismissTimer = Timer(widget.duration, _handleDismiss);
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    if (_isDismissing) return;
    _isDismissing = true;
    _autoDismissTimer?.cancel();
    if (mounted) {
      await _animController.reverse();
      if (mounted) widget.onDismiss();
    }
  }

  Color _getIconColor() => switch (widget.type) {
        IosBannerType.info => AppColors.accent,
        IosBannerType.success => const Color(0xFF34C759),
        IosBannerType.warning => const Color(0xFFFF9500),
        IosBannerType.error => const Color(0xFFFF3B30),
      };

  IconData _getIcon() {
    if (widget.icon != null) return widget.icon!;
    return switch (widget.type) {
      IosBannerType.info => CupertinoIcons.info_circle_fill,
      IosBannerType.success => CupertinoIcons.checkmark_alt_circle_fill,
      IosBannerType.warning => CupertinoIcons.exclamationmark_triangle_fill,
      IosBannerType.error => CupertinoIcons.xmark_circle_fill,
    };
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final iconColor = _getIconColor();

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              if (DateTime.now().difference(_createdAt).inMilliseconds >= 100) {
                _handleDismiss();
              }
            },
          ),
        ),
        Positioned(
          top: topPadding + 10,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: SlideTransition(
              position: _offsetAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: GestureDetector(
                  onTap: _handleDismiss,
                  onVerticalDragUpdate: (details) {
                    if (details.primaryDelta! < -3) _handleDismiss();
                  },
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(color: Color(0x14000000), blurRadius: 20, spreadRadius: -2, offset: Offset(0, 8)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                                child: Icon(_getIcon(), size: 18, color: iconColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.message,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    height: 1.3,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
