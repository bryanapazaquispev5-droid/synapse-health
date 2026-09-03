import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_area_model.dart';
import '../models/topic_model.dart';

class MedicalAreasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String areasCollection = 'medical_areas';

  // Plantilla inicial de las 16 áreas maestras (solo se inserta si la BD está completamente vacía)
  static final List<MedicalAreaModel> defaultAreas = [
    const MedicalAreaModel(
      id: 'semiologia',
      name: 'Semiología',
      code: 'SEMIOLOGÍA',
      iconKey: 'semiologia',
      order: 1,
    ),
    const MedicalAreaModel(
      id: 'hematologia',
      name: 'Hematología',
      code: 'HEMATOLOGÍA',
      iconKey: 'hematologia',
      order: 2,
    ),
    const MedicalAreaModel(
      id: 'neuroanatomia',
      name: 'Neuroanatomía',
      code: 'NEUROANATOMIA',
      iconKey: 'neuroanatomia',
      order: 3,
    ),
    const MedicalAreaModel(
      id: 'inmunologia',
      name: 'Inmunología',
      code: 'INMUNOLOGIA',
      iconKey: 'inmunologia',
      order: 4,
    ),
    const MedicalAreaModel(
      id: 'medicina_interna',
      name: 'Medicina Interna',
      code: 'MEDICINA INTERNA',
      iconKey: 'medicina_interna',
      order: 5,
    ),
    const MedicalAreaModel(
      id: 'dermatologia',
      name: 'Dermatología',
      code: 'DERMATOLOGIA',
      iconKey: 'dermatologia',
      order: 6,
    ),
    const MedicalAreaModel(
      id: 'bioquimica',
      name: 'Bioquímica',
      code: 'BIOQUIMICA',
      iconKey: 'bioquimica',
      order: 7,
    ),
    const MedicalAreaModel(
      id: 'genetica',
      name: 'Genética',
      code: 'GENETICA',
      iconKey: 'genetica',
      order: 8,
    ),
    const MedicalAreaModel(
      id: 'embriologia',
      name: 'Embriología',
      code: 'EMBRIOLOGIA',
      iconKey: 'embriologia',
      order: 9,
    ),
    const MedicalAreaModel(
      id: 'farmacologia',
      name: 'Farmacología',
      code: 'FARMACOLOGIA',
      iconKey: 'farmacologia',
      order: 10,
    ),
    const MedicalAreaModel(
      id: 'infectologia',
      name: 'Infectología',
      code: 'INFECTOLOGIA',
      iconKey: 'infectologia',
      order: 11,
    ),
    const MedicalAreaModel(
      id: 'microbiologia',
      name: 'Microbiología',
      code: 'MICROBIOLOGIA',
      iconKey: 'microbiologia',
      order: 12,
    ),
    const MedicalAreaModel(
      id: 'fisiopatologia',
      name: 'Fisiopatología',
      code: 'FISIOPATOLOGIA',
      iconKey: 'fisiopatologia',
      order: 13,
    ),
    const MedicalAreaModel(
      id: 'fisiologia',
      name: 'Fisiología',
      code: 'FISIOLOGIA',
      iconKey: 'fisiologia',
      order: 14,
    ),
    const MedicalAreaModel(
      id: 'anatomia',
      name: 'Anatomía',
      code: 'ANATOMIA',
      iconKey: 'anatomia',
      order: 15,
    ),
    const MedicalAreaModel(
      id: 'histologia',
      name: 'Histología',
      code: 'HISTOLOGIA',
      iconKey: 'histologia',
      order: 16,
    ),
  ];

  // Si la colección en Firestore está 100% vacía, inserta las 16 áreas iniciales una sola vez
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
}
