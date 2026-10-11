// ============================================================================
// Archivo: cheatsheet_list_screen.dart
// Propósito: Pantalla de visualizacion y exploracion para las fichas y resumenes medicos [cheatsheet_list_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/states/app_async_content.dart';
import '../../../core/theme/app_theme.dart';
import '../api/medical_areas_service.dart';
import '../model/medical_area_model.dart';
import 'widgets/medical_area_card.dart';

// Pantalla de interfaz de usuario [CheatsheetListScreen]
class CheatsheetListScreen extends StatefulWidget {
  const CheatsheetListScreen({super.key});

  @override
  State<CheatsheetListScreen> createState() => _CheatsheetListScreenState();
}

// Estado reactivo y control de ciclo de vida para [CheatsheetListScreen]
class _CheatsheetListScreenState extends State<CheatsheetListScreen>
    with AutomaticKeepAliveClientMixin {
  final MedicalAreasService _service = MedicalAreasService();
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<MedicalAreaModel>> _areasStream;
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  // Inicializacion de dependencias y estado local del componente
  @override
  void initState() {
    super.initState();
    _areasStream = _service.getAreasStream();
  }

  // Liberacion de controladores y recursos para evitar fugas de memoria
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Renderizado reactivo del arbol de widgets
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppAsyncStreamBuilder<List<MedicalAreaModel>>(
          stream: _areasStream,
          onRetryStream: _service.getAreasStream,
          builder: (context, snapshot, retry) {
            final allAreas = snapshot.data ?? [];
            final filtered = allAreas.where((a) {
              return a.name.toLowerCase().contains(_searchQuery) ||
                  a.code.toLowerCase().contains(_searchQuery);
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
                      top: 16,
                      bottom: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'Fichas',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -1.0,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            snapshot.hasData && !snapshot.isAccessFailure
                                ? '${allAreas.length} Áreas'
                                : 'Áreas',
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      placeholder: 'Buscar especialidad o código...',
                      placeholderStyle: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textMuted,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      borderRadius: BorderRadius.circular(11),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      backgroundColor: const Color(0xFFE3E3E8),
                      onChanged: (val) => setState(
                        () => _searchQuery = val.trim().toLowerCase(),
                      ),
                      onSuffixTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
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
                      emptyTitle: 'No hay áreas médicas disponibles',
                      emptyMessage:
                          'Todavía no hay especialidades para consultar.',
                      errorMessage: 'No se pudieron cargar las especialidades. Inténtalo de nuevo.',
                    ),
                  )
                else if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      title: 'No se encontró "$_searchQuery"',
                      message:
                          'Comprueba la ortografía o prueba con otro término.',
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
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 6,
                      bottom: 100,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.12,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final area = filtered[index];
                        return MedicalAreaCard(area: area);
                      }, childCount: filtered.length),
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
