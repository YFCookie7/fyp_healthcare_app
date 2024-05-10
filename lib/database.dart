import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;

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

    await db.execute('''
        CREATE TABLE IF NOT EXISTS REAL_TIME (
          id INTEGER PRIMARY KEY,
          timestamp TEXT,
          bio TEXT,
          value REAL,
          description TEXT
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

Future<void> insertRealTimeData(
    String timestamp, String bio, double value, String description) async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'SQMS.db');

  Database database = await openDatabase(path, version: 1);

  await database.rawInsert(
    'INSERT INTO REAL_TIME(timestamp, bio, value, description) VALUES(?, ?, ?, ?)',
    [timestamp, bio, value, description],
  );
  developer.log("Real time data inserted", name: 'debug.db');

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

Future<List<DataHistory>> readRealTimeData() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'SQMS.db');

  Database database = await openDatabase(path, version: 1);

  List<Map<String, dynamic>> result =
      await database.rawQuery('SELECT * FROM REAL_TIME');

  List<DataHistory> dataHistory = [];
  for (var row in result) {
    DataHistory data = DataHistory(
      timestamp: row['timestamp'],
      bio: row['bio'],
      value: row['value'],
      description: row['description'],
    );
    dataHistory.add(data);
  }

  developer.log('Selected data from REAL_TIME table:', name: 'debug.home');
  for (var data in dataHistory) {
    developer.log(data.timestamp, name: 'debug.home');
    developer.log(data.value.toString(), name: 'debug.home');
  }

  await database.close();

  return dataHistory;
}

Future<void> deleteData() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'SQMS.db');

  Database database = await openDatabase(path, version: 1);

  await database.rawDelete('DELETE FROM DATA');

  await database.close();
}

Future<void> deleteRealTimeTable() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'SQMS.db');

  Database database = await openDatabase(path, version: 1);

  await database.rawDelete('DELETE FROM REAL_TIME');

  await database.close();
}

Future<void> deleteDatabaseFile() async {
  var databasesPath = await getDatabasesPath();

  String path = join(databasesPath, 'SQMS.db');

  try {
    await deleteDatabase(path);
    developer.log("Database deleted successfully", name: 'debug.home');
  } catch (e) {
    developer.log("Error deleting database: $e", name: 'debug.home');
  }
}

class DataHistory {
  final String timestamp;
  final String bio;
  final double value;
  final String description;

  DataHistory({
    required this.timestamp,
    required this.bio,
    required this.value,
    required this.description,
  });
}
