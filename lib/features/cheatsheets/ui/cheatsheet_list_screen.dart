// ============================================================================
// File: cheatsheet_list_screen.dart
// Purpose: Screen for browsing study notes and medical summaries [cheatsheet_list_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/states/app_async_content.dart';
import '../../../core/theme/app_theme.dart';
import '../api/medical_areas_service.dart';
import '../model/medical_area_model.dart';
import 'widgets/medical_area_card.dart';

// User interface screen [CheatsheetListScreen]
class CheatsheetListScreen extends StatefulWidget {
  const CheatsheetListScreen({super.key});

  @override
  State<CheatsheetListScreen> createState() => _CheatsheetListScreenState();
}

// Reactive state and lifecycle management for [CheatsheetListScreen]
class _CheatsheetListScreenState extends State<CheatsheetListScreen>
    with AutomaticKeepAliveClientMixin {
  final MedicalAreasService _service = MedicalAreasService();
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<MedicalAreaModel>> _areasStream;
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  // Initialize the component dependencies and local state
  @override
  void initState() {
    super.initState();
    _areasStream = _service.getAreasStream();
  }

  // Release controllers and resources to prevent memory leaks
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Reactive rendering of the widget tree
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
                      top: 16,
                      bottom: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'Study Notes',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -1.0,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            snapshot.hasData && !snapshot.isAccessFailure
                                ? '${allAreas.length} Areas'
                                : 'Areas',
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      placeholder: 'Search specialties or codes...',
                      placeholderStyle: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textMuted,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      borderRadius: BorderRadius.circular(11),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      backgroundColor: const Color(0xFFE3E3E8),
                      onChanged: (val) => setState(
                        () => _searchQuery = val.trim().toLowerCase(),
                      ),
                      onSuffixTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
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
                      emptyTitle: 'No medical areas available',
                      emptyMessage:
                          'There are no specialties to browse yet.',
                      errorMessage: 'Could not load specialties. Please try again.',
                    ),
                  )
                else if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      title: 'No results found for "$_searchQuery"',
                      message:
                          'Check the spelling or try another term.',
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
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 6,
                      bottom: 100,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.12,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final area = filtered[index];
                        return MedicalAreaCard(area: area);
                      }, childCount: filtered.length),
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
