import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/services/connectivity_service.dart';
import 'package:synapse_health/core/theme/app_theme.dart';
import 'package:synapse_health/core/widgets/states/app_async_content.dart';

class FakeConnectivity extends Fake implements ConnectivityService {
  FakeConnectivity({this.online = true});
  bool online;
  final changes = StreamController<bool>.broadcast();
  @override
  bool get isOnline => online;
  @override
  Stream<bool> get isOnlineStream => changes.stream;
  @override
  Future<bool> checkConnection() async => online;
  void setOnline(bool value) {
    online = value;
    changes.add(value);
  }
}

Widget content(
  Stream<List<String>> stream,
  FakeConnectivity connection, {
  Stream<List<String>> Function()? retryStream,
}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: AppAsyncStreamBuilder<List<String>>(
        stream: stream,
        connectivity: connection,
        onRetryStream: retryStream,
        builder: (context, snapshot, retry) {
          if (!snapshot.hasData ||
              snapshot.data!.isEmpty ||
              snapshot.isAccessFailure) {
            return AppAsyncStatus(
              snapshot: snapshot,
              isEmpty: snapshot.data?.isEmpty ?? true,
              onRetry: retry,
              emptyTitle: 'Sin fichas',
              emptyMessage: 'No hay fichas disponibles.',
            );
          }
          return Column(
            children: [
              AppAsyncNotice(snapshot: snapshot, onRetry: retry),
              Text(snapshot.data!.join(',')),
              TextButton(onPressed: retry, child: const Text('Actualizar')),
            ],
          );
        },
      ),
    ),
  );
}
