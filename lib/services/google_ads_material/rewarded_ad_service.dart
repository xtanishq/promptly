import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_variable.dart';

enum RewardedAdShowResult {
  completed,
  dismissed,
  unavailable,
  failedToShow,
}

class RewardedAdService {
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;
  static String? _loadedAdUnitId;

  static Future<void> preloadGenerateAd() async {
    final adUnitId = AdsVariable.rewarded_generate_ad_id;
    if (!_isValidAdUnitId(adUnitId)) return;
    if (_isLoading) return;
    if (_rewardedAd != null && _loadedAdUnitId == adUnitId) return;

    await _loadGenerateAd(adUnitId);
  }

  static Future<RewardedAdShowResult> showGenerateAd() async {
    final adUnitId = AdsVariable.rewarded_generate_ad_id;
    if (!_isValidAdUnitId(adUnitId)) {
      return RewardedAdShowResult.unavailable;
    }

    if (_rewardedAd == null || _loadedAdUnitId != adUnitId) {
      final loaded = await _loadGenerateAd(adUnitId);
      if (!loaded) {
        return RewardedAdShowResult.unavailable;
      }
    }

    final ad = _rewardedAd;
    if (ad == null) {
      return RewardedAdShowResult.unavailable;
    }

    _rewardedAd = null;
    _loadedAdUnitId = null;

    final completer = Completer<RewardedAdShowResult>();
    var rewardEarned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _triggerNextPreload();
        if (!completer.isCompleted) {
          completer.complete(
            rewardEarned
                ? RewardedAdShowResult.completed
                : RewardedAdShowResult.dismissed,
          );
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        _triggerNextPreload();
        if (!completer.isCompleted) {
          completer.complete(RewardedAdShowResult.failedToShow);
        }
      },
    );

    try {
      ad.show(
        onUserEarnedReward: (_, __) {
          rewardEarned = true;
        },
      );
    } catch (error) {
      debugPrint('Rewarded ad show threw unexpectedly: $error');
      ad.dispose();
      _triggerNextPreload();
      return RewardedAdShowResult.failedToShow;
    }

    return completer.future;
  }

  static Future<bool> _loadGenerateAd(String adUnitId) async {
    if (_isLoading) {
      while (_isLoading) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      return _rewardedAd != null && _loadedAdUnitId == adUnitId;
    }

    _isLoading = true;
    final completer = Completer<bool>();

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd?.dispose();
          _rewardedAd = ad;
          _loadedAdUnitId = adUnitId;
          _isLoading = false;
          completer.complete(true);
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          _rewardedAd = null;
          _loadedAdUnitId = null;
          _isLoading = false;
          completer.complete(false);
        },
      ),
    );

    return completer.future;
  }

  static bool _isValidAdUnitId(String value) {
    return value.isNotEmpty && value != '11';
  }

  static void _triggerNextPreload() {
    unawaited(preloadGenerateAd());
  }
}
