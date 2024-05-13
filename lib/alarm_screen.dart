import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyp_healthcare_app/globals.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:http/http.dart' as http;
import 'package:giffy_dialog/giffy_dialog.dart' as giffy_dialog;

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({Key? key}) : super(key: key);

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  String textbox = 'Hi';
  String tb_start = '00:00';
  String tb_end = '06:00';
  String tb_alarm = 'No alarm set';
  double _pointerValue1 = 0;
  double _pointerValue2 = 6;
  bool isToggled = false;
  DateTime startTime = DateTime.now();
  DateTime selectedTime = DateTime.now();
  late SharedPreferences prefs;
  String dropdownValue = 'Adult';
  int optimal_hours = 8;
  String tb_timeDiff = "8h 0min";

  var alarmSettings = AlarmSettings(
    id: 42,
    dateTime: DateTime.now(),
    assetAudioPath: 'assets/audio/alarm.mp3',
    loopAudio: false,
    vibrate: true,
    volume: 0.8,
    fadeDuration: 3.0,
    notificationTitle: '',
    notificationBody: '',
    enableNotificationOnKill: true,
    androidFullScreenIntent: true,
  );

  Future<void> initializeData() async {
    DateTime now = DateTime.now();

    int currentHour = now.hour;
    int currentMinute = now.minute;

    int remainder = currentMinute % 5;

    if (remainder != 0) {
      currentMinute += (5 - remainder);
      if (currentMinute >= 60) {
        currentMinute -= 60;
        currentHour = (currentHour + 1) % 24;
      }
    }

    setState(() {
      _pointerValue1 = currentHour + currentMinute / 60.0 / 12.0 * 5.0;
      if (_pointerValue1 > 12) {
        _pointerValue1 = _pointerValue1 - 12;
      }
      tb_start = '$currentHour:${currentMinute.toString().padLeft(2, '0')}';

      startTime =
          DateTime(now.year, now.month, now.day, currentHour, currentMinute);
      developer.log("Start Time: $startTime", name: 'debug_alarm');

      selectedTime = startTime.add(const Duration(hours: 8));

      currentHour = (currentHour + 8) % 24;
      _pointerValue2 = currentHour + currentMinute / 60.0 / 12.0 * 5.0;
      if (_pointerValue2 > 12) {
        _pointerValue2 = _pointerValue2 - 12;
      }
      tb_end = '$currentHour:${currentMinute.toString().padLeft(2, '0')}';
    });

    prefs = await SharedPreferences.getInstance();
    final String? alarmTime = prefs.getString('alarmTime');
    if (alarmTime != null) {
      setState(() {
        tb_alarm = alarmTime;
        isToggled = true;
      });
    }
  }

  Future<void> ringAlarm() async {
    Map<String, dynamic> data = {"command": "alarm"};

    String jsonData = json.encode(data);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String piAddress = prefs.getString('piAddress') ?? '';
    String url = 'http://$piAddress:5000';

    setState(() {
      isToggled = false;
      overrideSleep = false;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        developer.log('Data sent successfully', name: 'debug_alarm');
      } else {
        developer.log('Failed to send data. Error code: ${response.statusCode}',
            name: 'debug_alarm');
      }
    } catch (e) {
      developer.log('Failed to send data. Error: $e', name: 'debug_alarm');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
    Alarm.ringStream.stream.listen((_) => ringAlarm());
  }

  @override
  void dispose() {
    super.dispose();
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
            'Alarm',
            style: TextStyle(
                fontFamily: 'PatuaOne', fontSize: 24, color: Colors.black),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return giffy_dialog.GiffyDialog.image(
                    Image.asset('assets/gif/sleep.gif',
                        height: 200, fit: BoxFit.cover),
                    title: const Text(
                      'Optimal Sleep Duration',
                      textAlign: TextAlign.center,
                    ),
                    content: const Text(
                      'Children: 9-11 hours\nTeenagers: 8-10 hours\nAdults: 7-9 hours\nElderly: 7-8 hours',
                      textAlign: TextAlign.justify,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.info_outline),
            padding: const EdgeInsets.only(top: 20.0, right: 5.0),
          ),
        ],
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 100),
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                  startAngle: 270,
                                  endAngle: 270,
                                  interval: 1,
                                  minimum: 0,
                                  maximum: 12,
                                  minorTicksPerInterval: 4,
                                  showFirstLabel: true,
                                  axisLineStyle: const AxisLineStyle(
                                    thickness: 15,
                                    cornerStyle: CornerStyle.bothCurve,
                                    gradient: SweepGradient(colors: <Color>[
                                      Color.fromARGB(255, 64, 220, 231),
                                      Color.fromARGB(255, 58, 177, 233)
                                    ], stops: <double>[
                                      0.25,
                                      0.75
                                    ]),
                                    thicknessUnit: GaugeSizeUnit.logicalPixel,
                                  ),
                                  ranges: <GaugeRange>[
                                    GaugeRange(
                                      startValue: _pointerValue1,
                                      endValue: _pointerValue2,
                                      color: const Color.fromARGB(
                                          255, 59, 212, 13),
                                    ),
                                  ],
                                  pointers: <GaugePointer>[
                                    MarkerPointer(
                                      value: _pointerValue1,
                                      markerType: MarkerType.invertedTriangle,
                                      color: const Color.fromARGB(
                                          255, 243, 135, 33),
                                      markerWidth: 30,
                                      markerHeight: 30,
                                      elevation: 5,
                                      enableDragging: true,
                                      onValueChanged: (value) {
                                        setState(() {
                                          _pointerValue1 = value;
                                          DateTime now = DateTime.now();
                                          int hour = _pointerValue1.toInt();
                                          int minute =
                                              ((_pointerValue1 - hour) * 60)
                                                  .toInt();
                                          int remainder = minute % 5;
                                          int roundedMinute = remainder < 3
                                              ? minute - remainder
                                              : minute + (5 - remainder);

                                          startTime = DateTime(
                                              now.year,
                                              now.month,
                                              now.day,
                                              hour,
                                              roundedMinute);

                                          if (startTime.isBefore(now)) {
                                            startTime = startTime
                                                .add(const Duration(hours: 12));
                                          }

                                          if (startTime.isBefore(now)) {
                                            startTime = startTime
                                                .add(const Duration(hours: 12));
                                          }

                                          Duration difference = selectedTime
                                              .difference(startTime);
                                          int hours = difference.inHours;
                                          int minutes = difference.inMinutes
                                              .remainder(60);

                                          tb_timeDiff =
                                              '${hours}h ${minutes}min';
                                          developer.log('Pointer 1: $value',
                                              name: 'debug_alarm');
                                          developer.log(
                                              'Pointer 1: $hour $roundedMinute',
                                              name: 'debug_alarm');

                                          tb_start = startTime
                                              .toString()
                                              .substring(11, 16);
                                        });
                                      },
                                    ),
                                    MarkerPointer(
                                      value: _pointerValue2,
                                      markerType: MarkerType.invertedTriangle,
                                      color: const Color.fromARGB(
                                          255, 243, 135, 33),
                                      markerWidth: 30,
                                      markerHeight: 30,
                                      elevation: 5,
                                      enableDragging: true,
                                      onValueChanged: (value) {
                                        setState(() {
                                          _pointerValue2 = value; // 0-12
                                          DateTime now = DateTime.now();
                                          int hour = _pointerValue2
                                              .toInt(); // round down
                                          int minute =
                                              ((_pointerValue2 - hour) *
                                                      60) // 0-60
                                                  .toInt();
                                          int remainder = minute % 5;
                                          int roundedMinute = remainder < 3
                                              ? minute - remainder
                                              : minute + (5 - remainder);
                                          selectedTime = DateTime(
                                              now.year,
                                              now.month,
                                              now.day,
                                              hour,
                                              roundedMinute);
                                          if (selectedTime.isBefore(now)) {
                                            selectedTime = selectedTime
                                                .add(const Duration(hours: 12));
                                            developer.log(
                                                "Selected Time is in the past",
                                                name: 'debug_alarm');
                                          }
                                          if (selectedTime.isBefore(now)) {
                                            selectedTime = selectedTime
                                                .add(const Duration(hours: 12));
                                          }

                                          Duration difference = selectedTime
                                              .difference(startTime);
                                          int hours = difference.inHours;
                                          int minutes = difference.inMinutes
                                              .remainder(60);

                                          tb_timeDiff =
                                              '${hours}h ${minutes}min';
                                          developer.log(
                                              'final Time: $selectedTime',
                                              name: 'debug_alarm');
                                          developer.log('Pointer 2: $value',
                                              name: 'debug_alarm');
                                          developer.log(
                                              'Pointer 2: $hour $roundedMinute',
                                              name: 'debug_alarm');
                                          tb_end = selectedTime
                                              .toString()
                                              .substring(11, 16);
                                        });
                                      },
                                    ),
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                        angle: 90,
                                        positionFactor: 0.05,
                                        widget: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              tb_start,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 28),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              "-",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              tb_end,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 28),
                                            ),
                                          ],
                                        ))
                                  ]),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tb_timeDiff,
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 25),
                            DropdownButton<String>(
                              value: dropdownValue,
                              // icon: const Icon(Icons.man),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.deepPurple),
                              underline: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (String? newValue) {
                                // start onchange
                                setState(() {
                                  developer.log("newValue: $newValue",
                                      name: 'debug_alarm');
                                  switch (newValue) {
                                    case 'Children':
                                      tb_timeDiff = '10h 0min';
                                      optimal_hours = 10;
                                      break;
                                    case 'Teenage':
                                      tb_timeDiff = '9h 0min';
                                      optimal_hours = 9;
                                      break;
                                    case 'Adult':
                                      tb_timeDiff = '8h 0min';
                                      optimal_hours = 8;
                                      break;
                                    case 'Elderly':
                                      tb_timeDiff = '8h 0min';
                                      optimal_hours = 8;
                                      break;
                                  }
                                  dropdownValue = newValue!;

                                  DateTime now = DateTime.now();
                                  int currentHour = now.hour;
                                  int currentMinute = now.minute;
                                  int remainder = currentMinute % 5;

                                  if (remainder != 0) {
                                    currentMinute += (5 - remainder);
                                    if (currentMinute >= 60) {
                                      currentMinute -= 60;
                                      currentHour = (currentHour + 1) % 24;
                                    }
                                  }

                                  _pointerValue1 = currentHour +
                                      currentMinute / 60.0 / 12.0 * 5.0;
                                  if (_pointerValue1 > 12) {
                                    _pointerValue1 = _pointerValue1 - 12;
                                  }
                                  tb_start =
                                      '$currentHour:${currentMinute.toString().padLeft(2, '0')}';

                                  startTime = DateTime(now.year, now.month,
                                      now.day, currentHour, currentMinute);
                                  selectedTime = startTime
                                      .add(Duration(hours: optimal_hours));

                                  currentHour =
                                      (currentHour + optimal_hours) % 24;
                                  _pointerValue2 = currentHour +
                                      currentMinute / 60.0 / 12.0 * 5.0;
                                  if (_pointerValue2 > 12) {
                                    _pointerValue2 = _pointerValue2 - 12;
                                  }
                                  tb_end =
                                      '$currentHour:${currentMinute.toString().padLeft(2, '0')}';
                                });
                                // end onchange
                              },
                              items: <String>[
                                'Children',
                                'Teenage',
                                'Adult',
                                'Elderly'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: SizedBox(
                                    width: 100,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        const Icon(Icons.man),
                                        // const SizedBox(width: 5),
                                        Text(
                                          value,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                DateTime now = DateTime.now();
                                developer.log("selectedTime: $selectedTime",
                                    name: 'debug_alarm');
                                Duration difference =
                                    selectedTime.difference(now);
                                int hours = difference.inHours;
                                int minutes =
                                    difference.inMinutes.remainder(60);

                                String durationString =
                                    '${hours.abs()}h ${minutes.abs()}m';

                                alarmSettings = AlarmSettings(
                                  id: 42,
                                  dateTime: selectedTime,
                                  assetAudioPath: 'assets/audio/alarm.mp3',
                                  loopAudio: false,
                                  vibrate: true,
                                  volume: 0.8,
                                  fadeDuration: 3.0,
                                  notificationTitle: '',
                                  notificationBody: '',
                                  enableNotificationOnKill: true,
                                  androidFullScreenIntent: true,
                                );
                                await Alarm.set(alarmSettings: alarmSettings);

                                Fluttertoast.showToast(
                                    msg:
                                        "Alarm will ring after $durationString",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    fontSize: 16.0);
                                prefs = await SharedPreferences.getInstance();
                                await prefs.setString('alarmTime',
                                    selectedTime.toString().substring(11, 16));
                                setState(() {
                                  overrideSleep = true;
                                  tb_alarm =
                                      selectedTime.toString().substring(11, 16);
                                  isToggled = true;
                                });
                              },
                              child: const Text('Set Alarm'),
                            ),
                            const SizedBox(width: 35),
                            ElevatedButton(
                              onPressed: () async {
                                await Alarm.stop(42);

                                prefs = await SharedPreferences.getInstance();
                                await prefs.remove('alarmTime');
                                setState(() {
                                  isToggled = false;
                                  overrideSleep = false;
                                });
                              },
                              child: const Text('Cancel Alarm'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Container(
                          width: 350,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              const Icon(
                                Icons.alarm,
                                size: 36,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    tb_alarm,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                              Switch(
                                value: isToggled,
                                onChanged: (bool value) {
                                  setState(() {});
                                },
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ))),
          ],
        ),
      ),
    );
  }
}
