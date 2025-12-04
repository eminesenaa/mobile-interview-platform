// ===================== File: profile_edit_controller.dart =====================
// Purpose: Profile edit logic using User model + Firestore sync
// Clean, modern, short, fully reactive controller
// ============================================================================

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class ProfileEditController extends GetxController {
  // ===================== USER FIELDS (Reactive) =====================
  final name = ''.obs;
  final surname = ''.obs;
  final username = ''.obs;
  final email = ''.obs;

  final country = ''.obs; // NEW → separate from location
  final city = ''.obs;

  final school = ''.obs;
  final company = ''.obs;
  final role = ''.obs;

  final website = ''.obs;
  final linkedinUrl = ''.obs;
  final githubUrl = ''.obs;

  final phoneNumber = ''.obs;
  final phoneCountryCode = '+90'.obs;
  final phoneCountryIso = 'TR'.obs;

  final cvUrl = ''.obs;

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

      name.value = data['name'] ?? '';
      surname.value = data['surname'] ?? '';
      username.value = data['username'] ?? '';
      email.value = data['email'] ?? '';

      // location → split into country + city
      final loc = data['location'] ?? '';
      if (loc.contains(',')) {
        final p = loc.split(",").map((e) => e.trim()).toList();
        country.value = p[0];
        city.value = p.length > 1 ? p[1] : "";
      }

      school.value = data['school'] ?? '';
      company.value = data['company'] ?? '';
      role.value = data['role'] ?? '';

      website.value = data['website'] ?? '';
      linkedinUrl.value = data['linkedinUrl'] ?? '';
      githubUrl.value = data['githubUrl'] ?? '';

      cvUrl.value = data['cvUrl'] ?? '';

      phoneNumber.value = data['phoneNumber'] ?? '';
      phoneCountryCode.value = data['phoneCountryCode'] ?? '+90';
      phoneCountryIso.value = data['phoneCountryIso'] ?? 'TR';
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
        country.value.trim(),
        city.value.trim(),
      ].where((e) => e.isNotEmpty).join(", ");

      final updateData = {
        "name": name.value,
        "surname": surname.value,
        "username": username.value,
        "email": email.value,
        "school": school.value,
        "company": company.value,
        "role": role.value,
        "website": website.value,
        "linkedinUrl": linkedinUrl.value,
        "githubUrl": githubUrl.value,
        "location": combinedLocation,
        "cvUrl": cvUrl.value,
        "phoneNumber": phoneNumber.value,
        "phoneCountryCode": phoneCountryCode.value,
        "phoneCountryIso": phoneCountryIso.value,
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update(updateData);

      _toast("Updated", "Your profile has been updated successfully 🎉",
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
        _toast("Error", "New password cannot match current password ❌",
            Colors.red);
        return;
      }

      await user.updatePassword(next);
      Get.back();
      _toast("Success", "Your password has been changed 🎉", Colors.green);
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

  // ===================== INTERNAL TOAST HELPER =====================
  void _toast(String title, String message, Color color) {
    showSimpleNotification(
      Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(message, style: const TextStyle(color: Colors.white)),
      background: color,
      autoDismiss: true,
      duration: const Duration(seconds: 3),
    );
  }
}
