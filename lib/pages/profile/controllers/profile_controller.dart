import 'package:get/get.dart';

class ProfileController extends GetxController {
  // ---- UI'da gösterilecek normalize alanlar ----
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
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      error.value = null;

      // TODO: Burayı gerçek servis/DB ile değiştir.
      // Şimdilik dummy veriler:
      name.value = 'Rümeysa';
      surname.value = 'Yavuzkanat';
      email.value = 'rumeysa@example.com';
      photoUrl.value = null; // bir url verirsen NetworkImage gösterir

      level.value = 3;
      totalXp.value = 450;
      streakDays.value = 5;
      savedCount.value = 12;

    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Navigation / Actions ----
  void goToSettings() {
    // Get.toNamed('/settings');
    Get.snackbar('Settings', 'Coming soon ✨');
  }

  void goToProgress() {
    // Get.toNamed('/progress');
    Get.snackbar('Progress', 'Opening…');
  }

  void goToInterviewResults() {
    // Get.toNamed('/interview-results');
    Get.snackbar('Interview Results', 'Opening…');
  }

  void goToEditProfile() {
    // Get.toNamed('/edit-profile');
    Get.snackbar('Edit Profile', 'Coming soon ✍️');
  }
}
