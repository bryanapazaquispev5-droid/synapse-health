import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/auth_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; // Alterna entre Iniciar Sesion y Registrarse
  bool _obscurePassword = true;

  // Controladores para Login
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  // Controladores para Registro
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerCareerController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Iniciando sesión: ${_loginEmailController.text.trim()}'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cuenta creada para: ${_registerNameController.text.trim()}'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _enterGuestMode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Accediendo como Invitado...'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerCareerController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo minimalista
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        size: 34,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Titulo y Subtitulo
                  Text(
                    _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin
                        ? 'Accede a tus chuletas y quizzes médicos'
                        : 'Únete para registrar tu racha y progreso',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Selector de pestanas Login / Registro
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _tabButton(
                            title: 'Ingresar',
                            isSelected: _isLogin,
                            onTap: () => setState(() => _isLogin = true),
                          ),
                        ),
                        Expanded(
                          child: _tabButton(
                            title: 'Registrarse',
                            isSelected: !_isLogin,
                            onTap: () => setState(() => _isLogin = false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Formulario condicional
                  if (_isLogin) ..._buildLoginForm() else ..._buildRegisterForm(),

                  const SizedBox(height: 24),

                  // Boton Principal
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin ? 'Acceder al Sistema' : 'Completar Registro',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pildora inferior de Modo Invitado (Cero Friccion)
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _enterGuestMode,
                      icon: const Icon(Icons.person_outline_rounded, size: 18),
                      label: const Text(
                        'Continuar como Invitado (Probar)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.border, width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
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
    );
  }

  Widget _tabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.surface : AppColors.primary,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLoginForm() {
    return [
      AuthTextField(
        controller: _loginEmailController,
        label: 'Correo Electrónico o Usuario',
        hint: 'ej. estudiante@tecsup.edu.pe',
        prefixIcon: Icons.alternate_email_rounded,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _loginPasswordController,
        label: 'Contraseña',
        hint: '••••••••',
        prefixIcon: Icons.lock_outline_rounded,
        obscureText: _obscurePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    ];
  }

  List<Widget> _buildRegisterForm() {
    return [
      AuthTextField(
        controller: _registerNameController,
        label: 'Nombre Completo',
        hint: 'ej. Bryan Apaza',
        prefixIcon: Icons.badge_outlined,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _registerEmailController,
        label: 'Correo Electrónico',
        hint: 'ej. alumno@salud.pe',
        prefixIcon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _registerCareerController,
        label: 'Carrera o Especialidad',
        hint: 'ej. Medicina / Enfermería',
        prefixIcon: Icons.school_outlined,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _registerPasswordController,
        label: 'Crear Contraseña',
        hint: 'Mínimo 6 caracteres',
        prefixIcon: Icons.lock_outline_rounded,
        obscureText: _obscurePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    ];
  }
}