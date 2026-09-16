import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static final FirebaseCrashlytics _instance = FirebaseCrashlytics.instance;

  static Future<void> initialize() async {
    // Enable crashlytics collection (always enabled in release, optionally enabled in debug)
    await _instance.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Capture Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      } else {
        _instance.recordFlutterFatalError(details);
      }
    };

    // Capture uncaught asynchronous errors
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      if (kDebugMode) {
        debugPrint('Uncaught async error: $error\n$stack');
      } else {
        _instance.recordError(error, stack, fatal: true);
      }
      return true;
    };
  }

  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool isFatal = false,
  }) async {
    await _instance.recordError(
      exception,
      stack,
      reason: reason,
      fatal: isFatal,
    );
  }

  static Future<void> log(String message) async {
    await _instance.log(message);
  }

  static Future<void> setUserId(String userId) async {
    await _instance.setUserIdentifier(userId);
  }

  static Future<void> setCustomKey(String key, Object value) async {
    await _instance.setCustomKey(key, value);
  }
}
