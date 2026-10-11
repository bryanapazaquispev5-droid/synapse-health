// ============================================================================
// Archivo: quiz_areas_screen.dart
// Propósito: Pantalla de seleccion y listado de cuestionarios clinicos [quiz_areas_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/states/app_async_content.dart';
import '../../cheatsheets/api/medical_areas_service.dart';
import '../../cheatsheets/model/medical_area_model.dart';
import 'widgets/quiz_course_card.dart';

// Pantalla de interfaz de usuario [QuizAreasScreen]
class QuizAreasScreen extends StatefulWidget {
  const QuizAreasScreen({super.key});

  @override
  State<QuizAreasScreen> createState() => _QuizAreasScreenState();
}

// Estado reactivo y control de ciclo de vida para [QuizAreasScreen]
class _QuizAreasScreenState extends State<QuizAreasScreen>
    with AutomaticKeepAliveClientMixin {
  final MedicalAreasService _medicalAreasService = MedicalAreasService();
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<MedicalAreaModel>> _areasStream;
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  // Inicializacion de dependencias y estado local del componente
  // Bloque: Inicialización de controladores, listeners y estado local
  @override
  void initState() {
    super.initState();
    _areasStream = _medicalAreasService.getAreasStream();
  }

  // Liberacion de controladores y recursos para evitar fugas de memoria
  // Bloque: Liberación de recursos y controladores para evitar fugas de memoria
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppAsyncStreamBuilder<List<MedicalAreaModel>>(
          stream: _areasStream,
          onRetryStream: _medicalAreasService.getAreasStream,
          builder: (context, snapshot, retry) {
            final allAreas = snapshot.data ?? [];
            final filteredAreas = allAreas.where((a) {
              return a.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  a.code.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

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
                      bottom: 8,
                    ),
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
                          onChanged: (val) =>
                              setState(() => _searchQuery = val.trim()),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                if (snapshot.hasData &&
                    allAreas.isNotEmpty &&
                    !snapshot.isAccessFailure)
                  SliverToBoxAdapter(
                    child: AppAsyncNotice(snapshot: snapshot, onRetry: retry),
                  ),
                if (!snapshot.hasData ||
                    allAreas.isEmpty ||
                    snapshot.isAccessFailure)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppAsyncStatus(
                      snapshot: snapshot,
                      isEmpty: allAreas.isEmpty,
                      onRetry: retry,
                      emptyTitle: 'No hay cursos de quizzes disponibles',
                      emptyMessage: 'Los cursos disponibles aparecerán aquí.',
                    ),
                  )
                else if (filteredAreas.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      title: 'No se encontraron cursos',
                      message: 'Prueba con otro término o limpia la búsqueda.',
                      icon: CupertinoIcons.search,
                      actionLabel: 'Limpiar búsqueda',
                      onAction: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final area = filteredAreas[index];
                        return QuizCourseCard(area: area);
                      }, childCount: filteredAreas.length),
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
