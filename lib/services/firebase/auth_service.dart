import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:interview_project/models/streak.dart';
import 'package:interview_project/models/user_library.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final AuthService instance = AuthService();

  /// 🔹 Kullanıcı kaydı (sign up) + Username kontrol
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String username,
  }) async {
    try {
      // ✅ Username kontrolü
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

      // ✅ Kullanıcı oluştur
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        // ✅ Firestore kaydı
        await _db.collection("users").doc(user.uid).set({
          "id": user.uid,
          "email": email,
          "name": name,
          "surname": surname,
          "username": username,
          "photoUrl": null,

          "role": "user",
          "totalXp": 0,
          "level": 1,
          "currentRank": 0,
          "previousRank": 0,

          "savedQuestions": [],
          "library": UserLibrary.empty().toJson(),
          "progress": {},
          "streak": Streak.empty().toJson(),

          "createdAt": FieldValue.serverTimestamp(),

          // Boş profil alanları
          "age": null,
          "location": null,
          "school": null,
          "company": null,
          "website": null,
          "linkedinUrl": null,
          "githubUrl": null,
          "cvUrl": null,
          "phoneNumber": null,
          "phoneCountryCode": "+90",
          "phoneCountryIso": "TR",
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("❌ SignUp error: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("❌ Unexpected error: $e");
      return null;
    }
  }

  /// 🔹 HR Kaydı (sign up)
  Future<User?> signUpAsHR({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String username,
    required String companyName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        // ✅ hr_users koleksiyonuna kaydet
        await _db.collection("hr_users").doc(user.uid).set({
          "id": user.uid,
          "email": email,
          "name": name,
          "surname": surname,
          "companyName": companyName,
          "username": username,
          "role": "hr",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("❌ HR SignUp error: ${e.code} - ${e.message}");
      rethrow;
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
      rethrow; // ✅ login_controller'a iletilsin
    } catch (e) {
      print("❌ Unexpected error: $e");
      rethrow;
    }
  }

  /// 🔹 Google ile Giriş
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = await _db.collection("users").doc(user.uid).get();
        if (!userDoc.exists) {
          await _createSocialUserInFirestore(user);
        }
      }
      return user;
    } catch (e) {
      print("❌ Google Sign In Error: $e");
      rethrow; // ✅ controller'a iletilsin
    }
  }

  /// 🔹 Apple ile Giriş (Nonce güvenliği ile)
  Future<User?> signInWithApple() async {
    try {
      // ✅ Güvenlik için rastgele nonce üret
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce, // ✅ Apple'a SHA256 hash gönder
      );

      final OAuthProvider oAuthProvider = OAuthProvider("apple.com");
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce, // ✅ Firebase'e raw nonce gönder
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // ✅ Apple ilk girişte ad/soyad verir, sonraki girişlerde vermez
        // Bu yüzden Firestore'a yazarken appleCredential'dan al
        final userDoc = await _db.collection("users").doc(user.uid).get();
        if (!userDoc.exists) {
          await _createSocialUserInFirestore(
            user,
            overrideName: appleCredential.givenName,
            overrideSurname: appleCredential.familyName,
          );
        }
      }
      return user;
    } on SignInWithAppleAuthorizationException catch (e) {
      // Kullanıcı iptal ettiyse sessizce geç
      if (e.code == AuthorizationErrorCode.canceled) return null;
      print("❌ Apple Sign In Error: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("❌ Apple Sign In Error: $e");
      rethrow;
    }
  }

  /// 🔹 Rastgele nonce üretici
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// 🔹 SHA256 hash
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 🔹 Sosyal medya yardımcısı (Veritabanı oluşturucu)
  Future<void> _createSocialUserInFirestore(
    User user, {
    String? overrideName,
    String? overrideSurname,
  }) async {
    String name = "User";
    String surname = "";

    // ✅ Apple'dan gelen ad/soyad öncelikli (sadece ilk girişte gelir)
    if (overrideName != null && overrideName.isNotEmpty) {
      name = overrideName;
      surname = overrideSurname ?? "";
    } else if (user.displayName != null) {
      var names = user.displayName!.split(" ");
      name = names.first;
      if (names.length > 1) surname = names.sublist(1).join(" ");
    }

    // ✅ Email null olabilir (Apple bazen email vermez)
    final email = user.email ?? "";
    final emailPrefix = email.isNotEmpty ? email.split("@")[0] : "user";
    final username = "${emailPrefix}_${user.uid.substring(0, 4)}";

    await _db.collection("users").doc(user.uid).set({
      "id": user.uid,
      "email": user.email,
      "name": name,
      "surname": surname,
      "username": username,
      "photoUrl": user.photoURL,
      "role": "user",
      "totalXp": 0,
      "level": 1,
      "currentRank": 0,
      "previousRank": 0,
      "savedQuestions": [],
      "library": UserLibrary.empty().toJson(),
      "progress": {},
      "streak": Streak.empty().toJson(),
      "createdAt": FieldValue.serverTimestamp(),
      "age": null,
      "location": null,
      "school": null,
      "company": null,
      "website": null,
      "linkedinUrl": null,
      "githubUrl": null,
      "cvUrl": null,
      "phoneNumber": null,
      "phoneCountryCode": "+90",
      "phoneCountryIso": "TR",
    });
  }

  /// 🔹 Çıkış
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
  }

  /// 🔹 Email Doğrulama Gönder
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// 🔹 Şifre Sıfırlama Gönder
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  User? get currentUser => _auth.currentUser;
}
