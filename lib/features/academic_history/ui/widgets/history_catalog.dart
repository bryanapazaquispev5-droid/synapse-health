import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../../../../core/services/connectivity_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/states/app_async_content.dart';
import '../../api/academic_history_repository.dart';
import '../../model/academic_history_entry.dart';

class HistoryLabels {
  final areas = <String, String>{};
  final topics = <(String, String), String>{};
  final quizzes = <(String, String, String), String>{};
  String area(AcademicHistoryEntry entry) =>
      areas[entry.areaId] ?? 'Área no disponible';
  String topic(AcademicHistoryEntry entry) =>
      topics[(entry.areaId, entry.topicId)] ?? 'Tema no disponible';
  String quiz(AcademicHistoryEntry entry) =>
      quizzes[(entry.areaId, entry.topicId, entry.quizId)] ??
      'Quiz no disponible';
}

/// Catalog subscriptions are shared across entries from the same area/topic.
class HistoryCatalog extends StatefulWidget {
  const HistoryCatalog({
    super.key,
    required this.uid,
    required this.entries,
    required this.repository,
    required this.builder,
    this.connectivity,
  });
  final String uid;
  final List<AcademicHistoryEntry> entries;
  final AcademicHistoryRepository repository;
  final ConnectivityService? connectivity;
  final Widget Function(HistoryLabels) builder;
  @override
  State<HistoryCatalog> createState() => _HistoryCatalogState();
}

class _HistoryCatalogState extends State<HistoryCatalog> {
  HistoryLabels _labels = HistoryLabels();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  final _areasRequested = <String>{};
  final _topicsRequested = <(String, String)>{};
  bool _hasError = false;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant HistoryCatalog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _load();
  }

  void _listen<T>(Stream<T> stream, void Function(T) update) {
    final generation = _generation;
    _subscriptions.add(
      stream.listen(
        (data) {
          if (mounted && generation == _generation) {
            setState(() => update(data));
          }
        },
        onError: (Object error, StackTrace stack) {
          developer.log(
            'History catalog subscription failed',
            name: 'HistoryCatalog',
            error: error,
            stackTrace: stack,
          );
          if (mounted && generation == _generation) {
            setState(() {
              _hasError = true;
              if (isContentAccessFailure(error)) _labels = HistoryLabels();
            });
          }
        },
      ),
    );
  }

  void _load() {
    if (_subscriptions.isEmpty) {
      _listen(widget.repository.watchAreas(widget.uid), (areas) {
        _labels.areas.clear();
        for (final area in areas) {
          if (area.name.trim().isNotEmpty && area.name != area.id) {
            _labels.areas[area.id] = area.name;
          }
        }
      });
    }
    for (final entry in widget.entries) {
      if (_areasRequested.add(entry.areaId)) {
        _listen(widget.repository.watchTopics(widget.uid, entry.areaId), (
          topics,
        ) {
          _labels.topics.removeWhere((key, _) => key.$1 == entry.areaId);
          for (final topic in topics) {
            if (topic.title.trim().isNotEmpty) {
              _labels.topics[(entry.areaId, topic.id)] = topic.title;
            }
          }
        });
      }
      if (_topicsRequested.add((entry.areaId, entry.topicId))) {
        _listen(
          widget.repository.watchQuizzes(
            widget.uid,
            entry.areaId,
            entry.topicId,
          ),
          (quizzes) {
            _labels.quizzes.removeWhere(
              (key, _) => key.$1 == entry.areaId && key.$2 == entry.topicId,
            );
            for (final quiz in quizzes) {
              if (quiz.cleanQuestionPrompt.trim().isNotEmpty) {
                _labels.quizzes[(entry.areaId, entry.topicId, quiz.id)] =
                    quiz.cleanQuestionPrompt;
              }
            }
          },
        );
      }
    }
  }

  void _retry() {
    _generation++;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    _areasRequested.clear();
    _topicsRequested.clear();
    setState(() {
      _labels = HistoryLabels();
      _hasError = false;
    });
    _load();
  }

  @override
  void dispose() {
    _generation++;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (_hasError)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Algunos nombres no están disponibles.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
              TextButton(onPressed: _retry, child: const Text('Reintentar')),
            ],
          ),
        ),
      Expanded(child: widget.builder(_labels)),
    ],
  );
}
