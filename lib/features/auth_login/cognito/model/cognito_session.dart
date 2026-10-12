import 'dart:convert';

import 'cognito_auth_exception.dart';
import 'cognito_config.dart';

class CognitoSession {
  const CognitoSession({
    required this.sub,
    required this.accessToken,
    required this.idToken,
    required this.refreshToken,
    required this.expiresAt,
    this.email,
    this.name,
  });
  final String sub;
  final String? email;
  final String? name;
  final String accessToken;
  final String idToken;
  final String refreshToken;
  final DateTime expiresAt;
  bool isExpired(DateTime now) =>
      !expiresAt.isAfter(now.add(const Duration(seconds: 30)));
  String encode() => jsonEncode({
    'AccessToken': accessToken,
    'IdToken': idToken,
    'RefreshToken': refreshToken,
  });
  // This client-side shape check is not signature verification. AWS TLS authenticates
  // responses; the backend must independently verify every JWT cryptographically.
  factory CognitoSession.parse(
    Map<String, dynamic> result,
    CognitoConfig config,
    DateTime now, {
    String? previousRefreshToken,
    bool allowExpired = false,
  }) {
    try {
      final access = result['AccessToken'] as String;
      final id = result['IdToken'] as String;
      final refresh =
          (result['RefreshToken'] ?? previousRefreshToken) as String;
      final a = _claims(access), i = _claims(id);
      if (refresh.isEmpty ||
          a['iss'] != config.issuer ||
          i['iss'] != config.issuer ||
          a['token_use'] != 'access' ||
          i['token_use'] != 'id' ||
          a['client_id'] != config.clientId ||
          i['aud'] != config.clientId ||
          a['sub'] is! String ||
          (a['sub'] as String).isEmpty ||
          a['sub'] != i['sub'] ||
          a['exp'] is! int ||
          i['exp'] is! int) {
        throw const FormatException();
      }
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        ((a['exp'] as int) < (i['exp'] as int)
                ? a['exp'] as int
                : i['exp'] as int) *
            1000,
        isUtc: true,
      );
      if (!allowExpired && !expiry.isAfter(now)) {
        throw const FormatException();
      }
      return CognitoSession(
        sub: a['sub'] as String,
        accessToken: access,
        idToken: id,
        refreshToken: refresh,
        expiresAt: expiry,
        email: i['email'] is String ? i['email'] as String : null,
        name: i['name'] is String ? i['name'] as String : null,
      );
    } catch (_) {
      throw const CognitoAuthException(
        'invalid_session',
        'Tu sesión no es válida. Inicia sesión nuevamente.',
      );
    }
  }
  static Map<String, dynamic> _claims(String token) {
    final parts = token.split('.');
    if (parts.length != 3 || parts.any((p) => p.isEmpty)) {
      throw const FormatException();
    }
    final header = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[0]))),
    ) as Map<String, dynamic>;
    if (header['alg'] != 'RS256' ||
        header['kid'] is! String ||
        (header['kid'] as String).isEmpty) {
      throw const FormatException();
    }
    return jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    ) as Map<String, dynamic>;
  }
}
