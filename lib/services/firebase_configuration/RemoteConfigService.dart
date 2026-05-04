import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

import '../../data/prompt_model.dart';
import '../google_ads_material/ads_variable.dart';
import 'firebase_options.dart';
class RemoteConfigService extends GetxService {
  // 1. CHANGE: Remove the "= FirebaseRemoteConfig.instance" from here.
  // We use 'late' so it only initializes AFTER Firebase.initializeApp() runs.
  late FirebaseRemoteConfig _remoteConfig;
  Future<RemoteConfigService> init() async {
    try {
      // 1. Initialize Firebase
      await Firebase.initializeApp();

      // 2. CHECK: Print status
      if (Firebase.apps.isNotEmpty) {
        debugPrint("✅ Firebase Initialized Successfully: ${Firebase.app().name}");
      } else {
        debugPrint("❌ Firebase failed to initialize (Apps list is empty).");
      }

      // 3. Initialize Remote Config
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(hours: 1),
      ));

      await _remoteConfig.fetchAndActivate();
      _setupCrashlytics();

    } catch (e) {
      debugPrint("❌ Firebase Initialization Error: $e");
    }

    return this;
  }
  List<Prompt> getPrompts() {
    String rawJson = _remoteConfig.getString('promptli_list');
    if (rawJson.isEmpty) return [];
    try {
      List<dynamic> decodedList = jsonDecode(rawJson);
      return decodedList.map((e) => Prompt.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error decoding prompts: $e");
      return [];
    }
  }

  void applyAdsSettings() {
    final String adsJson = _remoteConfig.getString("promptly");
    if (adsJson.isEmpty) return;

    try {
      final Map<String, dynamic> map = jsonDecode(adsJson);
      AdsVariable.mishy_ai_token = map["mishy_ai_token"] ?? "1";
      AdsVariable.facebookId = map["facebookId"]?.toString() ?? "11";
      // ... your other mapping
    } catch (e) {
      debugPrint("Ads Parsing Error: $e");
    }
  }

  void _setupCrashlytics() {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
}