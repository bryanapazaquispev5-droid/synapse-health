// ============================================================================
// File: main_navigation_wrapper.dart
// Purpose: Main navigation controller [main_navigation_wrapper] con transiciones fluidas estilo liquid wave.
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/auth/app_auth.dart';
import '../../../core/api/own_profile_repository.dart';

import '../../../core/services/user_local_profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_floating_pill.dart';
import '../../cheatsheets/ui/cheatsheet_list_screen.dart';
import '../../personal_progress/ui/personal_progress_screen.dart';
import '../../quizzes/ui/quiz_areas_screen.dart';
import '../../user_profile/ui/profile_screen.dart';
import 'widgets/liquid_wave_transition.dart';

// Main definition of class [MainNavigationWrapper]
class MainNavigationWrapper extends StatefulWidget {
  final AppUser user;
  final int initialIndex;

  const MainNavigationWrapper({
    super.key,
    required this.user,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

// Reactive state and lifecycle management for [MainNavigationWrapper]
class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  late int _currentIndex;
  late final Stream<ProfileRecord> _userStream;
  String _cachedGender = 'Hombre';

  // Initialize component dependencies and local state
  // Section: Initialize controllers, listeners, and local state
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _userStream = OwnProfileRepository().watch(widget.user.uid);
    _loadCachedGender();
  }

  Future<void> _loadCachedGender() async {
    final p = await UserLocalProfileService().getProfile(uid: widget.user.uid);
    if (mounted) {
      // Section: Reactive notification and UI rebuild
      setState(() => _cachedGender = p.gender);
    }
  }

  // Reactive widget tree rendering
  // Section: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          LiquidWaveTransition(
            currentIndex: _currentIndex,
            children: [
              const CheatsheetListScreen(),
              const QuizAreasScreen(),
              const PersonalProgressScreen(),
              ProfileScreen(user: widget.user),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: StreamBuilder<ProfileRecord>(
              stream: _userStream,
              builder: (context, snapshot) {
                final String gender =
                    snapshot.data?.data()?['gender'] ?? _cachedGender;
                final String userGif = (gender.toLowerCase() == 'mujer')
                    ? 'assets/images/user_girl.gif'
                    : 'assets/images/user_boy.gif';

                return BottomFloatingPill(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  items: [
                    const BottomPillItem(
                      assetPath: 'assets/images/book.gif',
                      label: 'Study Notes',
                    ),
                    const BottomPillItem(
                      assetPath: 'assets/images/quiz.gif',
                      label: 'Quizzes',
                    ),
                    const BottomPillItem(
                      assetPath: 'assets/images/progreso.gif',
                      label: 'Progress',
                    ),
                    BottomPillItem(assetPath: userGif, label: 'Profile'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
