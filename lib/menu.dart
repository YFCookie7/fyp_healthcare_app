import 'package:flutter/material.dart';
import 'package:fyp_healthcare_app/data-comm/bt2.dart';
import 'package:fyp_healthcare_app/profile_screen.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ProfileScreen(),
    const BT2(),
    const BT2(),
    const BT2(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomNavigationBar(
        scaleFactor: 0.5,
        // elevation: 10,
        items: [
          CustomNavigationBarItem(
            icon: const Icon(Icons.home),
          ),
          CustomNavigationBarItem(
            icon: const Icon(Icons.analytics_outlined),
          ),
          CustomNavigationBarItem(
            icon: const Icon(Icons.nights_stay_outlined),
            badgeCount: 2,
            showBadge: true,
          ),
          CustomNavigationBarItem(
            icon: const Icon(Icons.alarm_outlined),
          ),
          CustomNavigationBarItem(
            icon: const Icon(Icons.account_circle),
            badgeCount: 5,
            showBadge: true,
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
        iconSize: 32.0,
        selectedColor: Color(0xff0c18fb),
        unSelectedColor: Colors.black,
        backgroundColor: Color.fromARGB(186, 255, 255, 255),
        strokeColor: Color(0x300c18fb),
        // borderRadius: Radius.circular(20),
        isFloating: false,
        blurEffect: true,
        opacity: 0.8,
      ),
    );
  }
}
