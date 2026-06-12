import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:seaart_ai/ads/AdsVariable.dart';
import 'package:seaart_ai/controller/HomeController.dart';
import 'package:seaart_ai/in_app_purchase/constant.dart';
import 'package:seaart_ai/in_app_purchase/creditManager.dart';
import 'package:seaart_ai/in_app_purchase/initPlatformState.dart';
import 'package:seaart_ai/in_app_purchase/upsell_controller.dart';
import 'package:seaart_ai/screen/HomeScreen.dart';
import 'package:seaart_ai/screen/common_screen/constant.dart';
import 'package:seaart_ai/service/firebase_analytics.dart';
import 'package:seaart_ai/service/possessing_dialog.dart';
import 'package:seaart_ai/service/sharedPreferencesService.dart';

class CreditController extends GetxController {
  final bool item;
  Rx<Offerings?> offerings = Rx<Offerings?>(null);
  RxBool isClose = false.obs;
  RxMap<String, Package> availablePackages = <String, Package>{}.obs;
  Rx<Package?> selectedPackage = Rx<Package?>(null);
  RxBool week = true.obs;
  RxBool month = false.obs;
  RxBool lifetime = false.obs;

  CreditController(this.item);

  @override
  void onInit() {
    super.onInit();
    if (item) {
      FirebaseAnalyticsService.logEvent(
          eventName: 'trendify_ai_vide_generator_credit_screen_from_feature');
    } else {
      FirebaseAnalyticsService.logEvent(
          eventName: 'trendify_ai_vide_generator_credit_screen_from_splash');
    }
    fetchData();
    Future.delayed(const Duration(seconds: 3), () {
      isClose.value = true;
    });
  }

  Future<void> fetchData() async {
    try {
      final offeringsResult = await Purchases.getOfferings();
      offerings.value = offeringsResult;
      availablePackages.assignAll({
        for (var package in offeringsResult.current?.availablePackages ?? [])
          package.identifier: package,
      });

      if (availablePackages.length >= 2) {
        selectedPackage.value = availablePackages.entries.elementAt(2).value;
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void backToHome(BuildContext context) async {
    if (item) {
      Get.back();
    } else {
      final homeController = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>()
          : Get.put(HomeController());

      homeController.selectedTab.value = 0;
      Get.offAll(HomeScreen(), transition: Transition.fadeIn);
    }
  }

  String? getDiscountLabel(Package package) {
    if (package.storeProduct.identifier == AdsVariable.firstCreditIdentifier) {
      return null;
    }

    // Map product identifiers to credits
    final Map<String, int> creditsMap = AdsVariable.creditPlans;

    final baseCredits = AdsVariable.creditPlans.values.first;
    final basePrice =
        availablePackages[AdsVariable.firstCreditIdentifier]
            ?.storeProduct
            .price ??
        1.0; // fallback to avoid divide by 0

    final basePricePerCredit = basePrice / baseCredits;

    final currentCredits = creditsMap[package.storeProduct.identifier] ?? 0;
    final currentPrice = package.storeProduct.price;
    if (currentCredits == 0) return null;

    final currentPricePerCredit = currentPrice / currentCredits;

    // Calculate percentage discount compared to base plan
    final discount = ((1 - (currentPricePerCredit / basePricePerCredit)) * 100)
        .round();

    return discount > 0 ? "Save $discount%" : null;
  }

  Future<void> storeCredit() async {
    var credit = await SharedPreferencesService.getCreditValue('Credit');
    credit += AdsVariable
        .creditPlans[selectedPackage.value?.storeProduct.identifier]!;
    SharedPreferencesService.setCreditValue(credit, 'Credit');
    CreditsManager().saveUserCredits(credit);
    AdsVariable.credits.value = credit;
  }

  Future<void> buyCredits(BuildContext context) async {
    if (AdsVariable.isPurchase.value ||
        AdsVariable.without_subscription == '1' ||
        AdsVariable.purchaseScreenIndex == '1') {
      ProgressDialog.show('');
      try {
        final customerInfo = await Purchases.purchasePackage(
          selectedPackage.value!,
        );
        appData.entitlementIsActive = customerInfo
            .customerInfo
            .entitlements
            .all[entitlementKey]!
            .isActive;
        CheckPurchasesStatus.initPlatformState().then((value) {
          if (value) {
            showToast(msg: 'Your plan subscribe successfully');
            storeCredit();
            if (item) {
              Get.back();
            } else {
              Get.offAll(const HomeScreen(), transition: Transition.fadeIn);
            }
          } else {
            showToast(msg: 'Failed');
          }
        });
      } on PlatformException catch (e) {
        final errorCode = PurchasesErrorHelper.getErrorCode(e);
        if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
          if (kDebugMode) {
            print('User cancelled');
          }
        } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
          if (kDebugMode) {
            print('User not allowed to purchase');
          }
        } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
          if (kDebugMode) {
            print('Payment is pending');
          }
        }
      } finally {
        ProgressDialog.dismiss();
      }
    } else {
      showToast(msg: 'Please Subscribe First');
    }
  }
}
