import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_area_model.dart';
import '../models/topic_model.dart';
import '../models/cheatsheet_model.dart';
import '../models/medical_area_default_logos.dart';

class MedicalAreasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String areasCollection = 'medical_areas';

  // Plantilla canónica de las 16 áreas maestras con sus logos en texto Base64 (sin iconKey)
  static final List<MedicalAreaModel> defaultAreas = [
    MedicalAreaModel(
      id: 'semiologia',
      name: 'Semiología',
      code: 'SEMIOLOGÍA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('semiologia'),
      order: 1,
    ),
    MedicalAreaModel(
      id: 'hematologia',
      name: 'Hematología',
      code: 'HEMATOLOGÍA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('hematologia'),
      order: 2,
    ),
    MedicalAreaModel(
      id: 'neuroanatomia',
      name: 'Neuroanatomía',
      code: 'NEUROANATOMIA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('neuroanatomia'),
      order: 3,
    ),
    MedicalAreaModel(
      id: 'inmunologia',
      name: 'Inmunología',
      code: 'INMUNOLOGIA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('inmunologia'),
      order: 4,
    ),
    MedicalAreaModel(
      id: 'medicina_interna',
      name: 'Medicina Interna',
      code: 'MEDICINA INTERNA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('medicina_interna'),
      order: 5,
    ),
    MedicalAreaModel(
      id: 'dermatologia',
      name: 'Dermatología',
      code: 'DERMATOLOGIA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('dermatologia'),
      order: 6,
    ),
    MedicalAreaModel(
      id: 'bioquimica',
      name: 'Bioquímica',
      code: 'BIOQUIMICA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('bioquimica'),
      order: 7,
    ),
    MedicalAreaModel(
      id: 'genetica',
      name: 'Genética',
      code: 'GENETICA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('genetica'),
      order: 8,
    ),
    MedicalAreaModel(
      id: 'embriologia',
      name: 'Embriología',
      code: 'EMBRIOLOGIA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('embriologia'),
      order: 9,
    ),
    MedicalAreaModel(
      id: 'farmacologia',
      name: 'Farmacología',
      code: 'FARMACOLOGIA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('farmacologia'),
      order: 10,
    ),
    MedicalAreaModel(
      id: 'infectologia',
      name: 'Infectología',
      code: 'INFECTOLOGIA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('infectologia'),
      order: 11,
    ),
    MedicalAreaModel(
      id: 'microbiologia',
      name: 'Microbiología',
      code: 'MICROBIOLOGIA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('microbiologia'),
      order: 12,
    ),
    MedicalAreaModel(
      id: 'fisiopatologia',
      name: 'Fisiopatología',
      code: 'FISIOPATOLOGIA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('fisiopatologia'),
      order: 13,
    ),
    MedicalAreaModel(
      id: 'fisiologia',
      name: 'Fisiología',
      code: 'FISIOLOGIA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('fisiologia'),
      order: 14,
    ),
    MedicalAreaModel(
      id: 'anatomia',
      name: 'Anatomía',
      code: 'ANATOMIA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('anatomia'),
      order: 15,
    ),
    MedicalAreaModel(
      id: 'histologia',
      name: 'Histología',
      code: 'HISTOLOGIA',
      imageBase64: MedicalAreaDefaultLogos.getLogo('histologia'),
      order: 16,
    ),
  ];

  // Inserta las áreas iniciales SOLAMENTE si la colección en Firestore está 100% vacía.
  // NUNCA sobreescribe ni restaura un campo imageBase64 que el usuario haya borrado.
  Future<void> ensureInitialSeedIfEmpty() async {
    try {
      final snapshot = await _firestore.collection(areasCollection).limit(1).get();
      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        for (final area in defaultAreas) {
          final docRef = _firestore.collection(areasCollection).doc(area.id);
          batch.set(docRef, area.toMap());
        }
        await batch.commit();
      }
    } catch (_) {}
  }

  // Stream 100% en tiempo real: Cualquier cambio en Firestore (agregar, editar, eliminar)
  // se refleja instantáneamente en la pantalla de la app sin recargar ni actualizar.
  Stream<List<MedicalAreaModel>> getAreasStream() {
    return _firestore
        .collection(areasCollection)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => MedicalAreaModel.fromMap(doc.data(), doc.id))
          .toList();

      // Ordenar por el campo order (o por nombre si no tiene orden asignado)
      list.sort((a, b) {
        if (a.order != b.order) {
          return a.order.compareTo(b.order);
        }
        return a.name.compareTo(b.name);
      });

      return list;
    });
  }

  // Stream en tiempo real de subtemas para un área médica específica
  Stream<List<TopicModel>> getTopicsStream(String areaId) {
    return _firestore
        .collection(areasCollection)
        .doc(areaId)
        .collection('topics')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => TopicModel.fromMap(doc.data(), doc.id))
          .toList();

      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  // Stream en tiempo real de chuletas clínicas para un tema específico
  Stream<List<CheatsheetModel>> getTopicCheatsheetsStream(String areaId, String topicId) {
    return _firestore
        .collection(areasCollection)
        .doc(areaId)
        .collection('topics')
        .doc(topicId)
        .collection('cheatsheets')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CheatsheetModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
