// ============================================================================
// File: captcha_models.dart
// Purpose: Interactive CAPTCHA verification module to protect sign-up and sign-in.
// ============================================================================

import 'package:flutter/material.dart';

/// Model for an individual tile in the reCAPTCHA challenge
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

/// Model for an image challenge (e.g., "traffic lights," "ambulances," or "bicycles")
class CaptchaChallenge {
  final String keyword;
  final String subtitle;
  final List<CaptchaTile> tiles;
  final Set<int> correctIndices;

  const CaptchaChallenge({
    required this.keyword,
    this.subtitle = 'Click Verify when none remain.',
    required this.tiles,
    required this.correctIndices,
  });
}
