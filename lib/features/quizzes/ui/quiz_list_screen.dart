// ============================================================================
// File: quiz_list_screen.dart
// Purpose: Screen for selecting and listing clinical quizzes [quiz_list_screen].
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/states/app_async_content.dart';
import '../api/quiz_service.dart';
import '../model/quiz_model.dart';
import 'widgets/quiz_list_tile.dart';

// User interface screen [QuizListScreen]
class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

// Reactive state and lifecycle management for [QuizListScreen]
class _QuizListScreenState extends State<QuizListScreen>
    with AutomaticKeepAliveClientMixin {
  final QuizService _quizService = QuizService();
  late final Stream<List<QuizModel>> _quizzesStream;

  @override
  bool get wantKeepAlive => true;

  // Initialize the component dependencies and local state
  // Block: Initialize controllers, listeners, and local state
  @override
  void initState() {
    super.initState();
    _quizzesStream = _quizService.getQuizzesByAreaStream('anatomia');
  }

  // Reactive rendering of the widget tree
  // Block: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppAsyncStreamBuilder<List<QuizModel>>(
          stream: _quizzesStream,
          onRetryStream: () => _quizService.getQuizzesByAreaStream('anatomia'),
          builder: (context, snapshot, retry) {
            final quizzes = snapshot.data ?? [];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Quizzes',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Quick assessments with three options and immediate medical feedback.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (snapshot.hasData &&
                    quizzes.isNotEmpty &&
                    !snapshot.isAccessFailure)
                  SliverToBoxAdapter(
                    child: AppAsyncNotice(snapshot: snapshot, onRetry: retry),
                  ),
                if (!snapshot.hasData ||
                    quizzes.isEmpty ||
                    snapshot.isAccessFailure)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppAsyncStatus(
                      snapshot: snapshot,
                      isEmpty: quizzes.isEmpty,
                      onRetry: retry,
                      emptyTitle: 'No quizzes available',
                      emptyMessage: 'Quizzes for this area will appear here.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final quiz = quizzes[index];
                        return QuizListTile(
                          quiz: quiz,
                          index: index + 1,
                          allQuizzes: quizzes,
                          areaTitle: 'Human Anatomy',
                        );
                      }, childCount: quizzes.length),
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
