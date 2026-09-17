// ============================================================================
// Archivo: fcm_token_service.dart
// Propósito: Gestión del token FCM, almacenamiento en caché y sincronización segura con la subcolección de usuarios en Firestore.
// ============================================================================

import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_constants.dart';

/// Servicio de arquitectura y lógica de negocio para [FcmTokenService].
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

  Future<String?> getFcmToken() async {
    // Bloque: Ejecución protegida de operación asíncrona
    try {
      final token = await _messaging.getToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      if (token != null) {
        await saveTokenLocally(token);
      }
      return token ?? await getCachedToken();
    // Bloque: Captura de excepciones y gestión de retroalimentación
    } catch (e) {
      developer.log('Error obteniendo token FCM: $e', name: 'FcmTokenService');
      return await getCachedToken();
    }
  }

  Future<void> saveTokenLocally(String token) async {
    // Bloque: Ejecución protegida de operación asíncrona
    try {
      await _secureStorage.write(key: _secureKey, value: token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, token);
    // Bloque: Captura de excepciones y gestión de retroalimentación
    } catch (e) {
      developer.log('Error guardando token local: $e', name: 'FcmTokenService');
    }
  }

  Future<String?> getCachedToken() async {
    // Bloque: Ejecución protegida de operación asíncrona
    try {
      final secureVal = await _secureStorage.read(key: _secureKey);
      if (secureVal != null && secureVal.isNotEmpty) return secureVal;

      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefsKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> syncTokenToFirestore(String uid, [String? explicitToken]) async {
    // Bloque: Ejecución protegida de operación asíncrona
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

  Future<void> deleteTokenOnLogout(String uid) async {
    // Bloque: Ejecución protegida de operación asíncrona
    try {
      final token = await getCachedToken();
      if (token != null && token.isNotEmpty) {
        await _firestore
            .collection(AppConstants.FIRESTORE_USERS)
            .doc(uid)
            .collection('fcm_tokens')
            .doc(token)
            .delete()
            .timeout(const Duration(seconds: 5), onTimeout: () {});
      }

      await _messaging.deleteToken().timeout(
            const Duration(seconds: 5),
            onTimeout: () {},
          );

      await _secureStorage.delete(key: _secureKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);

      developer.log(
        'Token FCM purgado satisfactoriamente en logout para: $uid',
        name: 'FcmTokenService',
      );
    // Bloque: Captura de excepciones y gestión de retroalimentación
    } catch (e) {
      developer.log(
        'Aviso al purgar token en logout (no crítico): $e',
        name: 'FcmTokenService',
      );
    }
  }

  // Bloque: Liberación de recursos y controladores para evitar fugas de memoria
  void dispose() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
  }
}
