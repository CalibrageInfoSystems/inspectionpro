import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:io';
import 'dart:typed_data';

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

  Future<void> insertData(String tableName,
      List<Map<String, dynamic>> dataList) async {
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

  Future<void> updateData(String tableName, Map<String, dynamic> updatedValues,
      String whereClause) async {
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

  Future<void> deleteRow(String tableName, String columnName,
      String value) async {
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
      List<Map<String, dynamic>> tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'");
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


  /// Fetch Lines Data
  Future<List<Map<String, dynamic>>> getLines() async {
    final db = await database;
    return await db.query('lines');
  }

  /// Fetch Units Data
  Future<List<Map<String, dynamic>>> getUnits(String lineId) async {
    final db = await database;
    return await db.query(
      'units',
      where: 'lineId = ?',
      whereArgs: [lineId],
    );
  }

  Future<List<Map<String, dynamic>>> getLineValues() async {
    final db = await database;
    return await db.query('linevalues');
  }

  /// **Clear Table Data Before Inserting New Records**
  Future<void> clearTable(String tableName) async {
    final db = await database;
    print("🗑 Clearing table: $tableName...");
    await db.delete(tableName);
    print("✅ Table $tableName cleared.");
  }



  /// **Insert Methods for Specific Tables**

  Future<void> insertLines(List<dynamic> lines) async {
    print("🔄 Refreshing `lines` table...");
    await clearTable('lines'); // Clear existing data before inserting
    await clearTable('units'); // Clear existing data
    List<Map<String, dynamic>> dataList = lines.map((line) =>
    {
      'appId': line['appId'],
      'lineId': line['lineId'],
      'name': line['name'],
      'frequency': line['frequency'].toString(),
      'window': line['window'],
      'lastExecuted': line['lastExecuted'],
      'closed': line['closed'] ? 1 : 0,
      'status': line['status'] ? 1 : 0,
    }).toList();

    await insertData('lines', dataList);

    for (var line in lines) {
      if (line.containsKey('units')) {
        print("🔄 Refreshing `units` table for line: ${line['name']}...");
        await insertUnits(line['units'], line['lineId']);
      }
    }

    await fetchAndPrintRelatedData('lines');
  }

  Future<void> insertUnits(List<dynamic> units, String lineId) async {
    //await clearTable('units'); // Clear existing data

    List<Map<String, dynamic>> dataList = units.map((unit) =>
    {
      'appId': unit['appId'],
      'lineId': lineId,
      'unitId': unit['unitId'],
      'name': unit['name'],
    }).toList();

    await insertData('units', dataList);
    await fetchAndPrintRelatedData('units');
  }

  Future<void> insertLineValues(List<dynamic> values) async {
    await clearTable('linevalues'); // Clear existing data

    List<Map<String, dynamic>> dataList = values.map((value) =>
    {
      'appId': value['appId'],
      'id': value['id'],
      'parentId': value['parentId'],
      'name': value['name'],
      'isInspection': value['isInspection'] ? 1 : 0,
    }).toList();

    await insertData('linevalues', dataList);
    await fetchAndPrintRelatedData('linevalues');
  }

  Future<void> insertOperators(List<dynamic> operators) async {
    await clearTable('operators'); // Clear existing data

    List<Map<String, dynamic>> dataList = operators.map((op) => {'name': op})
        .toList();
    await insertData('operators', dataList);
    await fetchAndPrintRelatedData('operators');
  }

  /// **Fetch and Print Related Data**
  Future<void> fetchAndPrintRelatedData(String tableName) async {
    final db = await database;
    print("📊 Fetching data from table: $tableName");

    try {
      List<Map<String, dynamic>> data = await db.query(tableName);
      if (data.isNotEmpty) {
        print("✅ Data from $tableName:");
        for (var row in data) {
          print(row);
        }
      } else {
        print("⚠️ No data found in $tableName.");
      }
    } catch (e) {
      print("❌ Error fetching data from $tableName: $e");
    }
  }

  /// **Update Status Query**
  Future<void> updateStatus(int status, String lineId) async {
    final db = await database;

    // Print the raw SQL query for debugging
    String query = "UPDATE lines SET status = $status WHERE lineId = '$lineId'";
    print("📝 Executing Query: $query");

    // Execute the update query
    int rowsAffected = await db.rawUpdate(
      "UPDATE lines SET status = ? WHERE lineId = ?",
      [status, lineId],
    );

    // Check if update was successful
    if (rowsAffected > 0) {
      print("✅ Status updated successfully for lineId: $lineId ($rowsAffected rows affected)");
    } else {
      print("❌ Update failed. Check if lineId exists.");
      await debugTableContents();
    }
  }



  /// **🔍 Debugging: Fetch and Print All Rows in 'lines' Table**
  Future<void> debugTableContents() async {
    final db = await database;
    List<Map<String, dynamic>> rows = await db.query("lines");

    print("📊 Current 'lines' Table Data:");
    for (var row in rows) {
      print(row);
    }
  }
}


  /// **Insert Methods for Specific Tables with Print Statements**
  //
  // Future<void> insertLines(List<dynamic> lines) async {
  //   print("Inserting ${lines.length} lines...");
  //   List<Map<String, dynamic>> dataList = lines.map((line) => {
  //     'appId': line['appId'],
  //     'lineId': line['lineId'],
  //     'name': line['name'],
  //     'frequency': line['frequency'].toString(),
  //     'window': line['window'],
  //     'lastExecuted': line['lastExecuted'],
  //     'closed': line['closed'] ? 1 : 0,
  //     'status': line['status'] ? 1 : 0,
  //   }).toList();
  //
  //   await insertData('lines', dataList);
  //
  //   for (var line in lines) {
  //     if (line.containsKey('units')) {
  //       print("Inserting ${line['units'].length} units for line: ${line['name']}");
  //       await insertUnits(line['units'], line['lineId']);
  //     }
  //   }
  // }
  //
  // Future<void> insertUnits(List<dynamic> units, String lineId) async {
  //   print("Inserting ${units.length} units...");
  //   List<Map<String, dynamic>> dataList = units.map((unit) => {
  //     'appId': unit['appId'],
  //     'lineId': lineId,
  //     'unitId': unit['unitId'],
  //     'name': unit['name'],
  //   }).toList();
  //
  //   await insertData('units', dataList);
  // }
  //
  // Future<void> insertLineValues(List<dynamic> values) async {
  //   print("Inserting ${values.length} line values...");
  //   List<Map<String, dynamic>> dataList = values.map((value) => {
  //     'appId': value['appId'],
  //     'id': value['id'],
  //     'parentId': value['parentId'],
  //     'name': value['name'],
  //     'isInspection': value['isInspection'] ? 1 : 0,
  //   }).toList();
  //
  //   await insertData('linevalues', dataList);
  // }
  //
  // Future<void> insertOperators(List<dynamic> operators) async {
  //   print("Inserting ${operators.length} operators...");
  //   List<Map<String, dynamic>> dataList = operators.map((op) => {'name': op}).toList();
  //   await insertData('operators', dataList);
  // }





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
