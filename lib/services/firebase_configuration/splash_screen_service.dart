// import 'dart:async';
// import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import '../common_controller/pix3dcontroller/home_template_controller.dart';
// import '../google_ads_material/InterstitialAdUtil.dart';
// import '../google_ads_material/ads_variable.dart';
// import '../google_ads_material/app_lifecycle_reactor.dart';
// import '../google_ads_material/app_open_ad_manager.dart';
// import '../google_ads_material/gdpr_initialized.dart';
// import '../google_ads_material/nativeAdService.dart';
// import '../in_app_purchase/creadit_controller.dart';
// import '../in_app_purchase/purchase_controller.dart';
// import '../in_app_purchase/screens/credit_purchase_screen.dart';
// import '../in_app_purchase/screens/subscription_screen.dart';
// import '../pix3dScreen/PIX_home_screen.dart';
// import '../pix3dScreen/common_screen/PIX_onboarding_screen.dart';
// import '../service/sharedPreferencesService.dart';
//
// class InitializationService {
//   final AppOpenAdManager appOpenAdManager = AppOpenAdManager();
//    FirebaseAnalytics? analytics;
//   final _initializationHelper = InitializationHelper();
//   // final PurchaseController purchaseController = Get.put(PurchaseController());
//   final NativeAdManager nativeAdManager = Get.put(NativeAdManager());
//   // final CreditController creditController = Get.put(CreditController());
//
//
//   Future<void> checkConnectivityAndProceed() async {
//     print('mapValues4');
//     await purchaseController.checkPurchasesStatus();
//     analytics = FirebaseAnalytics.instance;
//     analytics!.setAnalyticsCollectionEnabled(true);
//     AppLifecycleReactor(appOpenAdManager: appOpenAdManager).listenToAppStateChanges();
//     _initialize();
//   }
//
//
//   Future<void> _initialize() async {
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       try {
//         await _initializationHelper.initialize();
//         loadNative();
//         if (AdsVariable.fullscreen_on_in_splash_screen == '0' &&
//             AdsVariable.appopen != '11') {
//           _loadAppOpenAd();
//         } else {
//           if (AdsVariable.appopen != '11') {
//             appOpenAdManager.loadAd();
//           }
//           if (AdsVariable.fullscreen_splash_adsId_high != '11') {
//             _loadInterstitialAd(AdsVariable.fullscreen_splash_adsId_high);
//           } else {
//             delayNavigation();
//           }
//         }
//       } catch (e) {
//         print("Initialization error: $e");
//       } finally {}
//     });
//   }
//
//   void _loadAppOpenAd() {
//     try {
//       AppOpenAd.load(
//         adUnitId: AdsVariable.appopen,
//         request: const AdRequest(),
//         adLoadCallback: AppOpenAdLoadCallback(
//           onAdLoaded: (ad) {
//             try {
//               AppOpenAdManager.appOpenAd = ad;
//               AppOpenAdManager.appOpenAd!.fullScreenContentCallback =
//                   FullScreenContentCallback(
//                 onAdDismissedFullScreenContent: (ad) {
//                   nextScreenNavigation();
//                 },
//                 onAdFailedToShowFullScreenContent: (ad, error) {
//                   nextScreenNavigation();
//                 },
//               );
//               AppOpenAdManager.appOpenAd!.show();
//               AppOpenAdManager.appOpenAd = null;
//             } catch (e) {
//               debugPrint('Error showing AppOpenAd: $e');
//               nextScreenNavigation();
//             }
//           },
//           onAdFailedToLoad: (error) {
//             debugPrint('AppOpenAd failed to load: $error');
//             nextScreenNavigation();
//           },
//         ),
//       );
//     } catch (e) {
//       debugPrint('Error loading AppOpenAd: $e');
//       delayNavigation();
//     }
//   }
//
//   void _loadInterstitialAd(String adUnitId) {
//     try {
//       InterstitialAd.load(
//         adUnitId: adUnitId,
//         request: const AdRequest(),
//         adLoadCallback: InterstitialAdLoadCallback(
//           onAdLoaded: (ad) {
//             try {
//               InterstitialAdManager.interstitialAd = ad;
//               InterstitialAdManager.interstitialAd!.fullScreenContentCallback =
//                   FullScreenContentCallback(
//                 onAdDismissedFullScreenContent: (ad) {
//                   try {
//                     ad.dispose();
//                   } catch (e) {
//                     debugPrint('Error disposing InterstitialAd: $e');
//                   }
//                   nextScreenNavigation();
//                 },
//                 onAdFailedToShowFullScreenContent: (ad, error) {
//                   try {
//                     ad.dispose();
//                   } catch (e) {
//                     debugPrint('Error disposing InterstitialAd: $e');
//                   }
//                   nextScreenNavigation();
//                 },
//               );
//               InterstitialAdManager.interstitialAd!.show();
//               InterstitialAdManager.interstitialAd = null;
//             } catch (e) {
//               debugPrint('Error showing InterstitialAd: $e');
//               nextScreenNavigation();
//             }
//           },
//           onAdFailedToLoad: (error) {
//             debugPrint('InterstitialAd failed to load: $error');
//             try {
//               InterstitialAd.load(
//                 adUnitId: AdsVariable.fullscreen_splash_adsId_normal,
//                 request: const AdRequest(),
//                 adLoadCallback: InterstitialAdLoadCallback(
//                   onAdLoaded: (ad) {
//                     try {
//                       InterstitialAdManager.interstitialAd = ad;
//                       InterstitialAdManager
//                               .interstitialAd!.fullScreenContentCallback =
//                           FullScreenContentCallback(
//                         onAdDismissedFullScreenContent: (ad) {
//                           try {
//                             ad.dispose();
//                           } catch (e) {
//                             debugPrint('Error disposing InterstitialAd: $e');
//                           }
//                           nextScreenNavigation();
//                         },
//                         onAdFailedToShowFullScreenContent: (ad, error) {
//                           try {
//                             ad.dispose();
//                           } catch (e) {
//                             debugPrint('Error disposing InterstitialAd: $e');
//                           }
//                           nextScreenNavigation();
//                         },
//                       );
//                       InterstitialAdManager.interstitialAd!.show();
//                       InterstitialAdManager.interstitialAd = null;
//                     } catch (e) {
//                       debugPrint('Error showing fallback InterstitialAd: $e');
//                       nextScreenNavigation();
//                     }
//                   },
//                   onAdFailedToLoad: (error) {
//                     debugPrint(
//                         'Fallback InterstitialAd failed to load: $error');
//                     nextScreenNavigation();
//                   },
//                 ),
//               );
//             } catch (e) {
//               debugPrint('Error loading fallback InterstitialAd: $e');
//               nextScreenNavigation();
//             }
//           },
//         ),
//       );
//     } catch (e) {
//       debugPrint('Error loading InterstitialAd: $e');
//       delayNavigation();
//     }
//   }
//
//   loadNative() {
//     SharedPreferencesService.getUser().then((value) {
//       if (value.isEmpty) {
//         nativeAdManager.loadLanguageScreenAd(AdsVariable.native_intro_big);
//       }
//     });
//   }
//
//   nextScreenNavigation() {
//     InterstitialAdManager.getInterstitial();
//     SharedPreferencesService.getUser().then(
//       (value) {
//         if (value.isNotEmpty) {
//           Get.to(() => purchaseController.isPurchaseActive.value
//               ? creditController.userCredit.value >= 20
//                   ? PIXHomeScreen()
//                   : CreditUpsellScreen(item: false, videoUrl: '')
//               : UpsellScreen(item: false, videoUrl: ''));
//         } else {
//           Get.to(() => PIXOnboardingScreen());
//         }
//       },
//     );
//   }
//
//   void delayNavigation() {
//     InterstitialAdManager.getInterstitial();
//     Timer(const Duration(seconds: 3), () {
//       SharedPreferencesService.getUser().then(
//         (value) {
//           if (value.isNotEmpty) {
//             Get.to(() => purchaseController.isPurchaseActive.value
//                 ? creditController.userCredit.value >= 20
//                     ? PIXHomeScreen()
//                     : CreditUpsellScreen(item: false, videoUrl: '')
//                 : UpsellScreen(item: false, videoUrl: ''));
//           } else {
//             Get.to(() => PIXOnboardingScreen());
//           }
//         },
//       );
//     });
//   }
// }
