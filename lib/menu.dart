import 'package:flutter/material.dart';
import 'package:fyp_healthcare_app/data-comm/bt_template.dart';
import 'package:fyp_healthcare_app/profile_screen.dart';
import 'package:fyp_healthcare_app/home_screen.dart';
import 'package:fyp_healthcare_app/device_screen.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';

import 'package:fyp_healthcare_app/data-comm/ble.dart';
import 'package:fyp_healthcare_app/device_panel_screen.dart';
import 'package:fyp_healthcare_app/test1.dart';
import 'package:fyp_healthcare_app/device_wearable_screen.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DeviceScreen(),
    const Test1(),
    const BtTemplate(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 65,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(
                  color: Color.fromARGB(255, 61, 59, 59), width: 0.2)),
        ),
        child: CustomNavigationBar(
          scaleFactor: 0.5,
          // elevation: 10,
          items: [
            CustomNavigationBarItem(
              icon: const Icon(Icons.home),
              title: const Text("Home"),
            ),
            CustomNavigationBarItem(
              icon: const Icon(Icons.devices_other),
              title: const Text("Device"),
            ),
            CustomNavigationBarItem(
              icon: const Icon(Icons.nights_stay_outlined),
              title: const Text("Alarm"),
              badgeCount: 2,
              showBadge: true,
            ),
            CustomNavigationBarItem(
              icon: const Icon(Icons.account_circle),
              title: const Text("Profile"),
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
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          // backgroundColor: Color.fromARGB(183, 255, 255, 255),
          strokeColor: Color(0x300c18fb),
          // borderRadius: Radius.circular(20),
          isFloating: false,
          blurEffect: true,
          opacity: 0.8,
        ),
      ),
    );
  }
}
