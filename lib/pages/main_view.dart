// ===================== File: lib/pages/main_view.dart =====================

import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav_bar.dart';
import 'exam/home/exam_home_page.dart';
import 'home/home_page.dart';
import 'practice/practice_page.dart';
import 'library/library_page.dart';
import 'profile/profile_page.dart';

class MainView extends StatefulWidget {
  /// Başlangıçta hangi sekme açık olacak
  /// 0: Home, 1: Practice, 2: Exam, 3: Library, 4: Profile
  final int initialIndex;

  const MainView({super.key, this.initialIndex = 0});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late int _currentIndex;

  /// Bottom navigation ile gösterilecek sayfalar dizisi
  final List<Widget> _screens = const [
    HomePage(),
    PracticePage(),
    ExamHomePage(),
    LibraryPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // 🔹 Dışarıdan gelen initialIndex'i kullan
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Seçili index'e göre ilgili sayfayı gösteriyoruz
      body: _screens[_currentIndex],

      // Alttaki custom bottom navigation bar
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
