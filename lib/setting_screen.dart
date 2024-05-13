import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController _textFieldController2 = TextEditingController();

  @override
  void dispose() {
    _textFieldController.dispose();
    _textFieldController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _textFieldController,
                  decoration: const InputDecoration(
                    labelText: "Configure Pi Address",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.wifi),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  String textFieldContent = _textFieldController.text;
                  developer.log('Content of TextField: $textFieldContent',
                      name: 'debug.setting');
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString('piAddress', textFieldContent);
                },
                child: const Text('Update Pi address'),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _textFieldController2,
                  decoration: const InputDecoration(
                    labelText: "Configure watch device name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.bluetooth),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  String textFieldContent = _textFieldController2.text;
                  developer.log('Content of TextField: $textFieldContent',
                      name: 'debug.setting');
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString('watch_name', textFieldContent);
                },
                child: const Text('Update Watch Device Name'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
