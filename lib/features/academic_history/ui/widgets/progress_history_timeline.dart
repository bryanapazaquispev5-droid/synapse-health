import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/services/connectivity_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/states/app_async_content.dart';
import '../../api/academic_history_repository.dart';
import '../../model/academic_history_entry.dart';
import '../academic_history_screen.dart';
import 'history_catalog.dart';
import 'progress_history_controls.dart';
import 'progress_history_groups.dart';
import 'progress_history_filters.dart';
import 'progress_history_rows.dart';

class ProgressHistoryTimeline extends StatefulWidget {
  const ProgressHistoryTimeline({
    super.key,
    required this.uid,
    required this.repository,
    this.connectivity,
  });

  final String uid;
  final AcademicHistoryRepository repository;
  final ConnectivityService? connectivity;

  @override
  State<ProgressHistoryTimeline> createState() =>
      _ProgressHistoryTimelineState();
}

class _ProgressHistoryTimelineState extends State<ProgressHistoryTimeline> {
  static const _pageSize = 5;
  late Stream<List<AcademicHistoryEntry>> _history;
  HistoryView _view = HistoryView.byArea;
  HistoryOutcome _outcome = HistoryOutcome.all;
  final _openedTopics = <(String, String)>{};
  String? _areaId;
  int _visibleCount = _pageSize;
  bool _isLoadingMore = false;
  int _requestGeneration = 0;

  @override
  void initState() {
    super.initState();
    _history = _read();
  }

  @override
  void didUpdateWidget(covariant ProgressHistoryTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.uid != oldWidget.uid ||
        widget.repository != oldWidget.repository) {
      _requestGeneration++;
      _view = HistoryView.byArea;
      _openedTopics.clear();
      _outcome = HistoryOutcome.all;
      _areaId = null;
      _visibleCount = _pageSize;
      _isLoadingMore = false;
      _history = _read();
    }
  }

  Stream<List<AcademicHistoryEntry>> _read() =>
      widget.repository.watchHistory(widget.uid);

  Future<void> _showMore(int matchedCount) async {
    if (_isLoadingMore) return;
    if (_view == HistoryView.recent && _visibleCount < matchedCount) {
      setState(() => _visibleCount += _pageSize);
      return;
    }
    final generation = _requestGeneration;
    final filters = (_view, _areaId, _outcome);
    setState(() => _isLoadingMore = true);
    try {
      await widget.repository.loadMore(widget.uid);
      if (mounted &&
          generation == _requestGeneration &&
          filters == (_view, _areaId, _outcome)) {
        setState(() => _visibleCount += _pageSize);
      }
    } catch (error, stack) {
      developer.log(
        'History pagination failed',
        name: 'ProgressHistoryTimeline',
        error: error,
        stackTrace: stack,
      );
    } finally {
      if (mounted && generation == _requestGeneration) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _resetFilters() => setState(() {
    _outcome = HistoryOutcome.all;
    _areaId = null;
    _visibleCount = _pageSize;
  });

  void _openTopic((String, String) topic) {
    if (!_openedTopics.contains(topic)) {
      setState(() => _openedTopics.add(topic));
    }
  }

  void _open(AcademicHistoryEntry entry) {
    if (widget.repository.currentUser?.uid != widget.uid) return;
    Navigator.of(context).push(
      AppPageRoute(
        child: AcademicHistoryScreen(
          repository: widget.repository,
          connectivity: widget.connectivity,
          entryId: entry.id,
          expectedUid: widget.uid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const ProgressHistoryHeading(),
      const SizedBox(height: 6),
      AppAsyncStreamBuilder<List<AcademicHistoryEntry>>(
        key: ValueKey(widget.uid),
        stream: _history,
        connectivity: widget.connectivity,
        onRetryStream: _read,
        builder: (context, snapshot, retry) {
          final entries = snapshot.data ?? const <AcademicHistoryEntry>[];
          if (!snapshot.hasData ||
              snapshot.isAccessFailure ||
              entries.isEmpty) {
            return AppAsyncStatus(
              snapshot: snapshot,
              isEmpty: entries.isEmpty,
              onRetry: retry,
              emptyTitle: 'Aún no hay actividades',
              emptyMessage: 'Tus respuestas guardadas aparecerán aquí.',
              emptyIcon: CupertinoIcons.clock,
              errorMessage:
                  'No se pudo cargar tu historial. Inténtalo de nuevo.',
            );
          }

          final isGrouped = _view == HistoryView.byArea;
          final areaIds = isGrouped
              ? const <String>{}
              : entries.map((entry) => entry.areaId).toSet();
          final activeArea = areaIds.contains(_areaId) ? _areaId : null;
          final matching = entries.where((entry) {
            return (activeArea == null || entry.areaId == activeArea) &&
                _outcome.matches(entry);
          }).toList()..sort(compareHistoryDates);
          final visible = isGrouped
              ? matching
              : matching.take(_visibleCount).toList();
          final hasMore =
              (!isGrouped && matching.length > _visibleCount) ||
              widget.repository.hasMore(widget.uid);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppAsyncNotice(snapshot: snapshot, onRetry: retry),
              HistoryCatalog(
                key: ValueKey((widget.uid, widget.repository)),
                uid: widget.uid,
                entries: visible,
                repository: widget.repository,
                connectivity: widget.connectivity,
                expand: false,
                quizScope: isGrouped ? _openedTopics : null,
                builder: (labels) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProgressHistoryViewPicker(
                      view: _view,
                      onChanged: (view) {
                        if (_view == view) return;
                        setState(() {
                          _view = view;
                          _visibleCount = _pageSize;
                        });
                      },
                    ),
                    ProgressHistoryFilters(
                      areaIds: areaIds,
                      areaLabels: labels.areas,
                      areaId: activeArea,
                      outcome: _outcome,
                      onAreaChanged: (area) => setState(() {
                        _areaId = area;
                        _visibleCount = _pageSize;
                      }),
                      onOutcomeChanged: (outcome) => setState(() {
                        _outcome = outcome;
                        _visibleCount = _pageSize;
                      }),
                    ),
                    const SizedBox(height: 12),
                    if (visible.isEmpty)
                      AppEmptyState(
                        title: 'Sin coincidencias',
                        message: hasMore
                            ? 'Puedes cargar más actividad o cambiar los filtros.'
                            : 'Prueba con otro filtro.',
                        icon: CupertinoIcons.line_horizontal_3_decrease,
                        actionLabel: 'Ver todas',
                        onAction: _resetFilters,
                      )
                    else if (isGrouped)
                      ProgressHistoryGroups(
                        entries: visible,
                        labels: labels,
                        onOpen: _open,
                        onTopicOpened: _openTopic,
                      )
                    else
                      ProgressHistoryRows(
                        entries: visible,
                        labels: labels,
                        onOpen: _open,
                      ),
                    if (hasMore)
                      ProgressHistoryMore(
                        isLoading: _isLoadingMore,
                        onPressed: () => _showMore(matching.length),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ],
  );
}
