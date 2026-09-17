// ============================================================================
// Archivo: user_local_profile_service.dart
// Propósito: Servicio de almacenamiento local en cache para la persistencia rapida de datos del perfil de usuario.
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Definicion principal de la clase [LocalUserProfile]
class LocalUserProfile {
  final String name;
  final String email;
  final String career;
  final String gender;
  final String? photoUrl;
  final Uint8List? photoBytes;

  const LocalUserProfile({
    required this.name,
    required this.email,
    required this.career,
    required this.gender,
    this.photoUrl,
    this.photoBytes,
  });
}

/// Servicio seguro para almacenar datos del usuario con cifrado por hardware (OWASP MASVS Sección 9.2).
/// Utiliza Android Keystore (EncryptedSharedPreferences) e iOS Keychain.
class UserLocalProfileService {
  static final UserLocalProfileService _instance = UserLocalProfileService._internal();
  factory UserLocalProfileService() => _instance;
  UserLocalProfileService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  Future<void> saveProfile({
    required String uid,
    required String name,
    required String email,
    required String career,
    required String gender,
    String? photoUrl,
  }) async {
    try {
      if (name.isNotEmpty) await _secureStorage.write(key: 'user_name_$uid', value: name);
      if (email.isNotEmpty) await _secureStorage.write(key: 'user_email_$uid', value: email);
      if (career.isNotEmpty) await _secureStorage.write(key: 'user_career_$uid', value: career);
      if (gender.isNotEmpty) await _secureStorage.write(key: 'user_gender_$uid', value: gender);
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await _secureStorage.write(key: 'user_photo_url_$uid', value: photoUrl);
        _downloadAndCachePhoto(uid, photoUrl);
      }
    } catch (_) {}
  }

  Future<void> _downloadAndCachePhoto(String uid, String url) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url)).timeout(const Duration(seconds: 4));
      final response = await request.close().timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        if (bytes.isNotEmpty) {
          final base64Str = base64Encode(bytes);
          await _secureStorage.write(key: 'user_photo_base64_$uid', value: base64Str);
        }
      }
    } catch (_) {}
  }

  Future<LocalUserProfile> getProfile({
    required String uid,
    String? fallbackName,
    String? fallbackEmail,
    String? fallbackPhotoUrl,
  }) async {
    try {
      // 1. Intentar lectura cifrada desde FlutterSecureStorage
      String? name = await _secureStorage.read(key: 'user_name_$uid');
      String? email = await _secureStorage.read(key: 'user_email_$uid');
      String? career = await _secureStorage.read(key: 'user_career_$uid');
      String? gender = await _secureStorage.read(key: 'user_gender_$uid');
      String? photoUrl = await _secureStorage.read(key: 'user_photo_url_$uid');
      String? photoBase64 = await _secureStorage.read(key: 'user_photo_base64_$uid');

      // 2. Fallback de migración transparente desde SharedPreferences si aún no fue migrado
      if (name == null || email == null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          name ??= prefs.getString('user_name_$uid');
          email ??= prefs.getString('user_email_$uid');
          career ??= prefs.getString('user_career_$uid');
          gender ??= prefs.getString('user_gender_$uid');
          photoUrl ??= prefs.getString('user_photo_url_$uid');
          photoBase64 ??= prefs.getString('user_photo_base64_$uid');

          // Migrar automáticamente al almacenamiento cifrado
          if (name != null) await _secureStorage.write(key: 'user_name_$uid', value: name);
          if (email != null) await _secureStorage.write(key: 'user_email_$uid', value: email);
          if (career != null) await _secureStorage.write(key: 'user_career_$uid', value: career);
          if (gender != null) await _secureStorage.write(key: 'user_gender_$uid', value: gender);
          if (photoUrl != null) await _secureStorage.write(key: 'user_photo_url_$uid', value: photoUrl);
        } catch (_) {}
      }

      Uint8List? photoBytes;
      if (photoBase64 != null && photoBase64.isNotEmpty) {
        try {
          photoBytes = base64Decode(photoBase64);
        } catch (_) {}
      }

      return LocalUserProfile(
        name: name ?? fallbackName ?? 'Estudiante de Salud',
        email: email ?? fallbackEmail ?? 'estudiante@synapse.app',
        career: career ?? 'Medicina Humana',
        gender: gender ?? 'Hombre',
        photoUrl: photoUrl ?? fallbackPhotoUrl,
        photoBytes: photoBytes,
      );
    } catch (_) {
      return LocalUserProfile(
        name: fallbackName ?? 'Estudiante de Salud',
        email: fallbackEmail ?? 'estudiante@synapse.app',
        career: 'Medicina Humana',
        gender: 'Hombre',
        photoUrl: fallbackPhotoUrl,
      );
    }
  }

  static Future<Uint8List> consolidateHttpClientResponseBytes(HttpClientResponse response) async {
    final List<List<int>> chunks = [];
    await for (final chunk in response) {
      chunks.add(chunk);
    }
    final int totalLength = chunks.fold(0, (sum, chunk) => sum + chunk.length);
    final Uint8List bytes = Uint8List(totalLength);
    int offset = 0;
    for (final chunk in chunks) {
      bytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    return bytes;
  }
}
