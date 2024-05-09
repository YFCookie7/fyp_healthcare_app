import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:intl/intl.dart';

import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:fyp_healthcare_app/data-comm/ble.dart';
import 'dart:math';
import 'package:fyp_healthcare_app/data-comm/bt_template.dart';
import 'dart:developer' as developer;
import 'package:fyp_healthcare_app/globals.dart';

class WatchDeviceScreen extends StatefulWidget {
  const WatchDeviceScreen({Key? key}) : super(key: key);

  @override
  _WatchDeviceScreenState createState() => _WatchDeviceScreenState();
}

class _WatchDeviceScreenState extends State<WatchDeviceScreen> {
  Timer? _refreshBioDataTimer;
  String tb_spo2 = '-';
  String tb_hr = '-';
  String tb_tempO = '-';
  String tb_tempA = '-';

  @override
  void initState() {
    super.initState();
    _refreshBioData();
  }

  @override
  void dispose() {
    _refreshBioDataTimer?.cancel();
    super.dispose();
  }

  void _refreshBioData() {
    _refreshBioDataTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      developer.log(spo22.toString(), name: 'debug.watch');
      developer.log(tb_spo22, name: 'debug.watch');
      setState(() {
        // spo2
        if (spo22 > 100) {
          tb_spo2 = "-";
        } else if (spo22 < 50) {
          tb_spo2 = "-";
        } else if (spo22 == 100) {
          tb_spo2 = "99";
        } else {
          tb_spo2 = spo22.round().toString();
        }

        // pr
        if (heartbeatValue_double2 > 200) {
          tb_hr = "-";
        } else if (heartbeatValue_double2 < 50) {
          tb_hr = "-";
        } else {
          tb_hr = heartbeatValue_double2.round().toString();
        }

        // body temp
        if (tempValue > 50) {
          tb_tempO = "-";
        } else if (tempValue < 28) {
          tb_tempO = "-";
        } else {
          tb_tempO = tempValue.toStringAsFixed(1);
        }

        // room temp
        if (roomtempValue > 50) {
          tb_tempA = "-";
        } else if (roomtempValue < 10) {
          tb_tempA = "-";
        } else {
          tb_tempA = roomtempValue.toStringAsFixed(1);
        }
      });
    });
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
            'Health Tracker',
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
          alignment: Alignment.topCenter,
          children: [
            Center(
              child: GlassmorphicContainer(
                  height: double.infinity,
                  width: double.infinity,
                  borderRadius: 0,
                  blur: 10,
                  alignment: Alignment.topCenter,
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
                  // start screen
                  //
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 130),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                developer.log("clicked", name: 'debug.watch');
                              },
                              child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromARGB(255, 72, 146, 243),
                                        Color.fromARGB(255, 31, 241, 241)
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          onPressed: () {
                                            developer.log("clicked",
                                                name: 'debug.watch');
                                          },
                                          icon: const Icon(Icons.info_outline,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const Positioned(
                                          top: 10,
                                          left: 13,
                                          child: Text(
                                            "SpO2",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Positioned(
                                          bottom: 20,
                                          left: 36,
                                          child: Text(
                                            tb_spo2,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 48,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      const Positioned(
                                          bottom: 28,
                                          right: 32,
                                          child: Text(
                                            "%",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ],
                                  )),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                developer.log("clicked", name: 'debug.watch');
                              },
                              child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromARGB(255, 198, 95, 245),
                                        Color.fromARGB(255, 253, 151, 253)
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          onPressed: () {
                                            developer.log("clicked",
                                                name: 'debug.watch');
                                          },
                                          icon: const Icon(Icons.info_outline,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const Positioned(
                                          top: 10,
                                          left: 13,
                                          child: Text(
                                            "PR",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Positioned(
                                          bottom: 25,
                                          left: 15,
                                          child: SizedBox(
                                            width: 80,
                                            child: Text(
                                              tb_hr,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 44,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                      const Positioned(
                                          bottom: 35,
                                          right: 20,
                                          child: Text(
                                            "bpm",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                developer.log("clicked", name: 'debug.watch');
                              },
                              child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromARGB(255, 32, 248, 61),
                                        Color.fromARGB(255, 189, 252, 43)
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          onPressed: () {
                                            developer.log("clicked",
                                                name: 'debug.watch');
                                          },
                                          icon: const Icon(Icons.info_outline,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const Positioned(
                                          top: 10,
                                          left: 13,
                                          child: Text(
                                            "Body temp.",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Positioned(
                                          bottom: 30,
                                          left: 20,
                                          child: Text(
                                            tb_tempO,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 42,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      const Positioned(
                                          bottom: 35,
                                          right: 15,
                                          child: Text(
                                            "°C",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ],
                                  )),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                developer.log("clicked", name: 'debug.watch');
                              },
                              child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromARGB(255, 255, 191, 52),
                                        Color.fromARGB(255, 250, 198, 42)
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          onPressed: () {
                                            developer.log("clicked",
                                                name: 'debug.watch');
                                          },
                                          icon: const Icon(Icons.info_outline,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const Positioned(
                                          top: 10,
                                          left: 13,
                                          child: Text(
                                            "Room temp.",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Positioned(
                                          bottom: 30,
                                          left: 20,
                                          child: Text(
                                            tb_tempA,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 42,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      const Positioned(
                                          bottom: 35,
                                          right: 15,
                                          child: Text(
                                            "°C",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ],
                                  )),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        // graphs
                        Container(
                          alignment: Alignment.center,
                          height: 200, // height of the graph
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("qwe"),
                              const SizedBox(width: 20),
                              Text("qwe"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Button"),
                        ),
                        const SizedBox(height: 120),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Button"),
                        ),
                      ],
                    ),
                  )
                  // end screen
                  ),
            )
          ],
        ),
      ),
    );
  }
}
