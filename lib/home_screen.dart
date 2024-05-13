import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:http/http.dart' as http;
import 'package:fyp_healthcare_app/data-comm/ble.dart';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:path/path.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fyp_healthcare_app/database.dart';
import 'package:fyp_healthcare_app/globals.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String textbox = 'Latest sleep record';
  late final String piAddress;
  bool? isSleeping;
  List<DataPoint> data = [];

  // biosignal
  String receivedData = '';
  // String textbox = 'Hi';
  double heartbeatValue = 60;
  double heartbeatValue_double = 0.0;
  double tempAvalue = 24.0;
  String tb_gyroX = '0'; // will be deprecated
  String tb_gyroY = '0'; // will be deprecated
  String tb_gyroZ = '0'; // will be deprecated
  String tb_spo2 = '0%';
  String tb_temp = '0';
  String tb_roomtemp = '0';
  String tb_heartrate = '0';

  var bufferIr = List<int>.filled(300, 0);
  var bufferRed = List<int>.filled(300, 0);

  double spo2 = 50;
  //double hr = 0;
  int now10Millisecond = 0;
  int last10Millisecond = 0;

  int nowRed = 0;
  int lastRed = 0;
  int nowIr = 0;
  int lastIr = 0;
  int nowTempA = 0;
  int lastTempA = 0;
  int nowTempO = 0;
  int lastTempO = 0;
  int nowGX = 0;
  int lastGX = 0;
  int nowGY = 0;
  int lastGY = 0;
  int nowGZ = 0;
  int lastGZ = 0;

  int redNowMax = 65535;
  int irNowMax = 65535;
  int redNextMax = 0;
  int irNextMax = 0;

  int redNowMin = 0;
  int irNowMin = 0;
  int redNextMin = 65535;
  int irNextMin = 65535;

  int nowSecond = 0;
  int lastSecond = 0;

  @override
  void initState() {
    super.initState();
    BluetoothBLE.registerCallback(_handleDataReceived);
    BluetoothBLE.connectToDevice();
    initDatabase();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      updateSleepState();
    });
    fetchData();
  }

  void _handleDataReceived(String data) {
    setState(() {
      // textbox = "$data ${Random().nextInt(1000)}";
      // developer.log(data, name: 'debug.device_watch');

      DateTime now = DateTime.now();
      nowSecond = now.second;
      now10Millisecond = (now.millisecond / 10).floor();

      if (nowSecond / 2 != lastSecond / 2) {
        redNowMax = redNextMax;
        redNowMin = redNextMin;
        redNextMax = 0;
        redNextMin = 65535;

        irNowMax = irNextMax;
        irNowMin = irNextMin;
        irNextMax = 0;
        irNextMin = 65535;
      }

      if (data.length == 14) {
        List<int> datum = data.codeUnits;
        nowRed = datum[1] * 256 + datum[0];
        nowIr = datum[3] * 256 + datum[2];
        nowTempA = datum[5] * 256 + datum[4];
        nowTempO = datum[7] * 256 + datum[6];
        nowGX = datum[9] * 256 + datum[8];
        nowGY = datum[11] * 256 + datum[10];
        nowGZ = datum[13] * 256 + datum[12];
      }

      if (nowIr > irNextMax) {
        irNextMax = nowIr;
      }
      if (nowIr < irNextMin) {
        irNextMin = nowIr;
      }
      if (nowRed > redNextMax) {
        redNextMax = nowRed;
      }
      if (nowRed < redNextMin) {
        redNextMin = nowRed;
      }
      roomtempValue = nowTempA / 50 - 273.15;
      tempValue = nowTempO / 50 - 273.15;

      if (nowIr > 4096 && nowRed > 4096) {
        //spo2 = 110-(25*(nowRed-redNowMin)/redNowMin)/((nowIr-irNowMin)/irNowMin);
        spo2 = 110 -
            (25 *
                (nowRed - redNowMin) *
                irNowMin /
                (redNowMin * (nowIr - irNowMin)));
      } else {
        spo2 = 0;
      }

      int i = last10Millisecond;
      int j = lastSecond;

      while (i != now10Millisecond || j != nowSecond) {
        bufferIr[i + (j % 3) * 100] = nowIr;
        bufferRed[i + (j % 3) * 100] = nowRed;
        //heartbeatValue_double = i+(j%3)*100;
        i++;
        if (i > 99) {
          i = 0;
          j++;
          if (j > 59) {
            j = 0;
          }
          //if it passes through the 300th second
          if (j % 3 == 0 && i == 0) {
            //start HR calculation for the last 3 seconds
            int firstMax = 0;
            int secondMax = 0;
            List<int> maxPoints = [];
            for (int count = 1; count < 299; count++) {
              //this is a max point
              if (bufferIr[count - 1] <= bufferIr[count] &&
                  bufferIr[count + 1] <= bufferIr[count]) {
                int numSmallerDataPast = 0;
                int numSmallerDataFuture = 0;
                int numDataPast = 0;
                int numDataFuture = 0;
                for (int k = 1; k < 30; k++) {
                  if (count + k <= 299) {
                    numDataFuture++;
                    if (bufferIr[count] > bufferIr[count + k]) {
                      numSmallerDataFuture++;
                    }
                  }
                  if (count - k >= 0) {
                    numDataPast++;
                    if (bufferIr[count] >= bufferIr[count - k]) {
                      numSmallerDataPast++;
                    }
                  }
                }

                if (numSmallerDataFuture / numDataFuture >= 0.95 &&
                    numSmallerDataPast / numDataPast >= 0.95) {
                  maxPoints.add(count);
                  count = count + 30;
                }
              }
            }
            int maxPointCount = 1;
            int interval = 0;

            if (maxPoints.isNotEmpty && redNowMin > 4096 && irNowMin > 4096) {
              while (maxPointCount < maxPoints.length) {
                interval = interval +
                    (maxPoints[maxPointCount] - maxPoints[maxPointCount - 1]);
                maxPointCount++;
              }
              heartbeatValue_double =
                  60 / (interval / (100 * (maxPointCount - 1)));
            } else {
              heartbeatValue_double = 0;
            }
            //tb_heartrate = "$heartbeatValue_double bpm";
          }
        }
      }

      // heartbeatValue = spo2;
      lastRed = nowRed;
      lastIr = nowIr;
      lastTempA = nowTempA;
      lastTempO = nowTempO;
      lastGX = nowGX;
      lastGY = nowGY;
      lastGZ = nowGZ;
      lastSecond = nowSecond;
      last10Millisecond = now10Millisecond;

      //heartbeatValue = nowSecond;
      tb_gyroX2 = nowGX.toString();
      tb_gyroY2 = nowGY.toString();
      tb_gyroZ2 = nowGZ.toString();

      // will be deprecated
      if (roomtempValue > 20 && roomtempValue < 50) {
        tb_roomtemp2 = "${roomtempValue.toStringAsFixed(1)}°C";
      }

      if (heartbeatValue_double > 20 && heartbeatValue_double < 150) {
        heartbeatValue_double2 = heartbeatValue_double;
      }

      if (spo2 > 30 && spo2 < 100) {
        spo22 = spo2;
        tb_spo22 = "${spo2.round()} %";
      }

      // tb_heartrate = heartbeatValue.toString();
    });
  }

  Future<void> fetchData() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'SQMS.db');

    Database database = await openDatabase(path, version: 1);

    List<Map<String, dynamic>> result =
        await database.rawQuery('SELECT * FROM DATA');

    setState(() {
      data = result
          .map<DataPoint>((row) => DataPoint(
                DateTime.parse(row['timestamp']),
                row['spo2'],
              ))
          .toList();
    });

    await database.close();
  }

  @override
  void dispose() {
    BluetoothBLE.unregisterCallback(_handleDataReceived);
    BluetoothBLE.disconnectedDevice();
    super.dispose();
  }

  Future<void> getSleepRecordsTimestamp() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'SQMS.db');

    Database database = await openDatabase(path, version: 1);

    List<Map<String, dynamic>> firstRecordResult = await database
        .rawQuery('SELECT timestamp FROM data ORDER BY timestamp ASC LIMIT 1');
    DateTime? firstTimestamp;
    if (firstRecordResult.isNotEmpty) {
      firstTimestamp = DateTime.parse(firstRecordResult[0]['timestamp']);
    }

    List<Map<String, dynamic>> lastRecordResult = await database
        .rawQuery('SELECT timestamp FROM data ORDER BY timestamp DESC LIMIT 1');
    DateTime? lastTimestamp;
    if (lastRecordResult.isNotEmpty) {
      lastTimestamp = DateTime.parse(lastRecordResult[0]['timestamp']);
    }
    developer.log('Timestamp of the first sleep record: $firstTimestamp',
        name: 'debug.home');
    developer.log('Timestamp of the last sleep record: $lastTimestamp',
        name: 'debug.home');

    await database.close();
  }

  Future<void> updateSleepState() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.1.109:5000"));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == "running") {
          isSleeping = true;
          developer.log("User is sleeping", name: 'debug.home');
        } else {
          isSleeping = false;
          developer.log("User is not sleeping", name: 'debug.home');
        }
      } else {
        developer.log(
            'GET request failed with status code: ${response.statusCode}',
            name: 'debug.home');
      }
    } catch (error) {
      developer.log('Error making GET request: $error', name: 'debug.home');
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
                  child: Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            textbox,
                            style: const TextStyle(fontSize: 20),
                          ),
                          SfCartesianChart(
                            primaryXAxis: DateTimeAxis(),
                            series: <CartesianSeries>[
                              SplineSeries<DataPoint, DateTime>(
                                dataSource: data,
                                xValueMapper: (DataPoint data, _) =>
                                    data.timestamp,
                                yValueMapper: (DataPoint data, _) => data.spo2,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => insertData(),
                            child: const Text('insert test data'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => readData(),
                            child: const Text('read test data'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => deleteRealTimeTable(),
                            child: const Text('delete data'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => getSleepRecordsTimestamp(),
                            child: const Text('Get data'),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class DataPoint {
  final DateTime timestamp;
  final int spo2;

  DataPoint(this.timestamp, this.spo2);
}
