import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_area_model.dart';
import '../models/topic_model.dart';
import '../models/medical_area_default_logos.dart';

class MedicalAreasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String areasCollection = 'medical_areas';

  // Plantilla canónica de las 16 áreas maestras con sus logos en texto Base64
  static final List<MedicalAreaModel> defaultAreas = [
    MedicalAreaModel(
      id: 'semiologia',
      name: 'Semiología',
      code: 'SEMIOLOGÍA',
      iconKey: 'semiologia',
      imageBase64: MedicalAreaDefaultLogos.getLogo('semiologia'),
      order: 1,
    ),
    MedicalAreaModel(
      id: 'hematologia',
      name: 'Hematología',
      code: 'HEMATOLOGÍA',
      iconKey: 'hematologia',
      imageBase64: MedicalAreaDefaultLogos.getLogo('hematologia'),
      order: 2,
    ),
    MedicalAreaModel(
      id: 'neuroanatomia',
      name: 'Neuroanatomía',
      code: 'NEUROANATOMIA',
      iconKey: 'neuroanatomia',
      imageBase64: MedicalAreaDefaultLogos.getLogo('neuroanatomia'),
      order: 3,
    ),
    MedicalAreaModel(
      id: 'inmunologia',
      name: 'Inmunología',
      code: 'INMUNOLOGIA',
      iconKey: 'inmunologia',
      imageBase64: MedicalAreaDefaultLogos.getLogo('inmunologia'),
      order: 4,
    ),
    MedicalAreaModel(
      id: 'medicina_interna',
      name: 'Medicina Interna',
      code: 'MEDICINA INTERNA',
      iconKey: 'medicina_interna',
      imageBase64: MedicalAreaDefaultLogos.getLogo('medicina_interna'),
      order: 5,
    ),
    MedicalAreaModel(
      id: 'dermatologia',
      name: 'Dermatología',
      code: 'DERMATOLOGIA',
      iconKey: 'dermatologia',
      imageBase64: MedicalAreaDefaultLogos.getLogo('dermatologia'),
      order: 6,
    ),
    MedicalAreaModel(
      id: 'bioquimica',
      name: 'Bioquímica',
      code: 'BIOQUIMICA',
      iconKey: 'bioquimica',
      imageBase64: MedicalAreaDefaultLogos.getLogo('bioquimica'),
      order: 7,
    ),
    MedicalAreaModel(
      id: 'genetica',
      name: 'Genética',
      code: 'GENETICA',
      iconKey: 'genetica',
      imageBase64: MedicalAreaDefaultLogos.getLogo('genetica'),
      order: 8,
    ),
    MedicalAreaModel(
      id: 'embriologia',
      name: 'Embriología',
      code: 'EMBRIOLOGIA',
      iconKey: 'embriologia',
      imageBase64: MedicalAreaDefaultLogos.getLogo('embriologia'),
      order: 9,
    ),
    MedicalAreaModel(
      id: 'farmacologia',
      name: 'Farmacología',
      code: 'FARMACOLOGIA',
      iconKey: 'farmacologia',
      imageBase64: MedicalAreaDefaultLogos.getLogo('farmacologia'),
      order: 10,
    ),
    MedicalAreaModel(
      id: 'infectologia',
      name: 'Infectología',
      code: 'INFECTOLOGIA',
      iconKey: 'infectologia',
      imageBase64: MedicalAreaDefaultLogos.getLogo('infectologia'),
      order: 11,
    ),
    MedicalAreaModel(
      id: 'microbiologia',
      name: 'Microbiología',
      code: 'MICROBIOLOGIA',
      iconKey: 'microbiologia',
      imageBase64: MedicalAreaDefaultLogos.getLogo('microbiologia'),
      order: 12,
    ),
    MedicalAreaModel(
      id: 'fisiopatologia',
      name: 'Fisiopatología',
      code: 'FISIOPATOLOGIA',
      iconKey: 'fisiopatologia',
      imageBase64: MedicalAreaDefaultLogos.getLogo('fisiopatologia'),
      order: 13,
    ),
    MedicalAreaModel(
      id: 'fisiologia',
      name: 'Fisiología',
      code: 'FISIOLOGIA',
      iconKey: 'fisiologia',
      imageBase64: MedicalAreaDefaultLogos.getLogo('fisiologia'),
      order: 14,
    ),
    MedicalAreaModel(
      id: 'anatomia',
      name: 'Anatomía',
      code: 'ANATOMIA',
      iconKey: 'anatomia',
      imageBase64: MedicalAreaDefaultLogos.getLogo('anatomia'),
      order: 15,
    ),
    MedicalAreaModel(
      id: 'histologia',
      name: 'Histología',
      code: 'HISTOLOGIA',
      iconKey: 'histologia',
      imageBase64: MedicalAreaDefaultLogos.getLogo('histologia'),
      order: 16,
    ),
  ];

  // Sube los logos en texto Base64 a Firestore para todos los documentos de medical_areas
  Future<void> ensureInitialSeedIfEmpty() async {
    try {
      final snapshot = await _firestore.collection(areasCollection).get();
      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        for (final area in defaultAreas) {
          final docRef = _firestore.collection(areasCollection).doc(area.id);
          batch.set(docRef, area.toMap());
        }
        await batch.commit();
      } else {
        // Si las áreas ya existen pero no tienen el campo imageBase64, se lo asigna directamente
        final batch = _firestore.batch();
        bool hasChanges = false;
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final String? existingImg = data['imageBase64'] ?? data['logoBase64'];
          if (existingImg == null || existingImg.trim().isEmpty) {
            final String? defaultLogo = MedicalAreaDefaultLogos.getLogo(doc.id);
            if (defaultLogo != null) {
              batch.set(doc.reference, {'imageBase64': defaultLogo}, SetOptions(merge: true));
              hasChanges = true;
            }
          }
        }
        if (hasChanges) {
          await batch.commit();
        }
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
