import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'iap_config.dart';

/// Thin, reusable wrapper around RevenueCat (`purchases_flutter`).
/// Depends only on [IapConfig] — drop this file + [IapConfig] into any app.
class PurchaseRepository {
  static const _kCreditsKey = 'promptly_credits';

  // ── Setup ──────────────────────────────────────────────────────────────────

  /// Configure RevenueCat for the current platform. Call once at startup.
  Future<void> configure({String? appUserId}) async {
    PurchasesConfiguration? config;
    if (Platform.isAndroid) {
      config = PurchasesConfiguration(IapConfig.androidApiKey);
    } else if (Platform.isIOS || Platform.isMacOS) {
      config = PurchasesConfiguration(IapConfig.appleApiKey);
    } else {
      return; // unsupported platform → IAP silently disabled
    }
    config.appUserID = appUserId;
    // TEMP DIAGNOSTIC: verbose RevenueCat logs in ALL builds. Revert to
    // `if (kDebugMode)` once the entitlement issue is resolved.
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(config);
  }

  // ── Entitlement ────────────────────────────────────────────────────────────

  /// Whether the configured entitlement is currently active.
  /// [forceRefresh] bypasses the local cache (used at startup / post-purchase).
  Future<bool> isEntitlementActive({bool forceRefresh = false}) async {
    if (forceRefresh) await Purchases.invalidateCustomerInfoCache();
    final info = await Purchases.getCustomerInfo();
    _logEntitlements('getCustomerInfo', info);
    return _active(info);
  }

  /// Emits the entitlement-active flag whenever RevenueCat reports a change
  /// (renewal, expiry, refund, cross-device purchase).
  Stream<bool> entitlementChanges() {
    final controller = StreamController<bool>.broadcast();
    Purchases.addCustomerInfoUpdateListener(
      (info) => controller.add(_active(info)),
    );
    return controller.stream;
  }

  bool _active(CustomerInfo info) =>
      info.entitlements.all[IapConfig.entitlementKey]?.isActive ?? false;

  // ── Purchases ──────────────────────────────────────────────────────────────

  Future<Offerings> getOfferings() => Purchases.getOfferings();

  /// Buys a subscription package and returns whether the entitlement is active
  /// afterwards. Reads the CustomerInfo returned by the purchase directly
  /// (authoritative at purchase time), then falls back to a fresh fetch to
  /// cover any server propagation lag.
  Future<bool> purchaseSubscription(Package package) async {
    debugPrint('[IAP] purchasing package "${package.identifier}" '
        '→ product "${package.storeProduct.identifier}"');
    final result = await Purchases.purchase(PurchaseParams.package(package));
    _logEntitlements('afterPurchase', result.customerInfo);
    final active = _active(result.customerInfo);
    return active || await isEntitlementActive(forceRefresh: true);
  }

  /// TEMP DIAGNOSTIC — prints exactly what RevenueCat returns so we can see the
  /// real entitlement identifier (vs IapConfig.entitlementKey) and whether the
  /// integration granted anything at all.
  void _logEntitlements(String where, CustomerInfo info) {
    debugPrint('[IAP] $where — all=${info.entitlements.all.keys.toList()} '
        'active=${info.entitlements.active.keys.toList()} '
        'looking-for="${IapConfig.entitlementKey}" '
        'activeSubs=${info.activeSubscriptions.toList()}');
  }

  /// Buys a one-time, non-subscription credit pack by product id.
  Future<void> purchaseCreditProduct(String productId) async {
    final products = await Purchases.getProducts(
      [productId],
      productCategory: ProductCategory.nonSubscription,
    );
    if (products.isEmpty) {
      throw const PurchaseProductNotFound();
    }
    await Purchases.purchaseStoreProduct(products.first);
  }

  /// Restores purchases; returns whether the entitlement is active afterwards.
  Future<bool> restore() async {
    final info = await Purchases.restorePurchases();
    return _active(info);
  }

  // ── Credit persistence ─────────────────────────────────────────────────────

  Future<int> loadCredits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kCreditsKey) ?? 0;
  }

  Future<void> saveCredits(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCreditsKey, value);
  }
}

/// Thrown when a credit-pack product id isn't found in the store.
class PurchaseProductNotFound implements Exception {
  const PurchaseProductNotFound();
  @override
  String toString() => 'Product not found in store.';
}
