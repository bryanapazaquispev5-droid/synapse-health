// Test doubles for FlutterFire transaction contracts; never used in production.
// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryAuth extends Fake implements FirebaseAuth {
  User? user = MemoryUser();
  @override
  User? get currentUser => user;
}

class MemoryUser extends Fake implements User {
  @override
  String get uid => 'student';
}

class MemoryFirestore extends Fake implements FirebaseFirestore {
  final documents = <String, Map<String, dynamic>>{};
  Future<void> _tail = Future.value();
  Object? failure;
  int transactions = 0;
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      MemoryCollection(this, path);
  @override
  Future<T> runTransaction<T>(
    TransactionHandler<T> handler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) {
    final result = Completer<T>();
    _tail = _tail.then((_) async {
      transactions++;
      final transaction = MemoryTransaction(this);
      try {
        final value = await handler(transaction);
        if (failure != null) throw failure!;
        documents.addAll(transaction.pending);
        result.complete(value);
      } catch (error, trace) {
        result.completeError(error, trace);
      }
    });
    return result.future;
  }
}

class MemoryCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  MemoryCollection(this.store, this.path);
  final MemoryFirestore store;
  @override
  final String path;
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      MemoryDocument(store, '${this.path}/$path');
}

class MemoryDocument extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  MemoryDocument(this.store, this.path);
  final MemoryFirestore store;
  @override
  final String path;
  @override
  CollectionReference<Map<String, dynamic>> collection(String name) =>
      MemoryCollection(store, '$path/$name');
}

class MemorySnapshot<T extends Object?> extends Fake
    implements DocumentSnapshot<T> {
  MemorySnapshot(this.value);
  final T? value;
  @override
  bool get exists => value != null;
  @override
  T? data() => value;
}

class MemoryTransaction extends Fake implements Transaction {
  MemoryTransaction(this.store);
  final MemoryFirestore store;
  final pending = <String, Map<String, dynamic>>{};
  @override
  Future<DocumentSnapshot<T>> get<T extends Object?>(
    DocumentReference<T> documentReference,
  ) async => MemorySnapshot<T>(store.documents[documentReference.path] as T?);
  @override
  Transaction set<T>(
    DocumentReference<T> documentReference,
    T data, [
    SetOptions? options,
  ]) {
    pending[documentReference.path] = Map<String, dynamic>.from(data as Map);
    return this;
  }
}
