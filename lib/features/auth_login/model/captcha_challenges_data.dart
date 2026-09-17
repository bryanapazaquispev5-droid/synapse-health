// ============================================================================
// Archivo: captcha_challenges_data.dart
// Propósito: Módulo de verificación humana con Captcha interactivo para mitigar accesos automatizados no autorizados.
// ============================================================================

import 'package:flutter/material.dart';
import 'captcha_models.dart';

/// Componente de interfaz de usuario reutilizable [CaptchaChallengesData].
class CaptchaChallengesData {
  static final List<CaptchaChallenge> challenges = [
    CaptchaChallenge(
      keyword: 'semáforos',
      subtitle: 'Haz clic en todas las imágenes que contengan semáforos.',
      correctIndices: const {0, 4, 7},
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

    CaptchaChallenge(
      keyword: 'ambulancias',
      subtitle: 'Haz clic en todas las imágenes que contengan ambulancias.',
      correctIndices: const {1, 3, 8},
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

    CaptchaChallenge(
      keyword: 'bicicletas',
      subtitle: 'Haz clic en todas las imágenes que contengan bicicletas.',
      correctIndices: const {0, 2, 6, 7},
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

    CaptchaChallenge(
      keyword: 'instrumentos médicos',
      subtitle: 'Haz clic en todas las imágenes relacionadas a salud y medicina.',
      correctIndices: const {2, 4, 8},
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
}
