// ============================================================================
// Archivo: quiz_topics_screen.dart
// Propósito: Pantalla de seleccion y listado de cuestionarios clinicos [quiz_topics_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../cheatsheets/api/medical_areas_service.dart';
import '../../cheatsheets/model/medical_area_model.dart';
import '../../cheatsheets/model/topic_model.dart';
import 'widgets/quiz_general_exam_card.dart';
import 'widgets/quiz_topic_card.dart';

// Pantalla de interfaz de usuario [QuizTopicsScreen]
class QuizTopicsScreen extends StatefulWidget {
  final MedicalAreaModel area;

  const QuizTopicsScreen({super.key, required this.area});

  @override
  State<QuizTopicsScreen> createState() => _QuizTopicsScreenState();
}

// Estado reactivo y control de ciclo de vida para [QuizTopicsScreen]
class _QuizTopicsScreenState extends State<QuizTopicsScreen> {
  final MedicalAreasService _medicalService = MedicalAreasService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<TopicModel>> _topicsStream;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _topicsStream = _medicalService.getTopicsStream(widget.area.id);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
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
                          'Atrás',
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
                  if (widget.area.hasImage)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: widget.area.buildLogoWidget(size: 20),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.area.name,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Elige un tema para evaluar tus conocimientos clínicos o realiza un examen completo.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Buscar tema anatómico...',
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<bool>(
                stream: _connectivityService.isOnlineStream,
                initialData: _connectivityService.isOnline,
                builder: (context, onlineSnap) {
                  final bool isOnline = onlineSnap.data ?? false;

                  if (!isOnline) {
                    return _buildOfflineState();
                  }

                  return StreamBuilder<List<TopicModel>>(
                    stream: _topicsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                        return const Center(
                          child: CupertinoActivityIndicator(radius: 14),
                        );
                      }

                      final allTopics = snapshot.data ?? [];
                      final topics = _searchQuery.isEmpty
                          ? allTopics
                          : allTopics.where((t) {
                              return t.title.toLowerCase().contains(_searchQuery) ||
                                  t.description.toLowerCase().contains(_searchQuery);
                            }).toList();

                      if (topics.isEmpty) {
                        return _buildEmptyTopicsState();
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 90),
                        itemCount: topics.length + 1,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return QuizGeneralExamCard(area: widget.area);
                          }
                          final topic = topics[index - 1];
                          return QuizTopicCard(
                            area: widget.area,
                            topic: topic,
                            number: index,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(CupertinoIcons.wifi_slash, size: 40, color: AppColors.systemRed),
          SizedBox(height: 12),
          Text(
            'Sin conexión a internet',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          SizedBox(height: 4),
          Text(
            'Conéctate a internet para acceder a los temas de quizzes.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTopicsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(CupertinoIcons.layers_alt, size: 40, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text(
            'No se encontraron temas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
