import 'package:flutter/material.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/colors.dart';
// ===================== File: lib/pages/main_view.dart =====================
// Purpose: Uygulamanın ana iskeleti. Alt tarafta bottom navigation bar ile
//          Home / Practice / Simulation / Library / Profile sayfaları arasında
//          geçiş yapılmasını sağlar.
//
// Önemli Notlar:
// - extendBody:true => Bottom bar üzerinde transparan efekt kullanırken
//   gövdenin barın altına doğru "taşmasını" sağlar.
// - Body'ye verilen bottom padding (88) içeriklerin bar'ın altında kalmasını engeller.
// - _currentIndex aktif sekmeyi tutar; _screens dizisiyle bire bir eşleşir.
//
// Bağımlılıklar:
// - awesome_bottom_bar (nav bar için)
// - font_awesome_flutter (ikonlar için)
// - constants/colors.dart (tema renkleri için; isme göre uyarlayın)
// ==========================================================================

import 'exam/exam_home_page.dart';
import 'home/home_page.dart';
import 'practice/practice_page.dart';
import 'library/library_page.dart';
import 'profile/profile_page.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  /// Aktif sekme index'i. 0..n arası [items] ve [_screens] ile birebir eşleşir.
  int _currentIndex = 0;

  /// Gösterilecek sayfalar dizisi (index => sayfa)
  final List<Widget> _screens = const [
    HomePage(),
    PracticePage(),
    ExamHomePage(),
    LibraryPage(),
    ProfilePage(),
  ];

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
