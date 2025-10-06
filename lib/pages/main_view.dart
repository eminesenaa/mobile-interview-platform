// ===================== File: lib/pages/main_view.dart =====================
import 'package:flutter/material.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/colors.dart';

import 'exam/exam_home_page.dart';
import 'home/home_page.dart';
import 'practice/practice_page.dart';
import 'library/library_page.dart';
import 'profile/profile_page.dart';

class MainView extends StatefulWidget {
  /// Başlangıçta hangi sekme açık olacak (0: Home, 1: Practice, 2: Exam, 3: Library, 4: Profile)
  final int initialIndex;

  const MainView({super.key, this.initialIndex = 0});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late int _currentIndex;

  /// Gösterilecek sayfalar dizisi
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
    _currentIndex = widget.initialIndex; // 🔹 Dışarıdan gelen index’i kullan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
        child: BottomBarFloating(
          items: const [
            TabItem(icon: Icons.home, title: 'Home'),
            TabItem(icon: FontAwesomeIcons.penToSquare, title: 'Practice'),
            TabItem(icon: FontAwesomeIcons.stopwatch, title: 'Exam'),
            TabItem(icon: FontAwesomeIcons.bookOpen, title: 'Library'),
            TabItem(icon: FontAwesomeIcons.user, title: 'Profile'),
          ],
          backgroundColor: primaryColor,
          color: headlineColor,
          colorSelected: secondaryColor,
          borderRadius: BorderRadius.circular(50),
          indexSelected: _currentIndex,
          iconSize: 20,
          paddingVertical: 18,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
