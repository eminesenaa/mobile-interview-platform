import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/colors.dart';
import 'firebase_options.dart';
import 'pages/auth/login_page.dart';
import 'pages/main_view.dart';
import 'controllers/question_controller.dart';
import 'controllers/auth_controller.dart';
import 'services/ai/ai_service.dart';
import 'package:overlay_support/overlay_support.dart';

Future<void> _initAi() async {
  Get.put<AiService>(AiService(), permanent: true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initAi();

  runApp(
    OverlaySupport.global(
      // 🔑 tüm app burada sarıldı
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mock Interview App',
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put<AuthController>(AuthController(), permanent: true);
        Get.put<QuestionController>(QuestionController(), permanent: true);
      }),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          elevation: 0,
          iconTheme: IconThemeData(color: headlineColor),
          titleTextStyle: TextStyle(
            color: headlineColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 🔹 Ana yönlendirme
      home: GetX<AuthController>(
        builder: (auth) {
          print(
              "🔥 build çalıştı: isLoading=${auth.isLoading.value}, user=${auth.user?.email}");

          if (auth.isLoading.value) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return auth.user != null ? MainView() : const LoginPage();
        },
      ),
    );
  }
}
