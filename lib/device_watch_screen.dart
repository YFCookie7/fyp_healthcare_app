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
import 'package:bottom_sheet/bottom_sheet.dart';

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
        } else if (tempValue < 32) {
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
                                            showFlexibleBottomSheet(
                                              minHeight: 0,
                                              initHeight: 0.8,
                                              maxHeight: 0.8,
                                              context: context,
                                              builder: _buildBottomSheet1,
                                              isExpand: false,
                                            );
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
                                          bottom: 25,
                                          left: 15,
                                          child: SizedBox(
                                            width: 80,
                                            child: Text(
                                              tb_spo2,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 44,
                                                  fontWeight: FontWeight.bold),
                                            ),
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
                                            showFlexibleBottomSheet(
                                              minHeight: 0,
                                              initHeight: 0.8,
                                              maxHeight: 0.8,
                                              context: context,
                                              builder: _buildBottomSheet2,
                                              isExpand: false,
                                            );
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
                              onTap: () {},
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
                                            showFlexibleBottomSheet(
                                              minHeight: 0,
                                              initHeight: 0.8,
                                              maxHeight: 0.8,
                                              context: context,
                                              builder: _buildBottomSheet3,
                                              isExpand: false,
                                            );
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

Widget _buildBottomSheet1(
  BuildContext context,
  ScrollController scrollController,
  double bottomSheetOffset,
) {
  return Material(
      child: Container(
          height: 500,
          decoration: const BoxDecoration(
            color: Color.fromARGB(161, 226, 251, 255),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FlexColumnWidth(0.5),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 112, 245, 130),
                            ),
                            height: 50,
                            child: const Center(child: Text('95 - 100%')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 154, 247, 167),
                            ),
                            height: 50,
                            child: const Center(
                                child: Text('Normal Blood Oxygen Level')),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 238, 83),
                            ),
                            height: 50,
                            child: const Center(child: Text('91 - 95%')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 248, 235, 115),
                            ),
                            height: 50,
                            child: const Center(child: Text('Below standard')),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 153, 70),
                            ),
                            height: 50,
                            child: const Center(child: Text('≤90%')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 250, 173, 128)),
                            height: 50,
                            child: const Center(child: Text('Too low')),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 52, 2),
                            ),
                            height: 50,
                            child: const Center(child: Text('<67%')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 129, 97),
                            ),
                            height: 50,
                            child: const Center(child: Text('Cyanosis')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          )));
}

