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
        'Confirm your email before signing in.',
      ),
      'CodeMismatchException' ||
      'ExpiredCodeException' => const CognitoAuthException(
        'invalid_code',
        'The code is invalid or has expired. Request a new one.',
      ),
      'TooManyRequestsException' ||
      'LimitExceededException' ||
      'TooManyFailedAttemptsException' => const CognitoAuthException(
        'rate_limited',
        'Wait a moment before trying again.',
      ),
      'InvalidPasswordException' => const CognitoAuthException(
        'invalid_password',
        'Your password does not meet the security requirements.',
      ),
      'NotAuthorizedException' ||
      'UserNotFoundException' ||
      'UsernameExistsException' => const CognitoAuthException(
        'authentication_failed',
        'Could not complete the request. Check your details or reset your password.',
      ),
      _ => const CognitoAuthException(
        'service_unavailable',
        'Could not complete the request. Try again.',
      ),
    };
  }
}

class CognitoSignOutResult {
  const CognitoSignOutResult({required this.remoteRevoked});
  final bool remoteRevoked;
}
