// ============================================================================
// File: welcome_screen.dart
// Purpose: Main user interface screen for the authentication flow [welcome_screen].
// ============================================================================

import '../../../core/api/own_profile_repository.dart';
import '../../../core/auth/app_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'widgets/email_verification_banner.dart';
import 'widgets/welcome_profile_card.dart';

// User interface screen [WelcomeScreen]
class WelcomeScreen extends StatelessWidget {
  final AppUser user;

  const WelcomeScreen({super.key, required this.user});

  // Reactive widget tree rendering
  // Section: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    final bool isAnonymous = user.isAnonymous;
    final bool needsVerification = !isAnonymous && !user.emailVerified;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<ProfileRecord>(
          stream: OwnProfileRepository().watch(user.uid),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? {};
            final String name =
                data['name'] ??
                user.displayName ??
                (isAnonymous ? 'Medical Guest' : 'Student');
            final String career =
                data['career'] ??
                (isAnonymous ? 'Temporary Explorer' : 'Health Sciences');
            final int streak = data['studyStreakDays'] ?? 0;
            final String email =
                user.email ??
                (isAnonymous ? 'No email (Guest Mode)' : 'No email');

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  if (needsVerification) ...[
                    EmailVerificationBanner(user: user),
                    const SizedBox(height: 20),
                  ],
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/app_logo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Congratulations, welcome!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your medical learning space in Synapse Health',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 24),
                  WelcomeProfileCard(
                    user: user,
                    name: name,
                    email: email,
                    career: career,
                    streak: streak,
                    isAnonymous: isAnonymous,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 50,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      onPressed: () async {
                        // Section: Protected execution of an asynchronous operation
                        await AppAuth.instance.signOut();
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.square_arrow_right,
                              size: 18,
                              color: AppColors.systemRed,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.systemRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
