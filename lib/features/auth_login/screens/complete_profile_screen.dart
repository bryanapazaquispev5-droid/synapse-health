import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
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

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final career = _careerController.text.trim();

    if (name.isEmpty || career.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor completa tu nombre y especialidad médica',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (name != widget.user.displayName) {
        await widget.user.updateDisplayName(name);
      }

      await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).set({
        'uid': widget.user.uid,
        'name': name,
        'email': widget.user.email?.toLowerCase() ?? '',
        'career': career,
        'studyStreakDays': 0,
        'updatedAt': FieldValue.serverTimestamp(),
        'authProvider': 'google.com',
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Perfil completado con éxito!'),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.primary,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Cuéntanos sobre tus estudios para personalizar tus chuletas y evaluaciones.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Campo de Nombre
                  AuthTextField(
                    controller: _nameController,
                    label: 'Nombre y Apellidos',
                    hint: 'ej. Bryan Apaza',
                    prefixIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Campo de Carrera
                  AuthTextField(
                    controller: _careerController,
                    label: 'Carrera o Especialidad',
                    hint: 'ej. Medicina Humana',
                    prefixIcon: Icons.school_outlined,
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
                      return ActionChip(
                        label: Text(c),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.surface : AppColors.primary,
                        ),
                        backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onPressed: () {
                          setState(() {
                            _careerController.text = c;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Boton Guardar y Continuar
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: AppColors.surface,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Guardar y Empezar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
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
    );
  }
}