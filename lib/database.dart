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

    await db.execute('''
        CREATE TABLE IF NOT EXISTS SLEEP (
          id INTEGER PRIMARY KEY,
          timestamp TEXT,
          spo2_value REAL,
          heart_rate_value REAL,
          body_temperature REAL
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

Future<void> insertSleepData(
  String timestamp,
  double spo2Value,
  double heartRateValue,
  double bodyTemperature,
) async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'SQMS.db');

  Database database = await openDatabase(path, version: 1);

  await database.rawInsert(
    'INSERT INTO SLEEP(timestamp, spo2_value, heart_rate_value, body_temperature) VALUES(?, ?, ?, ?)',
    [timestamp, spo2Value, heartRateValue, bodyTemperature],
  );
  developer.log("sleep data inserted", name: 'debug.db');

  await database.close();
}

Future<void> readSleepData() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'SQMS.db');

  Database database = await openDatabase(path, version: 1);

  List<Map<String, dynamic>> result =
      await database.rawQuery('SELECT * FROM SLEEP');

  developer.log('Selected data from SLEEP table:', name: 'debug.home');
  for (var row in result) {
    developer.log(row.toString(), name: 'debug.home');
  }

  await database.close();
}

Future<void> deleteSleepTable() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'SQMS.db');

  Database database = await openDatabase(path, version: 1);

  await database.rawDelete('DELETE FROM SLEEP');

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
