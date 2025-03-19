import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

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
