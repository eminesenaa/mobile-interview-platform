import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../../../models/question.dart';

class LibraryService {
  LibraryService._();
  static final instance = LibraryService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw StateError('No signed-in user');
    return u.uid;
  }

  // 🔹 Firestore path’leri
  CollectionReference<Map<String, dynamic>> get _savedColl =>
      _db.collection('users').doc(_uid).collection('saved');

  CollectionReference<Map<String, dynamic>> get _collectionsColl =>
      _db.collection('users').doc(_uid).collection('collections');

  DocumentReference<Map<String, dynamic>> get _libraryMeta =>
      _db.collection('users').doc(_uid).collection('meta').doc('library');

  // ============================================================
  // 🔹 STREAMS & READS
  // ============================================================

  /// 🔸 Bir soru “saved” veya herhangi bir koleksiyondaysa true
  Stream<bool> isSavedStream(String questionId) {
    final savedStream = _savedColl
        .where('questionId', isEqualTo: questionId)
        .snapshots()
        .map((q) => q.docs.isNotEmpty);

    final collectionsStream = _collectionsColl
        .where('questionIds', arrayContains: questionId)
        .snapshots()
        .map((q) => q.docs.isNotEmpty);

    return CombineLatestStream.combine2<bool, bool, bool>(
      savedStream,
      collectionsStream,
      (a, b) => a || b,
    ).distinct();
  }

  /// 🔹 Tüm kaydedilen sorular
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

  /// 🔹 Belirli bir koleksiyondaki soruları dinler
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

  Future<List<CollectionData>> getCollections() async {
    final snap = await _collectionsColl.get();
    return snap.docs.map((d) => CollectionData.fromFirestore(d)).toList();
  }

  Stream<List<CollectionData>> collectionsStream() {
    return _collectionsColl.snapshots().map(
        (snap) => snap.docs.map((d) => CollectionData.fromFirestore(d)).toList());
  }

  Future<List<String>> getCollectionsOfQuestion(String questionId) async {
    final snap = await _collectionsColl
        .where('questionIds', arrayContains: questionId)
        .get();
    return snap.docs.map((d) => d.id).toList(growable: false);
  }

  // ============================================================
  // 🔹 WRITES
  // ============================================================

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
    }

    await batch.commit();
  }

  Future<void> removeFromCollection(String collectionId, String questionId) async {
    final ref = _collectionsColl.doc(collectionId);
    await ref.set({
      'questionIds': FieldValue.arrayRemove([questionId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeQuestionEverywhere(String questionId) async {
    final batch = _db.batch();

    // saved’den kaldır
    final q = await _savedColl.where('questionId', isEqualTo: questionId).get();
    for (final d in q.docs) batch.delete(d.reference);

    // tüm koleksiyonlardan kaldır
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
    return ref;
  }

  Future<void> bumpSavedCount(int delta) async {
    await _libraryMeta.set({
      'savedCount': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

/// 🔹 Model
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
