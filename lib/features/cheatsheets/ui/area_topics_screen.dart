// ============================================================================
// Archivo: area_topics_screen.dart
// Propósito: Pantalla de visualizacion y exploracion para las fichas y resumenes medicos [area_topics_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/states/app_async_content.dart';
import '../../../core/theme/app_theme.dart';
import '../api/medical_areas_service.dart';
import '../model/medical_area_model.dart';
import '../model/topic_model.dart';
import 'widgets/topic_list_card.dart';

// Pantalla de interfaz de usuario [AreaTopicsScreen]
class AreaTopicsScreen extends StatefulWidget {
  final MedicalAreaModel area;

  const AreaTopicsScreen({super.key, required this.area});

  @override
  State<AreaTopicsScreen> createState() => _AreaTopicsScreenState();
}

// Estado reactivo y control de ciclo de vida para [AreaTopicsScreen]
class _AreaTopicsScreenState extends State<AreaTopicsScreen> {
  final MedicalAreasService _medicalService = MedicalAreasService();
  late final Stream<List<TopicModel>> _topicsStream;

  // Inicializacion de dependencias y estado local del componente
  // Bloque: Inicialización de controladores, listeners y estado local
  @override
  void initState() {
    super.initState();
    _topicsStream = _medicalService.getTopicsStream(widget.area.id);
  }

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
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
                bottom: 10,
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
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.area.name,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
            ),
            Expanded(
              child: AppAsyncStreamBuilder<List<TopicModel>>(
                stream: _topicsStream,
                onRetryStream: () =>
                    _medicalService.getTopicsStream(widget.area.id),
                builder: (context, snapshot, retry) {
                  final topics = snapshot.data ?? [];
                  if (!snapshot.hasData ||
                      topics.isEmpty ||
                      snapshot.isAccessFailure) {
                    return AppAsyncStatus(
                      snapshot: snapshot,
                      isEmpty: topics.isEmpty,
                      onRetry: retry,
                      emptyTitle: 'Sin temas registrados aún',
                      emptyMessage: 'Todavía no hay temas clínicos para esta especialidad.',
                      emptyIcon: CupertinoIcons.layers_alt,
                      errorMessage: 'No se pudieron cargar los temas. Inténtalo de nuevo.',
                    );
                  }
                  return Column(
                    children: [
                      AppAsyncNotice(snapshot: snapshot, onRetry: retry),
                      Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 4,
                            bottom: 90,
                          ),
                          itemCount: topics.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final topic = topics[index];
                            return TopicListCard(
                              area: widget.area,
                              topic: topic,
                              number: index + 1,
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
