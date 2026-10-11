import 'package:flutter/material.dart';

import '../../../../core/services/connectivity_service.dart';
import '../../../../core/widgets/states/app_async_content.dart';
import '../../../quizzes/model/quiz_topic_progress_model.dart';
import '../../api/personal_progress_repository.dart';
import '../../model/progress_summary.dart';
import '../../utils/progress_statistics.dart';
import 'progress_catalog_sections.dart';
import 'progress_overview.dart';

class PersonalProgressBody extends StatefulWidget {
  const PersonalProgressBody({
    super.key,
    required this.uid,
    required this.repository,
    required this.header,
    this.connectivity,
  });
  final String uid;
  final PersonalProgressRepository repository;
  final Widget header;
  final ConnectivityService? connectivity;
  @override
  State<PersonalProgressBody> createState() => _PersonalProgressBodyState();
}

class _PersonalProgressBodyState extends State<PersonalProgressBody> {
  late final Stream<Map<String, QuizTopicProgressModel>> _progress;
  Map<String, QuizTopicProgressModel>? _lastData;
  ProgressSummary? _summary;
  @override
  void initState() {
    super.initState();
    _progress = widget.repository.watchProgress(widget.uid);
  }

  @override
  Widget build(BuildContext context) =>
      AppAsyncStreamBuilder<Map<String, QuizTopicProgressModel>>(
        stream: _progress,
        connectivity: widget.connectivity,
        onRetryStream: () => widget.repository.watchProgress(widget.uid),
        builder: (context, snapshot, retry) {
          if (snapshot.hasData && !identical(_lastData, snapshot.data)) {
            _lastData = snapshot.data;
            _summary = calculateProgress(snapshot.data!);
          }
          final summary = _summary;
          final unavailable =
              !snapshot.hasData ||
              snapshot.isAccessFailure ||
              summary == null ||
              !summary.hasActivity;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: widget.header,
                ),
              ),
              if (!unavailable)
                SliverToBoxAdapter(
                  child: AppAsyncNotice(snapshot: snapshot, onRetry: retry),
                ),
              if (unavailable)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppAsyncStatus(
                    snapshot: snapshot,
                    isEmpty: summary == null || !summary.hasActivity,
                    onRetry: retry,
                    emptyTitle: 'Tu progreso empieza aquí',
                    emptyMessage: 'Responde quizzes para consultar tus resultados de práctica.',
                    errorMessage:
                        'No se pudo cargar tu progreso. Inténtalo de nuevo.',
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                    child: ProgressOverview(summary: summary),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ProgressCatalogSections(
                    key: ValueKey(widget.uid),
                    uid: widget.uid,
                    repository: widget.repository,
                    summary: summary,
                    connectivity: widget.connectivity,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ],
          );
        },
      );
}
