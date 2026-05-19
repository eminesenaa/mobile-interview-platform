// ===================== File: profile_edit_controller.dart =====================
// Purpose: Profile edit logic using User model + Firestore sync
// Clean, modern, short, fully reactive controller
// ============================================================================

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../constants/text_styles.dart';
import '../../home/controllers/home_controller.dart';

class ProfileEditController extends GetxController {
  // ===================== USER FIELDS (Reactive) =====================
  // ===================== USER FIELDS (Controllers) =====================
  final nameCtrl = TextEditingController();
  final surnameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  final countryCtrl = TextEditingController();
  final cityCtrl = TextEditingController();

  final schoolCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final roleCtrl = TextEditingController();

  final websiteCtrl = TextEditingController();
  final linkedinUrlCtrl = TextEditingController();
  final githubUrlCtrl = TextEditingController();

  final phoneNumberCtrl = TextEditingController();
  final phoneCountryCode = '+90'.obs;
  final phoneCountryIso = 'TR'.obs;

  final cvUrl = ''.obs;

  // ===================== AVATAR =====================
  final avatarPath = "assets/avatars/avatar1.jpg".obs;

  // Dropdown data
  final List<String> roleOptions = [
    "Student",
    "Software Engineer",
    "Frontend Developer",
    "Backend Developer",
    "Mobile Developer",
    "Data Scientist",
    "Product Manager",
    "Designer",
    "Other",
  ];

  // Load state
  final isLoading = false.obs;

  // ===================== ON INIT =====================
  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  // ===================== LOAD USER FROM FIRESTORE =====================
  Future<void> loadUser() async {
    try {
      isLoading.value = true;

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snap =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      final data = snap.data() ?? {};

      nameCtrl.text = data['name'] ?? '';
      surnameCtrl.text = data['surname'] ?? '';
      usernameCtrl.text = data['username'] ?? '';
      emailCtrl.text = data['email'] ?? '';

      // location → split into country + city
      final loc = data['location'] ?? '';
      if (loc.contains(',')) {
        final p = loc.split(",").map((e) => e.trim()).toList();
        countryCtrl.text = p[0];
        cityCtrl.text = p.length > 1 ? p[1] : "";
      } else {
        countryCtrl.text = loc;
        cityCtrl.text = "";
      }

      schoolCtrl.text = data['school'] ?? '';
      companyCtrl.text = data['company'] ?? '';
      roleCtrl.text = data['role'] ?? '';

      websiteCtrl.text = data['website'] ?? '';
      linkedinUrlCtrl.text = data['linkedinUrl'] ?? '';
      githubUrlCtrl.text = data['githubUrl'] ?? '';

      cvUrl.value = data['cvUrl'] ?? '';

      phoneNumberCtrl.text = data['phoneNumber'] ?? '';
      phoneCountryCode.value = data['phoneCountryCode'] ?? '+90';
      phoneCountryIso.value = data['phoneCountryIso'] ?? 'TR';
      // avatar (duelAvatar alanından çekiyoruz)
      final avatar = data['duelAvatar'];
      avatarPath.value = (avatar != null && avatar.isNotEmpty)
          ? avatar
          : "assets/avatars/avatar1.jpg";
    } catch (e) {
      _toast("Error", e.toString(), Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ===================== SAVE ALL CHANGES (ONE SHOT) =====================
  Future<void> saveProfileChanges() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Build location string
      final combinedLocation = [
        countryCtrl.text.trim(),
        cityCtrl.text.trim(),
      ].where((e) => e.isNotEmpty).join(", ");

      final updateData = {
        "name": nameCtrl.text,
        "surname": surnameCtrl.text,
        "username": usernameCtrl.text,
        "email": emailCtrl.text,
        "school": schoolCtrl.text,
        "company": companyCtrl.text,
        "role": roleCtrl.text,
        "website": websiteCtrl.text,
        "linkedinUrl": linkedinUrlCtrl.text,
        "githubUrl": githubUrlCtrl.text,
        "location": combinedLocation,
        "cvUrl": cvUrl.value,
        "phoneNumber": phoneNumberCtrl.text,
        "phoneCountryCode": phoneCountryCode.value,
        "phoneCountryIso": phoneCountryIso.value,
        "duelAvatar": avatarPath.value,
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update(updateData);

      Get.find<HomeController>().listenToUser();

      _toast("Updated", "Your profile has been updated successfully.",
          Colors.green);
    } catch (e) {
      _toast("Error", e.toString(), Colors.red);
    }
  }

  // ===================== PASSWORD CHANGE =====================
  Future<void> changePassword(String current, String next) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: current,
      );
      await user.reauthenticateWithCredential(cred);

      if (current == next) {
        _toast("Error", "New password cannot match current password.",
            Colors.red);
        return;
      }

      await user.updatePassword(next);
      Get.back();
      _toast("Success", "Your password has been changed.", Colors.green);
    } on FirebaseAuthException catch (e) {
      _toast("Error", e.message ?? "Password update failed", Colors.red);
    }
  }

  // ===================== VALIDATION =====================
  String? validateNotEmpty(String? v, String label) {
    if (v == null || v.trim().isEmpty) return "$label cannot be empty";
    return null;
  }

  String? validateUrl(String? v, String label) {
    if (v == null || v.trim().isEmpty) return null;
    final pattern = r"^(https?:\/\/)?([\w\-]+\.)+[\w]{2,}(\/.*)?$";
    final regex = RegExp(pattern);
    if (!regex.hasMatch(v.trim())) {
      return "Enter a valid $label URL";
    }
    return null;
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    surnameCtrl.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    countryCtrl.dispose();
    cityCtrl.dispose();
    schoolCtrl.dispose();
    companyCtrl.dispose();
    roleCtrl.dispose();
    websiteCtrl.dispose();
    linkedinUrlCtrl.dispose();
    githubUrlCtrl.dispose();
    phoneNumberCtrl.dispose();
    super.onClose();
  }

  // ===================== INTERNAL TOAST HELPER =====================
  void _toast(String title, String message, Color color) {
    showSimpleNotification(
      Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyStrong.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),

      background: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 3),
    );
  }
}
