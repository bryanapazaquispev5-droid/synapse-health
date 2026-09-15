import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/quiz_model.dart';
import '../widgets/interactive_matching_widget.dart';
import '../widgets/interactive_ordering_widget.dart';

class QuizSessionScreen extends StatefulWidget {
  final List<QuizModel> quizzes;
  final String areaTitle;

  final int initialIndex;

  const QuizSessionScreen({
    super.key,
    required this.quizzes,
    this.areaTitle = 'Anatomía Humana',
    this.initialIndex = 0,
  });

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  late int _currentIndex;
  int? _selectedOptionIndex;
  bool? _isMatchingCorrect;
  bool? _isOrderingCorrect;
  bool _isAnswered = false;
  int _score = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = (widget.initialIndex >= 0 && widget.initialIndex < widget.quizzes.length)
        ? widget.initialIndex
        : 0;
  }

  void _handleOptionSelected(int index) {
    if (_isAnswered) return;

    final currentQuiz = widget.quizzes[_currentIndex];
    final bool isCorrect = index == currentQuiz.correctIndex;

    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      if (isCorrect) {
        _score++;
      }
    });
  }

  void _handleMatchingCompleted(bool isCorrect) {
    setState(() {
      _isAnswered = true;
      _isMatchingCorrect = isCorrect;
      if (isCorrect) {
        _score++;
      }
    });
  }

  void _handleOrderingCompleted(bool isCorrect) {
    setState(() {
      _isAnswered = true;
      _isOrderingCorrect = isCorrect;
      if (isCorrect) {
        _score++;
      }
    });
  }

  void _handleNextQuestion() {
    if (_currentIndex < widget.quizzes.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isMatchingCorrect = null;
        _isOrderingCorrect = null;
        _isAnswered = false;
      });
    } else {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _isMatchingCorrect = null;
      _isOrderingCorrect = null;
      _isAnswered = false;
      _score = 0;
      _isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quizzes.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: CupertinoNavigationBar(
          middle: Text(widget.areaTitle),
        ),
        body: const Center(
          child: Text('No hay preguntas disponibles en este momento.'),
        ),
      );
    }

    if (_isCompleted) {
      return _buildResultView();
    }

    final quiz = widget.quizzes[_currentIndex];
    final double progress = (_currentIndex + 1) / widget.quizzes.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior de navegación estilo Apple
            Padding(
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
                        Icon(CupertinoIcons.chevron_back, size: 24, color: AppColors.accent),
                        SizedBox(width: 2),
                        Text(
                          'Salir',
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
                    child: Text(
                      '${_currentIndex + 1} de ${widget.quizzes.length}',
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

            // Barra de Progreso Lineal Delgada
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ),

            // Contenido desplazable del Quiz
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                children: [
                  // Badges de Tipo de Pregunta y Libro Fuente
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          quiz.typeLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          quiz.sourceBook,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Tarjeta del Enunciado de la Pregunta
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border, width: 0.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      quiz.cleanQuestionPrompt,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        height: 1.4,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Si es pregunta de tipo 'matching' (Para Relacionar), mostrar el widget de 2 columnas
                  if (quiz.type == 'matching') ...[
                    InteractiveMatchingWidget(
                      key: ValueKey('${quiz.id}_$_currentIndex'),
                      quiz: quiz,
                      isAnswered: _isAnswered,
                      onCompleted: _handleMatchingCompleted,
                    ),
                  ] else if (quiz.type == 'ordering') ...[
                    // Si es pregunta de tipo 'ordering' (Para Ordenar), mostrar el widget táctil reordenable
                    InteractiveOrderingWidget(
                      key: ValueKey('${quiz.id}_$_currentIndex'),
                      quiz: quiz,
                      isAnswered: _isAnswered,
                      onCompleted: _handleOrderingCompleted,
                    ),
                  ] else ...[
                    // Las 3 Alternativas para Selección Simple
                    ...List.generate(quiz.options.length, (index) {
                      final optionText = quiz.options[index];
                      final optionLetter = String.fromCharCode(65 + index); // A, B, C

                      return _buildOptionCard(
                        index: index,
                        letter: optionLetter,
                        text: optionText,
                        correctIndex: quiz.correctIndex,
                      );
                    }),
                  ],

                  // Caja de Justificación Médica (Feedback Inmediato)
                  if (_isAnswered) ...[
                    const SizedBox(height: 16),
                    _buildRationaleCard(quiz),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),

      // Botón Inferior Flotante (One UI Reachability)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isAnswered
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              height: 52,
              child: CupertinoButton.filled(
                borderRadius: BorderRadius.circular(16),
                onPressed: _handleNextQuestion,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentIndex < widget.quizzes.length - 1
                          ? 'Siguiente Pregunta'
                          : 'Ver Resultados Finales',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(CupertinoIcons.arrow_right, size: 18),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildOptionCard({
    required int index,
    required String letter,
    required String text,
    required int correctIndex,
  }) {
    Color cardBg = AppColors.surface;
    Color borderColor = AppColors.border;
    Color letterBg = const Color(0xFFF2F2F7);
    Color letterColor = AppColors.primary;
    Widget? trailingIcon;

    if (_isAnswered) {
      if (index == correctIndex) {
        // Opción correcta
        cardBg = const Color(0xFFE8F5E9);
        borderColor = AppColors.systemGreen;
        letterBg = AppColors.systemGreen;
        letterColor = Colors.white;
        trailingIcon = const Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.systemGreen, size: 22);
      } else if (index == _selectedOptionIndex) {
        // Opción incorrecta marcada por el usuario
        cardBg = const Color(0xFFFFEBEE);
        borderColor = AppColors.systemRed;
        letterBg = AppColors.systemRed;
        letterColor = Colors.white;
        trailingIcon = const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.systemRed, size: 22);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleOptionSelected(index),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Letra A, B o C
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: letterBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: letterColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Texto de la Alternativa
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),

                // Icono de acierto o error
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  trailingIcon,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRationaleCard(QuizModel quiz) {
    final bool isCorrect = quiz.type == 'matching'
        ? (_isMatchingCorrect ?? false)
        : quiz.type == 'ordering'
            ? (_isOrderingCorrect ?? false)
            : (_selectedOptionIndex == quiz.correctIndex);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFECACA),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.info_circle_fill,
                size: 18,
                color: isCorrect ? AppColors.systemGreen : AppColors.systemRed,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? '¡Respuesta Correcta!' : 'Explicación Anatómica',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCorrect ? AppColors.systemGreen : AppColors.systemRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            quiz.rationale,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final double percentage = (_score / widget.quizzes.length) * 100;
    final bool passed = percentage >= 60;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de celebración o refuerzo
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: passed ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      passed ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.exclamationmark_circle_fill,
                      size: 50,
                      color: passed ? AppColors.systemGreen : AppColors.systemRed,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  passed ? '¡Excelente Desempeño!' : 'Buen Intento de Repaso',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sesión de Quizzes completada para ${widget.areaTitle}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),

                // Tarjeta de Puntuación
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$_score / ${widget.quizzes.length}',
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accent,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${percentage.toStringAsFixed(0)}% de precisión médica',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Botón de Reiniciar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(16),
                    onPressed: _restartQuiz,
                    child: const Text(
                      'Repetir Quiz',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Botón de Volver
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Volver al Menú Principal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
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
