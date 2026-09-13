import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/user_local_profile_service.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    if (mounted) {
      setState(() => _localProfile = profile);
    }
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

  Future<T?> _showSmoothCupertinoDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0x33000000),
      transitionDuration: const Duration(milliseconds: 520),
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.90, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  Future<T?> _showSmoothCupertinoActionSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0x5A000000),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _handleSignOut() async {
    final bool? confirm = await _showSmoothCupertinoDialog<bool>(
      context: context,
      builder: (context) => Opacity(
        opacity: 0.90,
        child: CupertinoAlertDialog(
          title: const Text(
            'Cerrar Sesión',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text(
              '¿Estás seguro de que deseas salir de tu cuenta médica?',
              style: TextStyle(fontSize: 13),
            ),
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
    );

    if (confirm != true) return;

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      _showFeedback('Error al cerrar sesión: $e', isError: true);
    }
  }

  void _openEditNameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    _showSmoothCupertinoDialog(
      context: context,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final offsetY = bottomInset > 0 ? 100.0 : 0.0;
        return Transform.translate(
          offset: Offset(0, offsetY),
          child: Opacity(
            opacity: 0.90,
            child: CupertinoAlertDialog(
              title: const Text(
                'Editar Nombre',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ingresa tu nombre y apellidos para tu credencial médica:',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    CupertinoTextField(
                      controller: controller,
                      autofocus: false,
                      textCapitalization: TextCapitalization.words,
                      placeholder: 'Nombre y Apellidos',
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: const Color(0xFFD1D1D6), width: 0.8),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                ),
                CupertinoDialogAction(
                  onPressed: () async {
                    final newName = controller.text.trim();
                    if (newName.isEmpty) return;
                    Navigator.pop(context);
                    try {
                      await widget.user.updateDisplayName(newName);
                      await UserLocalProfileService().saveProfile(
                        uid: widget.user.uid,
                        name: newName,
                        email: widget.user.email ?? '',
                        career: _localProfile?.career ?? 'Medicina Humana',
                        gender: _localProfile?.gender ?? 'Hombre',
                        photoUrl: widget.user.photoURL,
                      );
                      _loadLocalProfile();
                      await FirebaseFirestore.instance
                          .collection(AppConstants.firestoreUsers)
                          .doc(widget.user.uid)
                          .set({'name': newName}, SetOptions(merge: true));
                      _showFeedback('¡Nombre actualizado!');
                    } catch (e) {
                      _showFeedback('Error al actualizar nombre: $e', isError: true);
                    }
                  },
                  child: const Text(
                    'Guardar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateCareer(String newCareer) async {
    if (newCareer.trim().isEmpty) return;
    try {
      await UserLocalProfileService().saveProfile(
        uid: widget.user.uid,
        name: _localProfile?.name ?? widget.user.displayName ?? '',
        email: widget.user.email ?? '',
        career: newCareer.trim(),
        gender: _localProfile?.gender ?? 'Hombre',
        photoUrl: widget.user.photoURL,
      );
      _loadLocalProfile();
      await FirebaseFirestore.instance
          .collection(AppConstants.firestoreUsers)
          .doc(widget.user.uid)
          .set({'career': newCareer.trim()}, SetOptions(merge: true));
      _showFeedback('¡Especialidad actualizada!');
    } catch (e) {
      _showFeedback('Error al actualizar especialidad: $e', isError: true);
    }
  }

  void _openCustomCareerDialog(String currentCareer) {
    final controller = TextEditingController(text: currentCareer);
    _showSmoothCupertinoDialog(
      context: context,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final offsetY = bottomInset > 0 ? 100.0 : 0.0;
        return Transform.translate(
          offset: Offset(0, offsetY),
          child: Opacity(
            opacity: 0.90,
            child: CupertinoAlertDialog(
              title: const Text(
                'Otra Especialidad',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.4),
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Escribe tu carrera médica o especialidad:',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    CupertinoTextField(
                      controller: controller,
                      autofocus: false,
                      textCapitalization: TextCapitalization.words,
                      placeholder: 'Ej: Cardiología, Pediatría...',
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: const Color(0xFFD1D1D6), width: 0.8),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                ),
                CupertinoDialogAction(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    Navigator.pop(context);
                    _updateCareer(text);
                  },
                  child: const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accent)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openEditCareerDialog(String currentCareer) {
    final List<Map<String, dynamic>> careers = [
      {'title': 'Medicina Humana', 'icon': CupertinoIcons.heart_fill, 'color': AppColors.systemRed},
      {'title': 'Enfermería', 'icon': CupertinoIcons.bandage_fill, 'color': AppColors.systemTeal},
      {'title': 'Odontología', 'icon': CupertinoIcons.sparkles, 'color': AppColors.systemIndigo},
      {'title': 'Farmacia y Bioquímica', 'icon': CupertinoIcons.lab_flask_solid, 'color': AppColors.systemGreen},
      {'title': 'Obstetricia', 'icon': CupertinoIcons.person_crop_circle_badge_checkmark, 'color': AppColors.systemPink},
      {'title': 'Nutrición', 'icon': CupertinoIcons.leaf_arrow_circlepath, 'color': AppColors.systemOrange},
    ];

    _showSmoothCupertinoActionSheet(
      context: context,
      builder: (context) => _OpaqueActionSheet(
        title: const Text(
          'Especialidad o Carrera',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            decoration: TextDecoration.none,
          ),
        ),
        message: const Text(
          'Selecciona tu área de formación en salud:',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: AppColors.textMuted,
            decoration: TextDecoration.none,
          ),
        ),
        actions: [
          ...careers.map((c) {
            final String title = c['title'] as String;
            final IconData icon = c['icon'] as IconData;
            final Color color = c['color'] as Color;
            final bool isSelected = currentCareer.trim().toLowerCase() == title.toLowerCase();

            return _OpaqueActionSheetActionItem(
              onPressed: () async {
                Navigator.pop(context);
                await _updateCareer(title);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.accent : AppColors.primary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    const Icon(CupertinoIcons.checkmark_alt, size: 16, color: AppColors.accent),
                  ],
                ],
              ),
            );
          }),
          _OpaqueActionSheetActionItem(
            onPressed: () {
              Navigator.pop(context);
              _openCustomCareerDialog(currentCareer);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.pencil_ellipsis_rectangle, color: AppColors.textMuted, size: 18),
                SizedBox(width: 8),
                Text(
                  'Otra especialidad...',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openEditGenderDialog(String currentGender) {
    _showSmoothCupertinoActionSheet(
      context: context,
      builder: (context) => _OpaqueActionSheet(
        title: const Text(
          'Seleccionar Género',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            decoration: TextDecoration.none,
          ),
        ),
        message: const Text(
          'Elige tu avatar de estudiante de salud:',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: AppColors.textMuted,
            decoration: TextDecoration.none,
          ),
        ),
        actions: [
          _OpaqueActionSheetActionItem(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await UserLocalProfileService().saveProfile(
                  uid: widget.user.uid,
                  name: _localProfile?.name ?? widget.user.displayName ?? '',
                  email: widget.user.email ?? '',
                  career: _localProfile?.career ?? 'Medicina Humana',
                  gender: 'Hombre',
                  photoUrl: widget.user.photoURL,
                );
                _loadLocalProfile();
                await FirebaseFirestore.instance
                    .collection(AppConstants.firestoreUsers)
                    .doc(widget.user.uid)
                    .set({'gender': 'Hombre'}, SetOptions(merge: true));
                _showFeedback('¡Género actualizado!');
              } catch (e) {
                _showFeedback('Error: $e', isError: true);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.person_fill, color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Hombre',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 15,
                    fontWeight: currentGender == 'Hombre' ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.accent,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          _OpaqueActionSheetActionItem(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await UserLocalProfileService().saveProfile(
                  uid: widget.user.uid,
                  name: _localProfile?.name ?? widget.user.displayName ?? '',
                  email: widget.user.email ?? '',
                  career: _localProfile?.career ?? 'Medicina Humana',
                  gender: 'Mujer',
                  photoUrl: widget.user.photoURL,
                );
                _loadLocalProfile();
                await FirebaseFirestore.instance
                    .collection(AppConstants.firestoreUsers)
                    .doc(widget.user.uid)
                    .set({'gender': 'Mujer'}, SetOptions(merge: true));
                _showFeedback('¡Género actualizado!');
              } catch (e) {
                _showFeedback('Error: $e', isError: true);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.person_crop_circle_fill, color: AppColors.systemPink, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Mujer',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 15,
                    fontWeight: currentGender == 'Mujer' ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.systemPink,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWidget(String userGif) {
    if (_localProfile?.photoBytes != null && _localProfile!.photoBytes!.isNotEmpty) {
      return Image.memory(
        _localProfile!.photoBytes!,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(userGif, width: 72, height: 72, fit: BoxFit.cover),
      );
    }
    if (widget.user.photoURL != null && widget.user.photoURL!.isNotEmpty) {
      return Image.network(
        widget.user.photoURL!,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(userGif, width: 72, height: 72, fit: BoxFit.cover),
      );
    }
    return Image.asset(
      userGif,
      width: 72,
      height: 72,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(AppConstants.firestoreUsers).doc(widget.user.uid).snapshots(),
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

        final String name = data?['name'] ?? _localProfile?.name ?? widget.user.displayName ?? 'Estudiante de Salud';
        final String email = data?['email'] ?? _localProfile?.email ?? widget.user.email ?? 'invitado@synapse.app';
        final String career = data?['career'] ?? _localProfile?.career ?? 'Medicina Humana';
        final String gender = data?['gender'] ?? _localProfile?.gender ?? 'Hombre';
        final String userGif = (gender.toLowerCase() == 'mujer')
            ? 'assets/images/user_girl.gif'
            : 'assets/images/user_boy.gif';
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
                // Apple Large Title
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border, width: 0.6),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x08000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/fire.gif',
                                width: 18,
                                height: 18,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '$streakDays días',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Apple ID Hero Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 0.6),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                            child: ClipOval(
                              child: _buildAvatarWidget(userGif),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                          letterSpacing: -0.4,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _openEditNameDialog(name),
                                      child: const Icon(
                                        CupertinoIcons.pencil_circle_fill,
                                        size: 20,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sección 1: Información Académica (iOS Inset Grouped)
                SliverToBoxAdapter(
                  child: _buildSectionHeader('INFORMACIÓN MÉDICA'),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 0.6),
                      ),
                      child: Column(
                        children: [
                          _buildAppleListTile(
                            icon: CupertinoIcons.book_fill,
                            iconBgColor: AppColors.accent,
                            title: 'Especialidad',
                            value: career,
                            onTap: () => _openEditCareerDialog(career),
                          ),
                          const Divider(height: 0.5, indent: 54, color: AppColors.border),
                          _buildAppleListTile(
                            icon: CupertinoIcons.person_2_fill,
                            iconBgColor: AppColors.systemPink,
                            title: 'Género',
                            value: gender,
                            onTap: () => _openEditGenderDialog(gender),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sección 2: Seguridad y Cuenta (iOS Inset Grouped)
                SliverToBoxAdapter(
                  child: _buildSectionHeader('SEGURIDAD Y ACCESO'),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 0.6),
                      ),
                      child: Column(
                        children: [
                          _buildAppleListTile(
                            icon: CupertinoIcons.checkmark_seal_fill,
                            iconBgColor: isEmailVerified ? AppColors.systemGreen : AppColors.systemOrange,
                            title: 'Estado Médico',
                            value: isEmailVerified ? 'Verificado' : 'Pendiente',
                            trailing: isEmailVerified
                                ? const Icon(CupertinoIcons.checkmark_circle_fill, size: 18, color: AppColors.systemGreen)
                                : (!isAnonymous
                                    ? CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () async {
                                          try {
                                            await widget.user.sendEmailVerification();
                                            _showFeedback('Enlace enviado a $email');
                                          } catch (e) {
                                            _showFeedback('Error: $e', isError: true);
                                          }
                                        },
                                        child: const Text('Reenviar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.systemOrange)),
                                      )
                                    : null),
                          ),
                          const Divider(height: 0.5, indent: 54, color: AppColors.border),
                          _buildAppleListTile(
                            icon: CupertinoIcons.person_badge_plus_fill,
                            iconBgColor: AppColors.systemIndigo,
                            title: 'ID de Estudiante',
                            value: '${widget.user.uid.substring(0, 8)}...',
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: widget.user.uid));
                              _showFeedback('ID copiado al portapapeles');
                            },
                            trailing: const Icon(CupertinoIcons.doc_on_doc, size: 16, color: AppColors.textMuted),
                          ),
                          const Divider(height: 0.5, indent: 54, color: AppColors.border),
                          _buildAppleListTile(
                            icon: CupertinoIcons.lock_shield_fill,
                            iconBgColor: const Color(0xFF636366),
                            title: 'Proveedor',
                            value: isGoogle ? 'Google' : isAnonymous ? 'Invitado' : 'Correo',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sección 3: Cierre de Sesión (Estilo iOS destructivo en lista)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 28, bottom: 100),
                    child: GestureDetector(
                      onTap: _handleSignOut,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border, width: 0.6),
                        ),
                        child: const Center(
                          child: Text(
                            'Cerrar Sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.systemRed,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 22, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildAppleListTile({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String value,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing,
            ] else if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                CupertinoIcons.chevron_forward,
                size: 14,
                color: Color(0xFFC7C7CC),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OpaqueActionSheetActionItem {
  final Widget child;
  final VoidCallback onPressed;

  const _OpaqueActionSheetActionItem({
    required this.child,
    required this.onPressed,
  });
}

class _OpaqueActionSheet extends StatelessWidget {
  final Widget? title;
  final Widget? message;
  final List<_OpaqueActionSheetActionItem> actions;

  const _OpaqueActionSheet({
    this.title,
    this.message,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // 10% de transparencia = 90% de opacidad
    final cardColor = const Color(0xFFFFFFFF).withValues(alpha: 0.90);
    const dividerColor = AppColors.border;

    return Material(
      type: MaterialType.transparency,
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: '.SF Pro Text',
          decoration: TextDecoration.none,
          color: AppColors.primary,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: bottomPadding > 0 ? 8 : 14,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top action group card
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: cardColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null || message != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ?title,
                                if (title != null && message != null) const SizedBox(height: 4),
                                ?message,
                              ],
                            ),
                          ),
                          const Divider(height: 0.5, thickness: 0.5, color: dividerColor),
                        ],
                        for (int i = 0; i < actions.length; i++) ...[
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: actions[i].onPressed,
                              highlightColor: const Color(0xFFE5E5EA).withValues(alpha: 0.5),
                              splashColor: Colors.transparent,
                              child: Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(minHeight: 52),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: actions[i].child,
                              ),
                            ),
                          ),
                          if (i < actions.length - 1)
                            const Divider(height: 0.5, thickness: 0.5, color: dividerColor),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Cancel button card
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Material(
                    color: cardColor,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      highlightColor: const Color(0xFFE5E5EA).withValues(alpha: 0.5),
                      splashColor: Colors.transparent,
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        alignment: Alignment.center,
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}