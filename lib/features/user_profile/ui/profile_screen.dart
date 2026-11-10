import 'package:flutter/material.dart';

import '../../../core/auth/app_auth.dart';
import '../../../core/services/user_local_profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ios_top_banner.dart';
import '../api/profile_api_service.dart';
import 'widgets/profile_career_sheet.dart';
import 'widgets/profile_edit_name_dialog.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_info_section.dart';
import 'widgets/profile_settings_sheet.dart';
import 'widgets/profile_sign_out_button.dart';
import 'widgets/profile_sign_out_dialog.dart';
import 'widgets/profile_streak_badge.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser user;

  const ProfileScreen({super.key, required this.user});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileApiService _profileApi = ProfileApiService();
  LocalUserProfile? _localProfile;

  @override
  void initState() {
    super.initState();
    _loadLocalProfile();
  }

  Future<void> _loadLocalProfile() async {
    final profile = await UserLocalProfileService().getProfile(
      uid: widget.user.uid,
      fallbackName: widget.user.displayName,
      fallbackEmail: widget.user.email,
      fallbackPhotoUrl: widget.user.photoURL,
    );
    if (mounted) setState(() => _localProfile = profile);
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    (isError ? IosTopBanner.error : IosTopBanner.success)(context, message);
  }

  Future<void> _handleSignOut() async {
    if (await ProfileSignOutDialog.show(context) != true) return;
    try {
      await _profileApi.signOut();
    } catch (error) {
      _showFeedback('Error signing out: $error', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProfileRecord>(
      stream: _profileApi.getUserProfileStream(widget.user.uid),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        if (data != null) {
          final String n = data['name'] ?? widget.user.displayName ?? '';
          final String e = data['email'] ?? widget.user.email ?? '';
          final String c = data['career'] ?? '';
          final String g = data['gender'] ?? '';
          if (n.isNotEmpty || c.isNotEmpty || g.isNotEmpty) {
            UserLocalProfileService().saveProfile(
              uid: widget.user.uid,
              name: n,
              email: e,
              career: c,
              gender: g,
              photoUrl: widget.user.photoURL,
            );
          }
        }

        final String name =
            data?['name'] ??
            _localProfile?.name ??
            widget.user.displayName ??
            'Healthcare Student';
        final String email =
            data?['email'] ??
            _localProfile?.email ??
            widget.user.email ??
            'invitado@synapse.app';
        final String career =
            data?['career'] ?? _localProfile?.career ?? 'Medicine';
        final String gender =
            data?['gender'] ?? _localProfile?.gender ?? 'Hombre';

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
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
                      bottom: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -1.0,
                          ),
                        ),
                        ProfileStreakBadge(
                          streakDays: data?['studyStreakDays'] ?? 0,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ProfileHeaderCard(
                      name: name,
                      email: email,
                      gender: gender,
                      photoUrl: widget.user.photoURL,
                      photoBytes: _localProfile?.photoBytes,
                      onEditName: () => ProfileEditNameDialog.show(
                        context: context,
                        currentName: name,
                        onSave: (newName) async {
                          try {
                            await _profileApi.updateName(
                              user: widget.user,
                              newName: newName,
                              localProfile: _localProfile,
                            );
                            _loadLocalProfile();
                            _showFeedback('Name updated!');
                          } catch (e) {
                            _showFeedback(
                              'Error updating name: $e',
                              isError: true,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ProfileInfoSection(
                    career: career,
                    gender: gender,
                    uid: widget.user.uid,
                    onEditCareer: () => ProfileCareerSheet.show(
                      context: context,
                      currentCareer: career,
                      onSelectCareer: (newCareer) async {
                        try {
                          await _profileApi.updateCareer(
                            user: widget.user,
                            newCareer: newCareer,
                            localProfile: _localProfile,
                          );
                          _loadLocalProfile();
                          _showFeedback('Specialty updated!');
                        } catch (e) {
                          _showFeedback('Error updating: $e', isError: true);
                        }
                      },
                    ),
                    onOpenSettings: () =>
                        ProfileSettingsSheet.show(context: context),
                    onShowFeedback: (msg) => _showFeedback(msg),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ProfileSignOutButton(onSignOut: _handleSignOut),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
