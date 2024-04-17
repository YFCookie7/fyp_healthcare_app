import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

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
                        const SizedBox(height: 120),
                        Container(
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
                                          DateTime selectedTime = DateTime(
                                              now.year,
                                              now.month,
                                              now.day,
                                              hour,
                                              minute);

                                          if (selectedTime.isBefore(now)) {
                                            selectedTime = selectedTime
                                                .add(const Duration(hours: 12));
                                            developer.log(
                                                "Selected Time is in the past",
                                                name: 'debug_alarm');
                                          }
                                          developer.log('Pointer 1: $value',
                                              name: 'debug_alarm');
                                          developer.log(
                                              'Pointer 1: $hour $minute',
                                              name: 'debug_alarm');

                                          tb_start = selectedTime
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
                                          _pointerValue2 = value;
                                          DateTime now = DateTime.now();
                                          int hour = _pointerValue2.toInt();
                                          int minute =
                                              ((_pointerValue2 - hour) * 60)
                                                  .toInt();
                                          DateTime selectedTime = DateTime(
                                              now.year,
                                              now.month,
                                              now.day,
                                              hour,
                                              minute);
                                          if (selectedTime.isBefore(now)) {
                                            selectedTime = selectedTime
                                                .add(const Duration(hours: 12));
                                            developer.log(
                                                "Selected Time is in the past",
                                                name: 'debug_alarm');
                                          }
                                          developer.log('Pointer 2: $value',
                                              name: 'debug_alarm');
                                          developer.log(
                                              'Pointer 2: $hour $minute',
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
                                        positionFactor: 0.1,
                                        widget: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              tb_start,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              "-",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              tb_end,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
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
                            ElevatedButton(
                              onPressed: () async {
                                DateTime now = DateTime.now();
                                int hour = _pointerValue2.toInt();
                                int minute =
                                    ((_pointerValue2 - hour) * 60).toInt();
                                DateTime selectedTime = DateTime(
                                    now.year, now.month, now.day, hour, minute);

                                if (now.isBefore(selectedTime)) {
                                  developer.log(
                                      "Selected Time is in the future",
                                      name: 'debug_alarm');
                                } else {
                                  selectedTime = selectedTime
                                      .add(const Duration(hours: 12));
                                  developer.log("Selected Time is in the past",
                                      name: 'debug_alarm');
                                }
                                developer.log("Current Time: $now",
                                    name: 'debug_alarm');
                                developer.log('Selected Time: $selectedTime',
                                    name: 'debug_alarm');
                                Duration difference =
                                    selectedTime.difference(now);
                                developer.log('Difference: $difference',
                                    name: 'debug_alarm');

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
                                    msg: "Alarm will ring after $difference",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    fontSize: 16.0);
                                setState(() {
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

                                setState(() {
                                  isToggled = false;
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
