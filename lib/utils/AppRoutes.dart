import 'package:get/get.dart';

import '../screens/detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String detail = '/detail';

  // GetX Pages की लिस्ट
  static final pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: onboarding, page: () => const OnBoardingScreen(fromHome: false)),
    GetPage(name: home, page: () =>  HomeScreen()),
    GetPage(name: detail, page: () => const DetailScreen()), // DetailScreen को arguments अंदर से मिल जाएंगे
  ];
}