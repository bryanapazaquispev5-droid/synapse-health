// ============================================================================
// Archivo: area_topics_screen.dart
// Propósito: Pantalla de visualización y consulta para chuletas y resúmenes médicos estructurados [area_topics_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_theme.dart';
import '../api/medical_areas_service.dart';
import '../model/medical_area_model.dart';
import '../model/topic_model.dart';
import 'widgets/cheatsheet_empty_state.dart';
import 'widgets/cheatsheet_offline_state.dart';
import 'widgets/topic_list_card.dart';

/// Pantalla principal de interfaz de usuario [AreaTopicsScreen].
class AreaTopicsScreen extends StatefulWidget {
  final MedicalAreaModel area;

  const AreaTopicsScreen({super.key, required this.area});

  @override
  State<AreaTopicsScreen> createState() => _AreaTopicsScreenState();
}

/// Estado mutable y controlador del ciclo de vida reactivo para [AreaTopicsScreen].
class _AreaTopicsScreenState extends State<AreaTopicsScreen> {
  final MedicalAreasService _medicalService = MedicalAreasService();
  final ConnectivityService _connectivityService = ConnectivityService();
  late final Stream<List<TopicModel>> _topicsStream;

  // Bloque: Inicialización de controladores, listeners y estado local
  @override
  void initState() {
    super.initState();
    _topicsStream = _medicalService.getTopicsStream(widget.area.id);
  }

  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 16, top: 10, bottom: 10),
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
              child: StreamBuilder<bool>(
                stream: _connectivityService.isOnlineStream,
                initialData: _connectivityService.isOnline,
                builder: (context, onlineSnap) {
                  final bool isOnline = onlineSnap.data ?? false;

                  if (!isOnline) {
                    return CheatsheetOfflineState(
                      message: 'Los temas clínicos no se almacenan localmente. Conéctate a internet para ver este temario.',
                    );
                  }

                  return StreamBuilder<List<TopicModel>>(
                    stream: _topicsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                        return const Center(
                          child: CupertinoActivityIndicator(radius: 14),
                        );
                      }

                      final topics = snapshot.data ?? [];

                      if (topics.isEmpty) {
                        return const CheatsheetEmptyState(
                          title: 'Sin temas registrados aún',
                          subtitle: 'Los temas clínicos de esta especialidad se sincronizarán en tiempo real.',
                          icon: CupertinoIcons.layers_alt,
                        );
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 90),
                        itemCount: topics.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final topic = topics[index];
                          return TopicListCard(
                            area: widget.area,
                            topic: topic,
                            number: index + 1,
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
