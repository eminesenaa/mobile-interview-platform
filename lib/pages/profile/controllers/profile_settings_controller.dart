import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class ProfileSettingsController extends GetxController {
  final RxString name = ''.obs;
  final RxString surname = ''.obs;
  final RxString username = ''.obs;
  final RxString email = ''.obs;
  final RxString language = 'English'.obs;

  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  /// Load user data from Firestore
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
      language.value = data['language'] ?? 'English';
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Validators ----
  String? validateNotEmpty(String? v, String field) {
    if (v == null || v.trim().isEmpty) {
      return '$field cannot be empty';
    }
    return null;
  }

  String? validateEmail(String? v) {
    if (v == null || !v.contains('@')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ---- Firestore Update Methods ----
  Future<void> setName(String v) async => _updateField("name", v, name, "Name");
  Future<void> setSurname(String v) async =>
      _updateField("surname", v, surname, "Surname");
  Future<void> setUsername(String v) async =>
      _updateField("username", v, username, "Username");
  Future<void> setEmail(String v) async =>
      _updateField("email", v, email, "Email");
  Future<void> setLanguage(String v) async =>
      _updateField("language", v, language, "Language");

Future<void> _updateField(
    String field, String value, RxString localVar, String label) async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({field: value});

    localVar.value = value;

    // Make first letter lowercase
    final labelLower = label[0].toLowerCase() + label.substring(1);

    _showNotification(
      "Updated",
      "Your $labelLower has been updated successfully ✅",
      Colors.green,
    );
  } catch (e) {
    final labelLower = label[0].toLowerCase() + label.substring(1);

    _showNotification(
      "Error",
      "Failed to update your $labelLower: $e",
      Colors.red,
    );
  }
}



  // ---- Password Change ----
  Future<void> changePassword(String current, String next) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Re-authenticate with the current password
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: current,
      );
      await user.reauthenticateWithCredential(cred);

      // Prevent using the same password
      if (current == next) {
        _showNotification(
            "Error", "New password cannot be the same as current password ❌",
            Colors.red);
        return;
      }

      // Update the password
      await user.updatePassword(next);

      // ✅ Success → close dialog + show notification
      Get.back(); // closes the password change dialog
      _showNotification(
          "Success", "Your password has been changed successfully 🎉",
          Colors.green);
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = "The current password is incorrect ❌";
      } else if (e.code == 'weak-password') {
        message = "The new password is too weak (minimum 6 characters) ❌";
      } else if (e.code == 'requires-recent-login') {
        message = "Please sign in again to update your password ⚠️";
      } else {
        message = e.message ?? "Password change failed ❌";
      }

      _showNotification("Error", message, Colors.red);
    } catch (e) {
      _showNotification("Error", e.toString(), Colors.red);
    }
  }

  // ---- Overlay Notification Helper ----
  void _showNotification(String title, String message, Color bgColor) {
    print("🔔 Notification triggered: $title - $message"); // debug log
    showSimpleNotification(
      Text(title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      subtitle: Text(message, style: const TextStyle(color: Colors.white)),
      background: bgColor,
      autoDismiss: true,
      duration: const Duration(seconds: 3),
      slideDismissDirection: DismissDirection.up,
    );
  }
}
