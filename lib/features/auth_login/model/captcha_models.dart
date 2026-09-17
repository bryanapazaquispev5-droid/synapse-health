// ============================================================================
// Archivo: captcha_models.dart
// Propósito: Modulo de verificacion humana con Captcha interactivo para proteger el registro e inicio de sesion.
// ============================================================================

import 'package:flutter/material.dart';

/// Modelo de un mosaico individual dentro del desafío reCAPTCHA
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

/// Modelo de un desafío de imágenes (ej. "semáforos", "ambulancias", "bicicletas")
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
