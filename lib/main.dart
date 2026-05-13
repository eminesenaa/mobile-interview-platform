import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:interview_project/pages/library/controllers/library_controller.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

import 'constants/colors.dart';
import 'firebase_options.dart';
import 'pages/auth/login_page.dart';
import 'pages/main_view.dart';
import 'controllers/question_controller.dart';
import 'controllers/auth_controller.dart';
import 'services/ai/ai_service.dart';
import 'pages/hr/dashboard/hr_dashboard_page.dart';
import 'services/interview/job_application_service.dart';

Future<void> _initAi() async {
  Get.put<AiService>(AiService(), permanent: true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _initAi();
  await dotenv.load(fileName: ".env");

  // Sistem UI (status bar vs) ayarı
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  Get.put(LibraryController(), permanent: true);

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
        Get.put<JobApplicationService>(JobApplicationService(), permanent: true);
      }),
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          toolbarHeight: 70,
          iconTheme: IconThemeData(
            color: AppColors.textPrimary, // geri ok + diğer ikonlar
            size: 24,
          ),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          centerTitle: true,
          // AppBar altına ince çizgi
          shape: Border(
            bottom: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.primary,
          surface: AppColors.surface,
          background: AppColors.background,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
      ),
      // 🔹 Ana yönlendirme
      home: GetX<AuthController>(
        builder: (auth) {
          print(
            "🔥 build çalıştı: isLoading=${auth.isLoading.value}, user=${auth.user?.email}, isHr=${auth.isHr.value}",
          );

          if (auth.isLoading.value) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (auth.user != null) {
            return auth.isHr.value ? const HRDashboardPage() : MainView();
          }

          return const LoginPage();
        },
      ),
    );
  }
}
