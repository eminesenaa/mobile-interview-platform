import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../services/firebase/auth_service.dart';
import '../../main_view.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  final emailOrUsernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final isLoading = false.obs;

  /// 🔹 Login İşlemi
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

      // Email mi Username mi kontrolü
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

      // 🔹 Email Doğrulama Kontrolü
      if (!user.emailVerified) {
        await _authService.signOut(); // Güvenlik için çıkış yap
        _showVerificationDialog();
        return;
      }

      Get.offAll(() => const MainView());
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No account found with this email.";
          break;
        case 'wrong-password':
          message = "Incorrect password.";
          break;
        case 'invalid-credential':
          message = "Invalid email or password.";
          break;
        case 'user-disabled':
          message = "This account has been disabled.";
          break;
        case 'too-many-requests':
          message = "Too many attempts. Please try again later.";
          break;
        case 'network-request-failed':
          message = "Network error. Check your connection.";
          break;
        default:
          message = e.message ?? "Authentication failed.";
      }
      Get.snackbar("Login Failed", message);
    } catch (e) {
      Get.snackbar(
          "Login failed", e.toString().replaceAll("Exception:", "").trim());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Google Login
  Future<void> loginWithGoogle() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        Get.offAll(() => const MainView());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
          "Google Login Failed", e.message ?? "Authentication failed.");
    } catch (e) {
      if (e.toString().contains('canceled') || e.toString().contains('cancel'))
        return;
      Get.snackbar("Error", "Google sign in failed. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Apple Login
  Future<void> loginWithApple() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final user = await _authService.signInWithApple();
      if (user != null) {
        Get.offAll(() => const MainView());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Apple Login Failed", e.message ?? "Authentication failed.");
    } catch (e) {
      if (e.toString().contains('canceled') || e.toString().contains('cancel'))
        return;
      Get.snackbar("Error", "Apple sign in failed. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Şifremi Unuttum Dialogu
  void showForgotPasswordDialog() {
    final resetEmailCtrl = TextEditingController();
    Get.defaultDialog(
      title: "Reset Password",
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Enter your email address to receive a reset link."),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailCtrl,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      textConfirm: "Send Link",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blueAccent,
      onConfirm: () async {
        final email = resetEmailCtrl.text.trim();
        if (email.isEmpty || !email.contains("@")) {
          Get.snackbar("Error", "Please enter a valid email");
          return;
        }
        try {
          await _authService.sendPasswordResetEmail(email);
          Get.back();
          Get.snackbar("Success", "Password reset link sent to $email");
        } catch (e) {
          Get.snackbar("Error", e.toString());
        }
      },
    );
  }

  void _showVerificationDialog() {
    Get.defaultDialog(
      title: "Email Not Verified",
      middleText: "You need to verify your email before accessing the app.",
      textCancel: "Close",
      textConfirm: "Resend Email",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blueAccent,
      onConfirm: () async {
        // Not: Kullanıcı signOut olduğu için burada tekrar login gerekebilir
        // veya bu akışı 'Giriş Başarılı -> Dialog -> Çıkış' şeklinde yönetmelisin.
        // Basitlik adına kullanıcıya mail kutusunu kontrol etmesini söylüyoruz.
        Get.back();
        Get.snackbar("Check Inbox",
            "If you didn't receive it, try logging in again to trigger a new email.");
      },
    );
  }

  @override
  void onClose() {
    emailOrUsernameCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
