// Bloque: Pantalla de selección y listado de cuestionarios clínicos con progreso y reintentos
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/states/app_async_content.dart';
import '../../cheatsheets/model/medical_area_model.dart';
import '../../cheatsheets/model/topic_model.dart';
import '../api/quiz_progress_service.dart';
import '../api/quiz_service.dart';
import '../model/quiz_model.dart';
import '../model/quiz_topic_progress_model.dart';
import '../utils/quiz_scoring_helper.dart';
import 'widgets/quiz_list_tile.dart';
import 'widgets/quiz_topic_action_card.dart';
import 'widgets/quiz_topic_retry_card.dart';
import 'widgets/topic_quizzes_header.dart';

// Bloque: Pantalla principal [TopicQuizzesScreen]
class TopicQuizzesScreen extends StatefulWidget {
  final MedicalAreaModel area;
  final TopicModel topic;
  const TopicQuizzesScreen({
    super.key,
    required this.area,
    required this.topic,
  });
  @override
  State<TopicQuizzesScreen> createState() => _TopicQuizzesScreenState();
}

class _TopicQuizzesScreenState extends State<TopicQuizzesScreen> {
  final QuizService _quizService = QuizService();
  late final Stream<List<QuizModel>> _quizzesStream;
  late final Stream<QuizTopicProgressModel?> _progressStream;
  @override
  void initState() {
    super.initState();
    _quizzesStream = _quizService.getQuizzesByTopicStream(
      widget.area.id,
      widget.topic.id,
    );
    _progressStream = QuizProgressService().getTopicProgressStream(
      widget.topic.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppAsyncStreamBuilder<QuizTopicProgressModel?>(
          stream: _progressStream,
          onRetryStream: () =>
              QuizProgressService().getTopicProgressStream(widget.topic.id),
          builder: (context, progressSnap, retryProgress) {
            final progress = progressSnap.data;
            return AppAsyncStreamBuilder<List<QuizModel>>(
              stream: _quizzesStream,
              onRetryStream: () => _quizService.getQuizzesByTopicStream(
                widget.area.id,
                widget.topic.id,
              ),
              builder: (context, snapshot, retry) {
                final bool contentUnavailable =
                    !snapshot.hasData || snapshot.isAccessFailure;
                final bool progressUnavailable =
                    !progressSnap.hasData || progressSnap.hasError;
                final quizzes = snapshot.data ?? [];
                final bool hasStarted =
                    progress != null &&
                    progress.activeAttempt.answeredCount > 0;
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    TopicQuizzesAppBar(area: widget.area),
                    TopicQuizzesHeader(topic: widget.topic),
                    if (!contentUnavailable && quizzes.isNotEmpty)
                      SliverToBoxAdapter(
                        child: AppAsyncNotice(
                          snapshot: snapshot,
                          onRetry: retry,
                        ),
                      ),
                    if (!contentUnavailable &&
                        !progressUnavailable &&
                        quizzes.isNotEmpty)
                      SliverToBoxAdapter(
                        child: AppAsyncNotice(
                          snapshot: progressSnap,
                          onRetry: retryProgress,
                        ),
                      ),
                    if (!contentUnavailable &&
                        !progressUnavailable &&
                        quizzes.isNotEmpty &&
                        !hasStarted)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 4,
                          ),
                          child: QuizTopicActionCard(
                            quizzes: quizzes,
                            area: widget.area,
                          ),
                        ),
                      ),
                    if (!contentUnavailable &&
                        !progressUnavailable &&
                        quizzes.isNotEmpty &&
                        hasStarted)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                          child: QuizTopicRetryCard(
                            progress: progress,
                            totalQuizzes: quizzes.length,
                            totalMaxStars:
                                QuizScoringHelper.calculateTotalMaxStars(
                                  quizzes,
                                ),
                            areaId: widget.area.id,
                            topicId: widget.topic.id,
                          ),
                        ),
                      ),
                    if (contentUnavailable || quizzes.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppAsyncStatus(
                          snapshot: snapshot,
                          isEmpty: quizzes.isEmpty,
                          onRetry: retry,
                          emptyTitle: 'No hay quizzes en este tema',
                          emptyMessage:
                              'Los quizzes disponibles aparecerán aquí.',
                          emptyIcon: CupertinoIcons.question_circle,
                        ),
                      )
                    else if (progressUnavailable)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppAsyncStatus(
                          snapshot: progressSnap,
                          isEmpty: false,
                          onRetry: retryProgress,
                          emptyTitle: 'Progreso no disponible',
                          emptyMessage: 'No pudimos cargar tu progreso.',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final quiz = quizzes[index];
                            final qProgress = progress?.activeAttempt
                                .getQuizProgress(quiz.id);
                            return QuizListTile(
                              quiz: quiz,
                              index: index + 1,
                              allQuizzes: quizzes,
                              areaTitle: widget.area.name,
                              questionProgress: qProgress,
                              isAttemptStarted: hasStarted,
                            );
                          }, childCount: quizzes.length),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
