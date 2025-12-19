import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../services/firebase/auth_service.dart';
import '../login_page.dart';

class SignupController extends GetxController {
  final AuthService _authService = AuthService();

  final nameCtrl = TextEditingController();
  final surnameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final isLoading = false.obs;
  final acceptedTerms = false.obs;

  Future<void> signUp() async {
    if (isLoading.value) return;

    final name = nameCtrl.text.trim();
    final surname = surnameCtrl.text.trim();
    final username = usernameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (name.isEmpty || surname.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    if (!acceptedTerms.value) {
      Get.snackbar("Error", "You must accept the Terms of Service");
      return;
    }

    isLoading.value = true;

    try {
      // 1. Kayıt
      final user = await _authService.signUp(
        email: email,
        password: password,
        username: username,
        name: name,
        surname: surname,
      );

      if (user == null) throw Exception("Sign up failed");

      // 2. Doğrulama Maili
      await _authService.sendEmailVerification();

      // 3. Bilgilendirme ve Yönlendirme
      Get.defaultDialog(
        title: "Verify Your Email",
        middleText: "We have sent a verification link to $email.\nPlease verify your account before logging in.",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        buttonColor: Colors.blueAccent,
        barrierDismissible: false,
        onConfirm: () {
          Get.back();
          Get.offAll(() => const LoginPage());
        },
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case "username-already-in-use":
          message = "This username is already taken.";
          break;
        case "email-already-in-use":
          message = "This email is already registered.";
          break;
        case "weak-password":
          message = "Password is too weak (min 6 characters).";
          break;
        default:
          message = e.message ?? "Unknown error.";
      }
      Get.snackbar("Sign Up Error", message);
    } catch (e) {
      Get.snackbar("Error", e.toString().replaceAll("Exception:", "").trim());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    surnameCtrl.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}