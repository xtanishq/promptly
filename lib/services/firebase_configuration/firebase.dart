import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:promptly/controllers/HomeController.dart';
import '../../data/prompt_model.dart';
import '../google_ads_material/ads_variable.dart';
import 'firebase_options.dart';
//
// Future<bool> firebaseConfigure() async {
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     final remoteConfig = FirebaseRemoteConfig.instance;
//     await remoteConfig.setConfigSettings(
//       RemoteConfigSettings(
//         fetchTimeout: const Duration(minutes: 1),
//         minimumFetchInterval: const Duration(minutes: 5),
//       ),
//     );
//     await remoteConfig.fetchAndActivate();
//
//     final String pixStyleEffectString = remoteConfig.getString("promptly");
//
//     String rawJson = remoteConfig.getString('promptli_list');
//
//     if (rawJson.isNotEmpty) {
//       List<dynamic> decodedList = jsonDecode(rawJson);
// HomeController controller=Get.find();
//       // 3. Map to your Model
//       var fetchedPrompts = decodedList.map((e) => Prompt.fromJson(e)).toList();
//
//       // 4. Update Observables
//       controller.prompts.assignAll(fetchedPrompts);
//       controller.filteredPrompts.assignAll(fetchedPrompts);
//
//       // 5. Update Categories dynamically
//       final cats = fetchedPrompts.map((e) => e.category).toSet().toList();
//       controller.categories.assignAll(['All', ...cats]);
//     }
//
//
//     print(pixStyleEffectString+"ttttttt");
//     if (pixStyleEffectString.isNotEmpty) {
//       try {
//         final Map<String, dynamic> mapValues = jsonDecode(pixStyleEffectString);
//
//
//         AdsVariable.mishy_ai_token = mapValues["mishy_ai_token"] ?? "1";
//         AdsVariable.showsubmitrating = mapValues["showsubmitrating"] ?? "1";
//
//         AdsVariable.facebookId = mapValues["facebookId"]?.toString() ?? "11";
//         AdsVariable.facebookToken = mapValues["facebookToken"]?.toString() ?? "11";
//
//         AdsVariable.in_app_screen_ad_continue_ads_online = mapValues["in_app_screen_ad_continue_ads_online"] ?? "0";
//         AdsVariable.home_screen_ad_continue_ads_online = mapValues["home_screen_ad_continue_ads_online"] ?? "0";
//         AdsVariable.fullscreen_on_in_splash_screen = mapValues["fullscreen_on_in_splash_screen"] ?? "0";
//         //
//         AdsVariable.fullscreen_preload_high_adsId = mapValues["fullscreen_preload_high_adsId"] ?? "";
//         AdsVariable.fullscreen_preload_normal_adsId = mapValues["fullscreen_preload_normal_adsId"] ?? "";
//         AdsVariable.fullscreen_splash_adsId_high = mapValues["fullscreen_splash_adsId_high"] ?? "";
//         AdsVariable.fullscreen_splash_adsId_normal = mapValues["fullscreen_splash_adsId_normal"] ?? "";
//         AdsVariable.fullscreen_in_app_adsId = mapValues["fullscreen_in_app_adsId"] ?? "";
//         AdsVariable.fullscreen_home = mapValues["fullscreen_home"] ?? "";
//         //
//         // AdsVariable.native_intro_big = mapValues["native_intro_big"] ?? "";
//         AdsVariable.native_home_small = mapValues["native_home_small"] ?? "";
//         AdsVariable.appopen = mapValues["appopen"] ?? "";
//         //
//         AdsVariable.nativeBGColor = mapValues["nativeBGColor"] ?? "222222";
//
//
//
//         print("Loaded Home Asset: ${mapValues["cut_video_credit"]}");
//
//
//       } catch (e) {
//         print("Error decoding pix_style_effect: $e");
//         print("Raw pix_style_effect string: $pixStyleEffectString");
//       }
//     } else {
//       print("pix_style_effect string from Remote Config is empty.");
//     }
//
//
//
//     setupFbAdsId();
//     FlutterError.onError = (errorDetails) {
//       FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
//     };
//     PlatformDispatcher.instance.onError = (error, stack) {
//       FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
//       return true;
//     };
//     return true;
//   } on FirebaseException catch (e) {
//     print('jasoda Firebase Exception: $e');
//     return false;
//   } on Exception catch (e) {
//     print('jasoda Exception during Firebase Config: $e');
//     return false;
//   }
// }
//
//
// void setupFbAdsId() {
//   const platformMethodChannel = MethodChannel('nativeChannel');
//   // platformMethodChannel.invokeMethod('setToast', {
//   //   'isPurchase': AdsVariable.isPurchase.toString(),
//   //   'facebookId': AdsVariable.facebookId,
//   //   'facebookToken': AdsVariable.facebookToken,
//   //   'nativeBGColor': AdsVariable.nativeBGColor,
//   //   'btnBgColor_start': AdsVariable.btnBgColor_start,
//   //   'btnBgColor_end': AdsVariable.btnBgColor_end,
//   //   'btnTextColor': AdsVariable.btnTextColor,
//   //   'headerTextColor': AdsVariable.headerTextColor,
//   //   'bodyTextColor': AdsVariable.bodyTextColor,
//   // });
// }