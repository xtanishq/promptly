import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:seaart_ai/ads/AdsVariable.dart';
import 'package:seaart_ai/in_app_purchase/constant.dart';
import 'package:seaart_ai/in_app_purchase/tester_screen.dart';
import 'package:seaart_ai/in_app_purchase/upsell_controller.dart';
import 'package:seaart_ai/screen/common_screen/privacy_policy.dart';
import 'package:seaart_ai/screen/common_screen/terms_screen.dart';
import 'package:seaart_ai/screen/common_screen/constant.dart';
import 'package:seaart_ai/service/dialog.dart';
import 'package:seaart_ai/service/possessing_dialog.dart';
import 'package:seaart_ai/service/press_unpress.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zo_animated_border/widget/zo_dotted_border.dart';

class UpsellScreen extends StatelessWidget {
  final bool item;
  final bool? isTester;

  const UpsellScreen({super.key, required this.item, this.isTester});

  @override
  Widget build(BuildContext context) {
    UpsellController upsellController = Get.put(UpsellController(item));
    return Scaffold(
      backgroundColor: appbackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: [
          Obx(
            () =>
                (upsellController.isClose.value ||
                    AdsVariable.show_close_delay == '0')
                ? PressUnpress(
                    width: 100.w,
                    height: 100.w,
                    onTap: () {
                      upsellController.backToHome(context);
                    },
                    imageAssetPress: 'assets/premium_screen/close_press.png',
                    imageAssetUnPress:
                        'assets/premium_screen/close_unpress.png',
                  ).marginAll(45.w)
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () {
          upsellController.backToHome(context);
          return Future(() => false);
        },
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Image.asset(
              'assets/premium_screen/logo.png',
              width: 1242.w,
              alignment: Alignment.topCenter,
              fit: BoxFit.cover,
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/premium_screen/tx.png',
                        width: 758.w,
                        height: 195.h,
                      ),

                      70.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: buildSubtext('Ad-Free Experience'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: buildSubtext('Unlock pro feature'),
                          ),
                        ],
                      ),
                      50.verticalSpace,
                      Obx(
                        () => upsellController.offerings.value != null
                            ? Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: upsellController.availablePackages.entries.take(1).map((
                                  packageEntry,
                                ) {
                                  print(
                                    packageEntry.value.storeProduct.identifier,
                                  );

                                  return GestureDetector(
                                    onTap: () {
                                      upsellController.selectedPackage.value =
                                          packageEntry.value;
                                    },
                                    child: SizedBox(
                                      width: 1146.w,
                                      height: 275.h,
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          ZoDottedBorder(
                                            borderRadius: 50.w,
                                            dashLength: 3,
                                            gapLength: 0,
                                            strokeWidth: 1.5,
                                            gradient:
                                                upsellController
                                                        .selectedPackage
                                                        .value ==
                                                    packageEntry.value
                                                ? unPressGradiant.withOpacity(
                                                    0.9,
                                                  )
                                                : LinearGradient(
                                                    colors: [
                                                      Color(0xff252525),
                                                      Color(0xff252525),
                                                    ],
                                                  ),
                                            animationSpeed: 0,
                                            borderStyle:
                                                BorderStyleType.gradient,
                                            padding: EdgeInsets.all(0),
                                            child: Container(
                                              width: 1146.w,
                                              height: 230.h,
                                              decoration: BoxDecoration(
                                                color:
                                                    upsellController
                                                            .selectedPackage
                                                            .value ==
                                                        packageEntry.value
                                                    ? null
                                                    : Color(0xff191B1D),
                                                gradient:
                                                    upsellController
                                                            .selectedPackage
                                                            .value ==
                                                        packageEntry.value
                                                    ? unPressGradiant
                                                          .withOpacity(0.2)
                                                    : null,
                                                borderRadius:
                                                    BorderRadius.circular(50.w),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 40.w,
                                              ),
                                              child: Row(
                                                children: [
                                                  // Image.asset(
                                                  //   upsellController
                                                  //               .selectedPackage
                                                  //               .value ==
                                                  //           packageEntry.value
                                                  //       ? 'assets/premium_screen/selected.png'
                                                  //       : 'assets/premium_screen/unselected.png',
                                                  //   width: 118.w,
                                                  //   height: 118.w,
                                                  // ),
                                                  // 40.horizontalSpace,
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          packageEntry
                                                                      .value
                                                                      .storeProduct
                                                                      .identifier ==
                                                                  planWeek
                                                              ? 'Weekly Plan'
                                                              : 'Yearly Plan',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 50.sp,
                                                            fontFamily:
                                                                fontFamilySemiBold,
                                                          ),
                                                        ),
                                                        Text(
                                                          (packageEntry
                                                                          .value
                                                                          .storeProduct
                                                                          .identifier ==
                                                                      planWeek ||
                                                                  AdsVariable
                                                                          .show_week_price ==
                                                                      '1')
                                                              ? '${AdsVariable.weekCredit} Credits'
                                                              : '${AdsVariable.weekCredit} Credits',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 42.sp,
                                                            fontFamily:
                                                                fontFamilyRegular,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  30.horizontalSpace,
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        packageEntry
                                                            .value
                                                            .storeProduct
                                                            .priceString,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 50.sp,
                                                          fontFamily:
                                                              fontFamilyBold,
                                                        ),
                                                      ),
                                                      Text(
                                                        packageEntry
                                                                    .value
                                                                    .storeProduct
                                                                    .identifier ==
                                                                planWeek
                                                            ? 'Per Week'
                                                            : 'Per Year',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 35.sp,
                                                          fontFamily:
                                                              fontFamilyRegular,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).marginOnly(bottom: 50.h),
                                  );
                                }).toList(),
                              )
                            : buildShimmer(),
                      ),
                      50.verticalSpace,
                      PressUnpress(
                        width: 1100.w,
                        height: 200.w,
                        onTap: () {
                          upsellController.buySubscription(context);
                        },
                        imageAssetPress:
                            'assets/premium_screen/continue_gif.gif',
                        imageAssetUnPress:
                            'assets/premium_screen/continue_gif.gif',
                        child: Center(
                          child: Text(
                            'Continue for payment',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 65.sp,
                              fontFamily: fontFamilyBold,
                            ),
                          ),
                        ),
                      ),
                      Obx(
                        () => upsellController.offerings.value != null
                            ? Text(
                                upsellController
                                            .selectedPackage
                                            .value!
                                            .storeProduct
                                            .identifier ==
                                        planWeek
                                    ? 'Subscription renews automatically Weekly. Cancel on Google Play anytime.'
                                    : '',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 35.sp,
                                  color: Colors.white,
                                  fontFamily: fontFamilyMedium,
                                ),
                              ).marginSymmetric(
                                horizontal: 50.w,
                                vertical: 20.h,
                              )
                            : 20.verticalSpace,
                      ),
                      privacyTermsOfUsRestore(context),
                      if (isTester != null &&
                          isTester! &&
                          AdsVariable.showIamTesterButton == '1')
                        TextButton(
                          onPressed: () async {
                            Get.to(
                              TesterScreen(
                                onDone: () {
                                  Get.back();
                                },
                              ),
                              transition: Transition.fadeIn,
                            );
                          },
                          child: Text(
                            "I am tester",
                            style: TextStyle(
                              color: appColor,
                              fontSize: 40.sp,
                              fontFamily: fontFamilyMedium,
                            ),
                          ),
                        ).marginOnly(bottom: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSubtext(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/premium_screen/done.png',
          width: 65.w,
          height: 65.w,
        ),
        20.horizontalSpace,
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 50.sp,
            fontFamily: fontFamilyMedium,
          ),
        ),
      ],
    );
  }

  Row privacyTermsOfUsRestore(BuildContext context) {
    return (Platform.isIOS || Platform.isMacOS)
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              20.horizontalSpace,
              TextButton(
                onPressed: () {
                  Get.to(TermsOfUse(), transition: Transition.fadeIn);
                },
                child: Text(
                  "Terms of use",
                  style: TextStyle(
                    color: Color(0xff90969F),
                    fontSize: 40.sp,
                    fontFamily: fontFamilyRegular,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(PrivacyPolicy(), transition: Transition.fadeIn);
                },
                child: Text(
                  "Privacy policy",
                  style: TextStyle(
                    color: Color(0xff90969F),
                    fontSize: 40.sp,
                    fontFamily: fontFamilyRegular,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  ProgressDialog.show('');
                  try {
                    final customerInfo = await Purchases.restorePurchases();
                    bool isActive =
                        customerInfo
                            .entitlements
                            .all[entitlementKey]
                            ?.isActive ??
                        false;
                    if (kDebugMode) {
                      print('isActive: $isActive');
                    }
                    if (!isActive) {
                      // ignore: use_build_context_synchronously
                      DialogService.restorePurchasesDialog(context);
                    }
                  } catch (e) {
                    if (kDebugMode) {
                      print('Exception during restore: $e');
                    }
                  } finally {
                    ProgressDialog.dismiss();
                  }
                },
                child: Text(
                  "Restore",
                  style: TextStyle(
                    color: Color(0xff90969F),
                    fontSize: 40.sp,
                    fontFamily: fontFamilyRegular,
                  ),
                ),
              ),
              30.horizontalSpace,
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              30.horizontalSpace,
              TextButton(
                onPressed: () {
                  Get.to(PrivacyPolicy(), transition: Transition.fadeIn);
                },
                child: Text(
                  "Privacy policy",
                  style: TextStyle(
                    color: Color(0xff90969F),
                    fontSize: 40.sp,
                    fontFamily: fontFamilyRegular,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  const url =
                      "https://play.google.com/store/account/subscriptions";
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open the subscription page'),
                      ),
                    );
                  }
                },
                child: Text(
                  "Google Play Subscription",
                  style: TextStyle(
                    color: Color(0xff90969F),
                    fontSize: 40.sp,
                    fontFamily: fontFamilyRegular,
                  ),
                ),
              ),
              20.horizontalSpace,
            ],
          );
  }

  Shimmer buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: appColor,
      child: Column(
        children: List.generate(2, (index) {
          return Container(
            width: 1110.w,
            height: 250.h,
            margin: EdgeInsets.only(top: 50.w),
            padding: EdgeInsets.symmetric(horizontal: 50.w),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xff131313)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Fake circle avatar
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: const BoxDecoration(
                    color: textColor,
                    shape: BoxShape.circle,
                  ),
                ),

                50.horizontalSpace,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 500.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: textColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.only(bottom: 20.h),
                    ),
                    Container(
                      width: 350.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: textColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 200.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: textColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
