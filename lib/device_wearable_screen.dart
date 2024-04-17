import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

class WearableDeviceScreen extends StatefulWidget {
  const WearableDeviceScreen({Key? key}) : super(key: key);

  @override
  _WearableDeviceScreenState createState() => _WearableDeviceScreenState();
}

class _WearableDeviceScreenState extends State<WearableDeviceScreen> {
  String receivedData = '';
  String textbox = 'Hi';
  double tempValue = 37.0;
  double roomtempValue = 30.0;
  double heartbeatValue = 60;
  double heartbeatValue_double = 0.0;
  double tempAvalue = 24.0;
  String tb_gyroX = '0';
  String tb_gyroY = '0';
  String tb_gyroZ = '0';
  String tb_spo2 = '0%';
  String tb_temp = '0';
  String tb_roomtemp = '0';
  String tb_heartrate = '0';

  String titleText = "Connecting to device";

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

  /*
  String redText = "redText";
  String irText = "irText";
  String tempAText = "tempAText";
  String tempOText = "tempOText";
  String gyroXText = "gyroXText";
  String gyroYText = "gyroYText";
  String gyroZText = "gyroZText";
  */

  @override
  void initState() {
    super.initState();
    BluetoothBLE.registerCallback(_handleDataReceived);
    BluetoothBLE.connectToDevice();
    initDatabase();
    // titleText = await BluetoothBLE.connectToDevice();

    // if(await BluetoothBLE.isConnected())
    // {
    //   await BluetoothBLE.readDataStream();
    // }

    // const oneSec = Duration(seconds: 1);
    // Timer.periodic(oneSec, (Timer t) async {
    //   if (await BluetoothBLE.isConnected()) {
    //     BluetoothBLE.registerCallback(_handleDataReceived);
    //   } else {
    //     BluetoothBLE.unregisterCallback(_handleDataReceived);
    //     // titleText = await BluetoothBLE.connectToDevice();
    //   }
    // });
  }

  @override
  void dispose() {
    BluetoothBLE.unregisterCallback(_handleDataReceived);
    BluetoothBLE.disconnectedDevice();
    super.dispose();
  }

