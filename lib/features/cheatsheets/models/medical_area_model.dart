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
  final Uint8List? cachedBytes;

  MedicalAreaModel({
    required this.id,
    required this.name,
    required this.code,
    this.imageBase64,
    required this.order,
    this.topicsCount = 0,
    this.cheatsheetsCount = 0,
    this.quizzesCount = 0,
    this.isAvailable = true,
    Uint8List? cachedBytes,
  }) : cachedBytes = cachedBytes ?? _decodeBase64String(imageBase64);

  static final Map<String, Uint8List> _bytesCache = {};

  static Uint8List? _decodeBase64String(String? base64Str) {
    if (base64Str == null || base64Str.trim().isEmpty) return null;
    final clean = base64Str.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://') || clean.startsWith('assets/')) {
      return null;
    }
    if (_bytesCache.containsKey(clean)) {
      return _bytesCache[clean];
    }
    try {
      String raw = clean;
      if (raw.contains(',')) {
        raw = raw.split(',').last;
      }
      raw = raw.replaceAll(RegExp(r'\s+'), '');
      final bytes = base64Decode(raw);
      _bytesCache[clean] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  bool get hasImage {
    return cachedBytes != null || (imageBase64 != null && imageBase64!.trim().isNotEmpty);
  }

  // Retorna los bytes binarios de la imagen memoizados
  Uint8List? get decodedImageBytes => cachedBytes;

  factory MedicalAreaModel.fromMap(Map<String, dynamic> rawMap, String documentId) {
    // Normalizar todas las claves para tolerar espacios accidentales o mayúsculas en Firebase
    final Map<String, dynamic> map = {};
    rawMap.forEach((key, value) {
      map[key.trim().toLowerCase()] = value;
    });

    final String rawName = (map['name'] ?? documentId).toString();
    final dynamic rawImg = map['imagebase64'] ??
        map['logobase64'] ??
        map['image64'] ??
        map['logo64'] ??
        map['image'] ??
        map['imagen'] ??
        map['imageurl'] ??
        map['logourl'] ??
        map['iconurl'];

    final String? img = rawImg?.toString().trim();

    final int parsedOrder = (map['order'] is int)
        ? map['order']
        : int.tryParse('${map['order']}') ?? 15;

    final int parsedTopics = (map['topicscount'] is int)
        ? map['topicscount']
        : int.tryParse('${map['totaltopics']}') ??
            int.tryParse('${map['topicscount']}') ??
            0;

    final int parsedCheatsheets = (map['cheatsheetscount'] is int)
        ? map['cheatsheetscount']
        : int.tryParse('${map['totalcheatsheets']}') ??
            int.tryParse('${map['cheatsheetscount']}') ??
            0;

    final int parsedQuizzes = (map['quizzescount'] is int)
        ? map['quizzescount']
        : int.tryParse('${map['totalquizzes']}') ??
            int.tryParse('${map['quizzescount']}') ??
            0;

    return MedicalAreaModel(
      id: documentId,
      name: rawName,
      code: (map['code'] ?? rawName.toUpperCase()).toString(),
      imageBase64: (img?.isNotEmpty ?? false) ? img : null,
      order: parsedOrder,
      topicsCount: parsedTopics,
      cheatsheetsCount: parsedCheatsheets,
      quizzesCount: parsedQuizzes,
      isAvailable: map['isavailable'] ?? true,
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

  // Renderiza únicamente la imagen si existe en Firebase; con gaplessPlayback para evitar parpadeos
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
          gaplessPlayback: true,
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
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
        );
      }
    }

    // Si no hay imagen en Firebase, no muestra ningún icono
    return const SizedBox.shrink();
  }
}
