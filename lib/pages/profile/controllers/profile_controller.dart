import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
