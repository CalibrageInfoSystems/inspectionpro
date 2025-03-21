import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CommonUtils {
  static const dropdownListBgColor = Color(0xff6f6f6f);

  static Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult[0] == ConnectivityResult.mobile ||
        connectivityResult[0] == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  static void showLoadingDialog(BuildContext context,
      {String? status = 'Please wait...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.blue),
                const SizedBox(width: 20),
                Text(
                  '$status',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  static void showErrorToast(context, String message) {
    FToast fToast = FToast();
    fToast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red, width: 2), // Add border color
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.black, fontSize: 20,fontFamily: 'roboto'),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.CENTER, // Change position
      toastDuration: const Duration(seconds: 3),
    );
  }
 static Future<bool> isNetworkAvailable() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    print("🔍 Connectivity Check: $connectivityResult"); // Debug log

    bool hasInternet = await InternetConnectionChecker().hasConnection;
    print("🌐 Actual Internet Connection: $hasInternet"); // Debug log

    return hasInternet;
  }
/*   static void showLoadingDialog22(BuildContext context,
      {String? status = 'Please wait...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(options.length, (index) {
                        return CheckboxListTile(
                          title: Text(options[index]),
                          value: isChecked[index],
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked[index] = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity
                              .leading, // Checkbox on the left
                        );
                      }),
                    ),
                  ),
                  );
            },
          ),
        );
        /*  return StatefulBuilder(
          builder: (context,) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(options.length, (index) {
                    return CheckboxListTile(
                      title: Text(options[index]),
                      value: isChecked[index],
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked[index] = value ?? false;
                        });
                      },
                      controlAffinity:
                          ListTileControlAffinity.leading, // Checkbox on the left
                    );
                  }),
                ),
              ),
              ),
            );
          }
        );
      */
      },
    );
  } */
}
