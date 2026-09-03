import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class MedicalAreaModel {
  final String id;
  final String name;
  final String code;
  final String iconKey;
  final String? imageBase64;
  final int order;
  final int topicsCount;
  final int cheatsheetsCount;
  final int quizzesCount;
  final bool isAvailable;

  const MedicalAreaModel({
    required this.id,
    required this.name,
    required this.code,
    required this.iconKey,
    this.imageBase64,
    required this.order,
    this.topicsCount = 0,
    this.cheatsheetsCount = 0,
    this.quizzesCount = 0,
    this.isAvailable = true,
  });

  // Decodifica el texto Base64 a bytes binarios de imagen
  Uint8List? get decodedImageBytes {
    if (imageBase64 == null || imageBase64!.trim().isEmpty) return null;
    try {
      String clean = imageBase64!.trim();
      // Si es una URL o ruta de asset, no es Base64
      if (clean.startsWith('http://') || clean.startsWith('https://') || clean.startsWith('assets/')) {
        return null;
      }
      // Si viene con prefijo tipo "data:image/png;base64,..."
      if (clean.contains(',')) {
        clean = clean.split(',').last;
      }
      clean = clean.replaceAll(RegExp(r'\s+'), '');
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  factory MedicalAreaModel.fromMap(Map<String, dynamic> map, String documentId) {
    final String rawName = map['name'] ?? documentId;
    final String? img = map['imageBase64'] ??
        map['logoBase64'] ??
        map['image'] ??
        map['imageUrl'] ??
        map['logoUrl'] ??
        map['iconUrl'];

    return MedicalAreaModel(
      id: documentId,
      name: rawName,
      code: map['code'] ?? rawName.toUpperCase(),
      iconKey: (map['iconKey'] ?? '').toString().toLowerCase().trim(),
      imageBase64: (img != null && img.trim().isNotEmpty) ? img.trim() : null,
      order: (map['order'] is int) ? map['order'] : int.tryParse('${map['order']}') ?? 999,
      topicsCount: (map['topicsCount'] is int) ? map['topicsCount'] : 0,
      cheatsheetsCount: (map['cheatsheetsCount'] is int) ? map['cheatsheetsCount'] : 0,
      quizzesCount: (map['quizzesCount'] is int) ? map['quizzesCount'] : 0,
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'iconKey': iconKey,
      if (imageBase64 != null) 'imageBase64': imageBase64,
      'order': order,
      'topicsCount': topicsCount,
      'cheatsheetsCount': cheatsheetsCount,
      'quizzesCount': quizzesCount,
      'isAvailable': isAvailable,
    };
  }

  // Renderiza la imagen desde el texto Base64 de Firestore
  Widget buildLogoWidget({
    double size = 24,
    BoxFit fit = BoxFit.cover,
    Color? iconColor,
  }) {
    // 1. Imagen desde texto Base64 almacenado en Firebase
    final bytes = decodedImageBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Icon(iconData, size: size, color: iconColor);
          },
        ),
      );
    }

    // 2. Soporte para URLs o Assets si aplica
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      if (imageBase64!.startsWith('http://') || imageBase64!.startsWith('https://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.28),
          child: Image.network(
            imageBase64!,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => Icon(iconData, size: size, color: iconColor),
          ),
        );
      } else if (imageBase64!.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.28),
          child: Image.asset(
            imageBase64!,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => Icon(iconData, size: size, color: iconColor),
          ),
        );
      }
    }

    // 3. Fallback a icono clínico vectorial
    return Icon(iconData, size: size, color: iconColor);
  }

  IconData get iconData {
    final search = ('$iconKey $name $id').toLowerCase();

    if (search.contains('semiol') || search.contains('diagnos') || search.contains('clinic')) {
      return Icons.medical_services_rounded;
    }
    if (search.contains('hemato') || search.contains('sangre')) {
      return Icons.bloodtype_rounded;
    }
    if (search.contains('neuro') || search.contains('cerebro') || search.contains('psico')) {
      return Icons.psychology_rounded;
    }
    if (search.contains('inmuno') || search.contains('defensa') || search.contains('shield')) {
      return Icons.shield_rounded;
    }
    if (search.contains('interna') || search.contains('hospital') || search.contains('general')) {
      return Icons.health_and_safety_rounded;
    }
    if (search.contains('derma') || search.contains('piel')) {
      return Icons.healing_rounded;
    }
    if (search.contains('bioquim') || search.contains('quimica') || search.contains('lab')) {
      return Icons.science_rounded;
    }
    if (search.contains('genet') || search.contains('dna') || search.contains('adn')) {
      return Icons.biotech_rounded;
    }
    if (search.contains('embrio') || search.contains('pedia') || search.contains('niño')) {
      return Icons.child_care_rounded;
    }
    if (search.contains('farma') || search.contains('medicam') || search.contains('droga') || search.contains('pildora')) {
      return Icons.medication_rounded;
    }
    if (search.contains('infecto') || search.contains('virus') || search.contains('covid')) {
      return Icons.coronavirus_rounded;
    }
    if (search.contains('microbio') || search.contains('bacteria') || search.contains('hongo')) {
      return Icons.bubble_chart_rounded;
    }
    if (search.contains('fisiopat') || search.contains('patol')) {
      return Icons.monitor_heart_rounded;
    }
    if (search.contains('fisio') || search.contains('vital')) {
      return Icons.favorite_border_rounded;
    }
    if (search.contains('anato') || search.contains('hueso') || search.contains('cuerpo')) {
      return Icons.accessibility_new_rounded;
    }
    if (search.contains('histo') || search.contains('tejido') || search.contains('celula')) {
      return Icons.grain_rounded;
    }
    if (search.contains('cardio') || search.contains('corazon')) {
      return Icons.favorite_rounded;
    }
    if (search.contains('cirug') || search.contains('operacion')) {
      return Icons.cut_rounded;
    }
    if (search.contains('gineco') || search.contains('obste') || search.contains('mujer')) {
      return Icons.pregnant_woman_rounded;
    }
    if (search.contains('odonto') || search.contains('diente')) {
      return Icons.tag_faces_rounded;
    }
    if (search.contains('oftalmo') || search.contains('ojo')) {
      return Icons.visibility_rounded;
    }
    if (search.contains('trauma') || search.contains('ortoped')) {
      return Icons.personal_injury_rounded;
    }
    if (search.contains('pneumo') || search.contains('pulmon') || search.contains('respirat')) {
      return Icons.air_rounded;
    }
    if (search.contains('gastro') || search.contains('digest')) {
      return Icons.restaurant_rounded;
    }
    if (search.contains('nefro') || search.contains('renal') || search.contains('uro')) {
      return Icons.water_drop_rounded;
    }

    return Icons.local_hospital_rounded;
  }
}
