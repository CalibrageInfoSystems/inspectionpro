import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class InspDatabaseHelper {
  static const String _databaseName = "inspection.sqlite";
  static const int _databaseVersion = 1;

  static final InspDatabaseHelper _instance = InspDatabaseHelper._internal();
  factory InspDatabaseHelper() => _instance;

  InspDatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      print("Database already initialized.");
      return _database!;
    }
    print("Initializing database...");
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> get _dbPath async {
    String path = join(await getDatabasesPath(), _databaseName);
    print("Database path: $path");
    return path;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await _dbPath;
    bool dbExists = await databaseExists(dbPath);

    if (!dbExists) {
      print("Database does not exist. Copying from assets...");
      try {
        await _copyDatabaseFromAssets(dbPath);
        print("Database copied successfully.");
      } catch (e) {
        print("Error copying database: $e");
        throw Exception("Error copying database: $e");
      }
    } else {
      print("Database already exists.");
    }

    print("Opening database...");
    return await openDatabase(dbPath, version: _databaseVersion);
  }

  /// Create Database (if it doesn't exist)
  Future<void> createDatabase() async {
    String dbPath = await _dbPath;
    bool dbExists = await databaseExists(dbPath);

    if (!dbExists) {
      print("Database does not exist. Copying from assets...");
      try {
        await _copyDatabaseFromAssets(dbPath);
        print('Database copied successfully.');
      } catch (e) {
        print('Error copying database: $e');
        throw Exception('Error copying database');
      }
    } else {
      print("Database already exists, skipping copy.");
    }

    // Open the database after creation or if it already exists
    print("Opening database after creation...");
    await printTables();
  }

  Future<void> _copyDatabaseFromAssets(String dbPath) async {
    print("Loading database from assets...");
    ByteData data = await rootBundle.load("assets/$_databaseName");
    List<int> bytes = data.buffer.asUint8List();

    print("Writing database to: $dbPath");
    await File(dbPath).writeAsBytes(bytes, flush: true);
    print("Database written successfully.");
  }

  Future<void> insertData(String tableName, List<Map<String, dynamic>> dataList) async {
    final db = await database;
    print("Inserting data into table: $tableName");

    try {
      for (var data in dataList) {
        print("Inserting row: $data");
        await db.insert(tableName, data);
      }
      print("Data inserted successfully.");
    } catch (e) {
      print("Data insertion failed: $e");
      throw Exception("Data insertion failed: $e");
    }
  }

  Future<void> updateData(String tableName, Map<String, dynamic> updatedValues, String whereClause) async {
    final db = await database;
    print("Updating table: $tableName");
    print("Values to update: $updatedValues");
    print("Condition: $whereClause");

    try {
      await db.update(tableName, updatedValues, where: whereClause);
      print("Data updated successfully.");
    } catch (e) {
      print("Data update failed: $e");
      throw Exception("Data update failed: $e");
    }
  }

  Future<void> deleteRow(String tableName, String columnName, String value) async {
    final db = await database;
    print("Deleting from table: $tableName");
    print("Condition: $columnName = $value");

    try {
      await db.delete(tableName, where: "$columnName = ?", whereArgs: [value]);
      print("Row deleted successfully.");
    } catch (e) {
      print("Error deleting row: $e");
      throw Exception("Error deleting row: $e");
    }
  }

  Future<void> printTables() async {
    final db = await database;
    print("Fetching list of tables...");

    try {
      List<Map<String, dynamic>> tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      print("Tables in database:");
      for (var table in tables) {
        print(" - ${table['name']}");
      }
    } catch (e) {
      print("Error fetching tables: $e");
    }
  }



  Future<List<Map<String, dynamic>>> getData(String query) async {
    final db = await database;
    return await db.rawQuery(query);
  }

  Future<List<Line>> getLines(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(query);

    return result.map((map) => Line.fromMap(map)).toList();
  }

  Future<List<Unit>> getUnits(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(query);

    return result.map((map) => Unit.fromMap(map)).toList();
  }


}

// Line model
class Line {
  String? appId;
  String? lineId;
  String? name;
  int? frequency;
  int? window;
  String? lastExecuted;
  bool? closed;
  bool? status;

  Line({
    this.appId,
    this.lineId,
    this.name,
    this.frequency,
    this.window,
    this.lastExecuted,
    this.closed,
    this.status,
  });

  factory Line.fromMap(Map<String, dynamic> map) {
    return Line(
      appId: map['appId'],
      lineId: map['lineId'],
      name: map['name'],
      frequency: map['frequency'],
      window: map['window'],
      lastExecuted: map['lastExecuted'],
      closed: (map['closed'] ?? 0) > 0,
      status: (map['status'] ?? 0) > 0,
    );
  }
}

// Unit model
class Unit {
  String? appId;
  String? unitId;
  String? name;

  Unit({this.appId, this.unitId, this.name});

  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(
      appId: map['appId'],
      unitId: map['unitId'],
      name: map['name'],
    );
  }
}
