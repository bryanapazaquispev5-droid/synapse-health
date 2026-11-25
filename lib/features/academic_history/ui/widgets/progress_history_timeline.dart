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
  HistoryOutcome _outcome = HistoryOutcome.all;
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
    if (_visibleCount < matchedCount) {
      setState(() => _visibleCount += _pageSize);
      return;
    }
    final generation = _requestGeneration;
    final filters = (_areaId, _outcome);
    setState(() => _isLoadingMore = true);
    try {
      await widget.repository.loadMore(widget.uid);
      if (mounted &&
          generation == _requestGeneration &&
          filters == (_areaId, _outcome)) {
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

          final areaIds = entries.map((entry) => entry.areaId).toSet();
          final activeArea = areaIds.contains(_areaId) ? _areaId : null;
          final matching = entries.where((entry) {
            return (activeArea == null || entry.areaId == activeArea) &&
                _outcome.matches(entry);
          }).toList()..sort(compareHistoryDates);
          final visible = matching.take(_visibleCount).toList();
          final hasMore =
              matching.length > _visibleCount ||
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
                builder: (labels) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                      )
                    else
                      ProgressHistoryRows(
                        entries: visible,
                        labels: labels,
                        onOpen: _open,
                      ),
                    if (hasMore)
                      Align(
                        alignment: Alignment.center,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1D7256),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: _isLoadingMore
                              ? null
                              : () => _showMore(matching.length),
                          icon: _isLoadingMore
                              ? const SizedBox.square(
                                  dimension: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  CupertinoIcons.chevron_down,
                                  size: 16,
                                ),
                          label: Text(
                            _isLoadingMore ? 'Cargando…' : 'Mostrar más',
                          ),
                        ),
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
