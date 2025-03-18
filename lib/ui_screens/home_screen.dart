import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inspectionpro/models/appinfo_model.dart';
import 'package:inspectionpro/ui_screens/failed_pipeline.dart';
import 'package:inspectionpro/utils/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:sqflite/sqflite.dart';

import '../database/InspDatabaseHelper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> lines = [];
  List<Map<String, dynamic>> units = [];
  List<Map<String, dynamic>> lineValues = [];
  String? selectedUnit;
  List<dynamic> selectedLineValues = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }
  Future<void> getAppInfo() async {
    try {
      final apiUrl = Uri.parse('$baseUrl$getLines');
      final jsonResponse = await http.get(apiUrl);

      if (jsonResponse.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(jsonResponse.body);

        final dbHelper = InspDatabaseHelper();

        await dbHelper.insertLines(data['lines']);
        await dbHelper.insertLineValues(data['values']);
        await dbHelper.insertOperators(data['operators']);

        Fluttertoast.showToast(msg: "Data saved successfully!");
      } else {
        Fluttertoast.showToast(msg: jsonResponse.body);
        throw Exception(jsonResponse.body);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF212121),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text(
              'InspectionPro',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const Spacer(),
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FailedPipeline()),
                  );
                },
                icon: const Icon(
                  Icons.sync_lock_outlined,
                  color: Colors.white,
                )),
            const SizedBox(width: 6),
            IconButton(
                onPressed: getAppInfo,
                icon: const Icon(
                  Icons.logout_outlined,
                  color: Colors.white,
                )),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              color: const Color.fromARGB(255, 153, 153, 153),
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'FACILITY: TestClient / USER: demo',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTab('All', 4, Colors.grey),
                  const SizedBox(width: 5),
                  _buildTab('Unsaved', 0, Colors.blue),
                  const SizedBox(width: 5),
                  _buildTab('Failed', 1, Colors.red),
                ],
              ),
            ),
            Expanded(
              child: lines.isEmpty
                  ? Center(child: Text("No data found"))
                  : ListView.builder(
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  return buildItem(lines[index]); // Pass data to `buildItem`
                },
              ),
            ),

            /// **🔹 Units Dropdown**
            Padding(
              padding: EdgeInsets.all(10),
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedUnit,
                hint: Text("Select Unit"),
                items: units.map((unit) {
                  return DropdownMenuItem<String>(
                    value: unit['name'],
                    child: Text(unit['name']),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedUnit = value;
                  });
                },
              ),
            ),


    Padding(
    padding: EdgeInsets.all(10),
    child: MultiSelectDialogField(
    items: lineValues.map((value) {
    return MultiSelectItem(value['name'], value['name']);
    }).toList(),
    title: Text("Select Line Values"),
    buttonText: Text("Choose Line Values"),
    initialValue: selectedLineValues,
    onConfirm: (values) {
    setState(() {
    selectedLineValues = values;
    });
    },
    ),
    ),

          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int count, Color color) {
    return Expanded(
      child: Container(
        height: 70,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$label: $count',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// **UI for Each Line Item**
  Widget buildItem(Map<String, dynamic> line) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          /// **Line Name & Last Executed Time**
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line['name'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                "${line['lastExecuted']}   ${line['status'] == 1 ? "Passed" : "Failed"}",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),

          const Spacer(),

          /// **Thumbs Up & Down Buttons**
          IconButton(
            onPressed: () {
              print("Approved: ${line['name']}");
            },
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              side: const BorderSide(color: Colors.green),
            ),
            icon: const Icon(Icons.thumb_up, color: Colors.green, size: 20),
          ),

          IconButton(
            onPressed: () {
              print("Rejected: ${line['name']}");
            },
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              side: const BorderSide(color: Colors.red),
            ),
            icon: const Icon(Icons.thumb_down, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }


  /// Fetch Data from SQLite
  Future<void> fetchData() async {
    final dbHelper = InspDatabaseHelper();

    List<Map<String, dynamic>> fetchedLines = await dbHelper.getLines();
    List<Map<String, dynamic>> fetchedUnits = await dbHelper.getUnits();
    List<Map<String, dynamic>> fetchedLineValues = await dbHelper.getLineValues();

    setState(() {
      lines = fetchedLines;
      units = fetchedUnits;
      lineValues = fetchedLineValues;
    });
  }
}
