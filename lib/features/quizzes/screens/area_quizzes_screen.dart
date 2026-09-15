import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../cheatsheets/models/medical_area_model.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';
import 'quiz_session_screen.dart';

class AreaQuizzesScreen extends StatefulWidget {
  final MedicalAreaModel area;

  const AreaQuizzesScreen({super.key, required this.area});

  @override
  State<AreaQuizzesScreen> createState() => _AreaQuizzesScreenState();
}

class _AreaQuizzesScreenState extends State<AreaQuizzesScreen> {
  final QuizService _quizService = QuizService();
  late final Stream<List<QuizModel>> _quizzesStream;

  @override
  void initState() {
    super.initState();
    _quizzesStream = _quizService.getQuizzesByAreaStream(widget.area.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior de navegación estilo Apple
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 16, top: 10, bottom: 8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.bolt_fill, size: 12, color: AppColors.accent),
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

            // Contenido reactivo con Stream de Quizzes
            Expanded(
              child: StreamBuilder<List<QuizModel>>(
                stream: _quizzesStream,
                builder: (context, snapshot) {
                  final bool isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;
                  final quizzes = snapshot.data ?? [];

                  if (isLoading) {
                    return const Center(child: CupertinoActivityIndicator(radius: 14));
                  }

                  if (quizzes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.question_circle, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No hay quizzes disponibles para ${widget.area.name}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
                    children: [
                      // Banner del Curso
                      _buildCourseHeaderBanner(context, quizzes),
                      const SizedBox(height: 20),

                      // Título de la lista de preguntas
                      const Text(
                        'Preguntas del Curso',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Listado de Quizzes
                      ...List.generate(quizzes.length, (index) {
                        final q = quizzes[index];
                        return _buildQuizTile(context, q, index + 1, quizzes);
                      }),
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

  Widget _buildCourseHeaderBanner(BuildContext context, List<QuizModel> quizzes) {
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: widget.area.hasImage
                      ? widget.area.buildLogoWidget(size: 26)
                      : const Icon(CupertinoIcons.bolt_fill, color: AppColors.accent, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.area.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${quizzes.length} Preguntas Clínicas • 3 Alternativas',
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
          Text(
            'Evaluación interactiva y casos clínicos de alto rendimiento basados en ${widget.area.name} (Rouvière Tomos 1 al 4).',
            style: const TextStyle(
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
                      areaTitle: widget.area.name,
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
                    'Iniciar Examen Completo',
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

  Widget _buildQuizTile(
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
            Navigator.push(
              context,
              AppPageRoute(
                child: QuizSessionScreen(
                  quizzes: allQuizzes,
                  initialIndex: index - 1,
                  areaTitle: '${widget.area.name} - Pregunta #$index',
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
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              quiz.sourceBook,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
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
