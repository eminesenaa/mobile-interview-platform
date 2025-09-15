import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/services/firebase/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main_view.dart';   // 🔹 MainView'i import et
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailOrUsernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final authService = AuthService();

  bool isLoading = false;

  Future<void> _login() async {
    setState(() => isLoading = true);

    String input = emailOrUsernameCtrl.text.trim();
    final password = passwordCtrl.text.trim();
    String email;

    if (input.contains("@")) {
      // Kullanıcı email yazdı
      email = input;
    } else {
      // Kullanıcı username yazdı → Firestore’dan email bul
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: input)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() => isLoading = false);
        Get.snackbar("Error", "Username not found.");
        return;
      }

      email = snapshot.docs.first["email"];
    }

    final user = await authService.signIn(email, password);

    setState(() => isLoading = false);

    if (user == null) {
      Get.snackbar("Error", "Login failed. Please check your credentials.");
    } else {
      // 🔹 Login başarılı → Ana sayfaya yönlendir
      Get.offAll(() => const MainView());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome Back 👋",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Login to continue",
                  style: TextStyle(color: Colors.black54, fontSize: 16)),
              const SizedBox(height: 32),

              TextField(
                controller: emailOrUsernameCtrl,
                decoration: const InputDecoration(
                  labelText: "Email or Username",
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
                onPressed: isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () => Get.to(() => const SignUpPage()),
                    child: const Text("Sign Up"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
