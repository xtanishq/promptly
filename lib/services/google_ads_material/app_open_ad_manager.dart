import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads_variable.dart';

class AppOpenAdManager {
  static AppOpenAd? appOpenAd;
  static bool _isShowingAd = false;
  static bool isLoaded = false;
  static bool dismissed = false;
  static bool shouldShowAd = true;


   void loadAd() {
     if(AdsVariable.appopen == "11"){
       return;
     }
    AppOpenAd.load(
      adUnitId: AdsVariable.appopen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          appOpenAd = ad;
          isLoaded = true;
        },
        onAdFailedToLoad: (error) {
        },
      ),
    );
  }

  static bool get isAdAvailable {
    return appOpenAd != null;
  }

   bool get isDismissed {
    return dismissed;
  }

   void showAdIfAvailable() {
    if (!shouldShowAd) {
      return;
    }
    if (appOpenAd == null) {
      dismissed = true;
      loadAd();
      return;
    }
    if (_isShowingAd) {
      return;
    }
    appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        dismissed = true;
        ad.dispose();
        appOpenAd = null;
        loadAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        appOpenAd = null;
        dismissed = true;
        loadAd();
      },
    );
    appOpenAd!.show();
    appOpenAd = null;
  }
}