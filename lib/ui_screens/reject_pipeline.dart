import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:inspectionpro/database/InspDatabaseHelper.dart';
import 'package:inspectionpro/widgets/custom_button.dart';
import 'package:inspectionpro/widgets/custom_textfield.dart';

class RejectPipeline extends StatefulWidget {
  const RejectPipeline({super.key});

  @override
  State<RejectPipeline> createState() => _RejectPipelineState();
}

class _RejectPipelineState extends State<RejectPipeline> {
  final List<String> daysOfWeek = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];
  String? selectedDay;

  List<String> options = [
    'Re-sanitize',
    'Scrub',
    'Scrub, re-rinse, re-sanitize, re-inspect',
    'Re-inspect',
    'Other',
    'Re-rinse, re-sanitize, re-inspect',
    'Re-rinse',
  ];
  // List<bool> isChecked = List.filled(7, false);
  List<bool> isChecked = [];
  List<Map<String, dynamic>> selectedItems = [];

  late Future<List<Map<String, dynamic>>> futureUnits;
  late Future<List<Map<String, dynamic>>> futureLines;
  late Future<List<Map<String, dynamic>>> futureLineValues;
  String? selectedDdUnit;
  String? selectedDdOperator;

  @override
  void initState() {
    super.initState();
    futureUnits = fetchUnits();
    futureLines = fetchLine();
    futureLineValues = fetchLineValues();
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
      final result = await dbHelper.getUnits();
      print('fetchUnits: ${jsonEncode(result)}');
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

  Future<List<Map<String, dynamic>>> fetchLineValues() async {
    try {
      final dbHelper = InspDatabaseHelper();
      final result = await dbHelper.getLineValues();
      print('fetchLineValues: ${jsonEncode(result)}');
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF212121),
        centerTitle: true,
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Failed Pipeline',
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
              deficiencySection(),
              const SizedBox(height: 5),
              units(),
              operator(),
              deficiencyType(),
              correctiveAction(),
              note(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F5),
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'RESET',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        btnText: 'SUBMIT',
                        backgroundColor: const Color(0xff96d465),
                        btnStyle: TextStyle(color: Colors.white),
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
            maxLines: 4,
            focusBorderColor: Colors.grey[500],
          ),
        ],
      ),
    );
  }

  FutureBuilder<List<Map<String, dynamic>>> correctiveAction() {
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
                                  : 'Select Corrective Action',
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
      future: futureUnits,
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
                              selectedItems.isNotEmpty
                                  ? selectedItems
                                      .map((e) => e['name'])
                                      .join(', ')
                                  : 'Select Deficiency Type',
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

  FutureBuilder<List<Map<String, dynamic>>> deficiency() {
    return FutureBuilder(
      future: futureLineValues,
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
              child: customDropDown(
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

  FutureBuilder<List<Map<String, dynamic>>> operator() {
    return FutureBuilder(
      future: futureLines,
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
              child: customDropDown(
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
      padding: const EdgeInsets.all(10),
      child: const Text(
        'FACILITY: TestClient / USER: demo',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Container deficiencySection() {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.red,
      padding: const EdgeInsets.all(10),
      child: const Text(
        '#Deficiency 1 - Phyche Line',
        style: TextStyle(fontSize: 16, color: Colors.white),
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
          child,
        ],
      ),
    );
  }

  DropdownButtonHideUnderline customDropDown(List<Map<String, dynamic>> data,
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
          'Choose Unit',
          style: TextStyle(
            fontSize: 15,
          ),
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
        /* (String? value) {
          setState(() {
            selectedValue = value;
          });
        }, */
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

  void showSelectionDialog(
      BuildContext context, List<Map<String, dynamic>> result,
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
                          /*  onPressed: () {
                            // Store selected items
                            setState(() {
                              selectedItems = [];
                              for (int i = 0; i < isChecked.length; i++) {
                                if (isChecked[i]) {
                                  selectedItems.add(result[i]);
                                }
                              }
                            });
                            Navigator.of(context).pop();
                          }, */
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
}
