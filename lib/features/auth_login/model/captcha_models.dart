// ============================================================================
// Archivo: captcha_models.dart
// Propósito: Módulo de verificación humana con Captcha interactivo para mitigar accesos automatizados no autorizados.
// ============================================================================

import 'package:flutter/material.dart';

/// Componente de interfaz de usuario reutilizable [CaptchaTile].
class CaptchaTile {
  final String imageUrl;
  final IconData fallbackIcon;
  final String label;

  const CaptchaTile({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.label,
  });
}

/// Componente de interfaz de usuario reutilizable [CaptchaChallenge].
class CaptchaChallenge {
  final String keyword;
  final String subtitle;
  final List<CaptchaTile> tiles;
  final Set<int> correctIndices;

  const CaptchaChallenge({
    required this.keyword,
    this.subtitle = 'Haz clic en Verificar cuando no quede ninguna.',
    required this.tiles,
    required this.correctIndices,
  });
}
