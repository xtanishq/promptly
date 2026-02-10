// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// import '../services/firebase_configuration/firebase.dart';
//
// class NetworkController extends GetxController {
//   var connectivityResults = <ConnectivityResult>[].obs;
//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription<List<ConnectivityResult>> _subscription;
//   bool isCalled = true;
//
//
//   @override
//   void onInit() {
//     super.onInit();
//     _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
//       connectivityResults.value = result;
//       if (result.isEmpty || result.contains(ConnectivityResult.none)) {
//         _showNoInternetHUD();
//       } else {
//         if (kDebugMode) {
//           print("+++++++++++++NetworkController++++++++++++++++++++++++++++");
//         }
//         initializedController();
//         if (Get.isDialogOpen == true) {
//           SVProgressHUD.dismiss();
//         }
//       }
//     });
//
//     _checkConnectivity();
//   }
//
//   Future<void> initializedController() async {
//     // await firebaseConfigure();
//     // Get.put(HomeTemplateController(),permanent: true);
//     isCalled = false;
//   }
//
//   Future<void> _checkConnectivity() async {
//     try {
//       final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
//       connectivityResults.value = result;
//       if (result.isEmpty || result.contains(ConnectivityResult.none)) {
//         _showNoInternetHUD();
//       }
//     } on PlatformException catch (e) {
//       if (kDebugMode) {
//         print('Failed to get connectivity: $e');
//       }
//     }
//   }
//
//   void _showNoInternetHUD() {
//     SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark);
//     SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient);
//     SVProgressHUD.show(status: 'No Internet Connection\nPlease check your connection.');
//     Future.delayed(const Duration(seconds: 5), () {
//       SVProgressHUD.dismiss();
//     });
//   }
//
//   @override
//   void onClose() {
//     _subscription.cancel();
//     super.onClose();
//   }
// }
