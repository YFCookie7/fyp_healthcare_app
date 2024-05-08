import 'package:flutter/material.dart';
import 'package:fyp_healthcare_app/data-comm/ble.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      home: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => EasyLoading.show(status: 'Loading...'),
              child: const Text('button'),
            ),
          ],
        ),
      ),
    );
  }
}
