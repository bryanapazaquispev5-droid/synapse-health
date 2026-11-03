// ============================================================================
// File: user_local_profile_service.dart
// Purpose: Local cache storage service for fast persistence of user profile data.
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Main definition of the [LocalUserProfile] class
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

/// Secure service for storing user data with hardware encryption (OWASP MASVS Section 9.2).
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
    // Block: Protected execution of an asynchronous operation
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
    // Block: Protected execution of an asynchronous operation
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
    // Block: Protected execution of an asynchronous operation
    try {
      // 1. Intentar lectura cifrada desde FlutterSecureStorage
      String? name = await _secureStorage.read(key: 'user_name_$uid');
      String? email = await _secureStorage.read(key: 'user_email_$uid');
      String? career = await _secureStorage.read(key: 'user_career_$uid');
      String? gender = await _secureStorage.read(key: 'user_gender_$uid');
      String? photoUrl = await _secureStorage.read(key: 'user_photo_url_$uid');
      String? photoBase64 = await _secureStorage.read(key: 'user_photo_base64_$uid');

      // 2. Transparent migration fallback from SharedPreferences if migration has not completed yet
      if (name == null || email == null) {
        // Block: Protected execution of an asynchronous operation
        try {
          final prefs = await SharedPreferences.getInstance();
          name ??= prefs.getString('user_name_$uid');
          email ??= prefs.getString('user_email_$uid');
          career ??= prefs.getString('user_career_$uid');
          gender ??= prefs.getString('user_gender_$uid');
          photoUrl ??= prefs.getString('user_photo_url_$uid');
          photoBase64 ??= prefs.getString('user_photo_base64_$uid');

          // Automatically migrate to encrypted storage
          if (name != null) await _secureStorage.write(key: 'user_name_$uid', value: name);
          if (email != null) await _secureStorage.write(key: 'user_email_$uid', value: email);
          if (career != null) await _secureStorage.write(key: 'user_career_$uid', value: career);
          if (gender != null) await _secureStorage.write(key: 'user_gender_$uid', value: gender);
          if (photoUrl != null) await _secureStorage.write(key: 'user_photo_url_$uid', value: photoUrl);
        } catch (_) {}
      }

      Uint8List? photoBytes;
      if (photoBase64 != null && photoBase64.isNotEmpty) {
        // Block: Protected execution of an asynchronous operation
        try {
          photoBytes = base64Decode(photoBase64);
        } catch (_) {}
      }

      return LocalUserProfile(
        name: name ?? fallbackName ?? 'Health Sciences Student',
        email: email ?? fallbackEmail ?? 'student@synapse.app',
        career: career ?? 'Human Medicine',
        gender: gender ?? 'Male',
        photoUrl: photoUrl ?? fallbackPhotoUrl,
        photoBytes: photoBytes,
      );
    } catch (_) {
      return LocalUserProfile(
        name: fallbackName ?? 'Health Sciences Student',
        email: fallbackEmail ?? 'student@synapse.app',
        career: 'Human Medicine',
        gender: 'Male',
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
