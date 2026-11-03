// ============================================================================
// File: auth_validators.dart
// Purpose: Helper functions and text field validators (email, secure passwords, etc.).
// ============================================================================

/// Validation and formatting utilities for authentication
class AuthValidators {
  static final RegExp _emailRegExp = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp _cognitoPasswordRegExp = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{12,}$',
  );

  /// Checks whether a string matches the standard email format
  static bool isValidEmail(String email) {
    return _emailRegExp.hasMatch(email.trim().toLowerCase());
  }

  /// Checks whether the password matches the email or username prefix
  static bool isPasswordEqualToEmail(String password, String email) {
    final String passwordLower = password.toLowerCase().trim();
    final String emailLower = email.toLowerCase().trim();
    final String emailPrefix = emailLower.contains('@') ? emailLower.split('@')[0] : '';

    return passwordLower == emailLower || (emailPrefix.length >= 3 && passwordLower == emailPrefix);
  }

  /// Matches the AWS Cognito user pool's configured password policy.
  static bool meetsCognitoPasswordPolicy(String password) =>
      _cognitoPasswordRegExp.hasMatch(password);
}
