// Bloque: Pantalla de selección y listado de cuestionarios clínicos con progreso y reintentos
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
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
    _quizzesStream = _quizService.getQuizzesByTopicStream(widget.area.id, widget.topic.id);
    _progressStream = QuizProgressService().getTopicProgressStream(widget.topic.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<QuizTopicProgressModel?>(
          stream: _progressStream,
          builder: (context, progressSnap) {
            final progress = progressSnap.data;

            return StreamBuilder<List<QuizModel>>(
              stream: _quizzesStream,
              builder: (context, snapshot) {
                final bool isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;
                final quizzes = snapshot.data ?? [];
                final bool hasStarted = progress != null && progress.activeAttempt.answeredCount > 0;

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    _buildAppBarSliver(context),
                    _buildTopicInfoSliver(),
                    if (!isLoading && quizzes.isNotEmpty && !hasStarted)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                          child: QuizTopicActionCard(quizzes: quizzes, area: widget.area),
                        ),
                      ),
                    if (!isLoading && quizzes.isNotEmpty && hasStarted)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                          child: QuizTopicRetryCard(
                            progress: progress,
                            totalQuizzes: quizzes.length,
                            totalMaxStars: QuizScoringHelper.calculateTotalMaxStars(quizzes),
                            areaId: widget.area.id,
                            topicId: widget.topic.id,
                          ),
                        ),
                      ),
                    if (isLoading)
                      const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator(radius: 14)))
                    else if (quizzes.isEmpty)
                      _buildEmptyState()
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final quiz = quizzes[index];
                              final qProgress = progress?.activeAttempt.getQuizProgress(quiz.id);
                              return QuizListTile(
                                quiz: quiz,
                                index: index + 1,
                                allQuizzes: quizzes,
                                areaTitle: widget.area.name,
                                questionProgress: qProgress,
                                isAttemptStarted: hasStarted,
                              );
                            },
                            childCount: quizzes.length,
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
    );
  }

  // Bloque: Header superior con navegación de regreso y área médica
  Widget _buildAppBarSliver(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 16, top: 10, bottom: 4),
        child: Row(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              minimumSize: const Size(36, 36),
              onPressed: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(CupertinoIcons.chevron_back, size: 24, color: AppColors.accent),
                  SizedBox(width: 2),
                  Text('Temas', style: TextStyle(fontSize: 17, color: AppColors.accent, fontWeight: FontWeight.w400, letterSpacing: -0.4)),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Text(widget.area.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
  }

  // Bloque: Título y descripción del tema anatómico
  Widget _buildTopicInfoSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.topic.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: AppColors.primary)),
            if (widget.topic.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(widget.topic.description, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.35)),
            ],
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  // Bloque: Vista cuando no hay quizzes disponibles en el tema
  Widget _buildEmptyState() {
    return const SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.question_circle, size: 48, color: AppColors.textMuted),
              SizedBox(height: 12),
              Text('Preparando quizzes clínicos...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
              SizedBox(height: 6),
              Text('Los quizzes de este tema se sincronizarán en unos momentos.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
