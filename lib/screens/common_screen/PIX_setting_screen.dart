import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:promptly/screens/common_screen/privacy_policy.dart';
import 'package:promptly/screens/common_screen/my_creations_screen.dart';
import 'package:promptly/services/constant.dart';

import '../../services/checkConnectivity.dart';
import '../../services/dialog.dart';
import '../../services/firebase_configuration/firebase_event.dart';
import '../../services/google_ads_material/ads_variable.dart';
import '../../services/google_ads_material/gdpr_initialized.dart';
import '../../services/press_unpress.dart';
import '../../services/submitRating.dart';
import '../../utils/AppTheme.dart';

class SettingScreen extends StatelessWidget {
  // final String data;

  const SettingScreen({super.key});

  void back() {
    AdsVariable.inAppFlag = 0;
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalyticsService.logEvent(eventName: 'promptly_setting_screen');
    final InitializationHelper initializationHelper = InitializationHelper();

    // final controller = Get.find<MomentsController>();
    bool isShare = false;
    return Scaffold(
      backgroundColor: appBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Setting',
          style: TextStyle(
            color: Colors.white,
            fontSize: 70.sp,
            // fontFamily: fontFamilySemiBold,
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          back();
          return false;
        },
        child: Container(
          width: 1242.w,
          height: 2688.h,
          decoration: const BoxDecoration(color: appBackgroundColor),
          child: SafeArea(
            child: Center(
              child: Column(
                children: [
                  10.verticalSpace,

                  Text(
                    "PROMPTLY" + " AI",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 140.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  16.verticalSpace,
                  Text(
                    "AI Prompt Explorer",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 55.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  60.verticalSpace,

                  PressUnpress(
                    onTap: () {
                      Get.to(() => const MyCreationsScreen());
                    },
                    height: 180.h,
                    width: 1103.w,
                    pressGradient: pressGradiant,
                    unPressGradient: unPressGradiant,
                    child: Center(
                      child: AutoSizeText(
                        "My Creations",
                        style: TextStyle(
                          fontSize: 55.sp,
                          fontFamily: "semibold",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  40.verticalSpace,

                  PressUnpress(
                    onTap: () {
                      ConnectivityService.checkConnectivity().then((value) {
                        if (value) {
                          SubmitRating().submitRating(context);
                        } else {
                          DialogService.showCheckConnectivity(context);
                        }
                      });
                    },
                    height: 180.h,
                    width: 1103.w,
                    pressGradient: pressGradiant,
                    unPressGradient: unPressGradiant,
                    child: Center(
                      child: AutoSizeText(
                        "Rate",
                        style: TextStyle(
                          fontSize: 55.sp,
                          fontFamily: "semibold",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  40.verticalSpace,

                  PressUnpress(
                    onTap: () {
                      ConnectivityService.checkConnectivity().then((value) {
                        if (value) {
                          if (!isShare) {
                            isShare = true;
                            SubmitRating().shareContent(context);
                            Future.delayed(const Duration(seconds: 2), () {
                              isShare = false;
                            });
                          }
                        } else {
                          DialogService.showCheckConnectivity(context);
                        }
                      });
                    },
                    height: 180.h,
                    width: 1103.w,
                    pressGradient: pressGradiant,
                    unPressGradient: unPressGradiant,
                    child: Center(
                      child: AutoSizeText(
                        "Share",
                        style: TextStyle(
                          fontSize: 55.sp,
                          fontFamily: "semibold",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  40.verticalSpace,
                  PressUnpress(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicy(),
                        ),
                      );
                    },
                    height: 180.h,
                    width: 1103.w,
                    pressGradient: pressGradiant,
                    unPressGradient: unPressGradiant,
                    child: Center(
                      child: AutoSizeText(
                        "Privacy Policy",
                        style: TextStyle(
                          fontSize: 55.sp,
                          fontFamily: "semibold",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  60.verticalSpace,

                  FutureBuilder<bool>(
                    future: isUnderGdpr(),
                    builder: (context, snapshot) {
                      // Jab tak check ho raha hai, kuch mat dikhao
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      // Agar GDPR user nahi hai → button hide
                      if (!snapshot.data!) {
                        return const SizedBox.shrink();
                      }

                      // GDPR user → Privacy Choices dikhao
                      return PressUnpress(
                        onTap: () async {
                          final didChangePreferences =
                              await initializationHelper
                                  .changePrivacyPreferences();

                          appToast(
                            didChangePreferences
                                ? 'Your privacy choices have been updated'
                                : 'An error occurred while trying to change your privacy choices',
                          );
                        },
                        height: 180.h,
                        width: 1103.w,
                        pressGradient: pressGradiant,
                        unPressGradient: unPressGradiant,
                        child: Center(
                          child: AutoSizeText(
                            "Privacy Choices",
                            style: TextStyle(
                              fontSize: 55.sp,
                              fontFamily: "semibold",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
