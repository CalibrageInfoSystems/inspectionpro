import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:inspectionpro/database/InspDatabaseHelper.dart';
import 'package:inspectionpro/widgets/custom_button.dart';
import 'package:inspectionpro/widgets/custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import '../utils/api_config.dart';
import 'home_screen.dart';

// class RejectPipeline extends StatefulWidget {
//   const RejectPipeline({super.key});
//
//   @override
//   State<RejectPipeline> createState() => _RejectPipelineState();
// }

class RejectPipeline extends StatefulWidget {
  final String lineId;
  final String name;

  const RejectPipeline({super.key, required this.lineId, required this.name});

  @override
  _RejectPipelineState createState() => _RejectPipelineState();
}

class _RejectPipelineState extends State<RejectPipeline> {

  String userName = "";
  String applicationName = "";
  List<bool> isChecked = []; // Correctly initialized
  List<Map<String, dynamic>> selectedItemsdiff = [];
  List<Map<String, dynamic>> selectedItems = [];
  late Future<List<Map<String, dynamic>>> futureUnits;
  late Future<List<Map<String, dynamic>>> futureLines;
  late Future<List<Map<String, dynamic>>> futureLineValuesfordificency;
  late Future<List<Map<String, dynamic>>> futureLineValuesforAction;
  late Future<List<Map<String, dynamic>>> operators;
  String? selectedDdUnit,selectedDdUnitID;
  String? selectedDdOperator;
  final TextEditingController noteController = TextEditingController(); // Add this at the top
  @override
  void initState() {
    super.initState();
    _loadUserData();
    futureUnits = fetchUnits();
    operators = fetchoperators();
    futureLines = fetchLine();
    futureLineValuesfordificency = fetchLineValues(1);
    futureLineValuesforAction = fetchLineValues(0);
    print("Received LineID: ${widget.lineId}, Name: ${widget.name}");
  }

/*   Future<List<Future>> fetchFutureData() async {
  try {
    final dbHelper = InspDatabaseHelper();
    final units = await dbHelper.getUnits();
    final lines = await dbHelper.getLines();
    final lineValues = await dbHelper.getLineValues();

    return [
      units ?? [],
      lines ?? [],
      lineValues ?? [],
    ];
  } catch (e) {
    rethrow;
  }
} */

