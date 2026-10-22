import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/auth_login/auth_provider_gate.dart';

void main() {
  Widget gate({
    String provider = 'firebase',
    bool staging = false,
    bool release = false,
  }) => MaterialApp(
    home: AuthProviderGate(
      firebaseChild: const Text('Existing Firebase'),
      provider: provider,
      stagingEnabled: staging,
      isRelease: release,
      cognitoBuilder: (useFirebase) => TextButton(
        onPressed: useFirebase,
        child: const Text('Staging Cognito'),
      ),
    ),
  );
  testWidgets('Firebase is the default provider', (tester) async {
    await tester.pumpWidget(gate());
    expect(find.text('Existing Firebase'), findsOneWidget);
    expect(find.text('Staging Cognito'), findsNothing);
  });
  testWidgets('Cognito requires explicit staging permission', (tester) async {
    await tester.pumpWidget(gate(provider: 'cognito'));
    expect(find.text('Acceso de prueba no disponible.'), findsOneWidget);
    expect(find.text('Staging Cognito'), findsNothing);
  });
  testWidgets('Cognito cannot become the release provider in this phase', (
    tester,
  ) async {
    await tester.pumpWidget(
      gate(provider: 'cognito', staging: true, release: true),
    );
    expect(find.text('Staging Cognito'), findsNothing);
    expect(find.text('Acceso de prueba no disponible.'), findsOneWidget);
  });
  testWidgets('opt-in non-release Cognito remains isolated from Firebase', (
    tester,
  ) async {
    await tester.pumpWidget(gate(provider: 'cognito', staging: true));
    expect(find.text('Staging Cognito'), findsOneWidget);
    expect(find.text('Existing Firebase'), findsNothing);
    await tester.tap(find.text('Staging Cognito'));
    await tester.pump();
    expect(find.text('Existing Firebase'), findsOneWidget);
  });
  testWidgets('unknown provider fails safely with Firebase recovery', (
    tester,
  ) async {
    await tester.pumpWidget(gate(provider: 'unexpected'));
    await tester.tap(find.text('Continuar con Firebase'));
    await tester.pump();
    expect(find.text('Existing Firebase'), findsOneWidget);
  });
}
