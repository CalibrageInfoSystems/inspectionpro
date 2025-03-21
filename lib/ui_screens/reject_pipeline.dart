import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inspectionpro/database/InspDatabaseHelper.dart';
import 'package:inspectionpro/gen/assets.gen.dart';
import 'package:inspectionpro/utils/styles.dart';
import 'package:inspectionpro/widgets/custom_button.dart';
import 'package:inspectionpro/widgets/custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import '../utils/api_config.dart';
import '../utils/commonutils.dart';
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
  String? selectedDdUnit, selectedDdUnitID;
  String? selectedDdOperator;
  int deficiencyCount = 1;
  final TextEditingController noteController =
      TextEditingController(); // Add this at the top
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
      final result =
          await dbHelper.getLineValues(isInspection); // Pass isInspection value
      print('fetchLineValues: ${jsonEncode(result)}');
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF212121),
        title: Row(
          children: [
            /// **App Logo from Assets**
            Image.asset(
              Assets.images.appLogo512.path,
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              facilitySection(),
              const SizedBox(height: 5),
              deficiencySection(widget.name),
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
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedDdUnitID = null;
                            selectedDdUnit = null;
                            selectedDdOperator = null;
                            selectedItems.clear();
                            selectedItemsdiff.clear();
                            noteController.clear();
                            FocusScope.of(context).unfocus();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CommonStyles.colorGrey[200],
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
          const SizedBox(height: 4),
          CustomTextfield(
            controller: noteController, // Assign controller here
            maxLines: 4,
            focusBorderColor: CommonStyles.colorGrey[500],
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
                  hintText: 'Select Corrective Action',
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
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ).copyWith(left: 21),
                      decoration: BoxDecoration(
                        border: Border.all(color: CommonStyles.colorGrey),
                        borderRadius: BorderRadius.circular(5),
                      ),
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
                              style: TextStyle(
                                  fontSize: 15,
                                  color: selectedItems.isNotEmpty
                                      ? Colors.black
                                      : CommonStyles.colorGrey),
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
                  hintText: 'Select Deficiency Type',
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
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ).copyWith(left: 21),
                      decoration: BoxDecoration(
                        border: Border.all(color: CommonStyles.colorGrey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
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
                              style: TextStyle(
                                  fontSize: 15,
                                  color: selectedItemsdiff.isNotEmpty
                                      ? Colors.black
                                      : CommonStyles.colorGrey),
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
              child: unitDropDown(
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
                    selectedDdUnitID = selectedUnit['unitId'];
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

  Widget unitDropDown(List<Map<String, dynamic>> data,
      {required String? selectedValue, void Function(String?)? onChanged}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CommonStyles.colorGrey),
        borderRadius: BorderRadius.circular(5),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          iconStyleData: const IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down_rounded),
          ),
          isExpanded: true,
          hint: const Text(
            'Choose Unit ',
            style: CommonStyles.txStyF15CgFF6,
            /* style: TextStyle(
              fontSize: 15,
              color: CommonStyles.colorGrey,
            ), */
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          items: [
            DropdownMenuItem<String>(
              value: '-1',
              enabled: false,
              child: Text(
                'Select Unit',
                style: CommonStyles.txStyF15CbFF6.copyWith(
                  color: CommonStyles.colorGrey,
                ),
              ),
            ),
            ...data.map(
              (Map<String, dynamic> value) => DropdownMenuItem<String>(
                value: value['name'],
                child: Text(
                  value['name'],
                  style: CommonStyles.txStyF15CbFF6,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
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
              child: operatorDropDown(
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
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Container deficiencySection(String s) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.red,
      padding: const EdgeInsets.all(10),
      child: Text(
        '#Deficiency $deficiencyCount - $s',
        // Use string interpolation instead of concatenation
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget categoryItem(
      {required String title,
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
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  Widget operatorDropDown(List<Map<String, dynamic>> data,
      {required String? selectedValue, void Function(String?)? onChanged}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CommonStyles.colorGrey),
        borderRadius: BorderRadius.circular(5),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
            ),
          ),
          isExpanded: true,
          hint: const Text(
            'Choose Operator',
            style: CommonStyles.txStyF15CgFF6,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          items: [
            DropdownMenuItem<String>(
              value: '-1',
              enabled: false,
              child: Text(
                'Select Operator',
                style: CommonStyles.txStyF15CbFF6.copyWith(
                  color: CommonStyles.colorGrey,
                ),
              ),
            ),
            ...data.map(
              (Map<String, dynamic> value) => DropdownMenuItem<String>(
                value: value['name'],
                child: Text(
                  value['name'],
                  style: CommonStyles.txStyF15CbFF6,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
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
      ),
    );
  }

  void showSelectionDialog(
      BuildContext context, List<Map<String, dynamic>> result,
      {required void Function()? onSubmit, required String hintText}) {
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            hintText,
                            style: CommonStyles.txStyF15CbFF6,
                          ),
                        ),
                        ...List.generate(result.length, (index) {
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
                      ],
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
    bool networkAvailable = await CommonUtils.isNetworkAvailable();

    final apiUrl = Uri.parse('$baseUrl$SaveLines');
    print("🌐 API URL: $apiUrl");
    print("🌐networkAvailable: $networkAvailable");
    if (networkAvailable) {
      //  _showProgressBar(context, "Please wait...");

      try {
        Map<String, dynamic> requestBody = sendObj(lineId);
        final response = await http.put(
          apiUrl,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody),
        );
        print("requestBody: ${jsonEncode(requestBody)}");
        print("Response Status Code: ${response.statusCode}");
        // _hideProgressBar(context);

        if (response.statusCode == 200) {
          print("✅ Data successfully sent to cloud!");
          //     await saveDataInDb(lineId);
        } else {
          print("❌ Failed to send data: ${response.body}");
        }
      } catch (e) {
        print("❌ Error sending data: $e");
        //  _hideProgressBar(context);
      }
    }
    else {
      await saveDataInDb(lineId);
    }
  }

  void _showProgressBar(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
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
        print("✅ dataMap ===: $dataMap");

        // Check if data exists
        List<Map<String, dynamic>> existingData = await txn.query(
          "savedData",
          where: "lineId = ?",
          whereArgs: [lineId],
        );

        // Delete existing data if found
        // if (existingData.isNotEmpty) {
        //   await txn
        //       .delete("savedData", where: "lineId = ?", whereArgs: [lineId]);
        //   print("🗑 Existing data deleted for lineId: $lineId");
        // }

        // Insert new data
        int insertedId = await txn.insert("savedData", dataMap);
        print("✅ Data inserted with ID: $insertedId");

        // Update status if insert is successful
        if (insertedId > 0) {
          int rowsAffected = await txn.rawUpdate(
            "UPDATE lines SET status = ? WHERE lineId = ?",
            [0, lineId],
          );
          if (rowsAffected > 0) {
            print(
                "✅ Status updated for lineId: $lineId ($rowsAffected rows affected)");
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
        "unitId": selectedDdUnitID, // Ensure this holds a valid Unit ID
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
  // void _showErrorSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // }

  void _handleSubmit() {
    if (!_validateUnit()) {
      CommonUtils.showErrorToast(context, 'Please select an unit.');
      return;
    }
    if (!_validateDeficiencyType()) {
      CommonUtils.showErrorToast(
          context, 'Please select at least one deficiency type.');
      return;
    }
    if (!_validateOperator()) {
      CommonUtils.showErrorToast(context, 'Please select an operator.');
      return;
    }
    if (!_validateCorrectiveAction()) {
      CommonUtils.showErrorToast(
          context, 'Please select at least one corrective action.');
      return;
    }
    print("Note Entered: ${noteController.text}");
    // All validations passed, proceed with form submission
    print('Selected Unit: $selectedDdUnitID');
    print('Selected Operator: $selectedDdOperator');
    print(
        'Selected Deficiency Types: ${selectedItemsdiff.map((e) => e['name']).join(', ')}');
    print(
        'Selected Corrective Actions: ${selectedItems.map((e) => e['name']).join(', ')}');
    // _showConfirmationDialog();
    // shoWMoreDeficienciesDialog(context);
    CommonUtils.showCustomDialog(
      context,
      title: 'InspectionPro',
      content: 'Do you want add more deficiencies',
      onCancel: () {
        Navigator.pop(context);
        sendDataToCloud(widget.lineId);
        /*  Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        ); */
        // Navigator.pop(context, true);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false);
      },
      onSubmit: () async {
        Navigator.pop(context);
       await sendDataToCloud(widget.lineId);

       setState(() {
          selectedDdUnitID = null;
          selectedDdUnit = null;
          selectedDdOperator = null;
          selectedItems.clear();
          selectedItemsdiff.clear();
          noteController.clear();
          deficiencyCount = deficiencyCount + 1;
          FocusScope.of(context).unfocus();
    });
      },
    );
    //   sendDataToCloud('${widget.lineId}');
  }


}
