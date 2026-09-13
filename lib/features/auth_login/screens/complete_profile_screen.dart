import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/user_local_profile_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../navigation/screens/main_navigation_wrapper.dart';
import '../widgets/auth_text_field.dart';

class CompleteProfileScreen extends StatefulWidget {
  final User user;

  const CompleteProfileScreen({super.key, required this.user});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late final TextEditingController _nameController;
  final TextEditingController _careerController = TextEditingController();
  bool _isLoading = false;
  String _selectedGender = 'Hombre';

  final List<String> _suggestedCareers = [
    'Medicina Humana',
    'Enfermería',
    'Odontología',
    'Farmacia y Bioquímica',
    'Obstetricia',
    'Nutrición',
    'Fisioterapia',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.user.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _careerController.dispose();
    super.dispose();
  }

  // Cancelar y retroceder: elimina la cuenta temporal de Firebase para que no quede registrada
  Future<void> _handleCancelAndGoBack() async {
    setState(() => _isLoading = true);

    try {
      await widget.user.delete();
    } catch (_) {}

    try {
      await GoogleSignIn().signOut();
    } catch (_) {}

    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

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

  // Guardar y confirmar registro definitivo en Firestore
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
      if (name != widget.user.displayName) {
        await widget.user.updateDisplayName(name);
      }

      // Registro definitivo en Firebase
      await FirebaseFirestore.instance.collection(AppConstants.firestoreUsers).doc(widget.user.uid).set({
        'uid': widget.user.uid,
        'name': name,
        'email': widget.user.email?.toLowerCase() ?? '',
        'career': career,
        'gender': _selectedGender,
        'studyStreakDays': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'authProvider': 'google.com',
      }, SetOptions(merge: true));

      // Guardar perfil del usuario localmente para soporte offline
      await UserLocalProfileService().saveProfile(
        uid: widget.user.uid,
        name: name,
        email: widget.user.email?.toLowerCase() ?? '',
        career: career,
        gender: _selectedGender,
        photoUrl: widget.user.photoURL,
      );

      // Registrar cuenta creada en este dispositivo
      try {
        final prefs = await SharedPreferences.getInstance();
        final current = prefs.getInt(AppConstants.prefCreatedAccounts) ?? 0;
        await prefs.setInt(AppConstants.prefCreatedAccounts, current + 1);
      } catch (_) {}

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationWrapper(user: widget.user),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar en Firebase: $e'),
            backgroundColor: AppColors.systemRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_isLoading) {
          _handleCancelAndGoBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo de la aplicacion
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
                    const SizedBox(height: 20),

                    // Titulo y Subtitulo
                    const Text(
                      '¡Casi listo!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Cuéntanos sobre tus estudios para completar tu registro médico.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Campo de Nombre
                    AuthTextField(
                      controller: _nameController,
                      label: 'Nombre y Apellidos',
                      hint: 'ej. Bryan Apaza',
                      prefixIcon: CupertinoIcons.person,
                    ),
                    const SizedBox(height: 16),

                    // Campo de Carrera
                    AuthTextField(
                      controller: _careerController,
                      label: 'Carrera o Especialidad',
                      hint: 'ej. Medicina Humana',
                      prefixIcon: CupertinoIcons.book,
                    ),
                    const SizedBox(height: 12),

                    // Pildoras de sugerencia de carreras
                    const Text(
                      'O selecciona una opción rápida:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestedCareers.map((c) {
                        final bool isSelected = _careerController.text == c;
                        return GestureDetector(
                          onTap: () => setState(() => _careerController.text = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accent.withValues(alpha: 0.15) : AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.accent : AppColors.border,
                                width: isSelected ? 1.5 : 0.8,
                              ),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.accent : AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Selector de Género con CupertinoSlidingSegmentedControl
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 2, bottom: 8),
                            child: Text(
                              'Género del Estudiante',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoSlidingSegmentedControl<String>(
                              groupValue: _selectedGender,
                              backgroundColor: const Color(0xFFE5E5EA),
                              thumbColor: AppColors.surface,
                              padding: const EdgeInsets.all(3),
                              children: const {
                                'Hombre': Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(CupertinoIcons.person_fill, size: 16, color: AppColors.accent),
                                      SizedBox(width: 6),
                                      Text('Hombre', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                    ],
                                  ),
                                ),
                                'Mujer': Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(CupertinoIcons.person_crop_circle_fill, size: 16, color: AppColors.systemPink),
                                      SizedBox(width: 6),
                                      Text('Mujer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                    ],
                                  ),
                                ),
                              },
                              onValueChanged: (val) {
                                if (val != null) setState(() => _selectedGender = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Boton Guardar y Continuar iOS (Vibrant Apple Blue)
                    SizedBox(
                      height: 50,
                      child: CupertinoButton.filled(
                        padding: EdgeInsets.zero,
                        borderRadius: BorderRadius.circular(14),
                        onPressed: _isLoading ? null : _handleSaveProfile,
                        child: _isLoading
                            ? const CupertinoActivityIndicator(color: AppColors.surface)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Guardar y Empezar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.surface,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(CupertinoIcons.arrow_right, size: 16, color: AppColors.surface),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Boton inferior de cancelar y volver
                    Center(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        onPressed: _isLoading ? null : _handleCancelAndGoBack,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(CupertinoIcons.clear_circled, size: 16, color: AppColors.systemRed),
                            SizedBox(width: 6),
                            Text(
                              'Cancelar y no registrarme',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.systemRed,
                              ),
                            ),
                          ],
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