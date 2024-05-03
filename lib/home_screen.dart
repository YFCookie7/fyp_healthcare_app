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

  void _handleDataReceived(String data) {
    developer.log(data, name: 'debug.home');
    setState(() {
      textbox = "$data home ${Random().nextInt(1000)}";
    });
  }

  Future<void> initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'SQMS.db');

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS DATA (
          id INTEGER PRIMARY KEY,
          timestamp TEXT,
          spo2 INTEGER,
          heartRate INTEGER,
          bodyTemperature REAL
        )
      ''');
    });

    var tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='DATA'");
    if (tables.isEmpty) {
    } else {
      developer.log("table exists", name: 'debug.home');
    }

    await database.close();
  }

  Future<void> insertData() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'SQMS.db');

    Database database = await openDatabase(path, version: 1);

    DateTime startDate = DateTime(2024, 5, 2, 0, 0, 0);
    DateTime endDate = startDate.add(const Duration(hours: 8));

    await database.transaction((txn) async {
      for (DateTime dateTime = startDate;
          dateTime.isBefore(endDate);
          dateTime = dateTime.add(const Duration(seconds: 30))) {
        Random random = Random();
        int spo2 = (85 + random.nextInt(16));
        int heartRate = (40 + random.nextInt(20));
        double bodyTemperature = 35 + random.nextDouble() * (37 - 35);

        await txn.rawInsert(
          'INSERT INTO DATA(timestamp, spo2, heartRate, bodyTemperature) VALUES(?, ?, ?, ?)',
          [dateTime.toIso8601String(), spo2, heartRate, bodyTemperature],
        );
      }
    });

    await database.close();
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

    setState(() {
      textbox = "Latest sleep record: \n$firstTimestamp - \n$lastTimestamp";
    });
    await database.close();
  }

  Future<void> readData() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'SQMS.db');

    Database database = await openDatabase(path, version: 1);

    List<Map<String, dynamic>> result =
        await database.rawQuery('SELECT * FROM DATA');

    developer.log('Selected data from DATA table:', name: 'debug.home');
    for (var row in result) {
      developer.log(row.toString(), name: 'debug.home');
    }

    await database.close();
  }

  Future<void> deleteData() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'SQMS.db');

    Database database = await openDatabase(path, version: 1);

    await database.rawDelete('DELETE FROM DATA');

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
        // title: const Padding(
        //   padding: EdgeInsets.only(top: 20.0, left: 5.0),
        //   child: Text(
        //     'My Devices',
        //     style: TextStyle(
        //         fontFamily: 'PatuaOne', fontSize: 24, color: Colors.black),
        //   ),
        // ),
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
                            onPressed: () => deleteData(),
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
