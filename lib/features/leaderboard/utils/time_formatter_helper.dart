// Bloque: Helper utilitario para formateo de tiempos y ritmo de quizzes
class TimeFormatterHelper {
  // Bloque: Formatea segundos a formato estándar "M:SS" (ej. 85s -> "1:25", 0s -> "0:00")
  static String formatSeconds(num totalSeconds) {
    final int secs = totalSeconds.toInt().clamp(0, 864000);
    final int minutes = secs ~/ 60;
    final int remainingSeconds = secs % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Bloque: Formatea el ritmo promedio por quiz (ej. 75.0 -> "1m 15s / quiz")
  static String formatPace(double averageSeconds) {
    if (averageSeconds <= 0) return '0s / quiz';
    final int secs = averageSeconds.round();
    final int minutes = secs ~/ 60;
    final int remaining = secs % 60;

    if (minutes == 0) return '${remaining}s / quiz';
    if (remaining == 0) return '${minutes}m / quiz';
    return '${minutes}m ${remaining}s / quiz';
  }
}
