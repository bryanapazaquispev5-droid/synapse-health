import 'package:flutter/material.dart';

class MedicalAreaModel {
  final String id;
  final String name;
  final String code;
  final String iconKey;
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
    required this.order,
    this.topicsCount = 0,
    this.cheatsheetsCount = 0,
    this.quizzesCount = 0,
    this.isAvailable = true,
  });

  factory MedicalAreaModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MedicalAreaModel(
      id: documentId,
      name: map['name'] ?? '',
      code: map['code'] ?? (map['name'] ?? '').toString().toUpperCase(),
      iconKey: map['iconKey'] ?? 'default',
      order: map['order'] ?? 0,
      topicsCount: map['topicsCount'] ?? 0,
      cheatsheetsCount: map['cheatsheetsCount'] ?? 0,
      quizzesCount: map['quizzesCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'iconKey': iconKey,
      'order': order,
      'topicsCount': topicsCount,
      'cheatsheetsCount': cheatsheetsCount,
      'quizzesCount': quizzesCount,
      'isAvailable': isAvailable,
    };
  }

  IconData get iconData {
    switch (iconKey) {
      case 'semiologia':
        return Icons.medical_services_outlined;
      case 'hematologia':
        return Icons.bloodtype_outlined;
      case 'neuroanatomia':
        return Icons.psychology_outlined;
      case 'inmunologia':
        return Icons.shield_outlined;
      case 'medicina_interna':
        return Icons.health_and_safety_outlined;
      case 'dermatologia':
        return Icons.healing_outlined;
      case 'bioquimica':
        return Icons.science_outlined;
      case 'genetica':
        return Icons.biotech_outlined;
      case 'embriologia':
        return Icons.child_care_outlined;
      case 'farmacologia':
        return Icons.medication_outlined;
      case 'infectologia':
        return Icons.coronavirus_outlined;
      case 'microbiologia':
        return Icons.bubble_chart_outlined;
      case 'fisiopatologia':
        return Icons.monitor_heart_outlined;
      case 'fisiologia':
        return Icons.favorite_border_rounded;
      case 'anatomia':
        return Icons.accessibility_new_rounded;
      case 'histologia':
        return Icons.grain_outlined;
      default:
        return Icons.local_hospital_outlined;
    }
  }
}
