// ============================================================================
// File: topic_cheatsheets_screen.dart
// Purpose: Screen for browsing study notes and medical summaries [topic_cheatsheets_screen].
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/states/app_async_content.dart';
import '../../../core/theme/app_theme.dart';
import '../api/medical_areas_service.dart';
import '../model/cheatsheet_model.dart';
import '../model/medical_area_model.dart';
import '../model/topic_model.dart';
import 'widgets/cheatsheet_item_card.dart';

// User interface screen [TopicCheatsheetsScreen]
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

// Reactive state and lifecycle management for [TopicCheatsheetsScreen]
class _TopicCheatsheetsScreenState extends State<TopicCheatsheetsScreen> {
  final MedicalAreasService _medicalService = MedicalAreasService();
  late final Stream<List<CheatsheetModel>> _cheatsheetsStream;

  // Initialize the component dependencies and local state
  // Block: Initialize controllers, listeners, and local state
  @override
  void initState() {
    super.initState();
    _cheatsheetsStream = _medicalService.getTopicCheatsheetsStream(
      widget.area.id,
      widget.topic.id,
    );
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
                bottom: 8,
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
                      children: [
                        const Icon(
                          CupertinoIcons.chevron_back,
                          size: 24,
                          color: AppColors.accent,
                        ),
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
              child: AppAsyncStreamBuilder<List<CheatsheetModel>>(
                stream: _cheatsheetsStream,
                onRetryStream: () => _medicalService.getTopicCheatsheetsStream(
                  widget.area.id,
                  widget.topic.id,
                ),
                builder: (context, snapshot, retry) {
                  final cheatsheets = snapshot.data ?? [];
                  if (!snapshot.hasData ||
                      cheatsheets.isEmpty ||
                      snapshot.isAccessFailure) {
                    return AppAsyncStatus(
                      snapshot: snapshot,
                      isEmpty: cheatsheets.isEmpty,
                      onRetry: retry,
                      emptyTitle: 'No study notes yet',
                      emptyMessage:
                          'There are no study notes available for this topic yet.',
                      emptyIcon: CupertinoIcons.doc_text,
                      errorMessage: 'Could not load study notes. Please try again.',
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
                          itemCount: cheatsheets.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final cs = cheatsheets[index];
                            return CheatsheetItemCard(
                              cheatsheet: cs,
                              area: widget.area,
                              index: index + 1,
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
