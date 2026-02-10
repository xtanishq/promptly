import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum AdLoadState { loading, failed, loaded }

class NativeAdManager extends GetxController {
  Rx<NativeAd?> nativeAd = Rx<NativeAd?>(null);
  Rx<NativeAd?> languageScreenNativeAd = Rx<NativeAd?>(null);

  Rx<AdLoadState> adLoadState = AdLoadState.failed.obs;
  Rx<AdLoadState> languageScreenAdLoadState = AdLoadState.failed.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    disposeNativeAd();
    disposeLanguageScreenAd();
    super.onClose();
  }

  void loadNativeAd(String adUnitId) {
    if (_isAdUnitIdValid(adUnitId)) {
      _loadAd(adUnitId, 'smallNativeAds', nativeAd, adLoadState);
    } else {
      adLoadState.value = AdLoadState.failed;
    }
  }

  void loadLanguageScreenAd(String adUnitId) {
    if (_isAdUnitIdValid(adUnitId)) {
      _loadAd(adUnitId, 'fullNativeAds', languageScreenNativeAd, languageScreenAdLoadState);
    } else {
      languageScreenAdLoadState.value = AdLoadState.failed;
    }
  }

  void _loadAd(String adUnitId, String factoryId, Rx<NativeAd?> ad, Rx<AdLoadState> loadState) {
    try {
      loadState.value = AdLoadState.loading;
      ad.value?.dispose();

      ad.value = NativeAd(
        adUnitId: adUnitId,
        factoryId: factoryId,
        listener: NativeAdListener(
          onAdLoaded: (loadedAd) {
            loadState.value = AdLoadState.loaded;
          },
          onAdFailedToLoad: (failedAd, error) {
            loadState.value = AdLoadState.failed;
            failedAd?.dispose();
            print('Ad failed to load: $error');
          },
        ),
        request: const AdRequest(),
      );

      ad.value!.load();
    } catch (e) {
      loadState.value = AdLoadState.failed;
      print('Exception while loading ad: $e');
    }
  }

  void disposeNativeAd() {
    adLoadState.value = AdLoadState.failed;
    nativeAd.value?.dispose();
  }

  void disposeLanguageScreenAd() {
    languageScreenAdLoadState.value = AdLoadState.failed;
    languageScreenNativeAd.value?.dispose();
  }

  bool _isAdUnitIdValid(String adUnitId) {
    return adUnitId != '11';
  }
}
