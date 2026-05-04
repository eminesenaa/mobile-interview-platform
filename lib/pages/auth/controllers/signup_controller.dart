import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../services/firebase/auth_service.dart';
import '../../main_view.dart';
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

  // ===================== SIGNUP MODE =====================

  /// false = Candidate, true = HR
  final isHrSignup = false.obs;

  // ===================== SIGNUP MODE SWITCH =====================

  void setSignupMode(bool isHr) {
    isHrSignup.value = isHr;
  }

  // ===================== SIGNUP HANDLER =====================

  void handleSignup() {
    if (isHrSignup.value) {
      signUpAsHR();
    } else {
      signUp();
    }
  }

  Future<void> signUp() async {
    if (isLoading.value) return;

    final name = nameCtrl.text.trim();
    final surname = surnameCtrl.text.trim();
    final username = usernameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (name.isEmpty ||
        surname.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
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
        middleText:
            "We have sent a verification link to $email.\nPlease verify your account before logging in.",
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

  // ===================== HR SIGNUP (TEMP) =====================

  Future<void> signUpAsHR() async {
    if (isLoading.value) return;

    final name = nameCtrl.text.trim();
    final surname = surnameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (name.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    if (!acceptedTerms.value) {
      Get.snackbar("Error", "You must accept the Terms of Service");
      return;
    }

    isLoading.value = true;

    try {
      // 🔥 TEMP LOGIC
      // Backend gelince:
      // - HRUser oluşturulacak
      // - Company oluşturulacak veya bağlanacak

      if (!email.contains("hr")) {
        Get.snackbar("Error", "Use an HR email (e.g. hr@company.com)");
        return;
      }

      // 🔥 Simülasyon
      await Future.delayed(const Duration(seconds: 1));

      Get.defaultDialog(
        title: "HR Account Created",
        middleText:
            "Your HR account has been created.\nYou can now manage interviews.",
        textConfirm: "Go to Login",
        confirmTextColor: Colors.white,
        buttonColor: Colors.blueAccent,
        barrierDismissible: false,
        onConfirm: () {
          Get.back();
          Get.offAll(() => const LoginPage());
        },
      );
    } catch (e) {
      Get.snackbar("HR Sign Up Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Google ile Kayıt / Giriş
  Future<void> signUpWithGoogle() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        Get.offAll(() => const MainView());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
          "Google Sign Up Failed", e.message ?? "Authentication failed.");
    } catch (e) {
      if (e.toString().contains('canceled') || e.toString().contains('cancel'))
        return;
      Get.snackbar("Error", "Google sign up failed. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Apple ile Kayıt / Giriş
  Future<void> signUpWithApple() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final user = await _authService.signInWithApple();
      if (user != null) {
        Get.offAll(() => const MainView());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
          "Apple Sign Up Failed", e.message ?? "Authentication failed.");
    } catch (e) {
      if (e.toString().contains('canceled') || e.toString().contains('cancel'))
        return;
      Get.snackbar("Error", "Apple sign up failed. Please try again.");
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
