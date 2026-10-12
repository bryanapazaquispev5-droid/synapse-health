import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import 'aws_api_contract.dart';
import 'aws_http_transport.dart';

export 'aws_api_contract.dart';

/// Disabled until an HTTPS deployment URL is explicitly configured.
/// Authentication failures never trigger a direct Firestore fallback.
class AwsApiClient {
  AwsApiClient({
    String baseUrl = const String.fromEnvironment('SYNAPSE_API_BASE_URL'),
    ApiTokenSupplier? tokenSupplier,
    ApiTransport? transport,
    String? Function()? sessionUidSupplier,
    this.timeout = const Duration(seconds: 15),
  }) : _baseUrl = _validateBaseUrl(baseUrl),
       _tokenSupplier = tokenSupplier ?? _firebaseToken,
       _transport = transport ?? apiHttpTransport,
       _sessionUidSupplier = sessionUidSupplier ?? _firebaseUid;

  final Uri? _baseUrl;
  final ApiTokenSupplier _tokenSupplier;
  final ApiTransport _transport;
  final String? Function() _sessionUidSupplier;
  final Duration timeout;

  bool get isConfigured => _baseUrl != null;
  bool get isEnabled => isConfigured;

  Future<Map<String, dynamic>> fetchOwnProfile() => _execute('GET');

  Future<Map<String, dynamic>> updateOwnProfile({
    required String field,
    required String value,
  }) {
    if (!{'name', 'career', 'gender'}.contains(field)) {
      throw ArgumentError('Unsupported profile field.');
    }
    return _execute('PATCH', body: jsonEncode({field: value}));
  }

  Future<Map<String, dynamic>> fetchHistoryPage({
    int limit = 50,
    String? cursor,
  }) {
    if (limit < 1 || limit > 50) throw ArgumentError('Invalid page limit');
    return _execute(
      'GET',
      path: 'api/v1/history',
      query: {'limit': '$limit', 'cursor': ?cursor},
    );
  }

  Future<Map<String, dynamic>> fetchHistoryEntry(String id) {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,2048}$').hasMatch(id)) {
      throw ArgumentError('Invalid history identifier');
    }
    return _execute('GET', path: 'api/v1/history/$id');
  }

  /// Authenticated relative REST request; never redirects to arbitrary URLs.
  Future<Map<String, dynamic>> requestData(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
  }) {
    if (!{'GET', 'POST', 'PATCH', 'DELETE'}.contains(method) ||
        !RegExp(r'^api/v1/[A-Za-z0-9_-]+(?:/[A-Za-z0-9_-]+)*$')
            .hasMatch(path) ||
        (body != null && !{'POST', 'PATCH'}.contains(method))) {
      throw ArgumentError('Invalid REST request.');
    }
    if (extraHeaders != null &&
        extraHeaders.entries.any(
          (entry) =>
              entry.key != 'If-Match' ||
              !RegExp(r'^"[1-9][0-9]*"$').hasMatch(entry.value),
        )) {
      throw ArgumentError('Invalid REST headers.');
    }
    return _execute(
      method,
      path: path,
      query: query,
      body: body == null ? null : jsonEncode(body),
      extraHeaders: extraHeaders,
    );
  }

  Future<Map<String, dynamic>> _execute(
    String method, {
    String? body,
    String path = 'v1/me/profile',
    Map<String, String>? query,
    Map<String, String>? extraHeaders,
  }) async {
    if (!isEnabled) throw const AwsApiException(ApiFailure.disabled);
    final uid = _sessionUidSupplier();
    try {
      var response = await _request(
        forceRefresh: false,
        method: method,
        body: body,
        uid: uid,
        path: path,
        query: query,
        extraHeaders: extraHeaders,
      );
      if (response.statusCode == 401) {
        response = await _request(
          forceRefresh: true,
          method: method,
          body: body,
          uid: uid,
          path: path,
          query: query,
          extraHeaders: extraHeaders,
        );
      }
      if (_sessionUidSupplier() != uid) {
        throw const AwsApiException(ApiFailure.unauthenticated);
      }
      if (response.statusCode == 204 && method == 'DELETE') return {};
      if (response.statusCode != 200 &&
          !(response.statusCode == 201 && method == 'POST')) {
        throw AwsApiException(_statusFailure(response.statusCode));
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> ||
          decoded['data'] is! Map<String, dynamic>) {
        throw const AwsApiException(ApiFailure.invalidResponse);
      }
      if (_sessionUidSupplier() != uid) {
        throw const AwsApiException(ApiFailure.unauthenticated);
      }
      return decoded['data'] as Map<String, dynamic>;
    } on AwsApiException {
      rethrow;
    } on FirebaseAuthException {
      throw const AwsApiException(ApiFailure.unauthenticated);
    } on TimeoutException {
      throw const AwsApiException(ApiFailure.timeout);
    } on SocketException {
      throw const AwsApiException(ApiFailure.offline);
    } on FormatException {
      throw const AwsApiException(ApiFailure.invalidResponse);
    } on HttpException {
      throw const AwsApiException(ApiFailure.unavailable);
    } on HandshakeException {
      throw const AwsApiException(ApiFailure.unavailable);
    }
  }

  Future<ApiResponse> _request({
    required bool forceRefresh,
    required String method,
    String? body,
    String? uid,
    required String path,
    Map<String, String>? query,
    Map<String, String>? extraHeaders,
  }) async {
    if (_sessionUidSupplier() != uid) {
      throw const AwsApiException(ApiFailure.unauthenticated);
    }
    final token = await _tokenSupplier(forceRefresh).timeout(timeout);
    if (token == null || token.isEmpty || _sessionUidSupplier() != uid) {
      throw const AwsApiException(ApiFailure.unauthenticated);
    }
    return _transport(
      _baseUrl!.resolve(path).replace(queryParameters: query),
      {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        if (body != null) 'Content-Type': 'application/json',
        ...?extraHeaders,
      },
      method,
      body,
    ).timeout(timeout);
  }

  static String? _firebaseUid() => FirebaseAuth.instance.currentUser?.uid;

  static Future<String?> _firebaseToken(bool forceRefresh) async {
    return FirebaseAuth.instance.currentUser?.getIdToken(forceRefresh);
  }

  static Uri? _validateBaseUrl(String value) {
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ArgumentError('API base URL must be an HTTPS URL.');
    }
    return uri.replace(
      path: uri.path.endsWith('/') ? uri.path : '${uri.path}/',
    );
  }

  static ApiFailure _statusFailure(int status) => switch (status) {
    400 || 413 || 415 || 422 => ApiFailure.invalidRequest,
    409 || 412 => ApiFailure.conflict,
    401 => ApiFailure.unauthenticated,
    403 => ApiFailure.forbidden,
    404 => ApiFailure.notFound,
    429 => ApiFailure.rateLimited,
    _ => ApiFailure.unavailable,
  };
}
