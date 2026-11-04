// ============================================================================
// File: quiz_areas_screen.dart
// Purpose: Screen for selecting and listing clinical quizzes [quiz_areas_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

// Reactive state and lifecycle management for [QuizAreasScreen]
class _QuizAreasScreenState extends State<QuizAreasScreen>
    with AutomaticKeepAliveClientMixin {
  final MedicalAreasService _medicalAreasService = MedicalAreasService();
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<MedicalAreaModel>> _areasStream;
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  // Initialize the component dependencies and local state
  // Block: Initialize controllers, listeners, and local state
  @override
  void initState() {
    super.initState();
    _areasStream = _medicalAreasService.getAreasStream();
  }

  // Release controllers and resources to prevent memory leaks
  // Block: Release resources and controllers to prevent memory leaks
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Reactive rendering of the widget tree
  // Block: Reactive rendering of the main widget tree
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
              return a.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  a.code.toLowerCase().contains(_searchQuery.toLowerCase());
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
                      top: 20,
                      bottom: 8,
                    ),
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
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CupertinoSearchTextField(
                          controller: _searchController,
                          placeholder: 'Search courses or specialties...',
                          onChanged: (val) =>
                              setState(() => _searchQuery = val.trim()),
                        ),
                        const SizedBox(height: 18),
                      ],
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
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final area = filteredAreas[index];
                        return QuizCourseCard(area: area);
                      }, childCount: filteredAreas.length),
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
