import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  /// --- OKUMALAR ---

  /// Soru 'All' listesine kaydedilmiş mi?
  Future<bool> isSavedToAll(String questionId) async {
    final q = await _savedColl.where('questionId', isEqualTo: questionId).limit(1).get();
    return q.docs.isNotEmpty;
  }

  /// Soru hangi koleksiyonlarda var? (koleksiyon id listesi)
  Future<List<String>> getCollectionsOfQuestion(String questionId) async {
    final snap = await _collectionsColl
        .where('questionIds', arrayContains: questionId)
        .get();
    return snap.docs.map((d) => d.id).toList(growable: false);
  }

  /// --- YAZMALAR ---

  /// All listesine ekle
  Future<void> saveToAll(String questionId) async {
    // Aynı questionId için tek kayıt:
    final exists = await _savedColl.where('questionId', isEqualTo: questionId).limit(1).get();
    if (exists.docs.isEmpty) {
      await _savedColl.add({
        'questionId': questionId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// All listesinden kaldır
  Future<void> removeFromAll(String questionId) async {
    final q = await _savedColl.where('questionId', isEqualTo: questionId).get();
    for (final d in q.docs) {
      await d.reference.delete();
    }
  }

  /// Koleksiyona ekle (koleksiyon dokümanında questionIds: [] array’ine push)
  Future<void> addToCollection(String collectionId, String questionId) async {
    final ref = _collectionsColl.doc(collectionId);
    await ref.set({
      'questionIds': FieldValue.arrayUnion([questionId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Koleksiyondan çıkar
  Future<void> removeFromCollection(String collectionId, String questionId) async {
    final ref = _collectionsColl.doc(collectionId);
    await ref.set({
      'questionIds': FieldValue.arrayRemove([questionId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  DocumentReference<Map<String, dynamic>> get _libraryMeta =>
      _db.collection('users').doc(_uid).collection('meta').doc('library');

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
