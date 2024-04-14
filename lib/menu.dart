import 'package:flutter/material.dart';
import 'package:fyp_healthcare_app/data-comm/bt_template.dart';
import 'package:fyp_healthcare_app/profile_screen.dart';
import 'package:fyp_healthcare_app/home_screen.dart';
import 'package:fyp_healthcare_app/device_screen.dart';
import "package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart";
import 'package:fyp_healthcare_app/data-comm/ble.dart';
import 'package:fyp_healthcare_app/device_panel_screen.dart';
import 'package:fyp_healthcare_app/setting_screen.dart';
import 'package:fyp_healthcare_app/test1.dart';
import 'package:fyp_healthcare_app/device_wearable_screen.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<PersistentTabConfig> _tabs() => [
        PersistentTabConfig(
          screen: const DeviceScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.home, size: 30),
            title: "Home",
            textStyle: const TextStyle(fontSize: 14),
          ),
        ),
        PersistentTabConfig(
          screen: const ProfileScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.devices, size: 30),
            title: "Device",
            textStyle: const TextStyle(fontSize: 14),
          ),
        ),
        PersistentTabConfig(
          screen: const DeviceScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.nights_stay, size: 30),
            title: "Alarm",
            textStyle: const TextStyle(fontSize: 14),
          ),
        ),
        PersistentTabConfig(
          screen: const ProfileScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.account_circle, size: 30),
            title: "Profile",
            textStyle: const TextStyle(fontSize: 14),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) => PersistentTabView(
        tabs: _tabs(),
        navBarBuilder: (navBarConfig) => Style2BottomNavBar(
          navBarConfig: navBarConfig,
        ),
      );
}
