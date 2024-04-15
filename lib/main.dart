import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fyp_healthcare_app/data-comm/bt_template.dart';
import 'package:fyp_healthcare_app/onboarding_screen.dart';
import 'package:fyp_healthcare_app/splash_screen.dart';
import 'package:fyp_healthcare_app/menu.dart';
import 'package:fyp_healthcare_app/device_wearable_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  String piAddress = await getPiAddress('raspberry');
  developer.log('Raspberry Pi IP Address: $piAddress', name: 'debug_main');

  String storedPiAddress = prefs.getString('piAddress') ?? '';
  if (storedPiAddress != piAddress && piAddress != '') {
    prefs.setString('piAddress', piAddress);
    developer.log('New ip address record stored in shared preference',
        name: 'debug_main');
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: WearableDeviceScreen());
  }
}

Future<String> getPiAddress(String hostname) async {
  try {
    final result = await InternetAddress.lookup(hostname);
    if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
      return result.first.address;
    } else {
      developer.log('Failed to find the device', name: 'debug_main');
    }
  } on SocketException catch (e) {
    developer.log('Error: $e', name: 'debug_main');
  }
  return '';
}
