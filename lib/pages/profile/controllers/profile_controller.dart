import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'dart:io';

import '../../../models/user.dart';
import '../../../models/streak.dart';
import '../profile_edit_page.dart';
import '../widgets/contact_info_modal.dart';
import '../widgets/pdf_viewer_page.dart';

/// ============================================================================
/// PROFILE CONTROLLER
/// Amaç: Kullanıcı profil verisini canlı olarak dinlemek, profil fotoğrafı
/// ve CV yükleme gibi işlemleri yönetmek.
/// Bu controller "read-only + actions" mantığında çalışır.
/// ============================================================================

class ProfileController extends GetxController {
  /// 🔹 Uygulama içinde gösterilecek domain model
  final Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    _listenToUserDocument();
  }

  // --------------------------------------------------------------------------
  // 🔹 LISTEN FIRESTORE USER SNAPSHOT
  // --------------------------------------------------------------------------
  void _listenToUserDocument() {
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance.collection("users").doc(uid).snapshots().listen(
        (snapshot) {
      if (!snapshot.exists) return;
      final data = snapshot.data() ?? {};

      // Streak parse (güvenli)
      final streakJson = data['streak'] ?? {};
      final parsedStreak = Streak.fromMap(streakJson);

      // Firestore JSON → Domain User
      user.value = User.fromJson({
        'id': uid,
        ...data,
        'streak': parsedStreak.toJson(),
      });

      print("PROFILE DEBUG → streakCount = ${parsedStreak.streakCount}");
    }, onError: (err) {
      Get.snackbar("Error", err.toString());
    });
  }

  // --------------------------------------------------------------------------
  // 🔹 FIRESTORE FIELD UPDATE HELPERS (for contact info modal)
  // --------------------------------------------------------------------------
  Future<void> _updateContactField(String field, dynamic value) async {
    try {
      final uid = fb.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({field: value});

      // local user model update
      user.value = user.value?.copyWith(
        // dynamic olarak doğru alana yazıyoruz
        email: field == "email" ? value : user.value?.email,
        phoneNumber: field == "phoneNumber" ? value : user.value?.phoneNumber,
        linkedinUrl: field == "linkedinUrl" ? value : user.value?.linkedinUrl,
        githubUrl: field == "githubUrl" ? value : user.value?.githubUrl,
        website: field == "website" ? value : user.value?.website,
      );

      Get.snackbar("Updated", "$field updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to update $field: $e");
    }
  }

  // ======================================================================
  // 🔹 Public update methods (UI will call these)
  // ======================================================================
  Future<void> updateEmail(String v) async => _updateContactField("email", v);

  Future<void> updatePhone(String v) async =>
      _updateContactField("phoneNumber", v);

  Future<void> updateLinkedIn(String v) async =>
      _updateContactField("linkedinUrl", v);

  Future<void> updateGithub(String v) async =>
      _updateContactField("githubUrl", v);

  Future<void> updateWebsite(String v) async =>
      _updateContactField("website", v);

  // --------------------------------------------------------------------------
  // 🔹 UPLOAD PROFILE PHOTO
  // --------------------------------------------------------------------------
  Future<void> pickAndUploadProfilePhoto() async {
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);

    try {
      final ref =
          FirebaseStorage.instance.ref().child("users/$uid/profile_photo.jpg");

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({"photoUrl": url});

      user.value = user.value?.copyWith(photoUrl: url);
      Get.snackbar("Success", "Profile photo updated!");
    } catch (e) {
      Get.snackbar("Error", "Failed to upload photo: $e");
    }
  }

  // --------------------------------------------------------------------------
  // 🔹 UPLOAD CV (PDF)
  // --------------------------------------------------------------------------
  Future<void> uploadCV() async {
    try {
      final uid = fb.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (picked == null || picked.files.isEmpty) {
        Get.snackbar("Cancelled", "No file selected");
        return;
      }

      final path = picked.files.single.path;
      if (path == null) return;

      final file = File(path);

      final ref = FirebaseStorage.instance.ref().child("users/$uid/cv.pdf");
      await ref.putFile(file);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({"cvUrl": url});

      user.value = user.value?.copyWith(cvUrl: url);

      Get.snackbar("Success", "Your CV has been uploaded! 📄");
    } catch (e) {
      Get.snackbar("Error", "Failed to upload CV: $e");
    }
  }

  // --------------------------------------------------------------------------
  // 🔹 OPEN CV VIEWER
  // --------------------------------------------------------------------------
  void openCVViewer() {
    final url = user.value?.cvUrl;
    if (url == null || url.isEmpty) {
      Get.snackbar("No CV", "You have not uploaded a CV yet.");
      return;
    }
    Get.to(() => PDFViewerPage(pdfUrl: url));
  }

  // --------------------------------------------------------------------------
  // 🔹 UI Actions (navigation helpers)
  // --------------------------------------------------------------------------
  void openEditProfile() => Get.to(() => const ProfileSettingsPage());

  void openProgressPage() => Get.snackbar("Progress", "Opening...");

  void openInterviewResults() =>
      Get.snackbar("Interview Results", "Coming soon");

  void openContactInfoModal() {
    Get.bottomSheet(
      ContactInfoModal(),
      isScrollControlled: true,
    );
  }
}
