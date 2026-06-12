import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:seaart_ai/ads/AdsVariable.dart';
import 'package:seaart_ai/controller/HomeController.dart';
import 'package:seaart_ai/in_app_purchase/constant.dart';
import 'package:seaart_ai/in_app_purchase/creditManager.dart';
import 'package:seaart_ai/in_app_purchase/initPlatformState.dart';
import 'package:seaart_ai/screen/HomeScreen.dart';
import 'package:seaart_ai/screen/common_screen/constant.dart';
import 'package:seaart_ai/service/firebase_analytics.dart';
import 'package:seaart_ai/service/possessing_dialog.dart';
import 'package:seaart_ai/service/sharedPreferencesService.dart';

class UpsellController extends GetxController {
  final bool item;
  Rx<Offerings?> offerings = Rx<Offerings?>(null);
  RxBool isClose = false.obs;
  RxMap<String, Package> availablePackages = <String, Package>{}.obs;
  Rx<Package?> selectedPackage = Rx<Package?>(null);
  RxBool week = true.obs;
  RxBool month = false.obs;
  RxBool lifetime = false.obs;
  double originalWeekPrice = 0;

  UpsellController(this.item);

  @override
  void onInit() {
    super.onInit();
    if (item) {
      FirebaseAnalyticsService.logEvent(
          eventName: 'trendify_ai_vide_generator_premium_screen_from_feature');
    } else {
      FirebaseAnalyticsService.logEvent(
          eventName: 'trendify_ai_vide_generator_premium_screen_from_splash');
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
          package.identifier: package
      });

      if (availablePackages.length >= 2) {
        selectedPackage.value = availablePackages.entries.elementAt(0).value;
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
      Get.offAll(const HomeScreen(), transition: Transition.fadeIn);
    }
  }

  Future<void> storeCredit() async {
    int credit = await SharedPreferencesService.getCreditValue('Credit');
    // credit += (selectedPackage.value?.storeProduct.identifier == planWeek)
    //     ? AdsVariable.weekCredit
    //     : AdsVariable.yearCredit;
    credit += AdsVariable.weekCredit;
    SharedPreferencesService.setCreditValue(credit, 'Credit');
    CreditsManager().saveUserCredits(credit);
    AdsVariable.credits.value = credit;
  }

  Future<void> buySubscription(BuildContext context) async {
    ProgressDialog.show('');
    try {
      final customerInfo =
          await Purchases.purchasePackage(selectedPackage.value!);
      appData.entitlementIsActive =
          customerInfo.customerInfo.entitlements.all[entitlementKey]!.isActive;
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
      if (kDebugMode) {
        print('object++$e');
      }
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
  }
}

class AppData {
  static final AppData _appData = AppData._internal();

  bool entitlementIsActive = false;
  String appUserID = '';

  factory AppData() {
    return _appData;
  }

  AppData._internal();
}

final appData = AppData();
