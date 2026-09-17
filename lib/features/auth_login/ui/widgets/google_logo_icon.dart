// ============================================================================
// Archivo: google_logo_icon.dart
// Propósito: Widget visual de soporte [google_logo_icon] para el formulario y flujo de inicio de sesion.
// ============================================================================

import 'package:flutter/material.dart';

// Definicion principal de la clase [GoogleLogoIcon]
class GoogleLogoIcon extends StatelessWidget {
  final double size;

  const GoogleLogoIcon({super.key, this.size = 20});

  // Renderizado reactivo del arbol de widgets
  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://developers.google.com/identity/images/g-logo.png',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.g_mobiledata_rounded,
        size: size * 1.5,
        color: const Color(0xFF4285F4),
      ),
    );
  }
}
