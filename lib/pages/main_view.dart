import 'package:flutter/material.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/colors.dart';

import 'home_page.dart';
import 'practice_page.dart';
import 'simulation_page.dart';
import 'library_page.dart';
import 'profile_page.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomePage(),
    PracticePage(),
    SimulationPage(),
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
            TabItem(icon: FontAwesomeIcons.stopwatch, title: 'Simulate'),
            TabItem(icon: FontAwesomeIcons.bookOpen, title: 'Library'),
            TabItem(icon: FontAwesomeIcons.user, title: 'Profile'),
          ],
          backgroundColor: pastelBlue,
          color: indigoDye,
          colorSelected: white,
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
