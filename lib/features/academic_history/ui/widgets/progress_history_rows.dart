import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/academic_history_entry.dart';
import 'history_catalog.dart';
import 'progress_history_filters.dart';

const _ink = Color(0xFF162F45);
const _muted = Color(0xFF506A7D);
const _rule = Color(0xFFDCE7EF);

Color _outcomeColor(bool isCorrect) =>
    isCorrect ? const Color(0xFF16776D) : const Color(0xFF9E4C47);

class ProgressHistoryRows extends StatelessWidget {
  const ProgressHistoryRows({
    super.key,
    required this.entries,
    required this.labels,
    required this.onOpen,
    this.showContext = true,
  });

  final List<AcademicHistoryEntry> entries;
  final HistoryLabels labels;
  final ValueChanged<AcademicHistoryEntry> onOpen;
  final bool showContext;

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
            showContext: showContext,
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
    required this.showContext,
  });

  final DateTime? day;
  final List<AcademicHistoryEntry> entries;
  final HistoryLabels labels;
  final ValueChanged<AcademicHistoryEntry> onOpen;
  final bool showContext;

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
              showContext: showContext,
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
    required this.showContext,
  });

  final AcademicHistoryEntry entry;
  final HistoryLabels labels;
  final bool connectsToNext;
  final VoidCallback onPressed;
  final bool showContext;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: connectsToNext
        ? const BoxDecoration(
            border: Border(bottom: BorderSide(color: _rule)),
          )
        : const BoxDecoration(),
    child: CupertinoButton(
      onPressed: onPressed,
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: _outcomeColor(entry.isCorrect).withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              entry.isCorrect ? CupertinoIcons.checkmark : CupertinoIcons.xmark,
              color: _outcomeColor(entry.isCorrect),
              size: 15,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _HistoryRowContent(
              entry: entry,
              labels: labels,
              showContext: showContext,
            ),
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
  const _HistoryRowContent({
    required this.entry,
    required this.labels,
    required this.showContext,
  });

  final AcademicHistoryEntry entry;
  final HistoryLabels labels;
  final bool showContext;

  @override
  Widget build(BuildContext context) {
    final date = entry.answeredAt?.toLocal();
    return DefaultTextStyle(
      style: const TextStyle(color: _muted, fontSize: 13, height: 1.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labels.quiz(entry),
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (showContext) ...[
            const SizedBox(height: 3),
            Text('${labels.area(entry)} · ${labels.topic(entry)}'),
          ],
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
              _metadata(
                CupertinoIcons.star_fill,
                '${entry.earnedStars}/${entry.maxStars} estrellas',
                const Color(0xFF8D651F),
              ),
              Text('Intento ${entry.attemptNumber}'),
              if (date != null)
                _metadata(
                  CupertinoIcons.clock,
                  MaterialLocalizations.of(context).formatTimeOfDay(
                    TimeOfDay.fromDateTime(date),
                    alwaysUse24HourFormat: true,
                  ),
                  _muted,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _metadata(IconData icon, String label, Color color) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(icon, size: 12, color: color),
    const SizedBox(width: 4),
    Flexible(child: Text(label)),
  ],
);

int compareHistoryDates(AcademicHistoryEntry left, AcademicHistoryEntry right) {
  final leftDate = left.answeredAt;
  final rightDate = right.answeredAt;
  if (leftDate == null) {
    return rightDate == null ? left.id.compareTo(right.id) : 1;
  }
  if (rightDate == null) return -1;
  final byDate = rightDate.compareTo(leftDate);
  return byDate == 0 ? left.id.compareTo(right.id) : byDate;
}
