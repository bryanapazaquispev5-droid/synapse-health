// ============================================================================
// Archivo: topic_cheatsheets_screen.dart
// Propósito: Pantalla de visualizacion y exploracion para las fichas y resumenes medicos [topic_cheatsheets_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/states/app_async_content.dart';
import '../../../core/theme/app_theme.dart';
import '../api/medical_areas_service.dart';
import '../model/cheatsheet_model.dart';
import '../model/medical_area_model.dart';
import '../model/topic_model.dart';
import 'widgets/cheatsheet_item_card.dart';

// Pantalla de interfaz de usuario [TopicCheatsheetsScreen]
class TopicCheatsheetsScreen extends StatefulWidget {
  final MedicalAreaModel area;
  final TopicModel topic;

  const TopicCheatsheetsScreen({
    super.key,
    required this.area,
    required this.topic,
  });

  @override
  State<TopicCheatsheetsScreen> createState() => _TopicCheatsheetsScreenState();
}

// Estado reactivo y control de ciclo de vida para [TopicCheatsheetsScreen]
class _TopicCheatsheetsScreenState extends State<TopicCheatsheetsScreen> {
  final MedicalAreasService _medicalService = MedicalAreasService();
  late final Stream<List<CheatsheetModel>> _cheatsheetsStream;

  // Inicializacion de dependencias y estado local del componente
  // Bloque: Inicialización de controladores, listeners y estado local
  @override
  void initState() {
    super.initState();
    _cheatsheetsStream = _medicalService.getTopicCheatsheetsStream(
      widget.area.id,
      widget.topic.id,
    );
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
                bottom: 8,
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
                      children: [
                        const Icon(
                          CupertinoIcons.chevron_back,
                          size: 24,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.area.name,
                          style: const TextStyle(
                            fontSize: 17,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.topic.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.7,
                  ),
                ),
              ),
            ),
            Expanded(
              child: AppAsyncStreamBuilder<List<CheatsheetModel>>(
                stream: _cheatsheetsStream,
                onRetryStream: () => _medicalService.getTopicCheatsheetsStream(
                  widget.area.id,
                  widget.topic.id,
                ),
                builder: (context, snapshot, retry) {
                  final cheatsheets = snapshot.data ?? [];
                  if (!snapshot.hasData ||
                      cheatsheets.isEmpty ||
                      snapshot.isAccessFailure) {
                    return AppAsyncStatus(
                      snapshot: snapshot,
                      isEmpty: cheatsheets.isEmpty,
                      onRetry: retry,
                      emptyTitle: 'Sin fichas aún',
                      emptyMessage:
                          'Todavía no hay fichas disponibles para este tema.',
                      emptyIcon: CupertinoIcons.doc_text,
                      errorMessage: 'No se pudieron cargar las fichas. Inténtalo de nuevo.',
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
                          itemCount: cheatsheets.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final cs = cheatsheets[index];
                            return CheatsheetItemCard(
                              cheatsheet: cs,
                              area: widget.area,
                              index: index + 1,
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
