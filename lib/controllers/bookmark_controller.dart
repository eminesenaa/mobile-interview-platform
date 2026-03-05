import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/sfx/sound_service.dart';

class BookmarkController extends GetxController {
  final bookmarks = <String>{}.obs;
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _loadBookmarks();
  }

  void _loadBookmarks() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .get();

    // bookmarks.value = snapshot.docs.map((d) => d.id).toSet();
  }

  Future<void> toggleBookmark(String questionId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final ref =
        _db.collection('users').doc(uid).collection('bookmarks').doc(questionId);

    if (bookmarks.contains(questionId)) {
      await ref.delete();
      bookmarks.remove(questionId);
      // 🔊 Bookmark removed
      SoundService.playSync(SoundEffect.bookmarkRemove);
    } else {
      await ref.set({'timestamp': FieldValue.serverTimestamp()});
      bookmarks.add(questionId);
      // 🔊 Bookmark added
      SoundService.playSync(SoundEffect.bookmarkAdd);
    }
  }

  bool isBookmarked(String questionId) => bookmarks.contains(questionId);
}
