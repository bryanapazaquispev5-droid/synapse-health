// ============================================================================
// Archivo: app_theme.dart
// Propósito: Definicion del tema visual, paleta de colores medicos, tipografia y estilos globales basados en Apple Human Interface Guidelines.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Paleta de colores nativa de Apple iOS (Human Interface Guidelines)
/// Incluye constantes en UPPER_SNAKE_CASE según Manual Maestro de Arquitectura (Sección 5.6)
class AppColors {
  // Fondos oficiales de iOS (UPPER_SNAKE_CASE)
  static const Color BACKGROUND = Color(0xFFF2F2F7); // iOS System Grouped Background
  static const Color SURFACE = Color(0xFFFFFFFF);    // iOS Secondary System Grouped Background (Pure White Card)
  static const Color SECONDARY_BACKGROUND = Color(0xFFE5E5EA); // iOS System Gray 5

  // Colores principales de iOS
  static const Color PRIMARY = Color(0xFF000000);     // iOS Label (Pure Black/Dark Text)
  static const Color PRIMARY_DARK = Color(0xFF1C1C1E); // iOS Secondary System Fill
  static const Color ACCENT = Color(0xFF007AFF);      // iOS System Blue (Vibrant Apple Blue)
  
  // Bordes y separadores oficiales de iOS
  static const Color BORDER = Color(0xFFE5E5EA);       // iOS Separator / Border
  static const Color SEPARATOR = Color(0xFFD1D1D6);    // iOS Opaque Separator
  static const Color TEXT_MUTED = Color(0xFF8E8E93);    // iOS Secondary Label (System Gray)
  static const Color TEXT_TERTIARY = Color(0xFFAEAEB2); // iOS Tertiary Label

  // Colores semánticos Apple
  static const Color SYSTEM_GREEN = Color(0xFF34C759);
  static const Color SYSTEM_RED = Color(0xFFFF3B30);
  static const Color SYSTEM_ORANGE = Color(0xFFFF9500);
  static const Color SYSTEM_YELLOW = Color(0xFFFFCC00);
  static const Color SYSTEM_PURPLE = Color(0xFFAF52DE);
  static const Color SYSTEM_PINK = Color(0xFFFF2D55);
  static const Color SYSTEM_TEAL = Color(0xFF5AC8FA);
  static const Color SYSTEM_INDIGO = Color(0xFF5856D6);

  // Alias para compatibilidad hacia atrás
  static const Color background = BACKGROUND;
  static const Color surface = SURFACE;
  static const Color secondaryBackground = SECONDARY_BACKGROUND;
  static const Color primary = PRIMARY;
  static const Color primaryDark = PRIMARY_DARK;
  static const Color accent = ACCENT;
  static const Color border = BORDER;
  static const Color separator = SEPARATOR;
  static const Color textMuted = TEXT_MUTED;
  static const Color textTertiary = TEXT_TERTIARY;
  static const Color systemGreen = SYSTEM_GREEN;
  static const Color systemRed = SYSTEM_RED;
  static const Color systemOrange = SYSTEM_ORANGE;
  static const Color systemYellow = SYSTEM_YELLOW;
  static const Color systemPurple = SYSTEM_PURPLE;
  static const Color systemPink = SYSTEM_PINK;
  static const Color systemTeal = SYSTEM_TEAL;
  static const Color systemIndigo = SYSTEM_INDIGO;
}

// Definicion principal de la clase [AppTheme]
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
