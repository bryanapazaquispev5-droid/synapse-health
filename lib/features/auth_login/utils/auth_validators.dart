// ============================================================================
// Archivo: auth_validators.dart
// Propósito: Funciones auxiliares y validadores de campos de texto (correo electronico, contrasenas seguras, etc.).
// ============================================================================

/// Validadores y utilidades de formato para autenticación
class AuthValidators {
  static final RegExp _emailRegExp = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Valida si una cadena cumple con el formato estándar de correo electrónico
  static bool isValidEmail(String email) {
    return _emailRegExp.hasMatch(email.trim().toLowerCase());
  }

  /// Verifica si la contraseña es idéntica al correo o al prefijo de usuario
  static bool isPasswordEqualToEmail(String password, String email) {
    final String passwordLower = password.toLowerCase().trim();
    final String emailLower = email.toLowerCase().trim();
    final String emailPrefix = emailLower.contains('@') ? emailLower.split('@')[0] : '';

    return passwordLower == emailLower || (emailPrefix.length >= 3 && passwordLower == emailPrefix);
  }

  /// Mensaje de error para códigos de excepción de Firebase Auth
  static String getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No existe ninguna cuenta registrada con este correo';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Contraseña o correo incorrecto';
      case 'email-already-in-use':
        return 'Este correo ya está registrado en el sistema. Inicia sesión o recupera tu clave.';
      case 'account-exists-with-different-credential':
        return 'Este correo ya está registrado con Google. Inicia sesión usando Google.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'invalid-email':
        return 'Formato de correo no válido';
      case 'too-many-requests':
        return 'Demasiados intentos. Tu acceso ha sido pausado temporalmente.';
      case 'admin-restricted-operation':
      case 'operation-not-allowed':
        return 'Para usar Invitado, activa el proveedor "Anónimo" en tu consola de Firebase.';
      default:
        return 'Error en autenticación ($errorCode)';
    }
  }
}
