import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/services/firebase/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:interview_project/pages/auth/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameCtrl = TextEditingController();
  final surnameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final authService = AuthService();
  bool isLoading = false;

  Future<void> _signUp() async {
  setState(() => isLoading = true);

  final email = emailCtrl.text.trim();
  final password = passwordCtrl.text.trim();
  final name = nameCtrl.text.trim();
  final surname = surnameCtrl.text.trim();
  final username = usernameCtrl.text.trim();

  try {
    final user = await authService.signUp(
      email: email,
      password: password,
      username: username,
      name: name,
      surname: surname,
    );

    setState(() => isLoading = false);
if (user == null) {
  Get.snackbar("Error", "Sign Up failed.");
} else {
  Get.offAll(() => LoginPage()); // 🔹 direkt LoginPage’e gönder
  Get.snackbar("Success", "Account created successfully! Please login.");
}

  } on FirebaseAuthException catch (e) {
    setState(() => isLoading = false);

    String msg;
    if (e.code == "username-already-in-use") {
      msg = "This username is already taken.";
    } else if (e.code == "email-already-in-use") {
      msg = "This email is already registered.";
    } else if (e.code == "weak-password") {
      msg = "Password is too weak (min 6 characters).";
    } else {
      msg = e.message ?? "Unknown error.";
    }

    Get.snackbar("Sign Up Error", msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black);
  } catch (e) {
    setState(() => isLoading = false);
    Get.snackbar("Error", "Unexpected error: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: surnameCtrl,
              decoration: const InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: usernameCtrl,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: isLoading ? null : _signUp,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