  void _handleDataReceived(String data) {
    setState(() {
      textbox = "$data ${Random().nextInt(1000)}";
      developer.log(data, name: 'debug.device_watch');

      DateTime now = DateTime.now();
      nowSecond = now.second;
      now10Millisecond = (now.millisecond/10).floor();

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

      int i=last10Millisecond;
      int j=lastSecond;

      while(i!=now10Millisecond || j!=nowSecond)
      {
        bufferIr[i+(j%3)*100] = nowIr;
        bufferRed[i+(j%3)*100] = nowRed;
        //heartbeatValue_double = i+(j%3)*100;
        i++;
        if(i>99)
        {
          i=0;
          j++;
          if(j>59)
          {
            j=0;
          }
          //if it passes through the 300th second
          if(j%3==0 && i==0)
          {
            //start HR calculation for the last 3 seconds
            int firstMax = 0;
            int secondMax = 0;
            List<int> maxPoints = [];
            for(int count=1; count<299; count++)
            {
              //this is a max point
              if(bufferIr[count-1]<=bufferIr[count] && bufferIr[count+1]<=bufferIr[count])
              {
                int numSmallerDataPast = 0;
                int numSmallerDataFuture = 0;
                int numDataPast = 0;
                int numDataFuture = 0;
                for(int k=1; k<30; k++)
                {
                  if(count+k<=299)
                  {
                    numDataFuture++;
                    if(bufferIr[count]>bufferIr[count+k])
                    {
                      numSmallerDataFuture++;
                    }
                  }
                  if(count-k>=0)
                  {
                    numDataPast++;
                    if(bufferIr[count]>=bufferIr[count-k])
                    {
                      numSmallerDataPast++;
                    }
                  }
                }

                if(numSmallerDataFuture/numDataFuture>=0.95 && numSmallerDataPast/numDataPast>=0.95)
                {
                  maxPoints.add(count);
                  count = count+30;
                }
              }
            }
            int maxPointCount = 1;
            int interval = 0;

            if(maxPoints.isNotEmpty && redNowMin>4096 && irNowMin>4096)
            {
              while(maxPointCount<maxPoints.length)
              {
                interval = interval + (maxPoints[maxPointCount]-maxPoints[maxPointCount-1]);
                maxPointCount++;
              }
              heartbeatValue_double = 60/(interval/(100*(maxPointCount-1)));
            }
            else
            {
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
      tb_gyroX = nowGX.toString();
      tb_gyroY = nowGY.toString();
      tb_gyroZ = nowGZ.toString();
      tb_spo2 = "${spo2.round()} %";
      tb_temp = nowTempO.toString();
      tb_roomtemp = "${roomtempValue.toStringAsFixed(1)}°C";
      // tb_heartrate = heartbeatValue.toString();

      addRecord(
        timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        spo2: spo2.round(),
        heartRate: heartbeatValue.toInt(),
        bodyTemperature: nowTempO.toDouble(),
      );

      // debug purpose
      // tempValue = 34 +
      //     Random().nextDouble() *
      //         (40 - 34); // replace this with actual temperature

      // int heartbeatValue = Random().nextInt(31) + 60;
      // heartbeatValue_double =
      //     heartbeatValue.toDouble(); // replace this with actual temperature
      // developer.log(heartbeatValue_double.toString(),
      //     name: 'debug.device_watch');

    });
  }

  Future<void> initDatabase() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'data.db'),
      onCreate: (db, version) {
        return createTable(db);
      },
      version: 1,
    );

    final db = await database;
    final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='DATA';");

    if (tables.isNotEmpty) {
      developer.log("Table exists", name: 'debug.device_watch');
    } else {
      await createTable(db);
      developer.log("Table created", name: 'debug.device_watch');
    }
  }

  Future<void> createTable(Database db) async {
    await db.execute('''
    CREATE TABLE DATA (
      id INTEGER PRIMARY KEY,
      timestamp TEXT,
      spo2 INTEGER,
      heartRate INTEGER,
      bodyTemperature REAL
    )
  ''');
  }

  Future<void> addRecord({
    required String timestamp,
    required int spo2,
    required int heartRate,
    required double bodyTemperature,
  }) async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'DATA.db'),
      version: 1,
    );

    final db = await database;

    await db.insert(
      'DATA',
      {
        'timestamp': timestamp,
        'spo2': spo2,
        'heartRate': heartRate,
        'bodyTemperature': bodyTemperature,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    developer.log("successfully added record", name: 'debug.device_watch');
  }

  Future<Map<String, dynamic>?> getRecord() async {
    Database database = await openDatabase('data.db');
    List<Map<String, dynamic>> result = await database.rawQuery('''
    SELECT * FROM DATA ORDER BY timestamp DESC LIMIT 1
  ''');
    return result.isNotEmpty ? result.first : null;
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: SfRadialGauge(axes: <RadialAxis>[
                              RadialAxis(
                                  minimum: 34,
                                  maximum: 40,
                                  ranges: <GaugeRange>[
                                    GaugeRange(
                                        startValue: 34,
                                        endValue: 36,
                                        color: Colors.green),
                                    GaugeRange(
                                        startValue: 36,
                                        endValue: 38,
                                        color: Colors.orange),
                                    GaugeRange(
                                        startValue: 38,
                                        endValue: 40,
                                        color: Colors.red)
                                  ],
                                  pointers: <GaugePointer>[
                                    NeedlePointer(
                                        value: tempValue, enableAnimation: true)
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                        widget: Container(
                                          width: 140.00,
                                          height: 50.00,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Image(
                                                image: ExactAssetImage(
                                                    'assets/icon/body_temperature.png'),
                                                fit: BoxFit.fitHeight,
                                                height: 35,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                "${tempValue.toStringAsFixed(1)}°C",
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        angle: 90,
                                        positionFactor: 0.5)
                                  ]),
                            ]),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: SfRadialGauge(axes: <RadialAxis>[
                              RadialAxis(
                                  interval: 10,
                                  startAngle: 270,
                                  endAngle: 270,
                                  showTicks: false,
                                  showLabels: false,
                                  axisLineStyle: AxisLineStyle(thickness: 20),
                                  pointers: <GaugePointer>[
                                    RangePointer(
                                        value: heartbeatValue_double,
                                        width: 20,
                                        color: Color(0xFFFFCD60),
                                        enableAnimation: true,
                                        cornerStyle: CornerStyle.bothCurve)
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                        widget: Column(
                                          children: <Widget>[
                                            const SizedBox(
                                              height: 25,
                                            ),
                                            Container(
                                              width: 100.00,
                                              height: 100.00,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Lottie.asset(
                                                    'assets/lottie/heartbeat_lottie.json',
                                                    width: 60,
                                                    height: 60,
                                                    // fit: BoxFit.cover,
                                                  ),
                                                  Text(
                                                    '${heartbeatValue_double.toStringAsFixed(0)} bpm',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        angle: 270,
                                        positionFactor: 0.1)
                                  ])
                            ]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: SfRadialGauge(axes: <RadialAxis>[
                              RadialAxis(
                                  minimum: 15,
                                  maximum: 50,
                                  ranges: <GaugeRange>[
                                    GaugeRange(
                                        startValue: 15,
                                        endValue: 20,
                                        color:
                                            Color.fromARGB(255, 3, 255, 242)),
                                    GaugeRange(
                                        startValue: 20,
                                        endValue: 35,
                                        color: Colors.orange),
                                    GaugeRange(
                                        startValue: 35,
                                        endValue: 50,
                                        color: Colors.red)
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                        widget: Container(
                                          width: 140.00,
                                          height: 50.00,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Lottie.asset(
                                                'assets/lottie/roomTemp_lottie.json',
                                                width: 40,
                                                height: 40,
                                                // fit: BoxFit.cover,
                                              ),
                                              Text(
                                                tb_roomtemp,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        angle: 90,
                                        positionFactor: 0.1)
                                  ]),
                            ]),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: SfRadialGauge(axes: <RadialAxis>[
                              RadialAxis(
                                  interval: 10,
                                  startAngle: 270,
                                  endAngle: 270,
                                  showTicks: false,
                                  showLabels: false,
                                  axisLineStyle:
                                      const AxisLineStyle(thickness: 20),
                                  pointers: <GaugePointer>[
                                    RangePointer(
                                        value: spo2,
                                        width: 20,
                                        color: const Color.fromARGB(
                                            255, 5, 66, 233),
                                        enableAnimation: true,
                                        cornerStyle: CornerStyle.bothCurve)
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                        widget: Column(
                                          children: <Widget>[
                                            const SizedBox(
                                              height: 25,
                                            ),
                                            Container(
                                              width: 100.00,
                                              height: 100.00,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Lottie.asset(
                                                    'assets/lottie/spo2_lottie.json',
                                                    width: 60,
                                                    height: 60,
                                                    // fit: BoxFit.cover,
                                                  ),
                                                  Text(
                                                    tb_spo2,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        angle: 270,
                                        positionFactor: 0.1)
                                  ])
                            ]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 400,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                    border: Border(
                                        right: BorderSide(color: Colors.grey))),
                                child: Center(
                                  child: Text('X:\n$tb_gyroX'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                    border: Border(
                                        right: BorderSide(color: Colors.grey))),
                                child: Center(
                                  child: Text('Y:\n$tb_gyroY'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Center(
                                  child: Text('Z:\n$tb_gyroZ'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Container(
                      //   width: 400,
                      //   decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.grey),
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       Expanded(
                      //         child: Container(
                      //           decoration: BoxDecoration(
                      //               border: Border(
                      //                   right: BorderSide(color: Colors.grey))),
                      //           child: Center(
                      //             child: Text('Time'),
                      //           ),
                      //         ),
                      //       ),
                      //       Expanded(
                      //         child: Container(
                      //           decoration: BoxDecoration(
                      //               border: Border(
                      //                   right: BorderSide(color: Colors.grey))),
                      //           child: Center(
                      //             child: Text('Body temperature'),
                      //           ),
                      //         ),
                      //       ),
                      //       Expanded(
                      //         child: Container(
                      //           decoration: BoxDecoration(
                      //               border: Border(
                      //                   right: BorderSide(color: Colors.grey))),
                      //           child: Center(
                      //             child: Text('Heart rate'),
                      //           ),
                      //         ),
                      //       ),
                      //       Expanded(
                      //         child: Container(
                      //           child: Center(
                      //             child: Text('Spo2'),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(height: 20),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     Map<String, dynamic>? newestRecord =
                      //         await getRecord();
                      //     if (newestRecord != null) {
                      //       developer.log("Record: $newestRecord",
                      //           name: 'debug.device_watch');
                      //     } else {
                      //       developer.log("No record",
                      //           name: 'debug.device_watch');
                      //     }
                      //   },
                      //   child: Text('test'),
                      // ),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     addRecord(
                      //       timestamp: DateFormat('yyyy-MM-dd HH:mm:ss')
                      //           .format(DateTime.now()),
                      //       spo2: spo2.round(),
                      //       heartRate: heartbeatValue.toInt(),
                      //       bodyTemperature: nowTempO.toDouble(),
                      //     );
                      //   },
                      //   child: Text('test'),
                      // ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class readingHistoryContainer extends StatelessWidget {
  String time;
  String bodyTemp;
  String spo2;
  String heartrate;

  readingHistoryContainer(
      {required this.time,
      required this.bodyTemp,
      required this.spo2,
      required this.heartrate});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey))),
                child: Center(
                  child: Text(time),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey))),
                child: Center(
                  child: Text(bodyTemp),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey))),
                child: Center(
                  child: Text(spo2),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: Center(
                  child: Text(heartrate),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
