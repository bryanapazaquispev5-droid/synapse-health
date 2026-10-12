import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'aws_api_contract.dart';

Future<ApiResponse> apiHttpTransport(
  Uri uri,
  Map<String, String> headers,
  String method,
  String? body,
) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    return await _readResponse(
      client,
      uri,
      headers,
      method,
      body,
    ).timeout(const Duration(seconds: 15));
  } finally {
    client.close(force: true);
  }
}

Future<ApiResponse> _readResponse(
  HttpClient client,
  Uri uri,
  Map<String, String> headers,
  String method,
  String? body,
) async {
  final request = await client.openUrl(method, uri);
  request.followRedirects = false;
  headers.forEach(request.headers.set);
  if (body != null) request.write(body);
  final response = await request.close();
  const maxBytes = 1024 * 1024;
  final bytes = <int>[];
  await for (final chunk in response) {
    if (bytes.length + chunk.length > maxBytes) {
      throw const AwsApiException(ApiFailure.invalidResponse);
    }
    bytes.addAll(chunk);
  }
  return ApiResponse(response.statusCode, utf8.decode(bytes));
}
