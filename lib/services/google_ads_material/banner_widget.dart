import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

import '../constant.dart';
import 'ads_variable.dart';
// import '../in_app_purchase/purchase_controller.dart';
// import '../service/constant.dart';

class BannerWidget extends StatefulWidget {
  final String adsId;

  const BannerWidget({super.key, required this.adsId});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final ValueNotifier<bool> _isLoaded = ValueNotifier<bool>(false);
  // final PurchaseController purchaseController = Get.find<PurchaseController>();
  BannerAd? _anchoredAdaptiveAd;
  AdSize? _adSize;
  double? _adWidth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAd();
    });
  }

  Future<void> _loadAd() async {
    if (!AdsVariable.ads_enabled ||
        AdsVariable.isPurchase.value ||
        widget.adsId == '11') {
      return;
    }

    await _anchoredAdaptiveAd?.dispose();
    _anchoredAdaptiveAd = null;
    _isLoaded.value = false;

    _adWidth = MediaQuery.of(context).size.width;

    if (_adWidth == null) return;

    try {
      _adSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        _adWidth!.truncate(),
      );

      if (_adSize == null) {
        print('Unable to get adaptive banner size.');
        return;
      }

      _anchoredAdaptiveAd = BannerAd(
        adUnitId: widget.adsId,
        size: _adSize!,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) async {
            print('Adaptive banner loaded: ${ad.responseInfo}');
            BannerAd bannerAd = (ad as BannerAd);
            final AdSize? size = await bannerAd.getPlatformAdSize();
            if (size == null) {
              print('Error: getPlatformAdSize() returned null for $bannerAd');
              return;
            }
            _anchoredAdaptiveAd = bannerAd;
            _adSize = size;
            _isLoaded.value = true;
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Adaptive banner failedToLoad: $error');
            ad.dispose();
            _isLoaded.value = false;
          },
        ),
      );

      await _anchoredAdaptiveAd!.load();
    } catch (e) {
      print(e);
    }
  }


  @override
  void dispose() {
    _anchoredAdaptiveAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoaded,
      builder: (BuildContext context, bool value, Widget? child) {
        return Obx(() {
          if (!AdsVariable.ads_enabled ||
              AdsVariable.isPurchase.value ||
              widget.adsId == '11') {
            return const SizedBox.shrink();
          }
          return _buildAdWidget();
        });
      },
    );
  }

  Widget _buildAdWidget() {
    if (_isLoaded.value && _anchoredAdaptiveAd != null && _adSize != null && _adWidth != null) {
      return Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: _adWidth,
          height: _adSize!.height.toDouble(),
          child: AdWidget(ad: _anchoredAdaptiveAd!),
        ),
      );
    } else {
      return widget.adsId != '11'
          ? Shimmer.fromColors(
        baseColor: appBackgroundColor,
        highlightColor: appColor,
        child: Container(
          height: MediaQuery.of(context).size.height / 13.5,
          width: double.infinity,
          color: CupertinoColors.white,
        ),
      )
          : const SizedBox.shrink();
    }
  }
}
