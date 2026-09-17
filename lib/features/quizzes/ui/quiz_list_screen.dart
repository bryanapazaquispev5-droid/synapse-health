// ============================================================================
// Archivo: quiz_list_screen.dart
// Propósito: Pantalla de navegación y listado de cuestionarios clínicos organizados por área y tema [quiz_list_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../api/quiz_service.dart';
import '../model/quiz_model.dart';
import 'widgets/quiz_list_tile.dart';

/// Pantalla principal de interfaz de usuario [QuizListScreen].
class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

/// Estado mutable y controlador del ciclo de vida reactivo para [QuizListScreen].
class _QuizListScreenState extends State<QuizListScreen> with AutomaticKeepAliveClientMixin {
  final QuizService _quizService = QuizService();
  late final Stream<List<QuizModel>> _quizzesStream;

  @override
  bool get wantKeepAlive => true;

  // Bloque: Inicialización de controladores, listeners y estado local
  @override
  void initState() {
    super.initState();
    _quizzesStream = _quizService.getQuizzesByAreaStream('anatomia');
  }

  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    super.build(context);

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
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 12),
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
                          'Evaluaciones rápidas con 3 alternativas y retroalimentación médica inmediata.',
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
                if (isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CupertinoActivityIndicator(radius: 14)),
                  )
                else if (quizzes.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.question_circle, size: 48, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text(
                            'No hay quizzes disponibles',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final quiz = quizzes[index];
                          return QuizListTile(
                            quiz: quiz,
                            index: index + 1,
                            allQuizzes: quizzes,
                            areaTitle: 'Anatomía Humana',
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
