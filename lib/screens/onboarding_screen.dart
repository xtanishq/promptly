import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:promptly/providers/app_state.dart';
import 'package:promptly/services/constant.dart';
import 'package:promptly/utils/AppTheme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../services/press_unpress.dart';

class OnBoardingScreen extends StatefulWidget {
  final bool fromHome;

  const OnBoardingScreen({required this.fromHome, super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // late SharedPreferences prefs;
  bool swipe = false;

  List<String> textts = [
    "Visual to text",
    "Relive Where Memories Were Made",
  ];
  List<String> subtext = [
    "Find the perfect prompt for any image instantly",
    "Tap any photo on the map to see location, story & details",
  ];
  AppController _appController = Get.find();

  void _finishOnboarding() async {
    _appController.completeOnboarding();

    // await Provider.of<AppState>(context, listen: false).completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void initState() {
    super.initState();
    // _initPrefs();
  }

  // void _initPrefs() async {
  //   prefs = await SharedPreferences.getInstance();
  //   setState(() {});
  // }

  late final List<Widget> _pages = [
    OnboardingPage(
      imagePath1: 'assets/onboarding/onboard1.png',
      width: 1290.w,
      height: 2796.h,
    ),

    OnboardingPage(
      imagePath1: '',
      width: 1290.w,
      height: 2796.h,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: 1290.w,
        height: 2796.h,
        decoration: const BoxDecoration(color: Colors.black),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _pages[index];
              },
              onPageChanged: (index) async {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  if (_currentPage == 0)
                    Padding(
                      padding:  EdgeInsets.only(top: 220.h),
                      child: CircleAvatar(
                        backgroundColor: Get.theme.colorScheme.secondary,
                        child: Icon(
                          Icons.arrow_downward,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ),
                  10.verticalSpace,
                  if(_currentPage==0)
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 110.w),
                        child: Text(
                          textts[_currentPage],

                          style: TextStyle(
                            fontSize: 90.sp,
                            fontFamily: "PlusJakarta",
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      18.verticalSpace,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 110.w),
                        child: Text(
                          subtext[_currentPage],
                          style: TextStyle(
                            fontSize: 65.sp,
                            fontFamily: "Bold",
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),







if(_currentPage==1)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /// Copy button
                      Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          color: neonGreen,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: neonGreen.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.copy_rounded, size: 32, color: Colors.black),
                            SizedBox(height: 6),
                            Text(
                              'COPY',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      50.verticalSpace,

                      const Text(
                        'One Tap',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
50.verticalSpace,
                      const Text(
                        'Copy and share prompts in\nseconds.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.white54,
                        ),
                      ),
                      350.verticalSpace,
                      // Spacer(),
                      Container(
                        margin: EdgeInsets.all(8),
                        padding:  EdgeInsets.symmetric(horizontal: 90.w, vertical: 50.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 28,
                              width: 28,
                              decoration: BoxDecoration(
                                color: neonGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                            // const SizedBox(width: 12),
                            30.horizontalSpace,
                            const Expanded(
                              child: Text(
                                'Prompt Copied!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Text(
                              'Just now',
                              style: TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      160.verticalSpace,

                    ],
                  ),
                  //

                  Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // if (_currentPage >= 1)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 60.h, left: 20.w),
                            child: SmoothPageIndicator(
                              controller: _pageController, // PageController
                              count: 2,

                              effect: ExpandingDotsEffect(
                                dotColor: Colors.grey.withOpacity(0.6),
                                activeDotColor: secondaryColor,
                                dotHeight: 25.h,
                                dotWidth: 40.w,
                              ), // your preferred effect
                              onDotClicked: (index) {},
                            ),
                          ),
                        ),
                        PressUnpress(
                          onTap: () async {
                            if (_currentPage < _pages.length - 1) {
                              setState(() {
                                _currentPage++;
                                _pageController.animateToPage(
                                  _currentPage,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              });
                            } else {
                              _finishOnboarding();                              //   SharedPreferencesService.setUser("username");
                              //   CheckPurchasesStatus.initPlatformState().then((
                              //       value,
                              //       ) async {
                              //     if (value) {
                              //       Get.offAll(
                              //         const Homescreennew(),
                              //         transition: Transition.fadeIn,
                              //       );
                              //
                              //     } else {
                              //       Get.offAll(
                              //         const UpsellScreen(item: false),
                              //         transition: Transition.fadeIn,
                              //       );
                              //     }
                              //   });
                            }
                          },
                          height: 200.h,
                          width: 200.w,
                          pressColor: secondaryColor,
                          unPressColor: secondaryColor,

                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // if (_currentPage == 0)
                                  Icon(
                                    _currentPage==0?Icons.arrow_forward_sharp:Icons.check,
                                    color: Colors.black,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  90.verticalSpace,
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  // void _finishOnboarding() async {
  //   // await Provider.of<AppState>(context, listen: false).completeOnboarding();
  //   if (mounted) {
  //     Navigator.of(context).pushReplacementNamed('/home');
  //   }
  // }

  static const Color neonGreen = Color(0xFFC6FF00);
  static const Color darkBg = Color(0xFF050505);
  Widget _progressBar({required bool active}) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: active ? neonGreen : Colors.white12,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage extends StatelessWidget {
  final String imagePath1;

  var height;
  var width;

  OnboardingPage({
    super.key,
    required this.imagePath1,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return imagePath1?.isEmpty == true
        ? Container(

      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.2,
          colors: [
            Color(0xFF1A1F0D), // subtle neon glow center
            Color(0xFF0A0C05), // mid dark
            Color(0xFF050505), // pure black edges
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    )
        : Image.asset(
      imagePath1,
      height: height,
      width: width,
      fit: BoxFit.contain,
      alignment: Alignment.topCenter,
    );
  }
}
