// ============================================================================
// File: area_topics_screen.dart
// Purpose: Screen for browsing study notes and medical summaries [area_topics_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/states/app_async_content.dart';
import '../../../core/theme/app_theme.dart';
import '../api/medical_areas_service.dart';
import '../model/medical_area_model.dart';
import '../model/topic_model.dart';
import 'widgets/topic_list_card.dart';

// User interface screen [AreaTopicsScreen]
class AreaTopicsScreen extends StatefulWidget {
  final MedicalAreaModel area;

  const AreaTopicsScreen({super.key, required this.area});

  @override
  State<AreaTopicsScreen> createState() => _AreaTopicsScreenState();
}

// Reactive state and lifecycle management for [AreaTopicsScreen]
class _AreaTopicsScreenState extends State<AreaTopicsScreen> {
  final MedicalAreasService _medicalService = MedicalAreasService();
  late final Stream<List<TopicModel>> _topicsStream;

  // Initialize the component dependencies and local state
  // Block: Initialize controllers, listeners, and local state
  @override
  void initState() {
    super.initState();
    _topicsStream = _medicalService.getTopicsStream(widget.area.id);
  }

  // Reactive rendering of the widget tree
  // Block: Reactive rendering of the main widget tree
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
                bottom: 10,
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
                      children: const [
                        Icon(
                          CupertinoIcons.chevron_back,
                          size: 24,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'Back',
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
              child: AppAsyncStreamBuilder<List<TopicModel>>(
                stream: _topicsStream,
                onRetryStream: () =>
                    _medicalService.getTopicsStream(widget.area.id),
                builder: (context, snapshot, retry) {
                  final topics = snapshot.data ?? [];
                  if (!snapshot.hasData ||
                      topics.isEmpty ||
                      snapshot.isAccessFailure) {
                    return AppAsyncStatus(
                      snapshot: snapshot,
                      isEmpty: topics.isEmpty,
                      onRetry: retry,
                      emptyTitle: 'No topics yet',
                      emptyMessage: 'There are no clinical topics for this specialty yet.',
                      emptyIcon: CupertinoIcons.layers_alt,
                      errorMessage: 'Could not load topics. Please try again.',
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
                          itemCount: topics.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final topic = topics[index];
                            return TopicListCard(
                              area: widget.area,
                              topic: topic,
                              number: index + 1,
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
