import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_theme.dart';
import '../models/cheatsheet_model.dart';
import '../models/medical_area_model.dart';
import '../models/topic_model.dart';
import '../services/medical_areas_service.dart';
import 'cheatsheet_detail_screen.dart';

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

class _TopicCheatsheetsScreenState extends State<TopicCheatsheetsScreen> {
  final MedicalAreasService _medicalService = MedicalAreasService();
  final ConnectivityService _connectivityService = ConnectivityService();
  late final Stream<List<CheatsheetModel>> _cheatsheetsStream;

  @override
  void initState() {
    super.initState();
    _cheatsheetsStream = _medicalService.getTopicCheatsheetsStream(widget.area.id, widget.topic.id);
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

            // Large Title del Tema
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

            // Lista de chuletas en tiempo real desde Firestore con verificación de conectividad
            Expanded(
              child: StreamBuilder<bool>(
                stream: _connectivityService.isOnlineStream,
                initialData: _connectivityService.isOnline,
                builder: (context, onlineSnap) {
                  final bool isOnline = onlineSnap.data ?? false;

                  if (!isOnline) {
                    return _buildOfflineState();
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
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E5EA),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(CupertinoIcons.doc_text, size: 30, color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Sin chuletas aún',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'El contenido médico de este tema se cargará próximamente.',
                                  style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 90),
                        itemCount: cheatsheets.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final cs = cheatsheets[index];
                          return _buildCheatsheetCard(context, cs, index + 1);
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

  Widget _buildCheatsheetCard(BuildContext context, CheatsheetModel cs, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          AppPageRoute(
            child: CheatsheetDetailScreen(cheatsheet: cs, area: widget.area),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.6),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'CHULETA #$index',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(CupertinoIcons.time, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${cs.readMinutes} min',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              cs.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.4,
              ),
            ),
            if (cs.summary.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                cs.summary,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (cs.sourceBook.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(CupertinoIcons.book, size: 12, color: AppColors.accent),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      cs.sourceBook,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                if (cs.keyPoints.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${cs.keyPoints.length} Puntos clave',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (cs.mnemonics.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.systemOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Mnemotecnia',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.systemOrange),
                    ),
                  ),
                ],
                const Spacer(),
                const Icon(CupertinoIcons.chevron_forward, size: 14, color: Color(0xFFC7C7CC)),
              ],
            ),
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
              'Las chuletas médicas se descargan en tiempo real por seguridad. Conéctate a internet para leerlas.',
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
}
