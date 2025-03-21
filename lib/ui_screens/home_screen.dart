import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:inspectionpro/ui_screens/login_screen.dart';
import 'package:inspectionpro/ui_screens/reject_pipeline.dart';
import 'package:inspectionpro/ui_screens/splash_screen.dart';
import 'package:inspectionpro/utils/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:inspectionpro/utils/styles.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/InspDatabaseHelper.dart';
import '../gen/assets.gen.dart';
import '../utils/commonutils.dart';

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

  int allCount = 0;
  int failedCount = 0;
  List<dynamic> linesData = [];
  List<Map<String, dynamic>> failedLinesData = [];
  bool isLoading = false; // To show a loading indicator
  final dbHelper = InspDatabaseHelper();
  bool showFailedOnly = false; // Toggle between All and Failed data
  String userName = "";
  String applicationName = "";
  @override
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    _loadUserData();

    bool networkAvailable = await CommonUtils.isNetworkAvailable();

    if (networkAvailable) {
      getAppInfo();
    } else {
      fetchData();

      //  debugPrint("Fetching data from database");
      //
      //  final dbHelper = InspDatabaseHelper();
      //
      //  await Future.delayed(Duration.zero, () async {
      //    await dbHelper.clearTable('lines');
      //
      //
      //
      // linesData = await dbHelper.getLines();
      //
      //    for (var line in linesData) {
      //      if (!line.status) {
      //     failedLinesData.add(line);
      //      }
      //    }
      //
      //
      //    debugPrint("check size... ${linesData.length}");

      // Delay toast until after the first frame to avoid context issues

      //  });
    }
  }

  Future<void> getAppInfo() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final apiUrl = Uri.parse('$baseUrl$getLines');
      final jsonResponse = await http.get(apiUrl);

      if (jsonResponse.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(jsonResponse.body);
        final dbHelper = InspDatabaseHelper();

        await dbHelper.insertLines(data['lines']);
        await dbHelper.insertLineValues(data['values']);
        await dbHelper.insertOperators(data['operators']);

     //   Fluttertoast.showToast(msg: "Data saved successfully!");
        await fetchData(); // Fetch updated data
      } else {
        Fluttertoast.showToast(msg: jsonResponse.body);
        throw Exception(jsonResponse.body);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false; // Stop loading when done
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonStyles.colorWhite,
      appBar: AppBar(
        backgroundColor: const Color(0xFF212121),
        title: Row(
          children: [
            /// **App Logo from Assets**
            Image.asset(
              'assets/images/app_logo_512.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 8),

            /// **App Name**
            const Text(
              'InspectionPro',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const Spacer(),

            /// **First Custom Icon (Sync)**
            IconButton(
              onPressed: _onSyncPressed,
              icon: Image.asset(
                Assets.images.sync.path,
                width: 24,
                height: 24,
                color: Colors.white, // Optional: Color overlay
              ),
            ),

            const SizedBox(width: 6),

            /// **Second Custom Icon (Lock)**
            IconButton(
              onPressed: () {
                // logOutDialog(context);
                CommonUtils.showCustomDialog(
                  context,
                  title: 'Confirmation',
                  content: 'Do you want to logout?',
                  onCancel: () => Navigator.of(context).pop(),
                  onSubmit: () {
                    Navigator.of(context).pop();
                    onConfirmLogout();
                  },
                );
              },
              icon: Image.asset(
                Assets.images.logout.path,
                width: 24,
                height: 24,
                color: Colors.white,
              ),
            ),
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
              child: Text(
                'FACILITY: $applicationName / USER: $userName',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => showFailedOnly = false),
                      child: _buildTab('All : ${lines.length}', Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _buildTab('Unsaved : 0', Colors.blue),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => showFailedOnly = true),
                      child: SizedBox(
                        width: double.infinity,
                        child: _buildTab(
                            'Failed : ${failedLinesData.length}', Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loader while data loads
                  : (showFailedOnly ? failedLinesData : lines).isEmpty
                      ? const Center(child: Text("No data found"))
                      : ListView.builder(
                          itemCount: showFailedOnly
                              ? failedLinesData.length
                              : lines.length,
                          itemBuilder: (context, index) {
                            final item = showFailedOnly
                                ? failedLinesData[index]
                                : lines[index];
                            return buildItem(item); // Pass data to `buildItem`
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, Color color) {
    return Container(
      height: 70,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  /// **UI for Each Line Item**
  Widget buildItem(Map<String, dynamic> line) {
    String formattedDate = getProperDate(line['lastExecuted']);
    print('formattedDate: $formattedDate');
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          //  String dateTimeString = "2025-03-17T12:49:00.05+00:00"; // Example ISO 8601 format

          /// **Line Name & Last Executed Time**
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line['name'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'roboto'),
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$formattedDate   ',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    TextSpan(
                      text: line['status'] == 1 ? 'Passed' : 'Failed',
                      style: TextStyle(
                        color:
                            line['status'] == 1 ? Colors.black54 : Colors.red,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),

          const Spacer(),

          /// **Thumbs Up & Down Buttons**
          IconButton(
            onPressed: () {
              print("Approved: ${line['name']}");
              SenddataCloud(line['lineId'], context);
              //  saveDataInDb(line['lineId']);
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
              String lineId = line['lineId'].toString();
              String name =
                  line['name'].toString(); // Assuming `name` exists in line

              print("Rejected: $lineId, Name: $name");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RejectPipeline(lineId: lineId, name: name),
                ),
              );
            },
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              side: const BorderSide(color: Colors.red),
            ),
            icon: const Icon(Icons.thumb_down, color: Colors.red, size: 20),
          )
        ],
      ),
    );
  }

  /// Fetch Data from SQLite
  ///
  Future<void> fetchData() async {
    setState(() {
      isLoading = true; // Start loading
    });
    final dbHelper = InspDatabaseHelper();

    List<Map<String, dynamic>> fetchedLines = await dbHelper.getLines();
    // ..  List<Map<String, dynamic>> fetchedUnits = await dbHelper.getUnits();
    //   List<Map<String, dynamic>> fetchedLineValues = await dbHelper.getLineValues();

    List<Map<String, dynamic>> failedLines = fetchedLines.where((line) {
      return line['status'] == 0; // Assuming 'status' is a boolean
    }).toList();

    setState(() {
      lines = fetchedLines;
      // units = fetchedUnits;
      //   lineValues = fetchedLineValues;
      failedLinesData = failedLines;
      isLoading = false; // Data loaded, hide loader
    });
  }
//   Future<void> fetchData() async {
//     final dbHelper = InspDatabaseHelper();
//
//     List<Map<String, dynamic>> fetchedLines = await dbHelper.getLines();
//     List<Map<String, dynamic>> fetchedUnits = await dbHelper.getUnits();
//     List<Map<String, dynamic>> fetchedLineValues = await dbHelper.getLineValues();
//
//     // Filtering failed lines
//     List<Map<String, dynamic>> failedLines = fetchedLines.where((line) {
//       return line['status'] == 0; // Assuming 'status' is a boolean
//     }).toList();
// print('failedLines: $failedLines');
//     print('failedLines.length: ${failedLinesData.length}');
//     setState(() {
//       lines = fetchedLines;
//       units = fetchedUnits;
//       lineValues = fetchedLineValues;
//       failedLinesData = failedLines; // Store failed lines
//     });
//   }

  void logOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontFamily: 'roboto',
            ),
          ),
          content: const Text(
            'Are You Sure You Want to Logout?',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontFamily: 'roboto',
            ),
          ),
          actions: [
            /// **❌ No Button**
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // White background
                side: BorderSide(
                  color: HexColor.fromHex('#33AADD'),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
              child: Text(
                'No',
                style: TextStyle(
                  fontSize: 16,
                  color: HexColor.fromHex('#33AADD'), // Text Color Fixed
                  fontFamily: 'roboto',
                ),
              ),
            ),
            const SizedBox(width: 10), // Space between buttons

            /// **✅ Yes Button**
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirmLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Use 'col' or fallback to blue
                side: BorderSide(
                  color: HexColor.fromHex('#33AADD'),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
              child: const Text(
                'Yes',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white, // White text
                  fontFamily: 'roboto',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> onConfirmLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.remove('userId');
    prefs.remove('userRoleId');
    Fluttertoast.showToast(msg: "Logout Successfully!");

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  String getProperDate(String dateTime) {
    try {
      // Parse the input string to DateTime
      DateTime parsedDate = DateTime.parse(dateTime).toLocal();

      // Format the date as "MM/dd/yyyy HH:mm"
      String formattedDate = DateFormat("MM/dd/yyyy HH:mm").format(parsedDate);

      print(formattedDate); // Debugging: Print formatted date
      return formattedDate;
    } catch (e) {
      print("Error parsing date: $e");
      return "Invalid Date";
    }
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
          await txn
              .delete("savedData", where: "lineId = ?", whereArgs: [lineId]);
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
            print(
                "✅ Status updated for lineId: $lineId ($rowsAffected rows affected)");
          } else {
            print("❌ Status update failed for lineId: $lineId");
            await debugTableContents();
          }
        }
      } catch (e) {
        print("❌ Error saving data: $e");
      }
    });

    refresh();
  }

  Future<void> refresh() async {
    setState(() => isLoading = true); // Show loading indicator

    fetchData();

    setState(() => isLoading = false); // Hide loading indicator
  }

  Map<String, dynamic> sendObj(String lineId) {
    print("check..lineId..$lineId");

    return {
      "lineId": lineId,
      "transactionId": null, // Equivalent to "null" in JSON
      "failedUnits": [] // Empty list (Equivalent to JSONArray)
    };
  }

  Future<void> debugTableContents() async {
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query("lines");

    print("📊 Current 'lines' Table Data:");
    for (var row in rows) {
      print(row);
    }
  }

  /// **Send Liked Data to Cloud**
  Future<void> SenddataCloud(String lineId, BuildContext context) async {
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
          refresh();
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

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('UserName') ?? 'Guest';
      applicationName = prefs.getString('ApplicationName') ?? 'UnknownApp';
    });
  }

  void _onSyncPressed() async {
    // _showProgressBar(context, "Syncing...");
    bool networkAvailable = await CommonUtils.isNetworkAvailable();

    if (networkAvailable) {
      bool syncReady = await makeSyncReady();

      if (!syncReady) {
        // _hideProgressBar(context);
        return;
      }

      bool success = await dbHelper.clearOldData();

      //   _hideProgressBar(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CommonUtils.showErrorToast(context,   success ? "Sync successful" : "Sync failed. Please try again.",isError: false);
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //         success ? "Sync successful" : "Sync failed. Please try again."),
      //   ),
      // );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CommonUtils.showErrorToast(context, "Please check internet connection",isError: true);;
      });
    }
  }

  Future<bool> makeSyncReady() async {
    _showProgressBar(context, "Please wait...");

    List<String> savedData = await dbHelper.getSavedData();
    print('savedData : $savedData');
    for (String sp in savedData) {
      print('sp : $sp');
      try {
        await pendingdatasyncCloud(sp);
      } catch (e) {
        print("Error: $e");
        _hideProgressBar(context);
      }
    }
    _hideProgressBar(context);
    return true;
  }

  Future<void> pendingdatasyncCloud(String sp) async {
    print("Pending Data Sync: $sp");
    bool networkAvailable = await isNetworkAvailable();

    if (!networkAvailable) {
      print("❌ No internet connection. Data will be stored locally.");
      return;
    }

    final apiUrl = Uri.parse('$baseUrl$SaveLines');
    print("🌐 API URL: $apiUrl");

    try {
      Map<String, dynamic> requestBody = jsonDecode(sp);

      // Ensure `transactionId` is properly handled
      requestBody["transactionId"] = requestBody["transactionId"] == "null"
          ? null
          : requestBody["transactionId"];

      print("📤 Request Body: ${jsonEncode(requestBody)}");

      final response = await http.put(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Data successfully sent to cloud!");
        refresh();
      } else {
        print("❌ Failed to send data: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending data: $e");
    }
  }
}

/// **Show Progress Bar (Uses Dialog)**
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
