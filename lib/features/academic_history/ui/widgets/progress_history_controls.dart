import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

enum HistoryView {
  byArea('Por área', CupertinoIcons.square_grid_2x2),
  recent('Recientes', CupertinoIcons.clock);

  const HistoryView(this.label, this.icon);

  final String label;
  final IconData icon;
}

class ProgressHistoryViewPicker extends StatelessWidget {
  const ProgressHistoryViewPicker({
    super.key,
    required this.view,
    required this.onChanged,
  });

  final HistoryView view;
  final ValueChanged<HistoryView> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 4,
    children: [
      for (final option in HistoryView.values)
        Semantics(
          selected: option == view,
          child: TextButton.icon(
            onPressed: () => onChanged(option),
            style: TextButton.styleFrom(
              foregroundColor: option == view
                  ? Colors.white
                  : const Color(0xFF4B6175),
              backgroundColor: option == view
                  ? const Color(0xFF155D81)
                  : const Color(0xFFEAF1F6),
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(option.icon, size: 17),
            label: Text(option.label),
          ),
        ),
    ],
  );
}

class ProgressHistoryMore extends StatelessWidget {
  const ProgressHistoryMore({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
    child: TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF1D7256),
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(CupertinoIcons.chevron_down, size: 16),
      label: Text(isLoading ? 'Cargando…' : 'Mostrar más'),
    ),
  );
}

class ProgressHistoryHeading extends StatelessWidget {
  const ProgressHistoryHeading({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFE4F3F9),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Padding(
            padding: EdgeInsets.all(7),
            child: Icon(
              CupertinoIcons.waveform_path_ecg,
              size: 19,
              color: Color(0xFF116C95),
            ),
          ),
        ),
        const SizedBox(width: 9),
        const Flexible(
          child: Text(
            'Actividad',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -.55,
              color: Color(0xFF162F45),
            ),
          ),
        ),
      ],
    ),
  );
}
