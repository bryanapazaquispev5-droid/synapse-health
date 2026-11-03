// ============================================================================
// File: app_constants.dart
// Purpose: Defines global constants and local preferences.
// ============================================================================

/// Global Synapse Health application constants
/// Following the UPPER_SNAKE_CASE guidelines in the Architecture Master Guide (Section 5.6)
class AppConstants {
  // Application Names
  static const String APP_NAME = 'Synapse Health';
  static const String APP_TAGLINE = 'High-Performance Health Learning Platform';

  // Local Preferences (SharedPreferences Keys)
  static const String PREF_CREATED_ACCOUNTS = 'created_accounts_on_device';
  static const String PREF_FAILED_LOGIN_ATTEMPTS = 'failed_login_attempts';
  static const String PREF_LOGIN_LOCKOUT_UNTIL = 'login_lockout_until';

  // Security Timeouts and Limits
  static const int LOCKOUT_TIER_1_SECONDS = 30;
  static const int LOCKOUT_TIER_2_SECONDS = 60;
  static const int LOCKOUT_TIER_3_SECONDS = 120;
  static const int MAX_PASSWORD_MIN_LENGTH = 6;

  // Backward Compatibility Aliases
  static const String appName = APP_NAME;
  static const String appTagline = APP_TAGLINE;
  static const String prefCreatedAccounts = PREF_CREATED_ACCOUNTS;
  static const String prefFailedLoginAttempts = PREF_FAILED_LOGIN_ATTEMPTS;
  static const String prefLoginLockoutUntil = PREF_LOGIN_LOCKOUT_UNTIL;
  static const int lockoutTier1Seconds = LOCKOUT_TIER_1_SECONDS;
  static const int lockoutTier2Seconds = LOCKOUT_TIER_2_SECONDS;
  static const int lockoutTier3Seconds = LOCKOUT_TIER_3_SECONDS;
  static const int maxPasswordMinLength = MAX_PASSWORD_MIN_LENGTH;
}
