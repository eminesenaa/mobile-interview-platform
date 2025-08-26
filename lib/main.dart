// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:interview_project/pages/main_view.dart';
import 'controllers/question_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Controller'i Firebase hazır olduktan SONRA enjekte et
  Get.put<QuestionController>(QuestionController(), permanent: true);

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mock Interview App',
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put<QuestionController>(QuestionController(), permanent: true);
      }),
      home: const MainView(),
    );
  }
}
