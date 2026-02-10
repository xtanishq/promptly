import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_variable.dart';

class InterstitialAdManager {
  static InterstitialAd? interstitialAd;

  static Future<void> getInterstitial() async {
    interstitialAd = null;
    if(AdsVariable.fullscreen_splash_adsId_high == '11'){
      return;
    }
    try {
      InterstitialAd.load(
        adUnitId: AdsVariable.fullscreen_splash_adsId_high,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            interstitialAd = null;
            try {
              InterstitialAd.load(
                adUnitId: AdsVariable.fullscreen_preload_high_adsId,
                request: const AdRequest(),
                adLoadCallback: InterstitialAdLoadCallback(
                  onAdLoaded: (InterstitialAd ad) {
                    interstitialAd = ad;
                  },
                  onAdFailedToLoad: (LoadAdError error) {
                    interstitialAd = null;
                  },
                ),
              );
            } catch (e) {
              print('Error while retrying interstitial ad load: $e');
            }
          },
        ),
      );
    } catch (e) {
      print('Error loading interstitial ad: $e');
    }
  }

  static void showInterstitial({
    required Function() onAdDismissed,
    required String continueAdsOnline,
    required String id,
    required int flagCount,
  }) {
    if (continueAdsOnline == '0') {
      flagCount = 0;
    }
    if (id != '11' && flagCount % 2 == 0) {
      if (interstitialAd != null) {
        try {
          interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onAdDismissed();
              preLoad();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onAdDismissed();
              preLoad();
            },
          );
          interstitialAd!.show();
          interstitialAd = null;
        } catch (e) {
          print('Error showing interstitial ad: $e');
          onAdDismissed();
          preLoad();
        }
      } else {
        _showLoadingDialog();
        try {
          print('=============================================');
          InterstitialAd.load(
            adUnitId: AdsVariable.fullscreen_preload_high_adsId,
            request: const AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (ad) {
                SVProgressHUD.dismiss();
                interstitialAd = ad;
                interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
                  onAdDismissedFullScreenContent: (ad) {
                    ad.dispose();
                    onAdDismissed();
                    preLoad();
                  },
                  onAdFailedToShowFullScreenContent: (ad, error) {
                    ad.dispose();
                    onAdDismissed();
                    preLoad();
                  },
                );
                try {
                  interstitialAd!.show();
                  interstitialAd = null;
                } catch (e) {
                  onAdDismissed();
                }
              },
              onAdFailedToLoad: (error) {
                print('High priority ad failed to load: $error');
                try {
                  InterstitialAd.load(
                    adUnitId: AdsVariable.fullscreen_preload_normal_adsId,
                    request: const AdRequest(),
                    adLoadCallback: InterstitialAdLoadCallback(
                      onAdLoaded: (ad) {
                        SVProgressHUD.dismiss();
                        interstitialAd = ad;
                        interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
                          onAdDismissedFullScreenContent: (ad) {
                            ad.dispose();
                            onAdDismissed();
                            preLoad();
                          },
                          onAdFailedToShowFullScreenContent: (ad, error) {
                            ad.dispose();
                            onAdDismissed();
                            preLoad();
                          },
                        );
                        try {
                          interstitialAd!.show();
                          interstitialAd = null;
                        } catch (e) {
                          print('Error showing fallback interstitial ad: $e');
                          onAdDismissed();
                        }
                      },
                      onAdFailedToLoad: (error) {
                        SVProgressHUD.dismiss();
                        print('Fallback ad failed to load: $error');
                        onAdDismissed();
                      },
                    ),
                  );
                } catch (e) {
                  print('Error retrying fallback ad load: $e');
                  onAdDismissed();
                }
              },
            ),
          );
        } catch (e) {
          print('Error loading high priority interstitial ad: $e');
          onAdDismissed();
          SVProgressHUD.dismiss();
        } finally {
          // print('++++++++++++++++++++++++++++++++++++++');
        }
      }
    } else {
      onAdDismissed();
    }
  }

  static void preLoad() {
    getInterstitial();
  }

  static void _showLoadingDialog() {
    SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark);
    SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black);
    SVProgressHUD.show(status: 'Showing Ads...');
  }
}
