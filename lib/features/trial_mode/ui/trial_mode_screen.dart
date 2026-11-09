import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth_login/model/trial_mode_session.dart';
import '../../cheatsheets/ui/cheatsheet_detail_screen.dart';
import '../../quizzes/ui/quiz_session_screen.dart';
import '../data/trial_content.dart';

/// Local-only preview: one topic, two notes, and a single-question quiz level.
class TrialModeScreen extends StatelessWidget {
  const TrialModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = TrialContent.notes;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Try Synapse Health'),
        leading: IconButton(
          tooltip: 'Return to sign in',
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: TrialModeSession.end,
        ),
        actions: [
          TextButton(
            onPressed: TrialModeSession.end,
            child: const Text('Sign in'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _TrialNotice(),
          const SizedBox(height: 20),
          Text(
            TrialContent.area.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            TrialContent.topic.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            TrialContent.topic.description,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          Text('Study Notes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final note in content)
            Card(
              child: ListTile(
                leading: const Icon(CupertinoIcons.book),
                title: Text(note.title),
                subtitle: Text(note.summary),
                trailing: const Icon(CupertinoIcons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CheatsheetDetailScreen(
                      cheatsheet: note,
                      area: TrialContent.area,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 18),
          Text('Quiz', style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: ListTile(
              leading: const Icon(CupertinoIcons.checkmark_seal),
              title: const Text('Level 1 · Anatomical Position'),
              subtitle: const Text('One practice question'),
              trailing: const Icon(CupertinoIcons.play_fill),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => QuizSessionScreen(
                    quizzes: TrialContent.quizLevelOne,
                    areaTitle: TrialContent.area.name,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrialNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
    ),
    child: const Text(
      'Preview mode uses sample content stored on this device. '
      'Your answers and progress are not saved, and AWS courses are unavailable.',
    ),
  );
}
