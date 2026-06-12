import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'constant.dart';

class StoreConfig {
  final Store store;
  final String apiKey;
  static StoreConfig? _instance;

  factory StoreConfig({required Store store, required String apiKey}) {
    _instance ??= StoreConfig._internal(store, apiKey);
    return _instance!;
  }

  StoreConfig._internal(this.store, this.apiKey);

  static StoreConfig get instance {
    return _instance!;
  }

  static bool isForAppleStore() =>
      instance.store == Store.appStore || instance.store == Store.macAppStore;

  static bool isForGooglePlay() => instance.store == Store.playStore;

  static bool isForAmazonAppstore() => instance.store == Store.amazon;
}

/// Initializes RevenueCat with the correct API key for the current platform.
/// Called once in main() before the app renders.
Future<void> configureStore({String? appUserId}) async {
  late PurchasesConfiguration configuration;

  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration(googleApiKey);
  } else if (Platform.isIOS || Platform.isMacOS) {
    configuration = PurchasesConfiguration(appleApiKey);
  } else {
    // Unsupported platform — skip IAP init silently
    return;
  }

  configuration.appUserID = appUserId;

  await Purchases.configure(configuration);
  if (kDebugMode) {
    await Purchases.setLogLevel(LogLevel.debug);
  }
}
