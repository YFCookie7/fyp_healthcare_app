import 'package:flutter/material.dart';
import 'package:fyp_healthcare_app/setting_screen.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';
import 'package:giffy_dialog/giffy_dialog.dart' as giffy_dialog;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:fyp_healthcare_app/data-comm/ble.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.blue),
        backgroundColor: Colors.transparent,
        title: const Padding(
          padding: EdgeInsets.only(top: 20.0, left: 5.0),
          child: Text(
            'My Devices',
            style: TextStyle(
                fontFamily: 'PatuaOne', fontSize: 24, color: Colors.black),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingScreen()),
                );
              },
              child: Container(
                height: 250,
                width: 300,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue, Colors.green],
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 20.0,
                      left: 20.0,
                      child: Text(
                        'Sleep Tracker',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 9.0,
                      right: 10.0,
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return giffy_dialog.GiffyDialog.image(
                                Image.asset('assets/gif/watch.gif',
                                    height: 200, fit: BoxFit.cover),
                                title: const Text(
                                  'Sleep Tracker',
                                  textAlign: TextAlign.center,
                                ),
                                content: const Text(
                                  'Sleep tracker can measure your body temperature, heartbeat, and spo2.\n\nBluetooth connection is required to connect to the device.',
                                  textAlign: TextAlign.justify,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.info, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      bottom: 50.0,
                      left: 50.0,
                      child: Image.asset(
                        'assets/icon/avatar.png',
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 50.0,
                      right: 40.0,
                      child: Lottie.asset(
                        'assets/lottie/tick_lottie.json',
                        height: 100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingScreen()),
                );
              },
              child: Container(
                height: 250,
                width: 300,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue, Colors.green],
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 20.0,
                      left: 20.0,
                      child: Text(
                        'Sleep Tracker',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 9.0,
                      right: 10.0,
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return giffy_dialog.GiffyDialog.image(
                                Image.asset('assets/gif/watch.gif',
                                    height: 200, fit: BoxFit.cover),
                                title: const Text(
                                  'Sleep Tracker',
                                  textAlign: TextAlign.center,
                                ),
                                content: const Text(
                                  'Sleep tracker can measure your body temperature, heartbeat, and spo2.\n\nBluetooth connection is required to connect to the device.',
                                  textAlign: TextAlign.justify,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.info, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      bottom: 50.0,
                      left: 50.0,
                      child: Image.asset(
                        'assets/icon/avatar.png',
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 50.0,
                      right: 40.0,
                      child: Lottie.asset(
                        'assets/lottie/tick_lottie.json',
                        height: 100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50)
          ],
        ),
      ),
    );
  }
}
