import 'package:flutter/cupertino.dart';

const _blue = Color(0xFF116C95);
const _teal = Color(0xFF16776D);
const _coral = Color(0xFF9E4C47);

(IconData, Color) progressHistoryMark(
  String source,
  bool isArea,
) => switch (source.toLowerCase()) {
  final name when name.contains('anatom') => (CupertinoIcons.person, _blue),
  final name when name.contains('cardio') || name.contains('vascular') => (
    CupertinoIcons.waveform_path_ecg,
    _coral,
  ),
  final name when name.contains('pediatr') => (CupertinoIcons.person_2, _teal),
  final name when name.contains('neuro') || name.contains('nervio') => (
    CupertinoIcons.bolt,
    _blue,
  ),
  final name when name.contains('neumo') || name.contains('pulmon') => (
    CupertinoIcons.wind,
    _teal,
  ),
  final name when name.contains('farmac') => (CupertinoIcons.capsule, _teal),
  final name when name.contains('osteolog') || name.contains('traumat') => (
    CupertinoIcons.bandage,
    _coral,
  ),
  _ =>
    isArea
        ? (CupertinoIcons.plus_circle, _blue)
        : (CupertinoIcons.doc_text, _teal),
};
