// ============================================================================
// Archivo: topic_quizzes_screen.dart
// Propósito: Pantalla de seleccion y listado de cuestionarios clinicos [topic_quizzes_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../cheatsheets/model/medical_area_model.dart';
import '../../cheatsheets/model/topic_model.dart';
import '../api/quiz_service.dart';
import '../model/quiz_model.dart';
import 'widgets/quiz_list_tile.dart';
import 'widgets/quiz_topic_action_card.dart';

// Pantalla de interfaz de usuario [TopicQuizzesScreen]
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

// Estado reactivo y control de ciclo de vida para [TopicQuizzesScreen]
class _TopicQuizzesScreenState extends State<TopicQuizzesScreen> {
  final QuizService _quizService = QuizService();
  late final Stream<List<QuizModel>> _quizzesStream;

  // Inicializacion de dependencias y estado local del componente
  @override
  void initState() {
    super.initState();
    _quizzesStream = _quizService.getQuizzesByTopicStream(widget.area.id, widget.topic.id);
  }

  // Renderizado reactivo del arbol de widgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<QuizModel>>(
          stream: _quizzesStream,
          builder: (context, snapshot) {
            final bool isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;
            final quizzes = snapshot.data ?? [];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
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
                              Text(
                                'Temas',
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.area.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.topic.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: AppColors.primary,
                          ),
                        ),
                        if (widget.topic.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.topic.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
                if (!isLoading && quizzes.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      child: QuizTopicActionCard(quizzes: quizzes, area: widget.area),
                    ),
                  ),
                if (isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CupertinoActivityIndicator(radius: 14),
                    ),
                  )
                else if (quizzes.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.question_circle, size: 48, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text(
                              'Preparando quizzes clínicos...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Los quizzes de este tema se sincronizarán en unos momentos.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final quiz = quizzes[index];
                          return QuizListTile(
                            quiz: quiz,
                            index: index + 1,
                            allQuizzes: quizzes,
                            areaTitle: widget.area.name,
                          );
                        },
                        childCount: quizzes.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
