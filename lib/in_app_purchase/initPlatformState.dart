import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:seaart_ai/ads/AdsVariable.dart';
import 'package:seaart_ai/in_app_purchase/app.dart';
import 'package:seaart_ai/in_app_purchase/app_credit.dart';
import 'package:seaart_ai/in_app_purchase/constant.dart';
import 'package:seaart_ai/service/checkConnectivity.dart';
import 'package:seaart_ai/screen/common_screen/constant.dart';
import 'package:seaart_ai/service/dialog.dart';
import 'package:seaart_ai/service/possessing_dialog.dart';
import 'package:seaart_ai/service/press_unpress.dart';
import 'package:seaart_ai/service/sharedPreferencesService.dart';

class CheckPurchasesStatus {
  static Future<bool> initPlatformState() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all[entitlementKey] != null &&
          customerInfo.entitlements.all[entitlementKey]!.isActive == true) {
        if (customerInfo.allPurchasedProductIdentifiers.contains(planWeek)) {
          AdsVariable.isPurchase.value = true;

          return true;
        } else {
          return (AdsVariable.without_subscription == '1' ||
              AdsVariable.purchaseScreenIndex == '1');
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static void checkPurchaseCredit(
      {required VoidCallback onTap,
      required int cutAddCredit,
      required String buyPurchaseText,
      required String buyCreditText}) {
    ConnectivityService.checkConnectivity().then((value) {
      if (value) {
        initPlatformState().then((value) async {
          if (value ||
              AdsVariable.without_subscription == '1' ||
              AdsVariable.purchaseScreenIndex == '1') {
            SharedPreferencesService.getCreditValue('Credit').then((value) {
              if (value >= cutAddCredit) {
                onTap();
              } else {
                AdsVariable.testerIsPurchase.value = false;
                Get.to(const CreditUpsellScreen(item: true, isTester: true),
                        transition: Transition.fadeIn)
                    ?.then(
                  (value) {
                    goWebView(onTap, cutAddCredit);
                  },
                );
                // showBuyCreditDialog(
                //   onTap: onTap,
                //   cutAddCredit: cutAddCredit,
                //   bodyText: buyCreditText,
                // );
              }
            });
          } else {
            AdsVariable.testerIsPurchase.value = false;
            Get.to(const UpsellScreen(item: true, isTester: true),
                    transition: Transition.fadeIn)
                ?.then(
              (value) {
                goWebView(onTap, cutAddCredit);
              },
            );
            // showBuyPurchaseDialog(
            //   onTap: onTap,
            //   cutAddCredit: cutAddCredit,
            //   bodyText: buyPurchaseText,
            // );
          }
        });
      } else {
        DialogService.showCheckConnectivity(Get.context!);
      }
    });
  }

  static void showBuyPurchaseDialog(
      {required VoidCallback onTap,
      required int cutAddCredit,
      required String bodyText}) async {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: 1080.w,
              height: 650.w,
              decoration: BoxDecoration(
                color: Color(0xff211E26),
                borderRadius: BorderRadius.circular(60.w),
                border: Border.all(color: Color(0xff404040)),
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  30.verticalSpace,
                  Row(
                    children: [
                      80.horizontalSpace,
                      Expanded(
                        child: Text(
                          'Subscribe Plan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 55.sp,
                            fontFamily: fontFamilySemiBold,
                          ),
                        ),
                      ),
                      PressUnpress(
                        width: 85.w,
                        height: 85.w,
                        onTap: () {
                          Get.back();
                        },
                        imageAssetPress:
                            'assets/premium_screen/close_press.png',
                        imageAssetUnPress:
                            'assets/premium_screen/close_unpress.png',
                      ).marginOnly(bottom: 50.h),
                    ],
                  ),
                  Text(
                    bodyText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff6B6B6B),
                      fontSize: 48.w,
                      decoration: TextDecoration.none,
                      fontFamily: fontFamilyMedium,
                    ),
                  ),
                  60.verticalSpace,
                  OnlyPressUnpress(
                    onTap: () {
                      Get.back();
                      Get.to(const UpsellScreen(item: true),
                              transition: Transition.fadeIn)
                          ?.then(
                        (value) {
                          goWebView(onTap, cutAddCredit);
                        },
                      );
                    },
                    child: Container(
                      width: 560.w,
                      height: 130.h,
                      decoration: BoxDecoration(
                        gradient: unPressGradiant,
                        borderRadius: BorderRadius.circular(30.w),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Subscribe Now',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50.sp,
                          fontFamily: fontFamilySemiBold,
                        ),
                      ),
                    ),
                  ),
                  // PressUnpress(
                  //   width: 560.w,
                  //   height: 130.h,
                  //   onTap: () {
                  //     Get.back();
                  //     Get.to(const UpsellScreen(item: true),
                  //             transition: Transition.fadeIn)
                  //         ?.then(
                  //       (value) {
                  //         goWebView(onTap, cutAddCredit);
                  //       },
                  //     );
                  //   },
                  //   pressGradient: pressGradiant,
                  //   unPressGradient: unPressGradiant,
                  //   alignment: Alignment.center,
                  //   child: Text(
                  //     'Subscribe Now',
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //       color: Colors.white,
                  //       fontSize: 55.sp,
                  //       fontFamily: fontFamilySemiBold,
                  //     ),
                  //   ),
                  // ),
                  50.verticalSpace,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void showBuyCreditDialog(
      {required VoidCallback onTap,
      required int cutAddCredit,
      required String bodyText}) {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: 1080.w,
              height: 650.w,
              decoration: BoxDecoration(
                color: Color(0xff211E26),
                borderRadius: BorderRadius.circular(60.w),
                border: Border.all(color: Color(0xff404040)),
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  30.verticalSpace,
                  Row(
                    children: [
                      80.horizontalSpace,
                      Expanded(
                        child: Text(
                          'Insufficient Credit',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 55.sp,
                            fontFamily: fontFamilySemiBold,
                          ),
                        ),
                      ),
                      PressUnpress(
                        width: 85.w,
                        height: 85.w,
                        onTap: () {
                          Get.back();
                        },
                        imageAssetPress:
                        'assets/premium_screen/close_press.png',
                        imageAssetUnPress:
                        'assets/premium_screen/close_unpress.png',
                      ).marginOnly(bottom: 50.h),
                    ],
                  ),
                  Text(
                    bodyText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff6B6B6B),
                      fontSize: 45.sp,
                      decoration: TextDecoration.none,
                      fontFamily: fontFamilyMedium,
                    ),
                  ),
                  60.verticalSpace,
                  OnlyPressUnpress(
                    onTap: () {
                      Get.back();
                      Get.to(const CreditUpsellScreen(item: true),
                              transition: Transition.fadeIn)
                          ?.then(
                        (value) {
                          goWebView(onTap, cutAddCredit);
                        },
                      );
                    },
                    child: Container(
                      width: 560.w,
                      height: 130.h,
                      decoration: BoxDecoration(
                        gradient: unPressGradiant,
                        borderRadius: BorderRadius.circular(30.w),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Buy Now',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50.sp,
                          fontFamily: fontFamilySemiBold,
                        ),
                      ),
                    ),
                  ),
                  // PressUnpress(
                  //   width: 560.w,
                  //   height: 130.h,
                  //   onTap: () {
                  //     Get.back();
                  //     Get.to(const CreditUpsellScreen(item: true),
                  //             transition: Transition.fadeIn)
                  //         ?.then(
                  //       (value) {
                  //         goWebView(onTap, cutAddCredit);
                  //       },
                  //     );
                  //   },
                  //   pressGradient: pressGradiant,
                  //   unPressGradient: unPressGradiant,
                  //   alignment: Alignment.center,
                  //   child: Text(
                  //     'Buy Now',
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //       color: Colors.black,
                  //       fontSize: 50.sp,
                  //       fontFamily: fontFamilySemiBold,
                  //     ),
                  //   ),
                  // ),
                  50.verticalSpace,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void goWebView(VoidCallback onTap, int cutAddCredit) async {
    ProgressDialog.show('');
    await Future.delayed(const Duration(seconds: 1));
    ProgressDialog.dismiss();
    if (AdsVariable.isPurchase.value) {
      SharedPreferencesService.getCreditValue('Credit').then((value) {
        if (value >= cutAddCredit) {
          onTap();
        }
        // else {
        // showPurchasesDialog();
        // }
      });
    }

    if(AdsVariable.testerIsPurchase.value){
      onTap();
    }
  }
}
