import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:seaart_ai/ads/AdsVariable.dart';
import 'package:seaart_ai/screen/common_screen/constant.dart';
import 'package:seaart_ai/service/press_unpress.dart';

class TesterScreen extends StatefulWidget {
  final VoidCallback onDone;

  const TesterScreen({super.key, required this.onDone});

  @override
  State<TesterScreen> createState() => _TesterScreenState();
}

class _TesterScreenState extends State<TesterScreen> {
  void back() {
    Get.back();
  }

  TextEditingController textEditingController1 = TextEditingController(),
      textEditingController2 = TextEditingController();

  FocusNode focusNode1 = FocusNode(), focusNode2 = FocusNode();

  RxString usernameErrorText = ''.obs, passErrorText = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: PressUnpress(
          onTap: () {
            back();
          },
          width: 120.w,
          height: 120.w,
          imageAssetPress: 'assets/category_screen/back_press.png',
          imageAssetUnPress: 'assets/category_screen/back_unpress.png',
        ).marginAll(30.w),
        title: Text(
          'Tester',
          style: TextStyle(
            color: Colors.white,
            fontSize: 70.sp,
            fontFamily: fontFamilySemiBold,
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () {
          back();
          return Future(() => false);
        },
        child: Container(
          width: 1242.w,
          height: 2688.h,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/home_screen/bg.png'),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                children: [
                  50.verticalSpace,
                  SizedBox(
                    width: 1110.w,
                    height: 220.h,
                    child: Obx(
                      () => TextField(
                        controller: textEditingController1,
                        focusNode: focusNode1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50.sp,
                          fontFamily: fontFamilyMedium,
                        ),
                        onTapOutside: (event) {
                          focusNode1.unfocus();
                        },
                        cursorColor: appColor,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Enter Username',
                          labelStyle: TextStyle(
                            color: Colors.white54,
                            fontSize: 50.sp,
                            fontFamily: fontFamilyMedium,
                          ),
                          errorText: usernameErrorText.value.isNotEmpty
                              ? usernameErrorText.value
                              : null,
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 40.sp,
                            fontFamily: fontFamilyMedium,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: appColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  50.verticalSpace,
                  SizedBox(
                    width: 1110.w,
                    height: 220.h,
                    child: Obx(
                      () => TextField(
                        controller: textEditingController2,
                        focusNode: focusNode2,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50.sp,
                          fontFamily: fontFamilyMedium,
                        ),
                        onTapOutside: (event) {
                          focusNode2.unfocus();
                        },
                        cursorColor: appColor,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Enter Password',
                          labelStyle: TextStyle(
                            color: Colors.white54,
                            fontSize: 50.sp,
                            fontFamily: fontFamilyMedium,
                          ),
                          errorText: passErrorText.value.isNotEmpty
                              ? passErrorText.value
                              : null,
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 40.sp,
                            fontFamily: fontFamilyMedium,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: appColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  100.verticalSpace,
                  PressUnpress(
                    width: 500.w,
                    height: 150.h,
                    onTap: () {
                      focusNode1.unfocus();
                      focusNode2.unfocus();
                      if (textEditingController1.text.isEmpty) {
                        usernameErrorText.value = 'Please enter username';
                      } else if (textEditingController1.text !=
                          AdsVariable.username) {
                        usernameErrorText.value = 'Username is not valid';
                      } else if (textEditingController1.text ==
                          AdsVariable.username) {
                        usernameErrorText.value = '';
                      } else if (textEditingController2.text.isEmpty) {
                        passErrorText.value = 'Please enter password';
                      } else if (textEditingController2.text !=
                          AdsVariable.password) {
                        passErrorText.value = 'Password is not valid';
                      } else if (textEditingController2.text ==
                          AdsVariable.password) {
                        passErrorText.value = '';
                      }
                      if (textEditingController1.text == AdsVariable.username &&
                          textEditingController2.text == AdsVariable.password) {
                        AdsVariable.testerIsPurchase.value = true;
                        Get.back();
                        widget.onDone();
                      }
                    },
                    pressGradient: pressGradiant,
                    unPressGradient: unPressGradiant,
                    alignment: Alignment.center,
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 60.sp,
                        fontFamily: fontFamilyBold,
                      ),
                    ),
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
