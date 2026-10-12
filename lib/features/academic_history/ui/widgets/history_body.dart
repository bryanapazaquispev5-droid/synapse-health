import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';

import '../../../../core/services/connectivity_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/states/app_async_content.dart';
import '../../api/academic_history_repository.dart';
import '../../model/academic_history_entry.dart';
import '../academic_history_screen.dart';
import 'history_catalog.dart';
import 'history_entry_card.dart';
import 'history_result.dart';

class HistoryBody extends StatefulWidget {
  const HistoryBody({
    super.key,
    required this.uid,
    required this.repository,
    this.connectivity,
    this.entryId,
  });
  final String uid;
  final AcademicHistoryRepository repository;
  final ConnectivityService? connectivity;
  final String? entryId;
  @override
  State<HistoryBody> createState() => _HistoryBodyState();
}

class _HistoryBodyState extends State<HistoryBody> {
  late final Stream<List<AcademicHistoryEntry>> _history;
  int _visibleCount = 20;
  bool _loadingMore = false;
  @override
  void initState() {
    super.initState();
    _history = _read();
  }

  Stream<List<AcademicHistoryEntry>> _read() => widget.entryId == null
      ? widget.repository.watchHistory(widget.uid)
      : widget.repository.watchEntry(widget.uid, widget.entryId!);
  Future<void> _showMore(int loadedCount) async {
    if (_loadingMore) return;
    if (_visibleCount < loadedCount) {
      setState(() => _visibleCount += 20);
      return;
    }
    setState(() => _loadingMore = true);
    try {
      await widget.repository.loadMore(widget.uid);
      if (mounted) setState(() => _visibleCount += 20);
    } catch (error, stack) {
      // The repository emits the failure to the existing content stream.
      developer.log(
        'History pagination failed',
        name: 'HistoryBody',
        error: error,
        stackTrace: stack,
      );
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _open(AcademicHistoryEntry entry) {
    if (widget.repository.currentUser?.uid != widget.uid) return;
    Navigator.push(
      context,
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
  Widget build(
    BuildContext context,
  ) => AppAsyncStreamBuilder<List<AcademicHistoryEntry>>(
    stream: _history,
    connectivity: widget.connectivity,
    onRetryStream: _read,
    builder: (context, snapshot, retry) {
      final entries = snapshot.data ?? const <AcademicHistoryEntry>[];
      final selected = widget.entryId == null
          ? entries
          : entries.where((entry) => entry.id == widget.entryId).toList();
      if (!snapshot.hasData || snapshot.isAccessFailure || selected.isEmpty) {
        return AppAsyncStatus(
          snapshot: snapshot,
          isEmpty: selected.isEmpty,
          onRetry: retry,
          emptyTitle: widget.entryId == null
              ? 'Aún no hay actividades'
              : 'Resultado no disponible',
          emptyMessage: widget.entryId == null
              ? 'Tus respuestas guardadas aparecerán aquí.'
              : 'Este registro ya no está en el historial conservado.',
          errorMessage: 'No se pudo cargar tu historial. Inténtalo de nuevo.',
        );
      }
      final visible = selected.take(_visibleCount).toList();
      return Column(
        children: [
          AppAsyncNotice(snapshot: snapshot, onRetry: retry),
          Expanded(
            child: HistoryCatalog(
              uid: widget.uid,
              entries: visible,
              repository: widget.repository,
              connectivity: widget.connectivity,
              builder: (labels) {
                if (widget.entryId != null) {
                  return HistoryResult(entry: selected.first, labels: labels);
                }
                return ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: Text(
                        'Respuestas de intentos conservados',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    for (final entry in visible)
                      HistoryEntryCard(
                        entry: entry,
                        labels: labels,
                        onTap: () => _open(entry),
                      ),
                    if (entries.length > _visibleCount ||
                        widget.repository.hasMore(widget.uid))
                      CupertinoButton(
                        onPressed: _loadingMore
                            ? null
                            : () => _showMore(entries.length),
                        child: _loadingMore
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CupertinoActivityIndicator(radius: 8),
                                  SizedBox(width: 8),
                                  Text('Cargando más…'),
                                ],
                              )
                            : const Text('Mostrar más'),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
