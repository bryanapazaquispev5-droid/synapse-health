import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';
import 'quiz_session_screen.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> with AutomaticKeepAliveClientMixin {
  final QuizService _quizService = QuizService();
  late final Stream<List<QuizModel>> _quizzesStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _quizzesStream = _quizService.getQuizzesByAreaStream('anatomia');
  }

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
                // Header estilo Apple Large Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quizzes',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Evaluaciones rápidas con 3 alternativas y retroalimentación médica inmediata.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                if (isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CupertinoActivityIndicator(radius: 14)),
                  )
                else if (quizzes.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
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
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Tarjeta Principal del Curso de Anatomía Humana
                        _buildAreaQuizBanner(context, quizzes),
                        const SizedBox(height: 20),

                        // Desglose de Preguntas Disponibles
                        const Text(
                          'Banco de Preguntas Disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ...List.generate(quizzes.length, (index) {
                          final q = quizzes[index];
                          return _buildQuizPreviewTile(context, q, index + 1, quizzes);
                        }),

                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAreaQuizBanner(BuildContext context, List<QuizModel> quizzes) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(CupertinoIcons.bolt_fill, color: AppColors.accent, size: 26),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Anatomía Humana',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${quizzes.length} Preguntas • 3 Alternativas',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Casos clínicos, preguntas de ordenamiento y emparejamiento anatómico basados en la colección completa de Rouvière (Tomos 1 al 4).',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: CupertinoButton.filled(
              borderRadius: BorderRadius.circular(14),
              onPressed: () {
                Navigator.push(
                  context,
                  AppPageRoute(
                    child: QuizSessionScreen(
                      quizzes: quizzes,
                      areaTitle: 'Anatomía Humana',
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.play_arrow_solid, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Comenzar Examen Completo',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizPreviewTile(
    BuildContext context,
    QuizModel quiz,
    int index,
    List<QuizModel> allQuizzes,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Inicia la sesión de quiz desde esta pregunta específica
            final subset = allQuizzes.sublist(index - 1);
            Navigator.push(
              context,
              AppPageRoute(
                child: QuizSessionScreen(
                  quizzes: subset,
                  areaTitle: 'Pregunta #$index',
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 0.6),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              quiz.typeLabel,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quiz.question,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(CupertinoIcons.chevron_forward, size: 14, color: Color(0xFFC7C7CC)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
