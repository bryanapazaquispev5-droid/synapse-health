// ============================================================================
// Archivo: app_constants.dart
// Propósito: Definicion de constantes globales del sistema, rutas, nombres de colecciones y configuraciones inmutables.
// ============================================================================

/// Constantes globales de la aplicación Synapse Health
/// Siguiendo los lineamientos de UPPER_SNAKE_CASE del Manual Maestro de Arquitectura (Sección 5.6)
class AppConstants {
  // Nombres de la Aplicación
  static const String APP_NAME = 'Synapse Health';
  static const String APP_TAGLINE = 'Plataforma de Alto Rendimiento en Salud';

  // Colecciones de Firestore
  static const String FIRESTORE_USERS = 'users';
  static const String FIRESTORE_MEDICAL_AREAS = 'medical_areas';
  static const String FIRESTORE_TOPICS = 'topics';
  static const String FIRESTORE_CHEATSHEETS = 'cheatsheets';
  static const String FIRESTORE_QUIZZES = 'quizzes';

  // Preferencias Locales (SharedPreferences Keys)
  static const String PREF_CREATED_ACCOUNTS = 'created_accounts_on_device';
  static const String PREF_FAILED_LOGIN_ATTEMPTS = 'failed_login_attempts';
  static const String PREF_LOGIN_LOCKOUT_UNTIL = 'login_lockout_until';

  // Tiempos y Límites de Seguridad
  static const int LOCKOUT_TIER_1_SECONDS = 30;
  static const int LOCKOUT_TIER_2_SECONDS = 60;
  static const int LOCKOUT_TIER_3_SECONDS = 120;
  static const int MAX_PASSWORD_MIN_LENGTH = 6;

  // Alias para compatibilidad hacia atrás
  static const String appName = APP_NAME;
  static const String appTagline = APP_TAGLINE;
  static const String firestoreUsers = FIRESTORE_USERS;
  static const String firestoreMedicalAreas = FIRESTORE_MEDICAL_AREAS;
  static const String firestoreTopics = FIRESTORE_TOPICS;
  static const String firestoreCheatsheets = FIRESTORE_CHEATSHEETS;
  static const String firestoreQuizzes = FIRESTORE_QUIZZES;
  static const String prefCreatedAccounts = PREF_CREATED_ACCOUNTS;
  static const String prefFailedLoginAttempts = PREF_FAILED_LOGIN_ATTEMPTS;
  static const String prefLoginLockoutUntil = PREF_LOGIN_LOCKOUT_UNTIL;
  static const int lockoutTier1Seconds = LOCKOUT_TIER_1_SECONDS;
  static const int lockoutTier2Seconds = LOCKOUT_TIER_2_SECONDS;
  static const int lockoutTier3Seconds = LOCKOUT_TIER_3_SECONDS;
  static const int maxPasswordMinLength = MAX_PASSWORD_MIN_LENGTH;
}
