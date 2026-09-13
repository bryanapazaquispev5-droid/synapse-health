import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Servicio exclusivo para almacenar únicamente los datos del usuario localmente (Nombre, Email, Foto, Carrera, Género).
/// NINGÚN dato médico, chuleta, tema ni área médica se almacena aquí.
class UserLocalProfileService {
  static final UserLocalProfileService _instance = UserLocalProfileService._internal();
  factory UserLocalProfileService() => _instance;
  UserLocalProfileService._internal();

  Future<void> saveProfile({
    required String uid,
    required String name,
    required String email,
    required String career,
    required String gender,
    String? photoUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (name.isNotEmpty) await prefs.setString('user_name_$uid', name);
      if (email.isNotEmpty) await prefs.setString('user_email_$uid', email);
      if (career.isNotEmpty) await prefs.setString('user_career_$uid', career);
      if (gender.isNotEmpty) await prefs.setString('user_gender_$uid', gender);
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await prefs.setString('user_photo_url_$uid', photoUrl);
        // Descargar foto de Google y guardarla en Base64 para visualización offline
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
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_photo_base64_$uid', base64Str);
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
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name_$uid') ?? fallbackName ?? 'Estudiante de Salud';
      final email = prefs.getString('user_email_$uid') ?? fallbackEmail ?? 'estudiante@synapse.app';
      final career = prefs.getString('user_career_$uid') ?? 'Medicina Humana';
      final gender = prefs.getString('user_gender_$uid') ?? 'Hombre';
      final photoUrl = prefs.getString('user_photo_url_$uid') ?? fallbackPhotoUrl;

      Uint8List? photoBytes;
      final photoBase64 = prefs.getString('user_photo_base64_$uid');
      if (photoBase64 != null && photoBase64.isNotEmpty) {
        try {
          photoBytes = base64Decode(photoBase64);
        } catch (_) {}
      }

      return LocalUserProfile(
        name: name,
        email: email,
        career: career,
        gender: gender,
        photoUrl: photoUrl,
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