  Future<List<Map<String, dynamic>>> fetchUnits() async {
    try {
      final dbHelper = InspDatabaseHelper();
      final result = await dbHelper.getUnits(widget.lineId); // Pass lineId
      print('fetchUnits: ${jsonEncode(result)}');
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchoperators() async {
    try {
      final dbHelper = InspDatabaseHelper();
      final result = await dbHelper.getoperators(); // Pass lineId
      print('fetchoperators: ${jsonEncode(result)}');
      return result;
    } catch (e) {
      rethrow;
    }
  }
  Future<List<Map<String, dynamic>>> fetchLine() async {
    try {
      final dbHelper = InspDatabaseHelper();
      final result = await dbHelper.getLines();
      print('fetchLine: ${jsonEncode(result)}');
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchLineValues(int isInspection) async {
    try {
      final dbHelper = InspDatabaseHelper();
      final result = await dbHelper.getLineValues(
          isInspection); // Pass isInspection value
      print('fetchLineValues: ${jsonEncode(result)}');
      return result;
    } catch (e) {
      rethrow;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF212121),
        title: Row(
          children: [

            /// **App Logo from Assets**
            Image.asset(
              'assets/images/app_logo_512.png', // Your logo path
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 8),

            /// **App Name**
            const Text(
              'InspectionPro',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),


          ],
        ),
      ),
      body:
      GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child:
        SingleChildScrollView(
          child: Column(
            children: [
              facilitySection(),
              const SizedBox(height: 5),
              deficiencySection('${widget.name}'),
              const SizedBox(height: 5),
              units(),
              deficiencyType(),
              operator(),
              correctiveAction(),
              note(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    /// **RESET Button - Clears all selected data**
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedDdUnitID= null;
                            selectedDdUnit = null;
                            selectedDdOperator = null;
                            selectedItems.clear();
                            selectedItemsdiff.clear();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F5),
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'RESET',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// **SUBMIT Button - Prints Selected Values**
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff96d465),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'SUBMIT',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  Padding note() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Note',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          CustomTextfield(
            controller: noteController,  // Assign controller here
            maxLines: 4,
            focusBorderColor: Colors.grey[500],
          ),
        ],
      ),
    );
  }

  FutureBuilder<List<Map<String, dynamic>>> correctiveAction() {
    return FutureBuilder(
      future: futureLineValuesforAction,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error occurred');
        } else {
          final resultLines = snapshot.data as List<Map<String, dynamic>>;
          if (resultLines.isNotEmpty) {
            return GestureDetector(
              onTap: () {
                showSelectionDialog(
                  context,
                  resultLines,
                  onSubmit: () {
                    setState(() {
                      selectedItems = [];
                      for (int i = 0; i < isChecked.length; i++) {
                        if (isChecked[i]) {
                          selectedItems.add(resultLines[i]);
                        }
                      }
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Corrective Action',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedItems.isNotEmpty
                                  ? selectedItems
                                  .map((e) => e['name'])
                                  .join(', ')
                                  : 'Choose Corrective Action',
                              style: const TextStyle(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Text('No Data found');
          }
        }
      },
    );
  }

  FutureBuilder<List<Map<String, dynamic>>> deficiencyType() {
    return FutureBuilder(
      future: futureLineValuesfordificency,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error occurred');
        } else {
          final resultLines = snapshot.data as List<Map<String, dynamic>>;
          if (resultLines.isNotEmpty) {
            return GestureDetector(
              onTap: () {
                showSelectionDialog(
                  context,
                  resultLines,
                  onSubmit: () {
                    setState(() {
                      selectedItemsdiff = [];
                      for (int i = 0; i < isChecked.length; i++) {
                        if (isChecked[i]) {
                          selectedItemsdiff.add(resultLines[i]);
                        }
                      }
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deficiency Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedItemsdiff.isNotEmpty
                                  ? selectedItemsdiff
                                  .map((e) => e['name'])
                                  .join(', ')
                                  : 'Choose Deficiency Type',
                              style: const TextStyle(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Text('No Data found');
          }
        }
      },
    );
  }


  FutureBuilder<List<Map<String, dynamic>>> units() {
    return FutureBuilder(
      future: futureUnits,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error occurred');
        } else {
          final resultLines = snapshot.data as List<Map<String, dynamic>>;
          if (resultLines.isNotEmpty) {
            return categoryItem(
              title: 'Unit',
              data: resultLines,
              child: customDropDown(
                resultLines,
                selectedValue: selectedDdUnit,
                onChanged: (String? value) {
                  setState(() {
                    selectedDdUnit = value;
                  });

                  // Find the selected unit in the list and print unitId & name
                  final selectedUnit = resultLines.firstWhere(
                        (unit) => unit['name'] == value,
                    orElse: () => {},
                  );

                  if (selectedUnit.isNotEmpty) {
                    selectedDdUnitID = selectedUnit['unitId'] ;
                    print("Selected Unit ID: ${selectedDdUnitID}");
                    print("Selected Unit Name: ${selectedUnit['name']}");
                  }
                },
              ),
            );
          } else {
            return const Text('No Data found');
          }
        }
      },
    );
  }

  DropdownButtonHideUnderline customDropDown(List<Map<String, dynamic>> data,
      {required String? selectedValue, void Function(String?)? onChanged}) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.keyboard_arrow_down_rounded),
        ),
        isExpanded: true,
        hint: const Text(
          'Choose Unit ',
          style: TextStyle(fontSize: 15),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        items: data
            .map(
              (Map<String, dynamic> value) => DropdownMenuItem<String>(
            value: value['name'],
            child: Text(
              value['name'],
              style: const TextStyle(
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
            .toList(),
        value: selectedValue,
        onChanged: onChanged,
        dropdownStyleData: DropdownStyleData(
          maxHeight: 250,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            color: Colors.white,
          ),
          offset: const Offset(0, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: WidgetStateProperty.all<double>(6),
            thumbVisibility: WidgetStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }


  FutureBuilder<List<Map<String, dynamic>>> operator() {
    return FutureBuilder(
      future: operators,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error occurred');
        } else {
          final resultLines = snapshot.data as List<Map<String, dynamic>>;
          if (resultLines.isNotEmpty) {
            return categoryItem(
              title: 'Operator',
              data: resultLines,
              child: custom_DropDown(
                resultLines,
                selectedValue: selectedDdOperator,
                onChanged: (String? value) {
                  setState(() {
                    selectedDdOperator = value;
                  });
                },
              ),
            );
          } else {
            return const Text('No Data found');
          }
        }
      },
    );
  }

  Container facilitySection() {
    return Container(
      alignment: Alignment.centerRight,
      color: const Color.fromARGB(255, 153, 153, 153),
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'FACILITY: $applicationName / USER: $userName',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Container deficiencySection(String s) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.red,
      padding: const EdgeInsets.all(10),
      child: Text(
        '#Deficiency 1 - $s',
        // Use string interpolation instead of concatenation
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget categoryItem({required String title,
    required List<Map<String, dynamic>> data,
    required Widget child}) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          child,
        ],
      ),
    );
  }

  DropdownButtonHideUnderline custom_DropDown(List<Map<String, dynamic>> data,
      {required String? selectedValue, void Function(String?)? onChanged}) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
          ),
        ),
        isExpanded: true,
        hint: const Text(
          'Choose Operator',
          style: TextStyle(
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        items: data
            .map(
              (Map<String, dynamic> value) =>
              DropdownMenuItem<String>(
                value: value['name'],
                child: Text(
                  value['name'],
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
        )
            .toList(),
        value: selectedValue,
        onChanged: onChanged,

        dropdownStyleData: DropdownStyleData(
          maxHeight: 250, // 6 items * 40 height per item = 240
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            color: Colors.white,
          ),
          offset: const Offset(0, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: WidgetStateProperty.all<double>(6),
            thumbVisibility: WidgetStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }

  void showSelectionDialog(BuildContext context,
      List<Map<String, dynamic>> result,
      {required void Function()? onSubmit}) {
    if (isChecked.length != result.length) {
      isChecked = List.filled(result.length, false);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(result.length, (index) {
                        final data = result[index];

                        return CheckboxListTile(
                          title: Text(data['name']),
                          value: isChecked[index],
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked[index] = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('CANCEL',
                              style: TextStyle(color: Colors.teal)),
                        ),
                        TextButton(
                          onPressed: onSubmit,

                          child: const Text('SUBMIT',
                              style: TextStyle(color: Colors.teal)),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('UserName') ?? 'Guest';
      applicationName = prefs.getString('ApplicationName') ?? 'UnknownApp';
    });


  }

  Future<void> sendDataToCloud(String lineId) async {
    bool networkAvailable = await isNetworkAvailable();

  final apiUrl = Uri.parse('$baseUrl$SaveLines');
  print("🌐 API URL: $apiUrl");
  print("🌐networkAvailable: $networkAvailable");
  if (networkAvailable) {
    _showProgressBar(context, "Please wait...");

    try {
      Map<String, dynamic> requestBody = sendObj(lineId);
      final response = await http.put(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );
      print("requestBody: ${jsonEncode(requestBody)}");
      print("Response Status Code: ${response.statusCode}");
      _hideProgressBar(context);

      if (response.statusCode == 200) {
        print("✅ Data successfully sent to cloud!");
        await saveDataInDb(lineId);

      } else {
        print("❌ Failed to send data: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending data: $e");
      _hideProgressBar(context);
    }
  } else {
    await saveDataInDb(lineId);
  }
  }
  Future<bool> isNetworkAvailable() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    print("🔍 Connectivity Check: $connectivityResult"); // Debug log

    bool hasInternet = await InternetConnectionChecker().hasConnection;
    print("🌐 Actual Internet Connection: $hasInternet"); // Debug log

    return hasInternet;
  }
  void _showProgressBar(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  /// **Hide Progress Bar**
  void _hideProgressBar(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
  Future<void> saveDataInDb(String lineId) async {
    final dbHelper = InspDatabaseHelper();
    final db = await dbHelper.database;

    await db.transaction((txn) async {
      try {
        // Prepare data
        Map<String, dynamic> dataMap = {
          "appId": "",
          "lineId": lineId,
          "name": jsonEncode(sendObj(lineId)), // Convert JSON to String
        };

        // Check if data exists
        List<Map<String, dynamic>> existingData = await txn.query(
          "savedData",
          where: "lineId = ?",
          whereArgs: [lineId],
        );

        // Delete existing data if found
        if (existingData.isNotEmpty) {
          await txn.delete("savedData", where: "lineId = ?", whereArgs: [lineId]);
          print("🗑 Existing data deleted for lineId: $lineId");
        }

        // Insert new data
        int insertedId = await txn.insert("savedData", dataMap);
        print("✅ Data inserted with ID: $insertedId");

        // Update status if insert is successful
        if (insertedId > 0) {
          int rowsAffected = await txn.rawUpdate(
            "UPDATE lines SET status = ? WHERE lineId = ?",
            [1, lineId],
          );
          if (rowsAffected > 0) {
            print("✅ Status updated for lineId: $lineId ($rowsAffected rows affected)");
          } else {
            print("❌ Status update failed for lineId: $lineId");

          }
        }
      } catch (e) {
        print("❌ Error saving data: $e");
      }
    });


  }


  Map<String, dynamic> sendObj(String lineId) {
    print("📌 Sending lineId: $lineId");
    print("Note Entered: ${noteController.text}");
    // Creating the `failedUnits` list with selected data
    List<Map<String, dynamic>> failedUnits = [
      {
        "deficiency": selectedItemsdiff.map((e) => e['name']).toList(),
        "correction": selectedItems.map((e) => e['name']).toList(),
        "unitId": selectedDdUnitID,  // Ensure this holds a valid Unit ID
        "person": selectedDdOperator, // Ensure this holds a valid Operator name
        "comments": '${noteController.text}' // You can change this dynamically
      }
    ];

    return {
      "lineId": lineId,
      "transactionId": null,
      "failedUnits": failedUnits,
    };
  }
  // Validation functions
  bool _validateUnit() {
    return selectedDdUnitID != null;
  }

  bool _validateDeficiencyType() {
    return selectedItemsdiff.isNotEmpty;
  }

  bool _validateOperator() {
    return selectedDdOperator != null;
  }

  bool _validateCorrectiveAction() {
    return selectedItems.isNotEmpty;
  }

  // Function to show SnackBar with error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Function to handle form submission
  void _handleSubmit() {
    if (!_validateUnit()) {
      _showErrorSnackBar('Please select a unit.');
      return;
    }
    if (!_validateDeficiencyType()) {
      _showErrorSnackBar('Please select at least one deficiency type.');
      return;
    }
    if (!_validateOperator()) {
      _showErrorSnackBar('Please select an operator.');
      return;
    }
    if (!_validateCorrectiveAction()) {
      _showErrorSnackBar('Please select at least one corrective action.');
      return;
    }
    print("Note Entered: ${noteController.text}");
    // All validations passed, proceed with form submission
    print('Selected Unit: $selectedDdUnitID');
    print('Selected Operator: $selectedDdOperator');
    print('Selected Deficiency Types: ${selectedItemsdiff.map((e) => e['name']).join(', ')}');
    print('Selected Corrective Actions: ${selectedItems.map((e) => e['name']).join(', ')}');
    _showConfirmationDialog();
 //   sendDataToCloud('${widget.lineId}');
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              "InspectionPro",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          content: const Text("Do you want to add more deficiencies?"),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      sendDataToCloud('${widget.lineId}');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("No", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        selectedDdUnitID = null;
                        selectedDdUnit = null;
                        selectedDdOperator = null;
                        selectedItems.clear();
                        selectedItemsdiff.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("Yes", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


}

