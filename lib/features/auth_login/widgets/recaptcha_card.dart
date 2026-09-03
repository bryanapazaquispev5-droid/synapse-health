import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// Modelo de un mosaico individual dentro del desafío reCAPTCHA
class CaptchaTile {
  final String imageUrl;
  final IconData fallbackIcon;
  final String label;

  const CaptchaTile({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.label,
  });
}

/// Modelo de un desafío de imágenes (ej. "semáforos", "ambulancias", "bicicletas")
class CaptchaChallenge {
  final String keyword;
  final String subtitle;
  final List<CaptchaTile> tiles;
  final Set<int> correctIndices;

  const CaptchaChallenge({
    required this.keyword,
    this.subtitle = 'Haz clic en Verificar cuando no quede ninguna.',
    required this.tiles,
    required this.correctIndices,
  });
}

class RecaptchaCard extends StatefulWidget {
  final ValueChanged<bool> onVerified;
  final bool isVerified;

  const RecaptchaCard({
    super.key,
    required this.onVerified,
    this.isVerified = false,
  });

  @override
  State<RecaptchaCard> createState() => _RecaptchaCardState();
}

class _RecaptchaCardState extends State<RecaptchaCard> {
  bool _isChecking = false;
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    _verified = widget.isVerified;
  }

  @override
  void didUpdateWidget(covariant RecaptchaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVerified != _verified) {
      setState(() => _verified = widget.isVerified);
    }
  }

  Future<void> _triggerCaptcha() async {
    if (_verified || _isChecking) return;

    setState(() => _isChecking = true);

    // Breve animación de giro en la casilla antes de desplegar el modal
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    // Abrir modal de selección de fotos interactivo
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CaptchaChallengeDialog(),
    );

    if (!mounted) return;

    if (result == true) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isChecking = false;
        _verified = true;
      });
      widget.onVerified(true);
    } else {
      setState(() {
        _isChecking = false;
        _verified = false;
      });
      widget.onVerified(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14.0, bottom: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _verified ? const Color(0xFF10B981) : AppColors.border,
          width: _verified ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Casilla de verificación reCAPTCHA
          GestureDetector(
            onTap: _triggerCaptcha,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _verified ? const Color(0xFF10B981) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _verified
                      ? const Color(0xFF10B981)
                      : (_isChecking ? const Color(0xFF4285F4) : const Color(0xFFCBD5E1)),
                  width: 2,
                ),
              ),
              child: Center(
                child: _isChecking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Color(0xFF4285F4),
                        ),
                      )
                    : _verified
                        ? const Icon(Icons.check_rounded, size: 22, color: Colors.white)
                        : null,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Texto "No soy un robot"
          Expanded(
            child: GestureDetector(
              onTap: _triggerCaptcha,
              child: const Text(
                'No soy un robot',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // Logo e información de Google reCAPTCHA
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://www.gstatic.com/recaptcha/api2/logo_48.png',
                width: 26,
                height: 26,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.shield_outlined,
                  size: 24,
                  color: Color(0xFF4285F4),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'reCAPTCHA',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.2,
                ),
              ),
              const Text(
                'Privacidad',
                style: TextStyle(
                  fontSize: 7,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Diálogo interactivo del desafío de selección de imágenes (reCAPTCHA Grid Challenge)
class CaptchaChallengeDialog extends StatefulWidget {
  const CaptchaChallengeDialog({super.key});

  @override
  State<CaptchaChallengeDialog> createState() => _CaptchaChallengeDialogState();
}

class _CaptchaChallengeDialogState extends State<CaptchaChallengeDialog> {
  late int _currentChallengeIndex;
  final Set<int> _selectedIndices = {};
  bool _hasError = false;
  String _errorMessage = '';

  static final List<CaptchaChallenge> _challenges = [
    // 1. Desafío: Semáforos
    CaptchaChallenge(
      keyword: 'semáforos',
      subtitle: 'Haz clic en todas las imágenes que contengan semáforos.',
      correctIndices: {0, 4, 7},
      tiles: const [
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1508873696983-2df5703bc2e0?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.traffic_rounded,
          label: 'Semáforo',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.route_rounded,
          label: 'Carretera',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.location_city_rounded,
          label: 'Edificios',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.apartment_rounded,
          label: 'Puente',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.traffic_rounded,
          label: 'Semáforo',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.directions_car_rounded,
          label: 'Automóvil',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.park_rounded,
          label: 'Bosque',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.traffic_rounded,
          label: 'Semáforo',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1477959858617-67f30bc75b82?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.nightlife_rounded,
          label: 'Avenida',
        ),
      ],
    ),

    // 2. Desafío: Ambulancias / Vehículos de salud
    CaptchaChallenge(
      keyword: 'ambulancias',
      subtitle: 'Haz clic en todas las imágenes que contengan ambulancias.',
      correctIndices: {1, 3, 8},
      tiles: const [
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1557223562-6c77ef16210f?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.local_taxi_rounded,
          label: 'Taxi',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1587745416684-47953f16f02f?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.emergency_rounded,
          label: 'Ambulancia',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.directions_bus_rounded,
          label: 'Autobús',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.emergency_rounded,
          label: 'Ambulancia',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.directions_car_rounded,
          label: 'Coche',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.speed_rounded,
          label: 'Deportivo',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1471180625745-944903837c22?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.moped_rounded,
          label: 'Moto',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.drive_eta_rounded,
          label: 'Camioneta',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.emergency_rounded,
          label: 'Ambulancia',
        ),
      ],
    ),

    // 3. Desafío: Bicicletas
    CaptchaChallenge(
      keyword: 'bicicletas',
      subtitle: 'Haz clic en todas las imágenes que contengan bicicletas.',
      correctIndices: {0, 2, 6, 7},
      tiles: const [
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.pedal_bike_rounded,
          label: 'Bicicleta',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.two_wheeler_rounded,
          label: 'Moto',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.pedal_bike_rounded,
          label: 'Bicicleta',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.directions_bus_rounded,
          label: 'Bus',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1557223562-6c77ef16210f?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.local_taxi_rounded,
          label: 'Taxi',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.directions_car_rounded,
          label: 'Auto',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1507035895480-2b3156c31fc8?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.pedal_bike_rounded,
          label: 'Bicicleta',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1471506480208-91b3a4cc75fb?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.pedal_bike_rounded,
          label: 'Bicicleta',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.sports_motorsports_rounded,
          label: 'Casco',
        ),
      ],
    ),

    // 4. Desafío: Instrumental o Salud Médica
    CaptchaChallenge(
      keyword: 'instrumentos médicos',
      subtitle: 'Haz clic en todas las imágenes relacionadas a salud y medicina.',
      correctIndices: {2, 4, 8},
      tiles: const [
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.laptop_mac_rounded,
          label: 'Laptop',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.coffee_rounded,
          label: 'Café',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.medical_services_rounded,
          label: 'Estetoscopio',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.route_rounded,
          label: 'Calle',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.medication_rounded,
          label: 'Medicamento',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.directions_car_rounded,
          label: 'Auto',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.park_rounded,
          label: 'Árboles',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.pedal_bike_rounded,
          label: 'Bicicleta',
        ),
        CaptchaTile(
          imageUrl: 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?auto=format&fit=crop&w=300&q=80',
          fallbackIcon: Icons.vaccines_rounded,
          label: 'Jeringa',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentChallengeIndex = Random().nextInt(_challenges.length);
  }

  void _nextChallenge() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentChallengeIndex = (_currentChallengeIndex + 1) % _challenges.length;
      _selectedIndices.clear();
      _hasError = false;
      _errorMessage = '';
    });
  }

  void _toggleTile(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _verify() {
    final challenge = _challenges[_currentChallengeIndex];
    final bool isCorrect = _selectedIndices.length == challenge.correctIndices.length &&
        _selectedIndices.containsAll(challenge.correctIndices);

    if (isCorrect) {
      Navigator.of(context).pop(true);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _hasError = true;
        _errorMessage = 'Por favor, vuelve a intentarlo. Selecciona todas las imágenes correctas.';
        _selectedIndices.clear();
        // Cambiar automáticamente a otro desafío para seguridad
        _currentChallengeIndex = (_currentChallengeIndex + 1) % _challenges.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _challenges[_currentChallengeIndex];

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera estilo Google reCAPTCHA
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFF1A73E8), // Azul oficial de Google
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona todas las imágenes que contengan',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.keyword,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Mensaje de Error si falló el intento previo
            if (_hasError) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: const Color(0xFFFEF2F2),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Matriz 3x3 de Imágenes
            Padding(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: challenge.tiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final tile = challenge.tiles[index];
                  final bool isSelected = _selectedIndices.contains(index);

                  return GestureDetector(
                    onTap: () => _toggleTile(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1A73E8) : const Color(0xFFE2E8F0),
                          width: isSelected ? 3.5 : 1.0,
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Imagen o Fallback visual
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.network(
                              tile.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: const Color(0xFFF1F5F9),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF1A73E8),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFF1F5F9),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(tile.fallbackIcon, size: 28, color: const Color(0xFF64748B)),
                                      const SizedBox(height: 3),
                                      Text(
                                        tile.label,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF475569),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // Sombra oscura y Checkmark azul cuando está seleccionado
                          if (isSelected) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A73E8).withValues(alpha: 0.22),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1A73E8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Barra inferior con herramientas y botón Verificar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFF5F6368), size: 22),
                    tooltip: 'Cambiar desafío',
                    onPressed: _nextChallenge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.headphones_outlined, color: Color(0xFF5F6368), size: 22),
                    tooltip: 'Desafío de audio',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('El desafío de audio no está disponible. Resuelve el gráfico.'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF5F6368), size: 22),
                    tooltip: 'Información',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('Seguridad reCAPTCHA', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          content: const Text(
                            'Esta comprobación confirma que eres un usuario humano y protege la base de datos médica contra registros masivos o bots.',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF5F6368),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text(
                      'CANCELAR',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'VERIFICAR',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}