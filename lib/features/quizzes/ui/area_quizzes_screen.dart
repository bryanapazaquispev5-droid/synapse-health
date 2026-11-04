// ============================================================================
// File: area_quizzes_screen.dart
// Purpose: Screen for selecting and listing clinical quizzes [area_quizzes_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/states/app_async_content.dart';
import '../../cheatsheets/model/medical_area_model.dart';
import '../api/quiz_service.dart';
import '../model/quiz_model.dart';
import 'widgets/quiz_list_tile.dart';

// User interface screen [AreaQuizzesScreen]
class AreaQuizzesScreen extends StatefulWidget {
  final MedicalAreaModel area;

  const AreaQuizzesScreen({super.key, required this.area});

  @override
  State<AreaQuizzesScreen> createState() => _AreaQuizzesScreenState();
}

// Reactive state and lifecycle management for [AreaQuizzesScreen]
class _AreaQuizzesScreenState extends State<AreaQuizzesScreen> {
  final QuizService _quizService = QuizService();
  late final Stream<List<QuizModel>> _quizzesStream;

  // Initialize the component dependencies and local state
  // Block: Initialize controllers, listeners, and local state
  @override
  void initState() {
    super.initState();
    _quizzesStream = _quizService.getQuizzesByAreaStream(widget.area.id);
  }

  // Reactive rendering of the widget tree
  // Block: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 16,
                top: 10,
                bottom: 8,
              ),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
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
                          'Cursos',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.bolt_fill,
                          size: 12,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.area.quizzesCount} Quizzes',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AppAsyncStreamBuilder<List<QuizModel>>(
                stream: _quizzesStream,
                onRetryStream: () =>
                    _quizService.getQuizzesByAreaStream(widget.area.id),
                builder: (context, snapshot, retry) {
                  final quizzes = snapshot.data ?? [];
                  if (!snapshot.hasData ||
                      quizzes.isEmpty ||
                      snapshot.isAccessFailure) {
                    return AppAsyncStatus(
                      snapshot: snapshot,
                      isEmpty: quizzes.isEmpty,
                      onRetry: retry,
                      emptyTitle: 'No quizzes in this specialty',
                      emptyMessage: 'Available quizzes will appear here.',
                      emptyIcon: CupertinoIcons.question_circle,
                    );
                  }
                  return Column(
                    children: [
                      AppAsyncNotice(snapshot: snapshot, onRetry: retry),
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
                          itemCount: quizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = quizzes[index];
                            return QuizListTile(
                              quiz: quiz,
                              index: index + 1,
                              allQuizzes: quizzes,
                              areaTitle: widget.area.name,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
