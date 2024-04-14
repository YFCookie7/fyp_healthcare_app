import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp_healthcare_app/device_wearable_screen.dart';
import 'package:fyp_healthcare_app/setting_screen.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';
import 'dart:developer' as developer;
import 'package:giffy_dialog/giffy_dialog.dart' as giffy_dialog;
import 'dart:async';
import 'package:fyp_healthcare_app/data-comm/ble.dart';
import 'package:http/http.dart' as http;

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key}) : super(key: key);

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final pi_address = 'http://192.168.1.109:5000';
  String receivedData = '';
  String animationFile = "assets/lottie/tick_lottie.json";

  @override
  void initState() {
    super.initState();
    BluetoothBLE.registerCallback(_handleDataReceived);
    BluetoothBLE.connectToDevice();
    _checkBtStatus();
  }

  void _checkBtStatus() async {
    if (await BluetoothBLE.isConnected()) {
      developer.log("Connected to device", name: 'debug.device');
      setState(() {
        animationFile = "assets/lottie/tick_lottie.json";
      });
    } else {
      developer.log("Not connected to device", name: 'debug.device');
      setState(() {
        animationFile = "assets/lottie/cross_lottie.json";
      });
    }
  }

  @override
  void dispose() {
    BluetoothBLE.unregisterCallback(_handleDataReceived);
    BluetoothBLE.disconnectedDevice();
    super.dispose();
  }

  void _handleDataReceived(String data) {
    developer.log(data, name: 'debug.device');
    setState(() {
      // developer.log(data, name: 'debug.device');
    });
  }

  Future<bool> checkPiStatus() async {
    try {
      final response = await http.get(Uri.parse(pi_address));
      if (response.statusCode == 200) {
        developer.log('GET request successful. Response: ${response.body}',
            name: 'debug.device');
        return true;
      } else {
        developer.log(
            'GET request failed with status code: ${response.statusCode}',
            name: 'debug.device');
      }
    } catch (error) {
      developer.log('Error making GET request: $error', name: 'debug.device');
    }
    return false;
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
            'My Devices',
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
                        const Color.fromARGB(255, 255, 255, 255)
                            .withOpacity(0.1),
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
                  child: Column(
                    children: [
                      const SizedBox(height: 120.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const WearableDeviceScreen()),
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
                                    _checkBtStatus();
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
                                  icon: const Icon(Icons.info,
                                      color: Colors.white),
                                ),
                              ),
                              Positioned(
                                bottom: 50.0,
                                left: 50.0,
                                child: Image.asset(
                                  'assets/image/watch.png',
                                  width: 100.0,
                                  height: 100.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                  bottom: 50.0,
                                  right: 40.0,
                                  child: LottieAnimation(
                                      animationFile: animationFile)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => SettingScreen()),
                          // );
                          checkPiStatus();
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
                                  'Smart alarm clock',
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
                                          Image.asset('assets/gif/clock.gif',
                                              height: 200, fit: BoxFit.cover),
                                          title: const Text(
                                            'Smart alarm clock',
                                            textAlign: TextAlign.center,
                                          ),
                                          content: const Text(
                                            'Smart alarm clock can automate the recording of your sleep data. And measure your body movement and noise during the sleep.\n\nNetwork connection is required to connect to this app.',
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
                                  icon: const Icon(Icons.info,
                                      color: Colors.white),
                                ),
                              ),
                              Positioned(
                                bottom: 50.0,
                                left: 50.0,
                                child: Image.asset(
                                  'assets/image/clock.png',
                                  width: 100.0,
                                  height: 100.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 50.0,
                                right: 40.0,
                                child: LottieAnimation(
                                    animationFile: animationFile),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class LottieAnimation extends StatefulWidget {
  final String animationFile;

  const LottieAnimation({Key? key, required this.animationFile})
      : super(key: key);

  @override
  _LottieAnimationState createState() => _LottieAnimationState();
}

class _LottieAnimationState extends State<LottieAnimation> {
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.animationFile,
      height: 100,
    );
  }
}
