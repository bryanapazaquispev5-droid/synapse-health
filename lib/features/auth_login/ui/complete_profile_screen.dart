// ============================================================================
// Archivo: complete_profile_screen.dart
// Propósito: Pantalla de autenticación y flujo de acceso [complete_profile_screen] con soporte para credenciales y Google Sign-In.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/user_local_profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../navigation/ui/main_navigation_wrapper.dart';
import '../api/auth_service.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/career_selector_modal.dart';
import 'widgets/complete_profile_header.dart';
import 'widgets/gender_selector_widget.dart';

/// Pantalla principal de interfaz de usuario [CompleteProfileScreen].
class CompleteProfileScreen extends StatefulWidget {
  final User user;

  const CompleteProfileScreen({super.key, required this.user});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

/// Estado mutable y controlador del ciclo de vida reactivo para [CompleteProfileScreen].
class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final AuthService _authService = AuthService();
  late final TextEditingController _nameController;
  final TextEditingController _careerController = TextEditingController();
  bool _isLoading = false;
  String _selectedGender = 'Hombre';

  final List<String> _suggestedCareers = const [
    'Medicina Humana',
    'Enfermería',
    'Odontología',
    'Farmacia y Bioquímica',
    'Obstetricia',
    'Nutrición',
    'Fisioterapia',
  ];

  // Bloque: Inicialización de controladores, listeners y estado local
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName ?? '');
  }

  // Bloque: Liberación de recursos y controladores para evitar fugas de memoria
  @override
  void dispose() {
    _nameController.dispose();
    _careerController.dispose();
    super.dispose();
  }

  Future<void> _handleCancelAndGoBack() async {
    setState(() => _isLoading = true);
    await _authService.cancelAndRollbackAccount(widget.user);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Registro cancelado. No se guardó ningún dato en Firebase.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.systemRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  Future<void> _handleSaveProfile() async {
    final name = _nameController.text.trim();
    final career = _careerController.text.trim();

    if (name.isEmpty || career.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor completa tu nombre y especialidad médica',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.systemRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.user.updateDisplayName(name);

      await _authService.firestore.collection(AppConstants.FIRESTORE_USERS).doc(widget.user.uid).set({
        'uid': widget.user.uid,
        'name': name,
        'email': widget.user.email ?? '',
        'career': career,
        'gender': _selectedGender,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await UserLocalProfileService().saveProfile(
        uid: widget.user.uid,
        name: name,
        email: widget.user.email ?? '',
        career: career,
        gender: _selectedGender,
        photoUrl: widget.user.photoURL,
      );

      try {
        final prefs = await SharedPreferences.getInstance();
        final current = prefs.getInt(AppConstants.PREF_CREATED_ACCOUNTS) ?? 0;
        await prefs.setInt(AppConstants.PREF_CREATED_ACCOUNTS, current + 1);
      } catch (_) {}

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MainNavigationWrapper(user: widget.user)),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.systemRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      }
    }
  }

  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleCancelAndGoBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CompleteProfileHeader(onCancel: _handleCancelAndGoBack),
                    const SizedBox(height: 24),
                    AuthTextField(
                      controller: _nameController,
                      label: 'Nombre completo',
                      hint: 'Ingresa tu nombre y apellido',
                      prefixIcon: CupertinoIcons.person_fill,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        CareerSelectorModal.show(
                          context: context,
                          careers: _suggestedCareers,
                          onSelected: (career) => setState(() => _careerController.text = career),
                        );
                      },
                      child: AbsorbPointer(
                        child: AuthTextField(
                          controller: _careerController,
                          label: 'Carrera o Especialidad',
                          hint: 'Selecciona o escribe tu carrera',
                          prefixIcon: CupertinoIcons.building_2_fill,
                          suffixIcon: const Icon(CupertinoIcons.chevron_down, size: 18, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GenderSelectorWidget(
                      selectedGender: _selectedGender,
                      onGenderChanged: (gender) => setState(() => _selectedGender = gender),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 52,
                      child: CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(14),
                        onPressed: _isLoading ? null : _handleSaveProfile,
                        child: _isLoading
                            ? const CupertinoActivityIndicator(color: Colors.white)
                            : const Text(
                                'Guardar y Continuar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
