import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/main.dart';

void main() {
  testWidgets('Hello World test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Hello World'), findsOneWidget);
  });
}