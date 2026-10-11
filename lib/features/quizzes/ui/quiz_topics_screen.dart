// Bloque: Pantalla de selección y listado de temas de quizzes por área médica
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/states/app_async_content.dart';
import '../../../core/theme/app_theme.dart';
import '../../cheatsheets/api/medical_areas_service.dart';
import '../../cheatsheets/model/medical_area_model.dart';
import '../../cheatsheets/model/topic_model.dart';
import '../api/quiz_progress_service.dart';
import '../model/quiz_topic_progress_model.dart';
import 'widgets/quiz_topic_card.dart';

// Bloque: Pantalla principal [QuizTopicsScreen]
class QuizTopicsScreen extends StatefulWidget {
  final MedicalAreaModel area;

  const QuizTopicsScreen({super.key, required this.area});

  @override
  State<QuizTopicsScreen> createState() => _QuizTopicsScreenState();
}

class _QuizTopicsScreenState extends State<QuizTopicsScreen> {
  final MedicalAreasService _medicalService = MedicalAreasService();
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<TopicModel>> _topicsStream;
  late final Stream<Map<String, QuizTopicProgressModel>> _progressStream;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _topicsStream = _medicalService.getTopicsStream(widget.area.id);
    _progressStream = QuizProgressService().getAllTopicsProgressStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildHeaderTitle(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Buscar tema anatómico...',
                onChanged: (val) =>
                    setState(() => _searchQuery = val.trim().toLowerCase()),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AppAsyncStreamBuilder<List<TopicModel>>(
                stream: _topicsStream,
                onRetryStream: () =>
                    _medicalService.getTopicsStream(widget.area.id),
                builder: (context, snapshot, retry) {
                  final allTopics = snapshot.data ?? [];
                  final topics = _searchQuery.isEmpty
                      ? allTopics
                      : allTopics
                            .where(
                              (topic) =>
                                  topic.title.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  topic.description.toLowerCase().contains(
                                    _searchQuery,
                                  ),
                            )
                            .toList();
                  if (!snapshot.hasData ||
                      topics.isEmpty ||
                      snapshot.isAccessFailure) {
                    return AppAsyncStatus(
                      snapshot: snapshot,
                      isEmpty: topics.isEmpty,
                      onRetry: retry,
                      emptyTitle: 'No se encontraron temas',
                      emptyMessage: _searchQuery.isEmpty
                          ? 'No hay temas disponibles en esta área.'
                          : 'Prueba con otra búsqueda.',
                      emptyIcon: CupertinoIcons.layers_alt,
                    );
                  }
                  return AppAsyncStreamBuilder<
                    Map<String, QuizTopicProgressModel>
                  >(
                    stream: _progressStream,
                    onRetryStream: () =>
                        QuizProgressService().getAllTopicsProgressStream(),
                    builder: (context, progressSnap, retryProgress) {
                      final progressMap = progressSnap.data ?? const {};
                      return Column(
                        children: [
                          AppAsyncNotice(snapshot: snapshot, onRetry: retry),
                          if (!progressSnap.hasData ||
                              progressSnap.hasError ||
                              progressSnap.isWaiting)
                            AppAsyncNotice(
                              snapshot: progressSnap,
                              onRetry: retryProgress,
                            ),
                          Expanded(
                            child: ListView.separated(
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 6,
                                bottom: 90,
                              ),
                              itemCount: topics.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) => QuizTopicCard(
                                area: widget.area,
                                topic: topics[index],
                                number: index + 1,
                                progress: progressMap[topics[index].id],
                                progressIsAvailable:
                                    progressSnap.hasData &&
                                    !progressSnap.hasError,
                                isLoadingProgress:
                                    !progressSnap.hasData &&
                                    !progressSnap.hasError,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bloque: Barra de navegación superior
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 16, top: 10, bottom: 6),
      child: Row(
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            minimumSize: const Size(36, 36),
            onPressed: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  CupertinoIcons.chevron_back,
                  size: 24,
                  color: AppColors.accent,
                ),
                SizedBox(width: 2),
                Text(
                  'Atrás',
                  style: TextStyle(
                    fontSize: 17,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (widget.area.hasImage)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: widget.area.buildLogoWidget(size: 20)),
            ),
        ],
      ),
    );
  }

  // Bloque: Título y descripción introductoria del área
  Widget _buildHeaderTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.area.name,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Elige un tema para evaluar tus conocimientos clínicos o realiza un examen completo.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
