import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

import '../../data/prompt_model.dart';
import '../google_ads_material/ads_variable.dart';

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
        debugPrint(
          "✅ Firebase Initialized Successfully: ${Firebase.app().name}",
        );
      } else {
        debugPrint("❌ Firebase failed to initialize (Apps list is empty).");
      }

      // 3. Initialize Remote Config
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );

      await _remoteConfig.fetchAndActivate();
      _setupCrashlytics();
    } catch (e) {
      debugPrint("❌ Firebase Initialization Error: $e");
    }

    return this;
  }

  // List<Prompt> getPrompts() {
  //   String rawJson = _remoteConfig.getString('promptli_list');
  //   if (rawJson.isEmpty) return [];
  //   try {
  //     List<dynamic> decodedList = jsonDecode(rawJson);
  //     return decodedList.map((e) => Prompt.fromJson(e)).toList();
  //   } catch (e) {
  //     debugPrint("Error decoding prompts: $e");
  //     return [];
  //   }
  // }

  void applyAdsSettings() {
    final String adsJson = _remoteConfig.getString("promptly");
    if (adsJson.isEmpty) return;

    try {
      final Map<String, dynamic> map = jsonDecode(adsJson);
      AdsVariable.fullscreen_preload_high_adsId = _readString(
        map,
        "fullscreen_preload_high_adsId",
        AdsVariable.fullscreen_preload_high_adsId,
      );
      AdsVariable.fullscreen_preload_normal_adsId = _readString(
        map,
        "fullscreen_preload_normal_adsId",
        AdsVariable.fullscreen_preload_normal_adsId,
      );
      AdsVariable.fullscreen_splash_adsId_high = _readString(
        map,
        "fullscreen_splash_adsId_high",
        AdsVariable.fullscreen_splash_adsId_high,
      );
      AdsVariable.fullscreen_splash_adsId_normal = _readString(
        map,
        "fullscreen_splash_adsId_normal",
        AdsVariable.fullscreen_splash_adsId_normal,
      );
      AdsVariable.fullscreen_in_app_adsId = _readString(
        map,
        "fullscreen_in_app_adsId",
        AdsVariable.fullscreen_in_app_adsId,
      );
      AdsVariable.fullscreen_credit_adsId = _readString(
        map,
        "fullscreen_credit_adsId",
        AdsVariable.fullscreen_credit_adsId,
      );
      AdsVariable.fullscreen_home = _readString(
        map,
        "fullscreen_home",
        AdsVariable.fullscreen_home,
      );
      AdsVariable.rewarded_generate_ad_id = _readString(
        map,
        "rewarded_generate_ad_id",
        AdsVariable.rewarded_generate_ad_id,
      );
      AdsVariable.appopen = _readString(
        map,
        "appopen",
        AdsVariable.appopen,
      );
      AdsVariable.native_intro_big = _readString(
        map,
        "native_intro_big",
        AdsVariable.native_intro_big,
      );
      AdsVariable.native_home_small = _readString(
        map,
        "native_home_small",
        AdsVariable.native_home_small,
      );
      AdsVariable.home_screen_ad_continue_ads_online = _readString(
        map,
        "home_screen_ad_continue_ads_online",
        AdsVariable.home_screen_ad_continue_ads_online,
      );
      AdsVariable.in_app_screen_ad_continue_ads_online = _readString(
        map,
        "in_app_screen_ad_continue_ads_online",
        AdsVariable.in_app_screen_ad_continue_ads_online,
      );
      AdsVariable.credit_screen_ad_continue_ads_online = _readString(
        map,
        "credit_screen_ad_continue_ads_online",
        AdsVariable.credit_screen_ad_continue_ads_online,
      );
      AdsVariable.gate_interstitial_ad_id = _readString(
        map,
        "gate_interstitial_ad_id",
        AdsVariable.gate_interstitial_ad_id,
      );
      AdsVariable.free_uses_limit = _readInt(
        map,
        "free_uses_limit",
        AdsVariable.free_uses_limit,
      );
      AdsVariable.ads_enabled = _readBool(
        map,
        "ads_enabled",
        AdsVariable.ads_enabled,
      );

      if (AdsVariable.fullscreen_home == '11' &&
          AdsVariable.fullscreen_preload_high_adsId != '11') {
        AdsVariable.fullscreen_home = AdsVariable.fullscreen_preload_high_adsId;
      }

      // PRINT VALUES
      debugPrint(
        "fullscreen_preload_high_adsId: ${AdsVariable.fullscreen_preload_high_adsId}",
      );
      debugPrint(
        "fullscreen_preload_normal_adsId: ${AdsVariable.fullscreen_preload_normal_adsId}",
      );
      debugPrint(
        "fullscreen_splash_adsId_high: ${AdsVariable.fullscreen_splash_adsId_high}",
      );
      debugPrint(
        "fullscreen_splash_adsId_normal: ${AdsVariable.fullscreen_splash_adsId_normal}",
      );
      debugPrint(
        "fullscreen_in_app_adsId: ${AdsVariable.fullscreen_in_app_adsId}",
      );
      debugPrint("fullscreen_home: ${AdsVariable.fullscreen_home}");
      debugPrint(
        "rewarded_generate_ad_id: ${AdsVariable.rewarded_generate_ad_id}",
      );
      // ─────────────────────────────────────────────────────────────────────
    } catch (e) {
      debugPrint("Ads Parsing Error: $e");
    }
  }

  String _readString(
    Map<String, dynamic> map,
    String key,
    String fallback,
  ) {
    final value = map[key];
    if (value == null) return fallback;

    final parsed = value.toString().trim();
    return parsed.isEmpty ? fallback : parsed;
  }

  int _readInt(
    Map<String, dynamic> map,
    String key,
    int fallback,
  ) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  bool _readBool(
    Map<String, dynamic> map,
    String key,
    bool fallback,
  ) {
    final value = map[key];
    if (value is bool) return value;
    final normalized = value?.toString().trim().toLowerCase();

    switch (normalized) {
      case '1':
      case 'true':
      case 'yes':
        return true;
      case '0':
      case 'false':
      case 'no':
        return false;
      default:
        return fallback;
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
