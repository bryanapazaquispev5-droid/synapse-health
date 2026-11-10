// ============================================================================
// File: cheatsheet_list_screen.dart
// Purpose: Screen for browsing study notes and medical summaries [cheatsheet_list_screen].
// ============================================================================

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/api/own_profile_repository.dart';
import '../../../core/auth/app_auth.dart';
import '../../../core/services/user_local_profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/states/app_async_content.dart';
import '../api/medical_areas_service.dart';
import '../model/medical_area_model.dart';
import 'widgets/medical_area_card.dart';

// User interface screen [CheatsheetListScreen]
class CheatsheetListScreen extends StatefulWidget {
  const CheatsheetListScreen({super.key});

  @override
  State<CheatsheetListScreen> createState() => _CheatsheetListScreenState();
}

class _CheatsheetListScreenState extends State<CheatsheetListScreen>
    with AutomaticKeepAliveClientMixin {
  final MedicalAreasService _service = MedicalAreasService();
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<MedicalAreaModel>> _areasStream;
  StreamSubscription<ProfileRecord>? _profileSub;
  String _searchQuery = '';
  String _userCareer = 'Medicine';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _areasStream = _service.getAreasStream();
    final uid = AppAuth.instance.currentUser?.uid;
    if (uid != null) {
      UserLocalProfileService().getProfile(uid: uid).then((p) {
        if (mounted) setState(() => _userCareer = p.career);
      });
      _profileSub = OwnProfileRepository().watch(uid).listen((rec) {
        final c = rec.data()?['career'];
        if (c is String && c.isNotEmpty && mounted && c != _userCareer) {
          setState(() => _userCareer = c);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _profileSub?.cancel();
    super.dispose();
  }

  Widget _buildSectionHeader(String title, {IconData? icon, Color? iconColor}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: iconColor ?? AppColors.accent),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaGrid(List<MedicalAreaModel> list, {bool isBottom = false}) {
    return SliverPadding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: isBottom ? 100 : 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => MedicalAreaCard(area: list[index]),
          childCount: list.length,
        ),
      ),
    );
  }

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

            final recommended = filtered.where((a) => a.isRecommendedFor(_userCareer)).toList();
            final others = filtered.where((a) => !a.isRecommendedFor(_userCareer)).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'Study Notes',
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -1.0),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, width: 0.8)),
                          child: Text(
                            snapshot.hasData && !snapshot.isAccessFailure ? '${allAreas.length} Areas' : 'Areas',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      placeholder: 'Search specialties or codes...',
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
                if (snapshot.hasData && allAreas.isNotEmpty && !snapshot.isAccessFailure)
                  SliverToBoxAdapter(child: AppAsyncNotice(snapshot: snapshot, onRetry: retry)),
                if (!snapshot.hasData || allAreas.isEmpty || snapshot.isAccessFailure)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppAsyncStatus(
                      snapshot: snapshot,
                      isEmpty: allAreas.isEmpty,
                      onRetry: retry,
                      emptyTitle: 'No medical areas available',
                      emptyMessage: 'There are no specialties to browse yet.',
                      errorMessage: 'Could not load specialties. Please try again.',
                    ),
                  )
                else if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      title: 'No results found for "$_searchQuery"',
                      message: 'Check the spelling or try another term.',
                      icon: CupertinoIcons.search,
                      actionLabel: 'Clear search',
                      onAction: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                  )
                else ...[
                  if (recommended.isNotEmpty) ...[
                    _buildSectionHeader(
                      'RECOMENDADO PARA TU CARRERA (${_userCareer.toUpperCase()})',
                      icon: CupertinoIcons.star_fill,
                      iconColor: AppColors.systemOrange,
                    ),
                    _buildAreaGrid(recommended, isBottom: others.isEmpty),
                  ],
                  if (others.isNotEmpty) ...[
                    _buildSectionHeader('OTROS CURSOS Y ESPECIALIDADES'),
                    _buildAreaGrid(others, isBottom: true),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
