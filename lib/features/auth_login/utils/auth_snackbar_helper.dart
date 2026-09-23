// ============================================================================
// Archivo: auth_snackbar_helper.dart
// Propósito: Funciones auxiliares y validadores de campos de texto (correo electronico, contrasenas seguras, etc.).
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../core/widgets/ios_top_banner.dart';

// Definicion principal de la clase [AuthSnackbarHelper]
class AuthSnackbarHelper {
  static void show(BuildContext context, String message, {bool isError = false}) {
    if (isError) {
      IosTopBanner.error(context, message);
    } else {
      IosTopBanner.success(context, message);
    }
  }
}
