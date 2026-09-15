import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../cheatsheets/models/medical_area_model.dart';
import '../../cheatsheets/models/topic_model.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';
import 'quiz_session_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _quizzesStream = _quizService.getQuizzesByTopicStream(widget.area.id, widget.topic.id);
  }

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
                // Barra superior de navegación estilo Apple
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

                // Large Title del Tema
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

                // Tarjeta de inicio rápido del Quiz del Tema
                if (!isLoading && quizzes.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      child: _buildTopicActionCard(context, quizzes),
                    ),
                  ),

                // Indicador de Carga
                if (isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CupertinoActivityIndicator(radius: 14),
                    ),
                  )
                // Estado Vacío
                else if (quizzes.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
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
                // Lista de Quizzes del Tema
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final quiz = quizzes[index];
                          return _buildQuizTile(context, quiz, index + 1, quizzes);
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

  /// Tarjeta de acción para iniciar el quiz del tema completo
  Widget _buildTopicActionCard(BuildContext context, List<QuizModel> quizzes) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.play_circle_fill,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Iniciar Quiz del Tema',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '${quizzes.length} preguntas clínicas de alto rendimiento',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: CupertinoButton.filled(
              borderRadius: BorderRadius.circular(12),
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.push(
                  context,
                  AppPageRoute(
                    child: QuizSessionScreen(
                      quizzes: quizzes,
                      initialIndex: 0,
                      areaTitle: widget.topic.title,
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
                    'Empezar Evaluación',
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

  /// Fila de cada pregunta en el tema
  Widget _buildQuizTile(
    BuildContext context,
    QuizModel quiz,
    int index,
    List<QuizModel> allQuizzes,
  ) {
    Color typeColor;
    Color typeBg;
    switch (quiz.type) {
      case 'case_study':
        typeColor = const Color(0xFFD97706);
        typeBg = const Color(0xFFFEF3C7);
        break;
      case 'matching':
        typeColor = const Color(0xFF2563EB);
        typeBg = const Color(0xFFDBEAFE);
        break;
      case 'ordering':
        typeColor = const Color(0xFF7C3AED);
        typeBg = const Color(0xFFEDE9FE);
        break;
      default:
        typeColor = const Color(0xFF059669);
        typeBg = const Color(0xFFD1FAE5);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Abrir la sesión iniciando exactamente en la pregunta tocada
            Navigator.push(
              context,
              AppPageRoute(
                child: QuizSessionScreen(
                  quizzes: allQuizzes,
                  initialIndex: index - 1,
                  areaTitle: '${widget.topic.title} - Pregunta #$index',
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 0.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              quiz.typeLabel,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: typeColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(CupertinoIcons.chevron_forward, size: 14, color: Color(0xFFC7C7CC)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        quiz.question,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (quiz.sourceBook.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          quiz.sourceBook,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
