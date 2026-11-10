// ============================================================================
// File: quiz_areas_screen.dart
// Purpose: Screen for selecting and listing clinical quizzes [quiz_areas_screen].
// ============================================================================

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/api/own_profile_repository.dart';
import '../../../core/auth/app_auth.dart';
import '../../../core/services/user_local_profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/states/app_async_content.dart';
import '../../cheatsheets/api/medical_areas_service.dart';
import '../../cheatsheets/model/medical_area_model.dart';
import 'widgets/quiz_course_card.dart';

// User interface screen [QuizAreasScreen]
class QuizAreasScreen extends StatefulWidget {
  const QuizAreasScreen({super.key});

  @override
  State<QuizAreasScreen> createState() => _QuizAreasScreenState();
}

class _QuizAreasScreenState extends State<QuizAreasScreen>
    with AutomaticKeepAliveClientMixin {
  final MedicalAreasService _medicalAreasService = MedicalAreasService();
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
    _areasStream = _medicalAreasService.getAreasStream();
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

  Widget _buildCourseList(List<MedicalAreaModel> list, {bool isBottom = false}) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, isBottom ? 100 : 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => QuizCourseCard(area: list[index]),
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
          onRetryStream: _medicalAreasService.getAreasStream,
          builder: (context, snapshot, retry) {
            final allAreas = snapshot.data ?? [];
            final filteredAreas = allAreas.where((a) {
              return a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  a.code.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            final recommended = filteredAreas.where((a) => a.isRecommendedFor(_userCareer)).toList();
            final others = filteredAreas.where((a) => !a.isRecommendedFor(_userCareer)).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
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
                          'Select a course or subject to test your medical knowledge.',
                          style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.35),
                        ),
                        const SizedBox(height: 16),
                        CupertinoSearchTextField(
                          controller: _searchController,
                          placeholder: 'Search courses or specialties...',
                          onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        ),
                        const SizedBox(height: 10),
                      ],
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
                      emptyTitle: 'No quiz courses available',
                      emptyMessage: 'Available courses will appear here.',
                    ),
                  )
                else if (filteredAreas.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      title: 'No courses found',
                      message: 'Try another term or clear your search.',
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
                      'CURSOS RECOMENDADOS (${_userCareer.toUpperCase()})',
                      icon: CupertinoIcons.star_fill,
                      iconColor: AppColors.systemOrange,
                    ),
                    _buildCourseList(recommended, isBottom: others.isEmpty),
                  ],
                  if (others.isNotEmpty) ...[
                    _buildSectionHeader('OTROS CURSOS DISPONIBLES'),
                    _buildCourseList(others, isBottom: true),
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
