// ignore_for_file: file_names

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }
}
