import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interview_project/models/streak.dart';
import 'package:interview_project/models/user_library.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔹 Kullanıcı kaydı (sign up) + Username kontrol
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String username,
  }) async {
    try {
      // ✅ Username Firestore’da daha önce alınmış mı kontrol et
      final existing = await _db
          .collection("users")
          .where("username", isEqualTo: username)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw FirebaseAuthException(
          code: "username-already-in-use",
          message: "This username is already taken.",
        );
      }

      // ✅ Firebase Authentication’da kullanıcı oluştur
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        // ✅ Firestore’da users/{uid} dökümanı oluştur
        await _db.collection("users").doc(user.uid).set({
          "id": user.uid,
          "email": email,
          "name": name,
          "surname": surname,
          "username": username, // 🔹 kullanıcıdan gelen değer
          "photoUrl": null,
          "age": null,

          /// XP / Level
          "totalXp": 0,
          "level": 1,

          /// Library
          "savedQuestions": [],
          "library": UserLibrary.empty().toJson(),

          /// Progress
          "progress": {},

          /// Streak (boş başlangıç)
          "streak": Streak.empty().toJson(),

          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("❌ SignUp error: ${e.code} - ${e.message}");
      rethrow; // UI'da snackbar gösterebilmek için hata fırlatıyoruz
    } catch (e) {
      print("❌ Unexpected error: $e");
      return null;
    }
  }

  /// 🔹 Kullanıcı girişi (sign in)
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print("❌ SignIn error: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("❌ Unexpected error: $e");
      return null;
    }
  }

  /// 🔹 Çıkış
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 🔹 Şu anki kullanıcı
  User? get currentUser => _auth.currentUser;

  /// 🔹 Firestore’daki user dökümanını getir
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserDoc() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection("users").doc(user.uid).get();
  }
}
