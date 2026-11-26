import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../model/academic_history_entry.dart';
import 'history_catalog.dart';
import 'progress_history_marks.dart';
import 'progress_history_rows.dart';

const _ink = Color(0xFF162F45);
const _muted = Color(0xFF506A7D);
const _blue = Color(0xFF116C95);
const _rule = Color(0xFFDCE7EF);

class ProgressHistoryGroups extends StatelessWidget {
  const ProgressHistoryGroups({
    super.key,
    required this.entries,
    required this.labels,
    required this.onOpen,
    this.onTopicOpened,
  });

  final List<AcademicHistoryEntry> entries;
  final HistoryLabels labels;
  final ValueChanged<AcademicHistoryEntry> onOpen;
  final ValueChanged<(String, String)>? onTopicOpened;

  @override
  Widget build(BuildContext context) {
    final groups = <String, Map<String, List<AcademicHistoryEntry>>>{};
    for (final entry in entries) {
      final topics = groups.putIfAbsent(entry.areaId, () => {});
      (topics[entry.topicId] ??= []).add(entry);
    }
    final areas = groups.entries.toList()
      ..sort(
        (left, right) =>
            _compareCatalog(_areaPosition(left.key), _areaPosition(right.key)),
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final area in areas)
          _HistoryDisclosure(
            key: ValueKey(area.key),
            title: _areaPosition(area.key).label,
            mark: progressHistoryMark(
              '${area.key} ${labels.areas[area.key] ?? ''}',
              true,
            ),
            isArea: true,
            child: _HistoryTopics(
              areaId: area.key,
              topics: area.value,
              labels: labels,
              onOpen: onOpen,
              onTopicOpened: onTopicOpened,
            ),
          ),
      ],
    );
  }

  _CatalogPosition _areaPosition(String id) => (
    order: labels.areaOrder[id],
    label: labels.areas[id] ?? 'Área no disponible',
    id: id,
  );
}

class _HistoryTopics extends StatelessWidget {
  const _HistoryTopics({
    required this.areaId,
    required this.topics,
    required this.labels,
    required this.onOpen,
    required this.onTopicOpened,
  });

  final String areaId;
  final Map<String, List<AcademicHistoryEntry>> topics;
  final HistoryLabels labels;
  final ValueChanged<AcademicHistoryEntry> onOpen;
  final ValueChanged<(String, String)>? onTopicOpened;

  @override
  Widget build(BuildContext context) {
    final sortedTopics = topics.entries.toList()
      ..sort(
        (left, right) => _compareCatalog(
          _topicPosition(left.key),
          _topicPosition(right.key),
        ),
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final topic in sortedTopics)
          _HistoryDisclosure(
            key: ValueKey(topic.key),
            title: _topicPosition(topic.key).label,
            mark: progressHistoryMark(
              '${topic.key} ${labels.topics[(areaId, topic.key)] ?? ''}',
              false,
            ),
            isArea: false,
            onOpened: () => onTopicOpened?.call((areaId, topic.key)),
            child: ProgressHistoryRows(
              entries: topic.value,
              labels: labels,
              showContext: false,
              onOpen: onOpen,
            ),
          ),
      ],
    );
  }

  _CatalogPosition _topicPosition(String id) => (
    order: labels.topicOrder[(areaId, id)],
    label: labels.topics[(areaId, id)] ?? 'Tema no disponible',
    id: id,
  );
}

typedef _CatalogPosition = ({int? order, String label, String id});

int _compareCatalog(_CatalogPosition left, _CatalogPosition right) {
  final leftOrder = left.order;
  final rightOrder = right.order;
  if (leftOrder != rightOrder) {
    if (leftOrder == null) return 1;
    if (rightOrder == null) return -1;
    return leftOrder.compareTo(rightOrder);
  }
  final byLabel = left.label.toLowerCase().compareTo(right.label.toLowerCase());
  return byLabel == 0 ? left.id.compareTo(right.id) : byLabel;
}

class _HistoryDisclosure extends StatefulWidget {
  const _HistoryDisclosure({
    super.key,
    required this.title,
    required this.isArea,
    required this.mark,
    required this.child,
    this.onOpened,
  });

  final String title;
  final bool isArea;
  final (IconData, Color) mark;
  final Widget child;
  final VoidCallback? onOpened;

  @override
  State<_HistoryDisclosure> createState() => _HistoryDisclosureState();
}

class _HistoryDisclosureState extends State<_HistoryDisclosure> {
  bool _isExpanded = false;

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) widget.onOpened?.call();
  }

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 210);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          expanded: _isExpanded,
          child: TextButton(
            onPressed: _toggle,
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              alignment: AlignmentDirectional.centerStart,
              padding: const EdgeInsets.symmetric(vertical: 9),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const RoundedRectangleBorder(),
              foregroundColor: _ink,
            ),
            child: Row(
              children: [
                Container(
                  width: widget.isArea ? 34 : 27,
                  height: widget.isArea ? 34 : 27,
                  decoration: BoxDecoration(
                    color: widget.mark.$2.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    widget.mark.$1,
                    size: widget.isArea ? 18 : 15,
                    color: widget.mark.$2,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: widget.isArea ? 17 : 15,
                      fontWeight: widget.isArea
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedRotation(
                  turns: _isExpanded ? .5 : 0,
                  duration: duration,
                  child: Icon(
                    CupertinoIcons.chevron_down,
                    size: 12,
                    color: _isExpanded ? _blue : _muted,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: _rule),
        AnimatedSize(
          duration: duration,
          alignment: Alignment.topCenter,
          curve: Curves.easeOutCubic,
          child: _isExpanded
              ? Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: widget.isArea ? 16 : 12,
                    top: widget.isArea ? 0 : 7,
                    bottom: 6,
                  ),
                  child: widget.child,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
