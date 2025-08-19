// ===================== File: lib/main.dart =====================
// Purpose: Uygulamanın giriş noktası. GetX ile sarmalanmış MaterialApp
//          oluşturarak `MainView`'i başlangıç sayfası olarak açar.
//
// Tech stack:
// - Flutter Material
// - GetX (navigation, state management, snackbar vs. için)
//
// Notlar:
// - `GetMaterialApp`, `MaterialApp`'in GetX özellikli versiyonudur.
// - Routing yapısı büyürse `getPages` ve `initialRoute` kullanabilirsiniz.
// ===============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/main_view.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      title: 'Mock Interview App',
      debugShowCheckedModeBanner: false,
      home: MainView(),
      // TODO: Route yapısı büyürse:
      // getPages: [
      //   GetPage(name: '/', page: () => const MainView()),
      //   GetPage(name: '/practice', page: () => const PracticePage()),
      //   ...
      // ],
      // initialRoute: '/',
      //
      // TODO: Tema merkezi yönetimi istenirse:
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      //   useMaterial3: true,
      // ),
    );
  }
}
