// ===================== File: lib/pages/library/services/library_service.dart =====================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/question.dart';

/// Library ile ilgili okuma/yazma helper'ları.
/// Kullanım: LibraryService.instance.method(...)
class LibraryService {
  LibraryService._();
  static final instance = LibraryService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) {
      throw StateError('No signed-in user');
    }
    return u.uid;
  }

  /// Pathler
  CollectionReference<Map<String, dynamic>> get _savedColl =>
      _db.collection('users').doc(_uid).collection('saved');

  CollectionReference<Map<String, dynamic>> get _collectionsColl =>
      _db.collection('users').doc(_uid).collection('collections');

  DocumentReference<Map<String, dynamic>> get _libraryMeta =>
      _db.collection('users').doc(_uid).collection('meta').doc('library');

  // ==================== OKUMALAR ====================

  Future<bool> isSavedToAll(String questionId) async {
    final q = await _savedColl
        .where('questionId', isEqualTo: questionId)
        .limit(1)
        .get();
    return q.docs.isNotEmpty;
  }

  Stream<bool> isSavedStream(String questionId) {
    return _savedColl
        .where('questionId', isEqualTo: questionId)
        .snapshots()
        .map((q) => q.docs.isNotEmpty);
  }

  /// 🔹 All tabındaki soruları gerçek `Question` modeli ile getir
  Stream<List<Question>> savedQuestionsStream() {
    return _savedColl.snapshots().asyncMap((snap) async {
      final ids = snap.docs.map((d) => d['questionId'] as String).toList();
      if (ids.isEmpty) return <Question>[];

      final qs = await _db
          .collection('questions')
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      return qs.docs
          .map((d) => Question.fromFirestore(d.data(), d.id))
          .toList();
    });
  }

  Stream<List<Question>> questionsInCollectionStream(String collectionId) {
    return _collectionsColl.doc(collectionId).snapshots().asyncMap((doc) async {
      if (!doc.exists) return <Question>[];
      final data = doc.data();
      final ids = List<String>.from(data?['questionIds'] ?? []);
      if (ids.isEmpty) return <Question>[];

      final qs = await _db
          .collection('questions')
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      return qs.docs
          .map((d) => Question.fromFirestore(d.data(), d.id))
          .toList();
    });
  }

  Future<List<String>> getCollectionsOfQuestion(String questionId) async {
    final snap = await _collectionsColl
        .where('questionIds', arrayContains: questionId)
        .get();
    return snap.docs.map((d) => d.id).toList(growable: false);
  }

  Future<bool> isInCollection(String collectionId, String questionId) async {
    final doc = await _collectionsColl.doc(collectionId).get();
    if (!doc.exists) return false;
    final data = doc.data();
    final ids = List<String>.from(data?['questionIds'] ?? []);
    return ids.contains(questionId);
  }

  Future<List<CollectionData>> getCollections() async {
    final snap = await _collectionsColl.get();
    return snap.docs.map((d) => CollectionData.fromFirestore(d)).toList();
  }

  Stream<List<CollectionData>> collectionsStream() {
    return _collectionsColl.snapshots().map((snap) {
      return snap.docs.map((d) => CollectionData.fromFirestore(d)).toList();
    });
  }

  // ==================== YAZMALAR ====================

  /// ✅ All listesine ekle
  Future<void> saveToAll(String questionId) async {
    final exists = await _savedColl
        .where('questionId', isEqualTo: questionId)
        .limit(1)
        .get();
    if (exists.docs.isEmpty) {
      await _savedColl.add({
        'questionId': questionId,
        'savedAt': FieldValue.serverTimestamp(),
      });
      await bumpSavedCount(1);
    }
  }

  /// ✅ Koleksiyona ekle (ve aynı anda All’a da ekle)
  Future<void> addToCollection(String collectionId, String questionId) async {
    final batch = _db.batch();

    final ref = _collectionsColl.doc(collectionId);
    batch.set(ref, {
      'questionIds': FieldValue.arrayUnion([questionId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final exists = await _savedColl
        .where('questionId', isEqualTo: questionId)
        .limit(1)
        .get();
    if (exists.docs.isEmpty) {
      final savedRef = _savedColl.doc();
      batch.set(savedRef, {
        'questionId': questionId,
        'savedAt': FieldValue.serverTimestamp(),
      });
      batch.set(_libraryMeta, {
        'savedCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// ✅ Bir soruyu her yerden (All + tüm koleksiyonlardan) kaldır
  Future<void> removeQuestionEverywhere(String questionId) async {
    final batch = _db.batch();

    // 🔹 All’dan kaldır
    final q = await _savedColl.where('questionId', isEqualTo: questionId).get();
    for (final d in q.docs) {
      batch.delete(d.reference);
      batch.set(_libraryMeta, {
        'savedCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // 🔹 Tüm koleksiyonlardan çıkar
    final collections = await _collectionsColl.get();
    for (final c in collections.docs) {
      batch.set(c.reference, {
        'questionIds': FieldValue.arrayRemove([questionId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<DocumentReference<Map<String, dynamic>>> createCollection(
      String name) async {
    final ref = await _collectionsColl.add({
      'name': name,
      'questionIds': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await bumpCollectionsCount(1);
    return ref;
  }

  // ==================== META ====================

  Future<void> bumpSavedCount(int delta) async {
    await _libraryMeta.set({
      'savedCount': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> bumpCollectionsCount(int delta) async {
    await _libraryMeta.set({
      'collectionsCount': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> bumpExamsCount(int delta) async {
    await _libraryMeta.set({
      'examsCount': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getLibraryMeta() async {
    return _libraryMeta.get();
  }
}

/// ==================== MODEL ====================
class CollectionData {
  final String id;
  final String name;
  final List<String> questionIds;

  CollectionData({
    required this.id,
    required this.name,
    required this.questionIds,
  });

  int get count => questionIds.length;

  factory CollectionData.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CollectionData(
      id: doc.id,
      name: data['name'] ?? '',
      questionIds: List<String>.from(data['questionIds'] ?? []),
    );
  }
}
