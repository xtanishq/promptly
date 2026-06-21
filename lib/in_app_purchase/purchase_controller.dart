// ignore_for_file: unused_import

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:promptly/in_app_purchase/constant.dart';
import 'package:promptly/services/google_ads_material/ads_variable.dart';

/// Singleton GetX controller for RevenueCat subscription + credit state.
/// Registered permanently in main() so it lives for the entire app lifecycle.
class PurchaseController extends GetxController {

  // ── Reactive state ─────────────────────────────────────────────────────────

  /// true when RevenueCat confirms an active entitlement.
  RxBool isSubscribed = false.obs;

  /// Current credit balance — shared with AdsVariable.credits.
  RxInt credits = AdsVariable.credits;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    ever(AdsVariable.isPurchase, (val) => isSubscribed.value = val);
    ever(credits, (val) => AdsVariable.credits.value = val);

    // Listen to RevenueCat real-time updates — fires whenever subscription changes
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      final active =
          customerInfo.entitlements.all[entitlementKey]?.isActive ?? false;
      debugPrint('[IAP] CustomerInfo updated — active: $active');
      AdsVariable.isPurchase.value = active;
      isSubscribed.value = active;
    });
  }

  // ── Startup hydration ──────────────────────────────────────────────────────

  /// Called once at startup (main.dart) to restore subscription + credit state.
  /// Forces a fresh fetch from RevenueCat's servers (bypassing any stale local
  /// cache) so a recently-activated entitlement is always picked up.
  Future<void> checkPurchasesStatus() async {
    try {
      await Purchases.invalidateCustomerInfoCache();
      final customerInfo = await Purchases.getCustomerInfo();
      final active =
          customerInfo.entitlements.all[entitlementKey]?.isActive ?? false;
      AdsVariable.isPurchase.value = active;
      isSubscribed.value = active;

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt('promptly_credits') ?? 0;
      credits.value = saved;
      AdsVariable.credits.value = saved;
    } catch (e, st) {
      debugPrint('[PurchaseController] checkPurchasesStatus error: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'checkPurchasesStatus failed at startup',
        fatal: false,
      );
    }
  }

  // ── Subscription purchase ──────────────────────────────────────────────────

  /// Buy a subscription package.
  /// Monthly → 20 credits | Yearly → 40 credits
  Future<bool> buySubscription({
    required Package package,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      // Step 1: Trigger purchase
      await Purchases.purchase(PurchaseParams.package(package));

      // Step 2: Fetch FRESH CustomerInfo and trust it — this is the same
      // check used at startup (checkPurchasesStatus), so granting access
      // here without it being true just gets reverted on next app launch.
      await Purchases.invalidateCustomerInfoCache();
      final freshInfo = await Purchases.getCustomerInfo();
      final isEntitlementActive =
          freshInfo.entitlements.all[entitlementKey]?.isActive ?? false;
      debugPrint('[IAP] Entitlement active after purchase: $isEntitlementActive');

      if (!isEntitlementActive) {
        // The store call succeeded but RevenueCat doesn't show an active
        // entitlement — likely an entitlement/product config mismatch.
        // Surface it instead of silently granting fake access.
        FirebaseCrashlytics.instance.recordError(
          'Purchase succeeded but entitlement "$entitlementKey" is not active',
          StackTrace.current,
          reason: 'buySubscription entitlement mismatch',
          fatal: false,
        );
        onError('Purchase completed but could not be verified. Please contact support or try Restore Purchases.');
        return false;
      }

      AdsVariable.isPurchase.value = true;
      isSubscribed.value = true;

      // Credits based on plan type
      final isYearly = package.packageType == PackageType.annual;
      final bonus = isYearly ? yearlyCredits : monthlyCredits;
      await _addCredits(bonus);

      onSuccess();
      return true;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code != PurchasesErrorCode.purchaseCancelledError) {
        onError(e.message ?? 'Purchase failed');
      }
      return false;
    }
  }

  // ── Credit pack purchase ───────────────────────────────────────────────────

  /// Buy a credit pack (one-time purchase).
  /// creditPack300 → 50 credits | creditPack600 → 100 credits
  Future<bool> buyCreditPack({
    required Package package,
    required int creditsToAdd,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await Purchases.purchase(PurchaseParams.package(package));
      await _addCredits(creditsToAdd);
      onSuccess();
      return true;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code != PurchasesErrorCode.purchaseCancelledError) {
        onError(e.message ?? 'Credit purchase failed');
      }
      return false;
    }
  }

  // ── Credit operations ──────────────────────────────────────────────────────

  /// Manually add credits (also used by debug simulate button).
  Future<void> addCredits(int amount) => _addCredits(amount);

  /// Deduct [amount] credits. Returns false if not enough credits.
  Future<bool> cutCredit(int amount) async {
    if (credits.value < amount) return false;
    credits.value -= amount;
    AdsVariable.credits.value = credits.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('promptly_credits', credits.value);
    return true;
  }

  /// Whether user has enough credits for an action.
  bool hasEnoughCredits(int needed) => credits.value >= needed;

  // ── Restore purchases ──────────────────────────────────────────────────────

  Future<void> restorePurchases({
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final result = await Purchases.restorePurchases();
      final active =
          result.entitlements.all[entitlementKey]?.isActive ?? false;
      if (active) {
        AdsVariable.isPurchase.value = true;
        isSubscribed.value = true;
        onSuccess();
      } else {
        onError('No active subscription found');
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _addCredits(int amount) async {
    credits.value += amount;
    AdsVariable.credits.value = credits.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('promptly_credits', credits.value);
  }
}