Widget _buildBottomSheet2(
  BuildContext context,
  ScrollController scrollController,
  double bottomSheetOffset,
) {
  return Material(
    child: Container(
        height: 500,
        decoration: const BoxDecoration(
          color: Color.fromARGB(161, 226, 251, 255),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text("Male resting heart rate",
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('AGE'))),
                        TableCell(child: Center(child: Text('Athlete'))),
                        TableCell(child: Center(child: Text('Excellent'))),
                        TableCell(child: Center(child: Text('Good'))),
                        TableCell(child: Center(child: Text('Average'))),
                        TableCell(child: Center(child: Text('Below average'))),
                        TableCell(child: Center(child: Text('Poor'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('18-25'))),
                        TableCell(child: Center(child: Text('49-55'))),
                        TableCell(child: Center(child: Text('56-61'))),
                        TableCell(child: Center(child: Text('62-65'))),
                        TableCell(child: Center(child: Text('70-73'))),
                        TableCell(child: Center(child: Text('74-81'))),
                        TableCell(child: Center(child: Text('82+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('26-35'))),
                        TableCell(child: Center(child: Text('49-54'))),
                        TableCell(child: Center(child: Text('55-61'))),
                        TableCell(child: Center(child: Text('62-65'))),
                        TableCell(child: Center(child: Text('71-74'))),
                        TableCell(child: Center(child: Text('75-81'))),
                        TableCell(child: Center(child: Text('82+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('36-45'))),
                        TableCell(child: Center(child: Text('50-56'))),
                        TableCell(child: Center(child: Text('57-62'))),
                        TableCell(child: Center(child: Text('63-66'))),
                        TableCell(child: Center(child: Text('71-75'))),
                        TableCell(child: Center(child: Text('76-82'))),
                        TableCell(child: Center(child: Text('83+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('46-55'))),
                        TableCell(child: Center(child: Text('50-57'))),
                        TableCell(child: Center(child: Text('58-63'))),
                        TableCell(child: Center(child: Text('64-67'))),
                        TableCell(child: Center(child: Text('72-76'))),
                        TableCell(child: Center(child: Text('77-83'))),
                        TableCell(child: Center(child: Text('84+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('56-65'))),
                        TableCell(child: Center(child: Text('51-56'))),
                        TableCell(child: Center(child: Text('57-61'))),
                        TableCell(child: Center(child: Text('62-67'))),
                        TableCell(child: Center(child: Text('72-75'))),
                        TableCell(child: Center(child: Text('76-81'))),
                        TableCell(child: Center(child: Text('82+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('>65'))),
                        TableCell(child: Center(child: Text('50-55'))),
                        TableCell(child: Center(child: Text('56-61'))),
                        TableCell(child: Center(child: Text('62-65'))),
                        TableCell(child: Center(child: Text('70-73'))),
                        TableCell(child: Center(child: Text('74-79'))),
                        TableCell(child: Center(child: Text('80+'))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text("Female resting heart rate",
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(),
                  // columnWidths: {
                  //   0: FlexColumnWidth(),
                  //   1: FixedColumnWidth(100.0),
                  //   2: FixedColumnWidth(150.0),
                  // },
                  children: [
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('AGE'))),
                        TableCell(child: Center(child: Text('Athlete'))),
                        TableCell(child: Center(child: Text('Excellent'))),
                        TableCell(child: Center(child: Text('Good'))),
                        TableCell(child: Center(child: Text('Average'))),
                        TableCell(child: Center(child: Text('Below average'))),
                        TableCell(child: Center(child: Text('Poor'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('18-25'))),
                        TableCell(child: Center(child: Text('54-70'))),
                        TableCell(child: Center(child: Text('61-65'))),
                        TableCell(child: Center(child: Text('66-69'))),
                        TableCell(child: Center(child: Text('74-78'))),
                        TableCell(child: Center(child: Text('79-84'))),
                        TableCell(child: Center(child: Text('85+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('26-35'))),
                        TableCell(child: Center(child: Text('54-59'))),
                        TableCell(child: Center(child: Text('60-64'))),
                        TableCell(child: Center(child: Text('65-68'))),
                        TableCell(child: Center(child: Text('73-76'))),
                        TableCell(child: Center(child: Text('77-82'))),
                        TableCell(child: Center(child: Text('83+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('36-45'))),
                        TableCell(child: Center(child: Text('54-59'))),
                        TableCell(child: Center(child: Text('60-64'))),
                        TableCell(child: Center(child: Text('65-69'))),
                        TableCell(child: Center(child: Text('74-78'))),
                        TableCell(child: Center(child: Text('79-84'))),
                        TableCell(child: Center(child: Text('85+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('46-55'))),
                        TableCell(child: Center(child: Text('54-60'))),
                        TableCell(child: Center(child: Text('61-65'))),
                        TableCell(child: Center(child: Text('66-69'))),
                        TableCell(child: Center(child: Text('74-77'))),
                        TableCell(child: Center(child: Text('78-83'))),
                        TableCell(child: Center(child: Text('84+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('56-65'))),
                        TableCell(child: Center(child: Text('54-59'))),
                        TableCell(child: Center(child: Text('60-64'))),
                        TableCell(child: Center(child: Text('65-68'))),
                        TableCell(child: Center(child: Text('74-77'))),
                        TableCell(child: Center(child: Text('78-83'))),
                        TableCell(child: Center(child: Text('84+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('>65'))),
                        TableCell(child: Center(child: Text('54-59'))),
                        TableCell(child: Center(child: Text('60-64'))),
                        TableCell(child: Center(child: Text('65-68'))),
                        TableCell(child: Center(child: Text('73-76'))),
                        TableCell(child: Center(child: Text('77-84'))),
                        TableCell(child: Center(child: Text('84+'))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        // child: ListView(
        //   controller: scrollController,
        //   shrinkWrap: true,
        // ),
        ),
  );
}

Widget _buildBottomSheet3(
  BuildContext context,
  ScrollController scrollController,
  double bottomSheetOffset,
) {
  return Material(
      child: Container(
          height: 500,
          decoration: const BoxDecoration(
            color: Color.fromARGB(161, 226, 251, 255),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FlexColumnWidth(0.5),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 240, 255, 29),
                            ),
                            height: 50,
                            child: const Center(child: Text('≤35.9°C')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 226, 241, 83),
                            ),
                            height: 50,
                            child:
                                const Center(child: Text('Lower than average')),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 9, 253, 1),
                            ),
                            height: 50,
                            child: const Center(child: Text('36.0°C - 37.0°C')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 94, 255, 0),
                            ),
                            height: 50,
                            child: const Center(child: Text('Normal')),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 153, 70),
                            ),
                            height: 50,
                            child: const Center(child: Text('37.1°C - 38.0°C')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 250, 173, 128)),
                            height: 50,
                            child: const Center(
                                child: Text('Higher than average')),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 52, 2),
                            ),
                            height: 50,
                            child: const Center(child: Text('38.1°C - 42.2°C')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 129, 97),
                            ),
                            height: 50,
                            child: const Center(child: Text('Fever')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          )));
}
