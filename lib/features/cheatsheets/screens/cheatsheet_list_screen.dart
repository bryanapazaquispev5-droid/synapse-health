import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_theme.dart';
import '../models/medical_area_model.dart';
import '../services/medical_areas_service.dart';
import 'area_topics_screen.dart';

class CheatsheetListScreen extends StatefulWidget {
  const CheatsheetListScreen({super.key});

  @override
  State<CheatsheetListScreen> createState() => _CheatsheetListScreenState();
}

class _CheatsheetListScreenState extends State<CheatsheetListScreen> with AutomaticKeepAliveClientMixin {
  final MedicalAreasService _service = MedicalAreasService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<MedicalAreaModel>> _areasStream;
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _areasStream = _service.getAreasStream();
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
        child: StreamBuilder<bool>(
          stream: _connectivityService.isOnlineStream,
          initialData: _connectivityService.isOnline,
          builder: (context, onlineSnap) {
            final bool isOnline = onlineSnap.data ?? false;

            if (!isOnline) {
              return _buildOfflineView();
            }

            return StreamBuilder<List<MedicalAreaModel>>(
              stream: _areasStream,
              builder: (context, snapshot) {
                final bool isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;
                final allAreas = snapshot.data ?? [];
                final filtered = allAreas.where((a) {
                  return a.name.toLowerCase().contains(_searchQuery) ||
                      a.code.toLowerCase().contains(_searchQuery);
                }).toList();

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    // iOS Large Title Navigation Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'Chuletas',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: -1.0,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border, width: 0.8),
                              ),
                              child: Text(
                                '${allAreas.length} Áreas',
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

                    // Barra de búsqueda nativa estilo Apple
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: CupertinoSearchTextField(
                          controller: _searchController,
                          placeholder: 'Buscar especialidad o código...',
                          placeholderStyle: const TextStyle(fontSize: 15, color: AppColors.textMuted),
                          style: const TextStyle(fontSize: 15, color: AppColors.primary, fontWeight: FontWeight.w500),
                          borderRadius: BorderRadius.circular(11),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          backgroundColor: const Color(0xFFE3E3E8),
                          onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                          onSuffixTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                      ),
                    ),

                    // Contenido
                    if (isLoading)
                      const SliverFillRemaining(
                        child: Center(
                          child: CupertinoActivityIndicator(radius: 14),
                        ),
                      )
                    else if (allAreas.isEmpty)
                      SliverFillRemaining(
                        child: _buildEmptyFirestoreView(),
                      )
                    else if (filtered.isEmpty)
                      SliverFillRemaining(
                        child: _buildNoSearchResults(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 100),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final area = filtered[index];
                              return _buildAppleAreaCard(context, area);
                            },
                            childCount: filtered.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppleAreaCard(BuildContext context, MedicalAreaModel area) {
    return GestureDetector(
      key: ValueKey(area.id),
      onTap: () {
        Navigator.push(
          context,
          AppPageRoute(
            child: AreaTopicsScreen(area: area),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.6),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: area.hasImage
                        ? area.buildLogoWidget(size: 26)
                        : const Icon(CupertinoIcons.book_fill, size: 22, color: AppColors.accent),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${area.order}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      area.topicsCount > 0
                          ? '${area.topicsCount} ${area.topicsCount == 1 ? "tema" : "temas"}'
                          : 'Disponible',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: area.topicsCount > 0 ? AppColors.accent : AppColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      CupertinoIcons.chevron_forward,
                      size: 13,
                      color: Color(0xFFC7C7CC),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.search, size: 44, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            'No se encontró "$_searchQuery"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Comprueba la ortografía o prueba con otro término.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineView() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEB),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(CupertinoIcons.wifi_slash, size: 40, color: AppColors.systemRed),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sin conexión a internet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para proteger la seguridad médica y mantener la información actualizada, las chuletas se cargan exclusivamente en línea desde la nube.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              borderRadius: BorderRadius.circular(14),
              onPressed: () async {
                final isConnected = await _connectivityService.checkConnection();
                if (!mounted) return;
                if (!isConnected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Aún no hay conexión a internet. Revisa tu Wi-Fi o datos móviles.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: AppColors.systemRed,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(CupertinoIcons.arrow_clockwise, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Reintentar conexión',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFirestoreView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(CupertinoIcons.folder_badge_minus, size: 32, color: AppColors.accent),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay áreas médicas disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Las especialidades médicas se sincronizarán en tiempo real.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
