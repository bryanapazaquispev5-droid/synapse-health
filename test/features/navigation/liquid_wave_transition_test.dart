// ============================================================================
// File: liquid_wave_transition_test.dart
// Purpose: Unit tests for state preservation in LiquidWaveTransition.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/services/app_settings_service.dart';
import 'package:synapse_health/features/navigation/ui/widgets/liquid_wave_transition.dart';

// Test widget for tracking initState and dispose calls
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

  testWidgets('LiquidWaveTransition does not destroy or reinitialize state when the wave completes', (tester) async {
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

    // Initially, Tab 0 and Tab 1 in Offstage mount only once
    expect(tab0Inits, 1);
    expect(tab1Inits, 1);
    expect(find.text('Tab0'), findsOneWidget);

    // Cambiar a Tab 1
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(); // Start animation

    // Advance halfway through the animation (350 ms)
    await tester.pump(const Duration(milliseconds: 350));
    // Neither Tab 0 nor Tab 1 should have been disposed
    expect(tab0Disposes, 0);
    expect(tab1Disposes, 0);

    // Complete the wave animation (700 ms total)
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // CRITICAL: Tab 1 must not be disposed or reset when the animation completes
    expect(tab1Inits, 1, reason: 'Tab 1 must not call initState twice when the wave completes');
    expect(tab1Disposes, 0, reason: 'Tab 1 must not be disposed when the animation completes');
    expect(tab0Disposes, 0, reason: 'Tab 0 must remain mounted in Offstage');
  });
}
