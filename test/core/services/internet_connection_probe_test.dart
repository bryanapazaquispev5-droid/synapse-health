import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/services/internet_connection_probe.dart';

class ProbeClient extends Fake implements HttpClient {
  ProbeClient({this.error, this.statusCode = 204});
  final Object? error;
  final int statusCode;
  bool closed = false;
  Uri? requested;
  @override
  set connectionTimeout(Duration? timeout) {}
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    requested = url;
    if (error != null) throw error!;
    return ProbeRequest(statusCode);
  }

  @override
  void close({bool force = false}) {
    closed = true;
  }
}

class ProbeRequest extends Fake implements HttpClientRequest {
  ProbeRequest(this.statusCode);
  final int statusCode;
  @override
  bool followRedirects = true;
  @override
  Future<HttpClientResponse> close() async => ProbeResponse(statusCode);
}

class ProbeResponse extends Fake implements HttpClientResponse {
  ProbeResponse(this.statusCode);
  @override
  final int statusCode;
  @override
  Future<E> drain<E>([E? futureValue]) => Future<E>.value(futureValue);
}

void main() {
  for (final status in [204, 503]) {
    test(
      'HTTPS response $status proves connection without implying server health',
      () async {
        final client = ProbeClient(statusCode: status);
        expect(await probeInternetConnection(httpClient: client), isTrue);
        expect(client.requested?.scheme, 'https');
        expect(client.closed, isTrue);
      },
    );
  }
  for (final error in [
    const SocketException('no network'),
    TimeoutException('timeout'),
  ]) {
    test(
      '${error.runtimeType} reports unreachable Internet and closes client',
      () async {
        final client = ProbeClient(error: error);
        expect(await probeInternetConnection(httpClient: client), isFalse);
        expect(client.closed, isTrue);
      },
    );
  }
  test(
    'unexpected programming failures are propagated, not reported as offline',
    () async {
      final client = ProbeClient(error: StateError('unexpected'));
      await expectLater(
        probeInternetConnection(httpClient: client),
        throwsStateError,
      );
      expect(client.closed, isTrue);
    },
  );
}
