import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../model/academic_history_entry.dart';

const _muted = Color(0xFF4B6175);
const _accent = Color(0xFF116C95);
const _rule = Color(0xFFD9E4ED);

class ProgressHistoryDayHeading extends StatelessWidget {
  const ProgressHistoryDayHeading({super.key, required this.day});

  static final _months = 'ene feb mar abr may jun jul ago sept oct nov dic'
      .split(' ');

  final DateTime? day;

  @override
  Widget build(BuildContext context) {
    final date = day;
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 3),
      child: Semantics(
        header: true,
        child: Row(
          children: [
            const Icon(CupertinoIcons.calendar, color: _accent, size: 14),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                date == null
                    ? 'Fecha no disponible'
                    : '${date.day} ${_months[date.month - 1]} ${date.year}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum HistoryOutcome {
  all('Todas'),
  correct('Correctas'),
  incorrect('Incorrectas');

  const HistoryOutcome(this.label);

  final String label;

  bool matches(AcademicHistoryEntry entry) => switch (this) {
    all => true,
    correct => entry.isCorrect,
    incorrect => !entry.isCorrect,
  };
}

class ProgressHistoryFilters extends StatelessWidget {
  const ProgressHistoryFilters({
    super.key,
    required this.areaIds,
    required this.areaLabels,
    required this.areaId,
    required this.outcome,
    required this.onAreaChanged,
    required this.onOutcomeChanged,
  });

  final Set<String> areaIds;
  final Map<String, String> areaLabels;
  final String? areaId;
  final HistoryOutcome outcome;
  final ValueChanged<String?> onAreaChanged;
  final ValueChanged<HistoryOutcome> onOutcomeChanged;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: _rule)),
    ),
    child: Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final option in HistoryOutcome.values)
          _OutcomeFilter(
            option: option,
            isSelected: option == outcome,
            onPressed: () => onOutcomeChanged(option),
          ),
        if (areaIds.length > 1)
          _HistoryAreaFilter(
            areaIds: areaIds,
            areaLabels: areaLabels,
            areaId: areaId,
            onAreaChanged: onAreaChanged,
          ),
      ],
    ),
  );
}

class _OutcomeFilter extends StatelessWidget {
  const _OutcomeFilter({
    required this.option,
    required this.isSelected,
    required this.onPressed,
  });

  final HistoryOutcome option;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: isSelected,
    child: DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected ? _color : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          shape: const RoundedRectangleBorder(),
          foregroundColor: isSelected ? _color : _muted,
          textStyle: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        icon: Icon(_icon, size: 14, color: _color),
        label: Text(option.label),
      ),
    ),
  );

  Color get _color => switch (option) {
    HistoryOutcome.all => _accent,
    HistoryOutcome.correct => const Color(0xFF1B7059),
    HistoryOutcome.incorrect => const Color(0xFFA24537),
  };

  IconData get _icon => switch (option) {
    HistoryOutcome.all => CupertinoIcons.line_horizontal_3_decrease,
    HistoryOutcome.correct => CupertinoIcons.checkmark_circle,
    HistoryOutcome.incorrect => CupertinoIcons.xmark_circle,
  };
}

class _HistoryAreaFilter extends StatelessWidget {
  const _HistoryAreaFilter({
    required this.areaIds,
    required this.areaLabels,
    required this.areaId,
    required this.onAreaChanged,
  });

  final Set<String> areaIds;
  final Map<String, String> areaLabels;
  final String? areaId;
  final ValueChanged<String?> onAreaChanged;

  @override
  Widget build(BuildContext context) {
    String label(String id) => areaLabels[id] ?? id;
    final options = areaIds.toList()
      ..sort((a, b) => label(a).compareTo(label(b)));
    return PopupMenuButton<String>(
      tooltip: 'Filtrar por área',
      initialValue: areaId ?? '',
      onSelected: (value) => onAreaChanged(value.isEmpty ? null : value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: '', child: Text('Todas las áreas')),
        for (final id in options)
          PopupMenuItem(value: id, child: Text(label(id))),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 48,
          minWidth: 48,
          maxWidth: 200,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  areaId == null ? 'Área' : label(areaId!),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: areaId == null ? _muted : _accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              const Icon(CupertinoIcons.chevron_down, color: _muted, size: 11),
            ],
          ),
        ),
      ),
    );
  }
}
