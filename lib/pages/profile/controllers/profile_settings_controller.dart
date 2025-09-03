import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Eğer profilden veri çekmek istersen:
// import '../../controllers/profile_controller.dart';

class ProfileSettingsController extends GetxController {
  // UI'de göstereceğimiz reaktif alanlar
  final name = ''.obs;
  final surname = ''.obs;
  final username = ''.obs;
  final email = ''.obs;

  final language = 'English'.obs;

  // Durum
  final isSaving = false.obs;
  final savedBanner = 'All changes saved'.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();

    // Başlangıç değerleri (mock). Burayı kendi user’ından doldur.
    name.value = 'Rümeysa';
    surname.value = 'Yavuzkanat';
    username.value = 'rumeysayvz';
    email.value = 'rumeysa@example.com';

    // Eğer ProfileController kullanıyorsan buradan senkronlayabilirsin:
    // try {
    //   final p = Get.find<ProfileController>();
    //   name.value = p.name.value;
    //   surname.value = p.surname.value;
    //   username.value = p.username.value;
    //   email.value = p.email.value;
    // } catch (_) {}
  }

  // -------- Validation helpers --------
  String? validateNotEmpty(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field cannot be empty';
    return null;
  }

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email cannot be empty';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim());
    if (!ok) return 'Invalid email';
    return null;
  }

  // -------- Setters (tile/dialog sonrası çağırılır) --------
  Future<void> setName(String v) async {
    final err = validateNotEmpty(v, 'Name');
    if (err != null) return _toast(err);
    name.value = v.trim();
    await saveProfile();
  }

  Future<void> setSurname(String v) async {
    final err = validateNotEmpty(v, 'Surname');
    if (err != null) return _toast(err);
    surname.value = v.trim();
    await saveProfile();
  }

  Future<void> setUsername(String v) async {
    final err = validateNotEmpty(v, 'Username');
    if (err != null) return _toast(err);
    username.value = v.trim();
    await saveProfile();
  }

  Future<void> setEmail(String v) async {
    final err = validateEmail(v);
    if (err != null) return _toast(err);
    email.value = v.trim();
    await saveProfile();
  }

  // Dil picker değişince çağır
  Future<void> setLanguage(String v) async {
    language.value = v;
    // küçük bir debounce ile kaydet (isteğe bağlı)
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => saveProfile());
  }

  // -------- Persist (mock) --------
  Future<void> saveProfile() async {
    savedBanner.value = 'Saving…';
    isSaving.value = true;
    try {
      // TODO: backend/Firebase update çağrısı
      await Future.delayed(const Duration(milliseconds: 500));

      // Profili ana sayfaya da yansıtmak istersen:
      // try {
      //   final p = Get.find<ProfileController>();
      //   p.name.value = name.value;
      //   p.surname.value = surname.value;
      //   p.email.value = email.value;
      //   // p.update(); // GetBuilder kullanıyorsan
      // } catch (_) {}

      savedBanner.value = 'All changes saved';
    } catch (e) {
      savedBanner.value = 'Failed to save';
      _toast('Save failed: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // -------- Password --------
  Future<void> changePassword(String current, String next) async {
    if (next.length < 6) {
      _toast('Password must be at least 6 characters');
      return;
    }
    isSaving.value = true;
    savedBanner.value = 'Saving…';
    try {
      // TODO: re-auth + update password
      await Future.delayed(const Duration(milliseconds: 700));
      _toast('Password updated 🔐');
      savedBanner.value = 'All changes saved';
    } catch (e) {
      _toast('Password change failed: $e');
      savedBanner.value = 'Failed to save';
    } finally {
      isSaving.value = false;
    }
  }

  // -------- Utils --------
  void _toast(String msg) {
    Get.snackbar('Info', msg, snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
