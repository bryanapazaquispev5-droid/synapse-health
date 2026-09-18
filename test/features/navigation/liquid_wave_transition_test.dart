// ============================================================================
// Archivo: liquid_wave_transition_test.dart
// Propósito: Pruebas unitarias para verificar la preservación de estado en LiquidWaveTransition.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/services/app_settings_service.dart';
import 'package:synapse_health/features/navigation/ui/widgets/liquid_wave_transition.dart';

// Widget de prueba para rastrear llamadas a initState y dispose
class _StatefulCounterTab extends StatefulWidget {
  final String label;
  final VoidCallback onInit;
  final VoidCallback onDispose;

  const _StatefulCounterTab({
    required this.label,
    required this.onInit,
    required this.onDispose,
  });

  @override
  State<_StatefulCounterTab> createState() => _StatefulCounterTabState();
}

class _StatefulCounterTabState extends State<_StatefulCounterTab> {
  int count = 0;

  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.label),
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () => setState(() => count++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}

void main() {
  setUp(() {
    AppSettingsService().setLiquidWaveEnabled(true);
  });

  testWidgets('LiquidWaveTransition no destruye ni reinicializa el estado al completar la ola', (tester) async {
    int tab0Inits = 0;
    int tab0Disposes = 0;
    int tab1Inits = 0;
    int tab1Disposes = 0;

    int currentIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: LiquidWaveTransition(
                currentIndex: currentIndex,
                children: [
                  _StatefulCounterTab(
                    label: 'Tab0',
                    onInit: () => tab0Inits++,
                    onDispose: () => tab0Disposes++,
                  ),
                  _StatefulCounterTab(
                    label: 'Tab1',
                    onInit: () => tab1Inits++,
                    onDispose: () => tab1Disposes++,
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => setState(() => currentIndex = 1),
              ),
            );
          },
        ),
      ),
    );

    // Inicialmente Tab 0 se monta y Tab 1 en Offstage se monta una sola vez
    expect(tab0Inits, 1);
    expect(tab1Inits, 1);
    expect(find.text('Tab0'), findsOneWidget);

    // Cambiar a Tab 1
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(); // Inicia animación

    // Avanzar a la mitad de la animación (350ms)
    await tester.pump(const Duration(milliseconds: 350));
    // Ni Tab0 ni Tab1 deben haberse destruido
    expect(tab0Disposes, 0);
    expect(tab1Disposes, 0);

    // Completar la animación de la ola (700ms total)
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // CRÍTICO: Al terminar la animación, Tab 1 NO debe haberse destruido ni reiniciado
    expect(tab1Inits, 1, reason: 'Tab1 no debe llamar initState dos veces al completar la ola');
    expect(tab1Disposes, 0, reason: 'Tab1 no debe ser disposed al completar la animación');
    expect(tab0Disposes, 0, reason: 'Tab0 debe mantenerse en memoria en Offstage');
  });
}
