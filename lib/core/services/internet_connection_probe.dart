import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

/// A successful HTTPS response proves reachability, not Firestore availability.
/// Unlike DNS alone this cannot report a cached DNS record as Internet access.
Future<bool> probeInternetConnection({HttpClient? httpClient}) async {
  final client = httpClient ?? HttpClient();
  client.connectionTimeout = const Duration(seconds: 2);
  try {
    final request = await client
        .getUrl(Uri.https('www.gstatic.com', '/generate_204'))
        .timeout(const Duration(seconds: 2));
    request.followRedirects = false;
    final response = await request.close().timeout(const Duration(seconds: 2));
    await response.drain<void>().timeout(const Duration(seconds: 2));
    // A server error is still an Internet connection; UI request errors are separate.
    return true;
  } on IOException catch (error, stack) {
    developer.log(
      'Internet reachability check failed',
      name: 'ConnectivityService',
      error: error,
      stackTrace: stack,
    );
    return false;
  } on TimeoutException catch (error, stack) {
    developer.log(
      'Internet reachability check timed out',
      name: 'ConnectivityService',
      error: error,
      stackTrace: stack,
    );
    return false;
  } finally {
    client.close(force: true);
  }
}
