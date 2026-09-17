// ============================================================================
// Archivo: google_logo_icon.dart
// Propósito: Widget visual modular [google_logo_icon] para el flujo y los formularios de inicio de sesión y registro.
// ============================================================================

import 'package:flutter/material.dart';

/// Componente de interfaz de usuario reutilizable [GoogleLogoIcon].
class GoogleLogoIcon extends StatelessWidget {
  final double size;

  const GoogleLogoIcon({super.key, this.size = 20});

  // Bloque: Renderizado reactivo del árbol de widgets principal
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
