import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/cheatsheets/api/medical_areas_service.dart';
import 'package:synapse_health/features/cheatsheets/model/medical_area_model.dart';
import 'package:synapse_health/features/cheatsheets/model/topic_model.dart';
import 'package:synapse_health/features/quizzes/api/quiz_progress_service.dart';
import 'package:synapse_health/features/quizzes/model/quiz_topic_progress_model.dart';

class FakeSession extends Fake implements FirebaseAuth {
  User? user;
  final sessions = StreamController<User?>.broadcast();
  @override
  User? get currentUser => user;
  @override
  Stream<User?> authStateChanges() => sessions.stream;
}

class FakeIdentity extends Fake implements User {
  FakeIdentity(this.uid);
  @override
  final String uid;
}

class FakeProgressSource extends Fake implements QuizProgressService {
  int calls = 0;
  int cancellations = 0;
  late final source = StreamController<Map<String, QuizTopicProgressModel>>(
    onCancel: () => cancellations++,
  );
  @override
  Stream<Map<String, QuizTopicProgressModel>> getAllTopicsProgressStream() {
    calls++;
    return source.stream;
  }
}

class FakeCatalogSource extends Fake implements MedicalAreasService {
  int areaCalls = 0;
  final topicCalls = <String>[];
  final areas = StreamController<List<MedicalAreaModel>>();
  final topics = StreamController<List<TopicModel>>();
  @override
  Stream<List<MedicalAreaModel>> getAreasStream() {
    areaCalls++;
    return areas.stream;
  }

  @override
  Stream<List<TopicModel>> getTopicsStream(String areaId) {
    topicCalls.add(areaId);
    return topics.stream;
  }
}
