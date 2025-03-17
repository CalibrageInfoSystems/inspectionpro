import 'package:connectivity_plus/connectivity_plus.dart';

class CommonUtils {
  static Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult[0] == ConnectivityResult.mobile ||
        connectivityResult[0] == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}
