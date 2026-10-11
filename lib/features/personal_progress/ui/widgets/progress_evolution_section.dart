import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/widgets/states/app_async_content.dart';
import '../../../cheatsheets/model/topic_model.dart';
import '../../model/progress_summary.dart';

class ProgressEvolutionSection extends StatelessWidget {
  const ProgressEvolutionSection({
    super.key,
    required this.series,
    required this.areaNames,
    required this.topicsStreamForArea,
    this.connectivity,
  });
  final List<TopicEvolution> series;
  final Map<String, String> areaNames;
  final Stream<List<TopicModel>> Function(String) topicsStreamForArea;
  final ConnectivityService? connectivity;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<TopicEvolution>>{};
    for (final item in series) {
      grouped.putIfAbsent(item.areaId, () => []).add(item);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evolución por tema',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (series.isEmpty)
          const AppEmptyState(
            title: 'Todavía no hay evolución disponible',
            message: 'Completa respuestas en más de un intento del mismo tema para comparar tus resultados.',
          ),
        for (final entry in grouped.entries)
          _AreaEvolution(
            key: ValueKey(entry.key),
            areaId: entry.key,
            areaName: areaNames[entry.key] ?? 'Área no disponible',
            series: entry.value,
            topicsStreamForArea: topicsStreamForArea,
            connectivity: connectivity,
          ),
      ],
    );
  }
}

class _AreaEvolution extends StatefulWidget {
  const _AreaEvolution({
    super.key,
    required this.areaId,
    required this.areaName,
    required this.series,
    required this.topicsStreamForArea,
    this.connectivity,
  });
  final String areaId;
  final String areaName;
  final List<TopicEvolution> series;
  final Stream<List<TopicModel>> Function(String) topicsStreamForArea;
  final ConnectivityService? connectivity;

  @override
  State<_AreaEvolution> createState() => _AreaEvolutionState();
}

class _AreaEvolutionState extends State<_AreaEvolution> {
  late final Stream<List<TopicModel>> _topics;

  @override
  void initState() {
    super.initState();
    _topics = widget.topicsStreamForArea(widget.areaId);
  }

  @override
  Widget build(BuildContext context) => AppAsyncStreamBuilder<List<TopicModel>>(
    stream: _topics,
    connectivity: widget.connectivity,
    onRetryStream: () => widget.topicsStreamForArea(widget.areaId),
    builder: (context, snapshot, retry) {
      if (!snapshot.hasData || snapshot.isAccessFailure) {
        return AppAsyncStatus(
          snapshot: snapshot,
          isEmpty: false,
          onRetry: retry,
          emptyTitle: 'Temas no disponibles',
          emptyMessage: 'No hay información de estos temas.',
        );
      }
      final titles = {
        for (final topic in snapshot.data!) topic.id: topic.title,
      };
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAsyncNotice(snapshot: snapshot, onRetry: retry),
          for (final series in widget.series)
            _TopicEvolutionCard(
              series: series,
              areaName: widget.areaName,
              topicName: titles[series.topicId]?.trim().isNotEmpty == true
                  ? titles[series.topicId]!
                  : 'Tema no disponible',
            ),
        ],
      );
    },
  );
}

class _TopicEvolutionCard extends StatelessWidget {
  const _TopicEvolutionCard({
    required this.series,
    required this.areaName,
    required this.topicName,
  });
  final TopicEvolution series;
  final String areaName;
  final String topicName;

  String _date(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          topicName,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          areaName,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        for (final point in series.points)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Semantics(
              label:
                  'Intento ${point.attemptNumber}, ${point.accuracy.toStringAsFixed(1)} por ciento de aciertos, ${point.correct} respuestas correctas de ${point.answered}. Última respuesta ${_date(point.lastAnsweredAt)}.',
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Intento ${point.attemptNumber} · ${point.accuracy.toStringAsFixed(1)} %',
                    ),
                    const SizedBox(height: 6),
                    LayoutBuilder(
                      builder: (context, constraints) => Container(
                        width: constraints.maxWidth,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width:
                              constraints.maxWidth *
                              point.accuracy.clamp(0, 100) /
                              100,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Última respuesta: ${_date(point.lastAnsweredAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
