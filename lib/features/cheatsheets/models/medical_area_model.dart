import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class MedicalAreaModel {
  final String id;
  final String name;
  final String code;
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
    this.imageBase64,
    required this.order,
    this.topicsCount = 0,
    this.cheatsheetsCount = 0,
    this.quizzesCount = 0,
    this.isAvailable = true,
  });

  bool get hasImage {
    return (imageBase64 != null && imageBase64!.trim().isNotEmpty);
  }

  // Decodifica el texto Base64 a bytes binarios de imagen
  Uint8List? get decodedImageBytes {
    if (imageBase64 == null || imageBase64!.trim().isEmpty) return null;
    try {
      String clean = imageBase64!.trim();
      if (clean.startsWith('http://') || clean.startsWith('https://') || clean.startsWith('assets/')) {
        return null;
      }
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
      if (imageBase64 != null) 'imageBase64': imageBase64,
      'order': order,
      'topicsCount': topicsCount,
      'cheatsheetsCount': cheatsheetsCount,
      'quizzesCount': quizzesCount,
      'isAvailable': isAvailable,
    };
  }

  // Renderiza únicamente la imagen si existe en Firebase; si no existe, no muestra nada
  Widget buildLogoWidget({
    double size = 24,
    BoxFit fit = BoxFit.cover,
  }) {
    // 1. Imagen desde texto Base64 de Firebase
    final bytes = decodedImageBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      );
    }

    // 2. Soporte para URLs Web si aplica
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      if (imageBase64!.startsWith('http://') || imageBase64!.startsWith('https://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.28),
          child: Image.network(
            imageBase64!,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
        );
      }
    }

    // Si no hay imagen en Firebase, no muestra ningún icono de respaldo
    return const SizedBox.shrink();
  }
}
