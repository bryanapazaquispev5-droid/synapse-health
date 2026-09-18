// ============================================================================
// Archivo: main_navigation_wrapper.dart
// Propósito: Controlador de navegacion principal [main_navigation_wrapper] con transiciones fluidas estilo liquid wave.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/user_local_profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_floating_pill.dart';
import '../../cheatsheets/ui/cheatsheet_list_screen.dart';
import '../../leaderboard/ui/leaderboard_screen.dart';
import '../../quizzes/ui/quiz_areas_screen.dart';
import '../../user_profile/ui/profile_screen.dart';
import 'widgets/liquid_wave_transition.dart';

// Definicion principal de la clase [MainNavigationWrapper]
class MainNavigationWrapper extends StatefulWidget {
  final User user;
  final int initialIndex;

  const MainNavigationWrapper({
    super.key,
    required this.user,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

// Estado reactivo y control de ciclo de vida para [MainNavigationWrapper]
class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  late int _currentIndex;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;
  String _cachedGender = 'Hombre';

  // Inicializacion de dependencias y estado local del componente
  // Bloque: Inicialización de controladores, listeners y estado local
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
      // Bloque: Notificación reactiva y redibujado de la interfaz
      setState(() => _cachedGender = p.gender);
    }
  }

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
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
              LeaderboardScreen(currentUser: widget.user),
              ProfileScreen(user: widget.user),
            ],
          ),
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
}
