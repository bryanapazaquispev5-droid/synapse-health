import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../model/cognito_auth_exception.dart';
import '../model/cognito_config.dart';

abstract interface class CognitoTransport {
  Future<Map<String, dynamic>> send(
    String operation,
    Map<String, dynamic> parameters,
  );
}

class CognitoHttpTransport implements CognitoTransport {
  CognitoHttpTransport(this.config);
  final CognitoConfig config;
  static const _timeout = Duration(seconds: 15);
  @override
  Future<Map<String, dynamic>> send(
    String operation,
    Map<String, dynamic> parameters,
  ) async {
    if (!config.isValid) {
      throw const CognitoAuthException(
        'configuration',
        'La autenticación aún no está configurada.',
      );
    }
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      return await _request(client, operation, parameters).timeout(_timeout);
    } on CognitoAuthException {
      rethrow;
    } on SocketException {
      throw const CognitoAuthException(
        'offline',
        'No hay conexión. Revisa tu conexión e inténtalo nuevamente.',
      );
    } on TimeoutException {
      throw const CognitoAuthException(
        'timeout',
        'La solicitud tardó demasiado. Inténtalo nuevamente.',
      );
    } catch (_) {
      throw const CognitoAuthException(
        'service_unavailable',
        'No se pudo completar la solicitud. Inténtalo nuevamente.',
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> _request(
    HttpClient client,
    String operation,
    Map<String, dynamic> parameters,
  ) async {
    final request = await client.postUrl(config.endpoint);
    request.followRedirects = false;
    request.headers.set('Content-Type', 'application/x-amz-json-1.1');
    request.headers.set(
      'X-Amz-Target',
      'AWSCognitoIdentityProviderService.$operation',
    );
    request.write(jsonEncode(parameters));
    final response = await request.close();
    final bytes = <int>[];
    await for (final chunk in response) {
      if (bytes.length + chunk.length > 65536) {
        throw const CognitoAuthException(
          'service_unavailable',
          'No se pudo completar la solicitud.',
        );
      }
      bytes.addAll(chunk);
    }
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException();
    }
    if (response.statusCode != 200) {
      throw CognitoAuthException.fromService(
        decoded['__type'] is String ? decoded['__type'] as String : 'Unknown',
      );
    }
    return decoded;
  }
}
