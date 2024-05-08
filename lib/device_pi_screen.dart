import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter/material.dart';
import 'package:fyp_healthcare_app/globals.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class PiDeviceScreen extends StatefulWidget {
  const PiDeviceScreen({Key? key}) : super(key: key);

  @override
  _PiDeviceScreenState createState() => _PiDeviceScreenState();
}

class _PiDeviceScreenState extends State<PiDeviceScreen> {
  Timer? _makeRequestTimer;
  String piAddress = "http://192.168.1.109:5000";
  IconData iconStatus = Icons.sync;
  IconData iconRecording = Icons.sync;
  Color deviceStatusColor = Colors.grey;
  Color deviceRecordingColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    getPiAddress();
    _checkSleepStatus();
  }

  @override
  void dispose() {
    _makeRequestTimer?.cancel();
    super.dispose();
  }

  Future<void> getPiAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    piAddress = prefs.getString('piAddress') ?? '';
    piAddress = "http://$piAddress:5000";
    // piAddress = "http://192.168.1.109:5000";
  }

  void _checkSleepStatus() {
    _makeRequestTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) async {
      _fetchStatus();
    });
  }

  void _fetchStatus() async {
    try {
      final response = await http
          .read(Uri.parse(piAddress))
          .timeout(const Duration(seconds: 1));
      final responseData = jsonDecode(response);

      setState(() {
        deviceStatusColor = Colors.green;
        if (responseData['status'] == "running") {
          isUserSleeping = true;
          iconStatus = Icons.check_circle;
          iconRecording = Icons.check_circle;
          deviceRecordingColor = Colors.green;
          developer.log("User is sleeping", name: 'debug.pi');
        } else {
          isUserSleeping = false;
          iconRecording = Icons.error;
          deviceRecordingColor = Colors.red;
          developer.log("User is not sleeping", name: 'debug.pi');
        }
      });
    } catch (error) {
      // failed to get or pi not online
      setState(() {
        deviceStatusColor = Colors.red;
        deviceRecordingColor = Colors.red;
        iconStatus = Icons.error;
        iconRecording = Icons.error;
        isUserSleeping = false;
      });
      developer.log('Error making GET request: $error', name: 'debug.pi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.blue),
        backgroundColor: Colors.transparent,
        title: const Padding(
          padding: EdgeInsets.only(top: 20.0, left: 5.0),
          child: Text(
            'Smart alarm clock',
            style: TextStyle(
                fontFamily: 'PatuaOne', fontSize: 24, color: Colors.black),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/background.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: GlassmorphicContainer(
                height: double.infinity,
                width: double.infinity,
                borderRadius: 0,
                blur: 10,
                alignment: Alignment.center,
                border: 0,
                linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
                      const Color.fromARGB(255, 255, 255, 255)
                          .withOpacity(0.05),
                    ],
                    stops: const [
                      0.1,
                      1,
                    ]),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFffffff).withOpacity(0.5),
                    const Color((0xFFFFFFFF)).withOpacity(0.5),
                  ],
                ),
                child:

                    // screen start
                    Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/image/clock.png',
                        width: 210.0,
                        height: 210.0,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 40),
                      Text("IP address: ${piAddress.substring(7)}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Status:",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(iconStatus,
                                  color: deviceStatusColor, size: 24)),
                          const SizedBox(width: 20),
                          const Text(
                            "Recording:",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(iconRecording,
                                  color: deviceRecordingColor, size: 24)),
                        ],
                      )
                    ],
                  ),
                ),
                // screen end
              ),
            )
          ],
        ),
      ),
    );
  }
}
