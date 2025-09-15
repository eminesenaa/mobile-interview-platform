import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileController extends GetxController {
  // ---- Normalized fields for UI ----
  final RxString name = ''.obs;
  final RxString surname = ''.obs;
  final RxString email = ''.obs;
  final RxnString photoUrl = RxnString();

  final RxInt level = 1.obs;
  final RxInt totalXp = 0.obs;
  final RxInt streakDays = 0.obs;
  final RxInt savedCount = 0.obs;

  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    listenProfile(); // switched to real-time listener
  }

  /// Listen to Firestore in real-time
  void listenProfile() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data() ?? {};

      name.value = data['name'] ?? '';
      surname.value = data['surname'] ?? '';
      email.value = data['email'] ?? '';
      photoUrl.value = data['photoUrl'];

      level.value = data['level'] ?? 1;
      totalXp.value = data['xp'] ?? 0;
      streakDays.value = data['streakDays'] ?? 0;
      savedCount.value = data['savedCount'] ?? 0;
    }, onError: (err) {
      error.value = err.toString();
    });
  }

  // ---- Profil fotoğrafı seçme & yükleme ----
  Future<void> pickAndUploadProfilePhoto() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      try {
        // Storage referansı
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_photos')
            .child('$uid.jpg');

        // Yükle
        await ref.putFile(file);

        // URL al
        final url = await ref.getDownloadURL();

        // Firestore’a kaydet
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'photoUrl': url});

        // Local state güncelle
        photoUrl.value = url;
      } catch (e) {
        error.value = e.toString();
      }
    }
  }

  // ---- Navigation / Actions ----
  void goToSettings() {
    Get.snackbar('Settings', 'Coming soon ✨');
  }

  void goToProgress() {
    Get.snackbar('Progress', 'Opening…');
  }

  void goToInterviewResults() {
    Get.snackbar('Interview Results', 'Opening…');
  }

  void goToEditProfile() {
    Get.snackbar('Edit Profile', 'Coming soon ✍️');
  }
}
