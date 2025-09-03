// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'constants/colors.dart';
import 'firebase_options.dart';
import 'pages/main_view.dart';
import 'controllers/question_controller.dart';

// AI wrapper
import 'services/ai/ai_service.dart';

Future<void> _initAi() async {
  // OpenAIService statik çalışıyor; yalnızca wrapper'ı DI'a koymamız yeterli
  Get.put<AiService>(AiService(), permanent: true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await _initAi();
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
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor, // constants’tan gelen renk
          elevation: 0,
          iconTheme: IconThemeData(
            color: headlineColor,        // geri ok rengi
          ),
          titleTextStyle: TextStyle(    // AppBar başlık yazısı stili
            color: headlineColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MainView(),
    );
  }
}
