import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:seaart_ai/ads/AdsVariable.dart';
import 'package:seaart_ai/in_app_purchase/creditManager.dart';
import 'package:seaart_ai/in_app_purchase/credit_controller.dart';
import 'package:seaart_ai/in_app_purchase/tester_screen.dart';
import 'package:seaart_ai/screen/common_screen/privacy_policy.dart';
import 'package:seaart_ai/screen/common_screen/terms_screen.dart';
import 'package:seaart_ai/screen/common_screen/constant.dart';
import 'package:seaart_ai/service/possessing_dialog.dart';
import 'package:seaart_ai/service/press_unpress.dart';
import 'package:seaart_ai/service/sharedPreferencesService.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zo_animated_border/widget/zo_dotted_border.dart';

class CreditUpsellScreen extends StatelessWidget {
  final bool item;
  final bool? isTester;

  const CreditUpsellScreen({super.key, required this.item, this.isTester});

  @override
  Widget build(BuildContext context) {
    CreditController creditController = Get.put(CreditController(item));

    return Scaffold(
      backgroundColor: appbackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: [
          Obx(
            () =>
                (creditController.isClose.value ||
                    AdsVariable.show_close_delay == '0')
                ? PressUnpress(
                    width: 100.w,
                    height: 100.w,
                    onTap: () {
                      creditController.backToHome(context);
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
          creditController.backToHome(context);
          return Future(() => false);
        },
        child: Container(
          width: 1242.w,
          height: 2688.h,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/premium_screen/bg.png'),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
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

                        50.verticalSpace,
                        Obx(() {
                          if (creditController.selectedPackage.value == null) {
                            return const SizedBox.shrink();
                          }

                          final packageId = creditController
                              .selectedPackage
                              .value!
                              .storeProduct
                              .identifier;
                          final credits =
                              AdsVariable.creditPlans[packageId] ?? 0;
                          final videoCount = (credits / 30).floor();

                          return Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: Text(
                              'You can generate $videoCount videos',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 50.sp,
                                fontFamily: fontFamilySemiBold,
                              ),
                            ),
                          );
                        }),
                        50.verticalSpace,

                        SizedBox(
                          width: 1242.w,
                          height: 1050.w,
                          child: Obx(
                            () => creditController.offerings.value != null
                                ? GridView.count(
                                    physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.all(40.w),
                                    crossAxisCount: 3,
                                    childAspectRatio: 0.82,
                                    mainAxisSpacing: 40.w,
                                    crossAxisSpacing: 40.w,
                                    children: creditController.availablePackages.entries.skip(1).map((
                                      packageEntry,
                                    ) {
                                      print(
                                        packageEntry
                                            .value
                                            .storeProduct
                                            .identifier,
                                      );

                                      return GestureDetector(
                                        onTap: () {
                                          creditController
                                                  .selectedPackage
                                                  .value =
                                              packageEntry.value;
                                        },
                                        child: ZoDottedBorder(
                                          borderRadius: 50.w,
                                          dashLength: 3,
                                          gapLength: 0,
                                          strokeWidth: 1.5,
                                          gradient:
                                              creditController
                                                      .selectedPackage
                                                      .value ==
                                                  packageEntry.value
                                              ? unPressGradiant.withOpacity(0.9)
                                              : LinearGradient(
                                                  colors: [
                                                    Color(0xff252525),
                                                    Color(0xff252525),
                                                  ],
                                                ),
                                          animationSpeed: 0,
                                          borderStyle: BorderStyleType.gradient,
                                          padding: EdgeInsets.all(0.5),
                                          child: Container(
                                            width: 360.w,
                                            height: 440.h,
                                            decoration: BoxDecoration(
                                              color:
                                                  creditController
                                                          .selectedPackage
                                                          .value ==
                                                      packageEntry.value
                                                  ? null
                                                  : Color(0xff191B1D),
                                              gradient:
                                                  creditController
                                                          .selectedPackage
                                                          .value ==
                                                      packageEntry.value
                                                  ? unPressGradiant.withOpacity(
                                                      0.3,
                                                    )
                                                  : null,
                                              borderRadius:
                                                  BorderRadius.circular(50.w),
                                            ),
                                            alignment: Alignment.center,
                                            child: Stack(
                                              children: [
                                                if (AdsVariable.showOffText ==
                                                    '1')
                                                  Positioned(
                                                    right: 0,
                                                    top: 0,
                                                    child: Builder(
                                                      builder: (_) {
                                                        final discountLabel =
                                                            creditController
                                                                .getDiscountLabel(
                                                                  packageEntry
                                                                      .value,
                                                                );
                                                        if (discountLabel ==
                                                            null) {
                                                          return SizedBox.shrink();
                                                        }
                                                        return Container(
                                                          width: 207.w,
                                                          height: 70.h,
                                                          decoration: BoxDecoration(
                                                            color:
                                                                creditController
                                                                        .selectedPackage
                                                                        .value ==
                                                                    packageEntry
                                                                        .value
                                                                ? null
                                                                : Color(
                                                                    0xff252525,
                                                                  ),
                                                            gradient:
                                                                creditController
                                                                        .selectedPackage
                                                                        .value ==
                                                                    packageEntry
                                                                        .value
                                                                ? unPressGradiant
                                                                : null,
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                  bottomLeft:
                                                                      Radius.circular(
                                                                        50.w,
                                                                      ),
                                                                  topRight:
                                                                      Radius.circular(
                                                                        50.w,
                                                                      ),
                                                                ),
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            discountLabel,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color:
                                                                  creditController
                                                                          .selectedPackage
                                                                          .value ==
                                                                      packageEntry
                                                                          .value
                                                                  ? Colors.black
                                                                  : Color(
                                                                      0xff90969F,
                                                                    ),
                                                              fontSize: 26.sp,
                                                              fontFamily:
                                                                  fontFamilyBold,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      20.horizontalSpace,
                                                      CircleAvatar(
                                                        radius:
                                                            creditController
                                                                    .selectedPackage
                                                                    .value ==
                                                                packageEntry
                                                                    .value
                                                            ? 9
                                                            : 7,
                                                        backgroundColor:
                                                            creditController
                                                                    .selectedPackage
                                                                    .value ==
                                                                packageEntry
                                                                    .value
                                                            ? appColor
                                                            : const Color(
                                                                0xff414141,
                                                              ),
                                                      ),
                                                      Text(
                                                        '${AdsVariable.creditPlans[packageEntry.value.storeProduct.identifier]} Credits',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 50.sp,
                                                          fontFamily:
                                                              fontFamilySemiBold,
                                                        ),
                                                      ),
                                                      30.verticalSpace,
                                                      Container(
                                                        width: 360.w,
                                                        height: 106.h,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              creditController
                                                                      .selectedPackage
                                                                      .value ==
                                                                  packageEntry
                                                                      .value
                                                              ? Color(
                                                                  0xff142539,
                                                                ).withOpacity(
                                                                  0.5,
                                                                )
                                                              : Color(
                                                                  0xff252525,
                                                                ),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                bottomLeft:
                                                                    Radius.circular(
                                                                      50.w,
                                                                    ),
                                                                bottomRight:
                                                                    Radius.circular(
                                                                      50.w,
                                                                    ),
                                                              ),
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          packageEntry
                                                              .value
                                                              .storeProduct
                                                              .priceString,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 46.sp,
                                                            fontFamily:
                                                                fontFamilyBold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  )
                                : buildColumn(),
                          ),
                        ),
                        50.verticalSpace,
                        PressUnpress(
                          width: 1146.w,
                          height: 200.w,
                          onTap: () {
                            creditController.buyCredits(context);
                          },
                          imageAssetPress:
                              'assets/premium_screen/continue_gif.gif',
                          imageAssetUnPress:
                              (AdsVariable.isPurchase.value ||
                                  AdsVariable.without_subscription == '1' ||
                                  AdsVariable.purchaseScreenIndex == '1')
                              ? 'assets/premium_screen/continue_gif.gif'
                              : 'assets/premium_screen/continue_gif.gif',
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
                    Future.delayed(const Duration(seconds: 2), () {
                      CreditsManager().getUserCredits().then((credits) {
                        // print(credits);
                        if (credits == 0) {
                          showToast(msg: 'Your plan not found!');

                          AdsVariable.isPurchase.value = false;
                        } else if (credits > 0) {
                          SharedPreferencesService.setCreditValue(
                            credits,
                            'Credit',
                          );
                          AdsVariable.credits.value = credits;
                          showToast(msg: 'Your plan restore successfully');
                        }
                      });
                    });
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
              30.horizontalSpace,
            ],
          );
  }

  GridView buildColumn() {
    return GridView.builder(
      itemCount: 6,
      padding: EdgeInsets.all(40.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.82,
        mainAxisSpacing: 40.w,
        crossAxisSpacing: 40.w,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: shimmerBgColor,
          highlightColor: appColor,
          child: Container(
            width: 360.w,
            height: 440.h,
            decoration: BoxDecoration(
              color: shimmerBgColor,
              borderRadius: BorderRadius.circular(50.w),
            ),
          ),
        );
      },
    );
  }
}
