import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:fyp_healthcare_app/data-comm/ble.dart';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:path/path.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String textbox = 'Hi';

  @override
  void initState() {
    super.initState();
    // BluetoothBLE.registerCallback(_handleDataReceived);
    // BluetoothBLE.connectToDevice();
    initDatabase();
  }

  @override
  void dispose() {
    // BluetoothBLE.unregisterCallback(_handleDataReceived);
    // BluetoothBLE.disconnectedDevice();
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

    await database.transaction((txn) async {
      for (int i = 0; i < 5; i++) {
        await txn.rawInsert(
          'INSERT INTO DATA(timestamp, spo2, heartRate, bodyTemperature) VALUES(?, ?, ?, ?)',
          ['2024-05-02 09:05:10', 98, 75, 37.6],
        );
      }
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
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => insertData(),
                            child: const Text('insert data'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => readData(),
                            child: const Text('read data'),
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
