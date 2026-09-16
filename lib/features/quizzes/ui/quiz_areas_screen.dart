import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../cheatsheets/api/medical_areas_service.dart';
import '../../cheatsheets/model/medical_area_model.dart';
import 'widgets/quiz_course_card.dart';

class QuizAreasScreen extends StatefulWidget {
  const QuizAreasScreen({super.key});

  @override
  State<QuizAreasScreen> createState() => _QuizAreasScreenState();
}

class _QuizAreasScreenState extends State<QuizAreasScreen> with AutomaticKeepAliveClientMixin {
  final MedicalAreasService _medicalAreasService = MedicalAreasService();
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<MedicalAreaModel>> _areasStream;
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _areasStream = _medicalAreasService.getAreasStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<MedicalAreaModel>>(
          stream: _areasStream,
          builder: (context, snapshot) {
            final bool isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;
            final allAreas = snapshot.data ?? [];
            final filteredAreas = allAreas.where((a) {
              return a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  a.code.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
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
                          'Selecciona un curso o materia para poner a prueba tus conocimientos médicos.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CupertinoSearchTextField(
                          controller: _searchController,
                          placeholder: 'Buscar curso o especialidad...',
                          onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CupertinoActivityIndicator(radius: 14)),
                  )
                else if (filteredAreas.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.search, size: 44, color: AppColors.textMuted),
                          SizedBox(height: 10),
                          Text(
                            'No se encontraron cursos de quizzes',
                            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
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
                          final area = filteredAreas[index];
                          return QuizCourseCard(area: area);
                        },
                        childCount: filteredAreas.length,
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
