import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/user_local_profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_floating_pill.dart';
import '../../user_profile/screens/profile_screen.dart';
import '../../cheatsheets/screens/cheatsheet_list_screen.dart';
import '../../quizzes/screens/quiz_areas_screen.dart';

class MainNavigationWrapper extends StatefulWidget {
  final User user;
  final int initialIndex;

  const MainNavigationWrapper({
    super.key,
    required this.user,
    this.initialIndex = 0, // Inicia en Chuletas Médicas
  });

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  late int _currentIndex;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;
  String _cachedGender = 'Hombre';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _userStream = FirebaseFirestore.instance
        .collection(AppConstants.firestoreUsers)
        .doc(widget.user.uid)
        .snapshots();
    _loadCachedGender();
  }

  Future<void> _loadCachedGender() async {
    final p = await UserLocalProfileService().getProfile(uid: widget.user.uid);
    if (mounted) {
      setState(() => _cachedGender = p.gender);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Pantallas de cada pestaña
          IndexedStack(
            index: _currentIndex,
            children: [
              const CheatsheetListScreen(),
              const QuizAreasScreen(),
              _buildPlaceholder(
                title: 'Métricas y Rachas',
                subtitle: 'Análisis mensual de rendimiento y detector de materias débiles.',
                gifPath: 'assets/images/progreso.gif',
                color: const Color(0xFF10B981),
                tag: 'Fase 4 del Plan',
              ),
              ProfileScreen(user: widget.user),
            ],
          ),

          // Píldora Flotante Ergonómica (Alcance del pulgar) - Mantenida intacta
          Align(
            alignment: Alignment.bottomCenter,
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _userStream,
              builder: (context, snapshot) {
                final String gender = snapshot.data?.data()?['gender'] ?? _cachedGender;
                final String userGif = (gender.toLowerCase() == 'mujer')
                    ? 'assets/images/user_girl.gif'
                    : 'assets/images/user_boy.gif';

                return BottomFloatingPill(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  items: [
                    const BottomPillItem(assetPath: 'assets/images/book.gif', label: 'Chuletas'),
                    const BottomPillItem(assetPath: 'assets/images/quiz.gif', label: 'Quizzes'),
                    const BottomPillItem(assetPath: 'assets/images/progreso.gif', label: 'Progreso'),
                    BottomPillItem(assetPath: userGif, label: 'Perfil'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder({
    required String title,
    required String subtitle,
    required String gifPath,
    required Color color,
    required String tag,
  }) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 28, right: 28, top: 40, bottom: 110),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
                ),
                child: Center(
                  child: Image.asset(
                    gifPath,
                    width: 52,
                    height: 52,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              CupertinoButton.filled(
                borderRadius: BorderRadius.circular(16),
                onPressed: () => setState(() => _currentIndex = 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.person_fill, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Ver mi Perfil Médico (Completado)',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}