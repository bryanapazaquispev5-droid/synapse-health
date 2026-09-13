import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Paleta de colores nativa de Apple iOS (Human Interface Guidelines)
class AppColors {
  // Fondos oficiales de iOS
  static const Color background = Color(0xFFF2F2F7); // iOS System Grouped Background
  static const Color surface = Color(0xFFFFFFFF);    // iOS Secondary System Grouped Background (Pure White Card)
  static const Color secondaryBackground = Color(0xFFE5E5EA); // iOS System Gray 5

  // Colores principales de iOS
  static const Color primary = Color(0xFF000000);     // iOS Label (Pure Black/Dark Text)
  static const Color primaryDark = Color(0xFF1C1C1E); // iOS Secondary System Fill
  static const Color accent = Color(0xFF007AFF);      // iOS System Blue (Vibrant Apple Blue)
  
  // Bordes y separadores oficiales de iOS
  static const Color border = Color(0xFFE5E5EA);       // iOS Separator / Border
  static const Color separator = Color(0xFFD1D1D6);    // iOS Opaque Separator
  static const Color textMuted = Color(0xFF8E8E93);    // iOS Secondary Label (System Gray)
  static const Color textTertiary = Color(0xFFAEAEB2); // iOS Tertiary Label

  // Colores semánticos Apple
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemYellow = Color(0xFFFFCC00);
  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemPink = Color(0xFFFF2D55);
  static const Color systemTeal = Color(0xFF5AC8FA);
  static const Color systemIndigo = Color(0xFF5856D6);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        surfaceContainerHighest: AppColors.background,
      ),
      fontFamily: '.SF Pro Text', // Native iOS font cascade
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: AppColors.accent,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: AppColors.surface,
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.primary,
          navLargeTitleTextStyle: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            color: AppColors.primary,
            fontFamily: '.SF Pro Display',
          ),
          navTitleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: AppColors.primary,
            fontFamily: '.SF Pro Text',
          ),
        ),
      ),
    );
  }
}

/// Transición de página fluida estilo Apple/OneUI sin parpadeos de barrera ni destellos
class AppPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  AppPageRoute({required this.child, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0.0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 180),
        );
}