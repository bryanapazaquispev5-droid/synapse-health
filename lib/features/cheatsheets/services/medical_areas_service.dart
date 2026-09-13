import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../models/medical_area_model.dart';
import '../models/topic_model.dart';
import '../models/cheatsheet_model.dart';

/// Servicio de Dominio / Datos para Áreas Médicas, Temas y Chuletas.
/// CERO persistencia local y CERO datos quemados en código:
/// Todo se obtiene estrictamente en tiempo real desde Firestore.
class MedicalAreasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String areasCollection = AppConstants.firestoreMedicalAreas;

  /// Stream reactivo en tiempo real de áreas médicas desde Firestore
  Stream<List<MedicalAreaModel>> getAreasStream() {
    return _firestore
        .collection(areasCollection)
        .snapshots()
        .map((snapshot) {
      final areas = snapshot.docs
          .map((doc) => MedicalAreaModel.fromMap(doc.data(), doc.id))
          .toList();

      areas.sort((a, b) {
        if (a.order != b.order) {
          return a.order.compareTo(b.order);
        }
        return a.name.compareTo(b.name);
      });

      return areas;
    });
  }

  /// Stream en tiempo real de subtemas para un área médica específica
  Stream<List<TopicModel>> getTopicsStream(String areaId) {
    return _firestore
        .collection(areasCollection)
        .doc(areaId)
        .collection(AppConstants.firestoreTopics)
        .snapshots()
        .map((snapshot) {
      final topics = snapshot.docs
          .map((doc) => TopicModel.fromMap(doc.data(), doc.id))
          .toList();

      topics.sort((a, b) => a.order.compareTo(b.order));
      return topics;
    });
  }

  /// Stream en tiempo real de chuletas clínicas para un tema específico
  Stream<List<CheatsheetModel>> getTopicCheatsheetsStream(String areaId, String topicId) {
    return _firestore
        .collection(areasCollection)
        .doc(areaId)
        .collection(AppConstants.firestoreTopics)
        .doc(topicId)
        .collection(AppConstants.firestoreCheatsheets)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CheatsheetModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
