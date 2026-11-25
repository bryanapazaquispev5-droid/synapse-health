import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/academic_history_entry.dart';
import 'history_catalog.dart';
import 'progress_history_filters.dart';

const _ink = Color(0xFF182520);
const _muted = Color(0xFF52625A);
const _rule = Color(0xFFDFE5DE);

Color _outcomeColor(bool isCorrect) =>
    isCorrect ? const Color(0xFF1D7256) : const Color(0xFF884533);

class ProgressHistoryRows extends StatelessWidget {
  const ProgressHistoryRows({
    super.key,
    required this.entries,
    required this.labels,
    required this.onOpen,
  });

  final List<AcademicHistoryEntry> entries;
  final HistoryLabels labels;
  final ValueChanged<AcademicHistoryEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    final days = <DateTime?, List<AcademicHistoryEntry>>{};
    for (final entry in entries) {
      final local = entry.answeredAt?.toLocal();
      final day = local == null ? null : DateUtils.dateOnly(local);
      (days[day] ??= []).add(entry);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in days.entries)
          _HistoryDay(
            key: ValueKey(group.key),
            day: group.key,
            entries: group.value,
            labels: labels,
            onOpen: onOpen,
          ),
      ],
    );
  }
}

class _HistoryDay extends StatelessWidget {
  const _HistoryDay({
    super.key,
    required this.day,
    required this.entries,
    required this.labels,
    required this.onOpen,
  });

  final DateTime? day;
  final List<AcademicHistoryEntry> entries;
  final HistoryLabels labels;
  final ValueChanged<AcademicHistoryEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProgressHistoryDayHeading(day: day),
        for (var index = 0; index < entries.length; index++)
          TweenAnimationBuilder<double>(
            key: ValueKey(entries[index].id),
            duration: reduceMotion
                ? Duration.zero
                : Duration(milliseconds: 180 + index.clamp(0, 4) * 30),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
            child: _HistoryRow(
              entry: entries[index],
              labels: labels,
              connectsToNext: index < entries.length - 1,
              onPressed: () => onOpen(entries[index]),
            ),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 5 * (1 - value)),
                child: child,
              ),
            ),
          ),
        const SizedBox(height: 9),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.entry,
    required this.labels,
    required this.connectsToNext,
    required this.onPressed,
  });

  final AcademicHistoryEntry entry;
  final HistoryLabels labels;
  final bool connectsToNext;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: connectsToNext
        ? const BoxDecoration(
            border: Border(bottom: BorderSide(color: _rule)),
          )
        : const BoxDecoration(),
    child: CupertinoButton(
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(
              entry.isCorrect ? CupertinoIcons.checkmark : CupertinoIcons.xmark,
              color: _outcomeColor(entry.isCorrect),
              size: 15,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: _HistoryRowContent(entry: entry, labels: labels),
          ),
          const Padding(
            padding: EdgeInsetsDirectional.only(start: 8, top: 4),
            child: Icon(CupertinoIcons.chevron_right, size: 12, color: _muted),
          ),
        ],
      ),
    ),
  );
}

class _HistoryRowContent extends StatelessWidget {
  const _HistoryRowContent({required this.entry, required this.labels});

  final AcademicHistoryEntry entry;
  final HistoryLabels labels;

  @override
  Widget build(BuildContext context) {
    final date = entry.answeredAt?.toLocal();
    return DefaultTextStyle(
      style: const TextStyle(color: _muted, fontSize: 12, height: 1.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labels.quiz(entry),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${labels.area(entry)} · ${labels.topic(entry)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 9,
            runSpacing: 4,
            children: [
              Text(
                entry.isCorrect ? 'Correcta' : 'Incorrecta',
                style: TextStyle(
                  color: _outcomeColor(entry.isCorrect),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text('${entry.earnedStars}/${entry.maxStars} estrellas'),
              Text('Intento ${entry.attemptNumber}'),
              if (date != null)
                Text(
                  MaterialLocalizations.of(context).formatTimeOfDay(
                    TimeOfDay.fromDateTime(date),
                    alwaysUse24HourFormat: true,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
