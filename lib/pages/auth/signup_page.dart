import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/services/firebase/auth_service.dart';

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

  final user = await authService.signUp(
    email: email,
    password: password,
    name: name,
    surname: surname,
    username: username,
  );

  setState(() => isLoading = false);

  if (user == null) {
    Get.snackbar("Error", "Sign Up failed.");
  } else {
    Get.back(); // başarıyla kaydoldu → LoginPage’e dön
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
