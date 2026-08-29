import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/main.dart';

void main() {
  testWidgets('Carga inicial de la pantalla de Auth (Login y Registro)', (WidgetTester tester) async {
    await tester.pumpWidget(const SynapseHealthApp());
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('Registrarse'), findsOneWidget);
  });
}