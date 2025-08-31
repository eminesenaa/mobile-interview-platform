// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/main_view.dart';
import 'services/ai/app_bindings.dart'; // AiService + QuestionController burada kaydoluyor

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mock Interview App',
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(), // <-- tüm DI burada
      home: const MainView(),
    );
  }
}
