import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_theme.dart';
import '../models/medical_area_model.dart';
import '../models/topic_model.dart';
import '../services/medical_areas_service.dart';
import 'topic_cheatsheets_screen.dart';

class AreaTopicsScreen extends StatefulWidget {
  final MedicalAreaModel area;

  const AreaTopicsScreen({super.key, required this.area});

  @override
  State<AreaTopicsScreen> createState() => _AreaTopicsScreenState();
}

class _AreaTopicsScreenState extends State<AreaTopicsScreen> {
  final MedicalAreasService _medicalService = MedicalAreasService();
  final ConnectivityService _connectivityService = ConnectivityService();
  late final Stream<List<TopicModel>> _topicsStream;

  @override
  void initState() {
    super.initState();
    _topicsStream = _medicalService.getTopicsStream(widget.area.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior estilo Apple Navigation Bar
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

            // Large Title de la especialidad
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

            // Lista de temas / subtemas en tiempo real desde Firestore con verificación de conectividad
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

                      final topics = snapshot.data ?? [];

                      if (topics.isEmpty) {
                        return _buildEmptyTopicsState(context);
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 90),
                        itemCount: topics.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final topic = topics[index];
                          return _buildTopicCard(context, topic, index + 1);
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

  Widget _buildTopicCard(BuildContext context, TopicModel topic, int number) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          AppPageRoute(
            child: TopicCheatsheetsScreen(area: widget.area, topic: topic),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.6),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (topic.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      topic.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_forward, size: 14, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineState() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(CupertinoIcons.wifi_slash, size: 36, color: AppColors.systemRed),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Sin conexión a internet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Los temas clínicos no se almacenan localmente. Conéctate a internet para ver este temario.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              borderRadius: BorderRadius.circular(12),
              onPressed: () => _connectivityService.checkConnection(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(CupertinoIcons.arrow_clockwise, size: 16),
                  SizedBox(width: 6),
                  Text('Reintentar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTopicsState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.area.hasImage)
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: widget.area.buildLogoWidget(size: 38),
                ),
              )
            else
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(CupertinoIcons.layers_alt, color: AppColors.textMuted, size: 32),
                ),
              ),
            const SizedBox(height: 18),
            const Text(
              'Sin temas registrados aún',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Los temas clínicos de esta especialidad se sincronizarán en tiempo real.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
