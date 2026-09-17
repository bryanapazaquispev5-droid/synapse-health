// ============================================================================
// Archivo: fcm_token_service.dart
// Propósito: Gestion, sincronizacion y almacenamiento seguro del token de dispositivo FCM en Firestore y almacenamiento local.
// ============================================================================

import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_constants.dart';

/// Servicio para administración, almacenamiento seguro y sincronización
/// de tokens FCM con Firestore (users/{uid}/fcm_tokens/{token}).
class FcmTokenService {
  static final FcmTokenService _instance = FcmTokenService._internal();
  factory FcmTokenService() => _instance;
  FcmTokenService._internal();

  static const String _secureKey = 'fcm_device_token';
  static const String _prefsKey = 'synapse_fcm_token';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  StreamSubscription<String>? _tokenRefreshSub;

  /// Obtiene el token FCM actual del dispositivo
  Future<String?> getFcmToken() async {
    try {
      final token = await _messaging.getToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      if (token != null) {
        await saveTokenLocally(token);
      }
      return token ?? await getCachedToken();
    } catch (e) {
      developer.log('Error obteniendo token FCM: $e', name: 'FcmTokenService');
      return await getCachedToken();
    }
  }

  /// Guarda el token en almacenamiento seguro y SharedPreferences de respaldo
  Future<void> saveTokenLocally(String token) async {
    try {
      await _secureStorage.write(key: _secureKey, value: token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, token);
    } catch (e) {
      developer.log('Error guardando token local: $e', name: 'FcmTokenService');
    }
  }

  /// Recupera el último token cacheado localmente
  Future<String?> getCachedToken() async {
    try {
      final secureVal = await _secureStorage.read(key: _secureKey);
      if (secureVal != null && secureVal.isNotEmpty) return secureVal;

      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefsKey);
    } catch (_) {
      return null;
    }
  }

  /// Sincroniza el token con la subcolección users/{uid}/fcm_tokens/{token}
  Future<void> syncTokenToFirestore(String uid, [String? explicitToken]) async {
    try {
      final token = explicitToken ?? await getFcmToken();
      if (token == null || token.trim().isEmpty) {
        developer.log('Token FCM nulo, se omite sincronización Firestore',
            name: 'FcmTokenService');
        return;
      }

      await saveTokenLocally(token);

      final tokenRef = _firestore
          .collection(AppConstants.FIRESTORE_USERS)
          .doc(uid)
          .collection('fcm_tokens')
          .doc(token);

      await tokenRef.set({
        'token': token,
        'platform': defaultTargetPlatform.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'isWeb': kIsWeb,
      }, SetOptions(merge: true));

      developer.log(
        'Token FCM sincronizado exitosamente para uid: $uid',
        name: 'FcmTokenService',
      );
    } catch (e, stack) {
      developer.log(
        'Fallo al sincronizar token FCM con Firestore: $e',
        name: 'FcmTokenService',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Observa la rotación automática de tokens FCM y actualiza Firestore
  void monitorTokenRefresh(String? Function() getCurrentUid) {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) async {
      developer.log(
        'FCM Token ha sido rotado por Google Play Services',
        name: 'FcmTokenService',
      );
      await saveTokenLocally(newToken);
      final uid = getCurrentUid();
      if (uid != null && uid.isNotEmpty) {
        await syncTokenToFirestore(uid, newToken);
      }
    });
  }

  /// Limpia el token al cerrar sesión del usuario para evitar notificaciones huérfanas
  Future<void> deleteTokenOnLogout(String uid) async {
    try {
      final token = await getCachedToken();
      if (token != null && token.isNotEmpty) {
        // Eliminar registro del token en la subcolección del usuario
        await _firestore
            .collection(AppConstants.FIRESTORE_USERS)
            .doc(uid)
            .collection('fcm_tokens')
            .doc(token)
            .delete()
            .timeout(const Duration(seconds: 5), onTimeout: () {});
      }

      // Desregistrar token en FCM
      await _messaging.deleteToken().timeout(
            const Duration(seconds: 5),
            onTimeout: () {},
          );

      // Limpiar memoria local
      await _secureStorage.delete(key: _secureKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);

      developer.log(
        'Token FCM purgado satisfactoriamente en logout para: $uid',
        name: 'FcmTokenService',
      );
    } catch (e) {
      developer.log(
        'Aviso al purgar token en logout (no crítico): $e',
        name: 'FcmTokenService',
      );
    }
  }

  /// Libera recursos y cancela suscripciones activas
  void dispose() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
  }
}
