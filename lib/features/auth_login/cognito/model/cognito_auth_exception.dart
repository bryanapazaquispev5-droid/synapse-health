class CognitoAuthException implements Exception {
  const CognitoAuthException(this.code, this.message);
  final String code;
  final String message;
  @override
  String toString() => 'CognitoAuthException($code)';
  static CognitoAuthException fromService(String type) {
    final code = type.split('#').last.split(':').first;
    return switch (code) {
      'UserNotConfirmedException' => const CognitoAuthException(
        'confirmation_required',
        'Confirma tu correo antes de iniciar sesión.',
      ),
      'CodeMismatchException' ||
      'ExpiredCodeException' => const CognitoAuthException(
        'invalid_code',
        'El código no es válido o ha vencido. Solicita uno nuevo.',
      ),
      'TooManyRequestsException' ||
      'LimitExceededException' ||
      'TooManyFailedAttemptsException' => const CognitoAuthException(
        'rate_limited',
        'Espera un momento antes de volver a intentarlo.',
      ),
      'InvalidPasswordException' => const CognitoAuthException(
        'invalid_password',
        'La contraseña no cumple los requisitos de seguridad.',
      ),
      'NotAuthorizedException' ||
      'UserNotFoundException' ||
      'UsernameExistsException' => const CognitoAuthException(
        'authentication_failed',
        'No se pudo completar la solicitud. Revisa tus datos o recupera tu contraseña.',
      ),
      _ => const CognitoAuthException(
        'service_unavailable',
        'No se pudo completar la solicitud. Inténtalo nuevamente.',
      ),
    };
  }
}

class CognitoSignOutResult {
  const CognitoSignOutResult({required this.remoteRevoked});
  final bool remoteRevoked;
}
