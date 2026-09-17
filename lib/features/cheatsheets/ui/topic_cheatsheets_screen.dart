// ============================================================================
// Archivo: topic_cheatsheets_screen.dart
// Propósito: Pantalla de visualizacion y exploracion para las chuletas y resumenes medicos [topic_cheatsheets_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_theme.dart';
import '../api/medical_areas_service.dart';
import '../model/cheatsheet_model.dart';
import '../model/medical_area_model.dart';
import '../model/topic_model.dart';
import 'widgets/cheatsheet_empty_state.dart';
import 'widgets/cheatsheet_item_card.dart';
import 'widgets/cheatsheet_offline_state.dart';

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
  final ConnectivityService _connectivityService = ConnectivityService();
  late final Stream<List<CheatsheetModel>> _cheatsheetsStream;

  // Inicializacion de dependencias y estado local del componente
  // Bloque: Inicialización de controladores, listeners y estado local
  @override
  void initState() {
    super.initState();
    _cheatsheetsStream = _medicalService.getTopicCheatsheetsStream(widget.area.id, widget.topic.id);
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
              padding: const EdgeInsets.only(left: 12, right: 16, top: 10, bottom: 8),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    minimumSize: const Size(36, 36),
                    onPressed: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.chevron_back, size: 24, color: AppColors.accent),
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
              child: StreamBuilder<bool>(
                stream: _connectivityService.isOnlineStream,
                initialData: _connectivityService.isOnline,
                builder: (context, onlineSnap) {
                  final bool isOnline = onlineSnap.data ?? false;

                  if (!isOnline) {
                    return CheatsheetOfflineState(
                      message: 'Las chuletas médicas se descargan en tiempo real por seguridad. Conéctate a internet para leerlas.',
                    );
                  }

                  return StreamBuilder<List<CheatsheetModel>>(
                    stream: _cheatsheetsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                        return const Center(
                          child: CupertinoActivityIndicator(radius: 14),
                        );
                      }

                      final cheatsheets = snapshot.data ?? [];

                      if (cheatsheets.isEmpty) {
                        return const CheatsheetEmptyState(
                          title: 'Sin chuletas aún',
                          subtitle: 'El contenido médico de este tema se cargará próximamente.',
                          icon: CupertinoIcons.doc_text,
                        );
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 90),
                        itemCount: cheatsheets.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final cs = cheatsheets[index];
                          return CheatsheetItemCard(
                            cheatsheet: cs,
                            area: widget.area,
                            index: index + 1,
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
}
