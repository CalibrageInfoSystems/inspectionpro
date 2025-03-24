import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inspectionpro/utils/styles.dart';
import 'package:inspectionpro/widgets/custom_button.dart';
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

  static void showErrorToast(BuildContext context, String message,
      {bool isError = true}) {
    FToast fToast = FToast();
    fToast.init(context);

    // Determine the color and icon based on error/success
    Color borderColor = isError ? Colors.red : Colors.green;
    Color iconColor = isError ? Colors.red : Colors.green;
    IconData iconData = isError ? Icons.error : Icons.check_circle;

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: borderColor, width: 2), // Border color changes
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
          Icon(iconData, color: iconColor, size: 24), // Dynamic icon
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.center, // Corrected placement
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM, // Change position
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

  static void showCustomDialog(
    BuildContext context, {
    required String title,
    String? content,
    void Function()? onCancel,
    void Function()? onSubmit,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  title,
                  style: CommonStyles.txStyF15CbFF5.copyWith(
                    fontSize: 22,
                    color: CommonStyles.colorBlue,
                  ),
                ),
              ),
              const Divider(
                color: CommonStyles.colorBlue,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Text(
                  '$content',
                  style: CommonStyles.txStyF15CbFF5.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomButton(
                        btnText: 'No',
                        backgroundColor: CommonStyles.colorBlue,
                        onPressed: onCancel,
                        btnStyle:
                            const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: CustomButton(
                        btnText: 'Yes',
                        backgroundColor: CommonStyles.colorBlue,
                        onPressed: onSubmit,
                        btnStyle:
                            const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
