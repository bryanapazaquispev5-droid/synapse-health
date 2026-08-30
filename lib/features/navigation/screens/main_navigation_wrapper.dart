import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_floating_pill.dart';
import '../../user_profile/screens/profile_screen.dart';

class MainNavigationWrapper extends StatefulWidget {
  final User user;
  final int initialIndex;

  const MainNavigationWrapper({
    super.key,
    required this.user,
    this.initialIndex = 3, // Inicia en Perfil para ver la pantalla completada
  });

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.user.uid).snapshots(),
      builder: (context, snapshot) {
        final String gender = snapshot.data?.data()?['gender'] ?? 'Hombre';
        final String userGif = (gender.toLowerCase() == 'mujer')
            ? 'assets/images/user_girl.gif'
            : 'assets/images/user_boy.gif';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Pantallas de cada pestaña
              IndexedStack(
                index: _currentIndex,
                children: [
                  _buildPlaceholder(
                    title: 'Chuletas Médicas',
                    subtitle: 'Resúmenes rápidos y directos de Farmacología, Anatomía y Fisiología.',
                    gifPath: 'assets/images/book.gif',
                    color: AppColors.accent,
                    tag: 'Fase 2 del Plan',
                  ),
                  _buildPlaceholder(
                    title: 'Quizzes y Casos Clínicos',
                    subtitle: 'Evaluación rápida con retroalimentación médica inmediata.',
                    gifPath: 'assets/images/quiz.gif',
                    color: const Color(0xFFF59E0B),
                    tag: 'Fase 3 del Plan',
                  ),
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

              // Píldora Flotante Ergonómica One UI (Alcance del pulgar)
              Align(
                alignment: Alignment.bottomCenter,
                child: BottomFloatingPill(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  items: [
                    const BottomPillItem(assetPath: 'assets/images/book.gif', label: 'Chuletas'),
                    const BottomPillItem(assetPath: 'assets/images/quiz.gif', label: 'Quizzes'),
                    const BottomPillItem(assetPath: 'assets/images/progreso.gif', label: 'Progreso'),
                    BottomPillItem(assetPath: userGif, label: 'Perfil'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
          padding: const EdgeInsets.only(left: 28, right: 28, top: 40, bottom: 110),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
                ),
                child: Center(
                  child: Image.asset(
                    gifPath,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => setState(() => _currentIndex = 3),
                icon: const Icon(Icons.person_outline_rounded, size: 18),
                label: const Text('Ver mi Perfil Médico (Completado)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}