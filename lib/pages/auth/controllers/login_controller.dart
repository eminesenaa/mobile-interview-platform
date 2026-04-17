import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/firebase/auth_service.dart';
import '../../../services/sfx/sound_service.dart';
import '../../hr/hr_dashboard_page.dart';
import '../../main_view.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  final emailOrUsernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final isLoading = false.obs;
  final rememberMe = false.obs;

  // ===================== LOGIN MODE =====================

  /// false = Candidate, true = HR
  final isHrLogin = false.obs;

  static const _kRememberMe = 'remember_me';
  static const _kSavedInput = 'saved_input';

  @override
  void onInit() {
    super.onInit();
    _loadRememberMe();
  }

  // ===================== REMEMBER ME =====================
  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final remembered = prefs.getBool(_kRememberMe) ?? false;
    rememberMe.value = remembered;
    if (remembered) {
      emailOrUsernameCtrl.text = prefs.getString(_kSavedInput) ?? '';
    }
  }

  Future<void> toggleRememberMe(bool value) async {
    rememberMe.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRememberMe, value);
    if (!value) {
      await prefs.remove(_kSavedInput);
    }
  }

  // ===================== LOGIN MODE SWITCH =====================

  void setLoginMode(bool isHr) {
    isHrLogin.value = isHr;
  }

  Future<void> _saveInputIfRemembered() async {
    if (rememberMe.value) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSavedInput, emailOrUsernameCtrl.text.trim());
    }
  }

  // ===================== LOGIN HANDLER =====================

  void handleLogin() {
    if (isHrLogin.value) {
      loginAsHR();
    } else {
      login();
    }
  }

  // ===================== LOGIN =====================
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

      if (!user.emailVerified) {
        await _authService.signOut();
        _showVerificationDialog();
        return;
      }

      await _saveInputIfRemembered();

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

  // ===================== HR LOGIN (TEMP) =====================

  Future<void> loginAsHR() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final input = emailOrUsernameCtrl.text.trim();
      final password = passwordCtrl.text.trim();

      if (input.isEmpty || password.isEmpty) {
        Get.snackbar("Error", "Please fill all fields");
        return;
      }

      // 🔥 TEMP LOGIC (backend gelince değişecek)
      if (!input.contains("hr")) {
        Get.snackbar("Error", "This account is not an HR account");
        return;
      }

      // 🔊 sound (optional)
      SoundService.play(SoundEffect.loginSuccess);

      // 🔥 TODO: HR Dashboard'a yönlendirilecek
      Get.offAll(() => const HRDashboardPage());

    } catch (e) {
      Get.snackbar("HR Login Failed", e.toString());
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
        // 🔊 Login success sound
        SoundService.play(SoundEffect.loginSuccess);
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
        // 🔊 Login success sound
        SoundService.play(SoundEffect.loginSuccess);
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

  /// 🔹 Şifremi Unuttum
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
        } finally {
          resetEmailCtrl.dispose(); // 🔥 Her durumda dispose et
        }
      },
      // 🔥 Cancel'da da dispose et
      onCancel: () => resetEmailCtrl.dispose(),
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
