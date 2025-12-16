import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/firebase/auth_service.dart';
import '../../main_view.dart';

class LoginController  extends GetxController {
  final AuthService _authService = AuthService();

  // --------------------
  // Controllers
  // --------------------
  final emailOrUsernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // --------------------
  // State
  // --------------------
  final isLoading = false.obs;

  // --------------------
  // Login
  // --------------------
  Future<void> login() async {
    if (isLoading.value) return;

    final input = emailOrUsernameCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (input.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    isLoading.value = true;

    try {
      String email;

      if (input.contains("@")) {
        email = input;
      } else {
        final snapshot = await FirebaseFirestore.instance
            .collection("users")
            .where("username", isEqualTo: input)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) {
          throw Exception("Username not found");
        }

        email = snapshot.docs.first["email"];
      }

      final user = await _authService.signIn(email, password);

      if (user == null) {
        throw Exception("Invalid credentials");
      }

      Get.offAll(() => const MainView());
    } catch (e) {
      Get.snackbar(
        "Login failed",
        e.toString().replaceAll("Exception:", "").trim(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --------------------
  // Social logins (UI hazır, logic sonra)
  // --------------------
  void loginWithGoogle() {
    Get.snackbar("Coming soon", "Google login will be added soon");
  }

  void loginWithApple() {
    Get.snackbar("Coming soon", "Apple login will be added soon");
  }

  @override
  void onClose() {
    emailOrUsernameCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
