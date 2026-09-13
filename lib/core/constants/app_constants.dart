/// Constantes globales de la aplicación Synapse Health
/// Siguiendo los lineamientos de Dart Style Guide y Clean Architecture
class AppConstants {
  // Nombres de la Aplicación
  static const String appName = 'Synapse Health';
  static const String appTagline = 'Plataforma de Alto Rendimiento en Salud';

  // Colecciones de Firestore
  static const String firestoreUsers = 'users';
  static const String firestoreMedicalAreas = 'medical_areas';
  static const String firestoreTopics = 'topics';
  static const String firestoreCheatsheets = 'cheatsheets';
  static const String firestoreQuizzes = 'quizzes';

  // Preferencias Locales (SharedPreferences Keys)
  static const String prefCreatedAccounts = 'created_accounts_on_device';
  static const String prefFailedLoginAttempts = 'failed_login_attempts';
  static const String prefLoginLockoutUntil = 'login_lockout_until';

  // Tiempos y Límites de Seguridad
  static const int lockoutTier1Seconds = 30;
  static const int lockoutTier2Seconds = 60;
  static const int lockoutTier3Seconds = 120;
  static const int maxPasswordMinLength = 6;
}
