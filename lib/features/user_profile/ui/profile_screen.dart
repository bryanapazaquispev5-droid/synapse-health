import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/services/user_local_profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../api/profile_api_service.dart';
import 'widgets/profile_career_sheet.dart';
import 'widgets/profile_edit_name_dialog.dart';
import 'widgets/profile_gender_sheet.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_info_section.dart';
import 'widgets/profile_settings_sheet.dart';
import 'widgets/profile_sign_out_button.dart';
import 'widgets/profile_streak_badge.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

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
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'),
        ),
        backgroundColor: isError ? AppColors.systemRed : AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final bool? confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0x33000000),
      transitionDuration: const Duration(milliseconds: 520),
      pageBuilder: (context, animation, secondaryAnimation) => Opacity(
        opacity: 0.90,
        child: CupertinoAlertDialog(
          title: const Text('Cerrar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text('¿Estás seguro de que deseas salir de tu cuenta médica?', style: TextStyle(fontSize: 13)),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(fontSize: 15)),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cerrar Sesión', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.90, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );
      },
    );

    if (confirm != true) return;

    try {
      await _profileApi.signOut();
    } catch (e) {
      _showFeedback('Error al cerrar sesión: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
              uid: widget.user.uid, name: n, email: e, career: c, gender: g, photoUrl: widget.user.photoURL,
            );
          }
        }

        final String name = data?['name'] ?? _localProfile?.name ?? widget.user.displayName ?? 'Estudiante de Salud';
        final String email = data?['email'] ?? _localProfile?.email ?? widget.user.email ?? 'invitado@synapse.app';
        final String career = data?['career'] ?? _localProfile?.career ?? 'Medicina Humana';
        final String gender = data?['gender'] ?? _localProfile?.gender ?? 'Hombre';
        final int streakDays = data?['studyStreakDays'] ?? 0;
        final bool isGoogle = widget.user.providerData.any((p) => p.providerId == 'google.com');
        final bool isAnonymous = widget.user.isAnonymous;
        final bool isEmailVerified = widget.user.emailVerified || isGoogle;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Perfil',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -1.0,
                          ),
                        ),
                        ProfileStreakBadge(streakDays: streakDays),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                            await _profileApi.updateName(user: widget.user, newName: newName, localProfile: _localProfile);
                            _loadLocalProfile();
                            _showFeedback('¡Nombre actualizado!');
                          } catch (e) {
                            _showFeedback('Error al actualizar nombre: $e', isError: true);
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
                    isEmailVerified: isEmailVerified,
                    isAnonymous: isAnonymous,
                    isGoogle: isGoogle,
                    onEditCareer: () => ProfileCareerSheet.show(
                      context: context,
                      currentCareer: career,
                      onSelectCareer: (newCareer) async {
                        try {
                          await _profileApi.updateCareer(user: widget.user, newCareer: newCareer, localProfile: _localProfile);
                          _loadLocalProfile();
                          _showFeedback('¡Especialidad actualizada!');
                        } catch (e) {
                          _showFeedback('Error al actualizar: $e', isError: true);
                        }
                      },
                    ),
                    onEditGender: () => ProfileGenderSheet.show(
                      context: context,
                      currentGender: gender,
                      onSelectGender: (newGender) async {
                        try {
                          await _profileApi.updateGender(user: widget.user, newGender: newGender, localProfile: _localProfile);
                          _loadLocalProfile();
                          _showFeedback('¡Género actualizado!');
                        } catch (e) {
                          _showFeedback('Error: $e', isError: true);
                        }
                      },
                    ),
                    onResendEmail: () async {
                      try {
                        await widget.user.sendEmailVerification();
                        _showFeedback('Enlace enviado a $email');
                      } catch (e) {
                        _showFeedback('Error: $e', isError: true);
                      }
                    },
                    onOpenSettings: () => ProfileSettingsSheet.show(context: context),
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
