import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_variable.dart';
import 'app_lifecycle_reactor.dart';
import 'app_open_ad_manager.dart';
import 'gdpr_initialized.dart';

/// ╔══════════════════════════════════════════════════════════════════════════╗
/// ║  AdsService — the single, reusable entry point for ALL ad formats.        ║
/// ║                                                                            ║
/// ║    await AdsService.instance.init();                 // once, at splash    ║
/// ║    AdsService.instance.showInterstitial(onDone: ..);                       ║
/// ║    AdsService.instance.showAppOpenIfAvailable();                           ║
/// ║    AdsService.instance.showRewarded(onReward: .., onUnavailable: ..);      ║
/// ║                                                                            ║
/// ║  All ad unit IDs + flags come from Remote Config via [AdsVariable].        ║
/// ║  Fullscreen formats are PRELOADED (App Open, Interstitial, Rewarded) so a  ║
/// ║  show is instant, and the NEXT ad is preloaded again on dismiss.           ║
/// ║  Every show is guarded: no-op for subscribers / disabled ads / unset id,   ║
/// ║  and an unavailable ad NEVER blocks the user (the callback still fires).   ║
/// ╚══════════════════════════════════════════════════════════════════════════╝
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  static const _disabledId = '11'; // sentinel used in Remote Config for "off"

  bool _initStarted = false;

  // Preloaded instances.
  final AppOpenAdManager _appOpen = AppOpenAdManager();
  InterstitialAd? _interstitialAd;
  String? _loadedInterstitialId;
  bool _preloadingInterstitial = false;
  bool _showingInterstitial = false;
  RewardedAd? _rewardedAd;
  bool _preloadingRewarded = false;

  // ── Startup ────────────────────────────────────────────────────────────────

  /// Consent (UMP) → MobileAds.initialize() → preload every fullscreen format →
  /// app-open-on-resume. No-op for subscribers / when ads are disabled. Never throws.
  Future<void> init() async {
    if (_initStarted) return;
    if (!AdsVariable.ads_enabled || AdsVariable.isPurchase.value) {
      _initStarted = true;
      return;
    }
    _initStarted = true;
    try {
      // Consent gathered first; MobileAds.initialize() runs inside (policy).
      await InitializationHelper().initialize();
      _appOpen.loadAd();        // App Open preload (reloads itself after dismiss)
      preloadInterstitial();    // Interstitial preload
      preloadRewarded();        // Rewarded preload
      AppLifecycleReactor(appOpenAdManager: _appOpen).listenToAppStateChanges();
    } catch (e) {
      debugPrint('[AdsService] init error: $e');
    }
  }

  // ── Guard ────────────────────────────────────────────────────────────────

  bool _canShow(String id) =>
      AdsVariable.ads_enabled &&
      !AdsVariable.isPurchase.value &&
      id.isNotEmpty &&
      id != _disabledId;

  /// The primary interstitial unit (gate id, falling back to the high slot).
  String get _primaryInterstitialId {
    final gate = AdsVariable.gate_interstitial_ad_id;
    if (gate.isNotEmpty && gate != _disabledId) return gate;
    return AdsVariable.fullscreen_preload_high_adsId;
  }

  // ── Interstitial ───────────────────────────────────────────────────────────

  /// Preload an interstitial into memory (high → normal fallback). Safe to call
  /// repeatedly — no-ops while a load is already in flight or one is ready.
  void preloadInterstitial() {
    if (_preloadingInterstitial || _interstitialAd != null) return;
    final id = _primaryInterstitialId;
    if (!_canShow(id)) return;
    _preloadingInterstitial = true;
    _loadInterstitialInto(id, AdsVariable.fullscreen_preload_normal_adsId);
  }

  void _loadInterstitialInto(String id, String? fallbackId) {
    InterstitialAd.load(
      adUnitId: id,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loadedInterstitialId = id;
          _preloadingInterstitial = false;
        },
        onAdFailedToLoad: (_) {
          if (fallbackId != null && fallbackId != id && _canShow(fallbackId)) {
            _loadInterstitialInto(fallbackId, null); // try normal id once
          } else {
            _preloadingInterstitial = false;
          }
        },
      ),
    );
  }

  /// Shows an interstitial, then calls [onDone] (whether or not an ad showed).
  /// Uses the preloaded ad when ready (instant); otherwise loads on demand.
  /// After dismissal, the next interstitial is preloaded automatically.
  void showInterstitial({required VoidCallback onDone, String? adUnitId}) {
    final id = adUnitId ?? _primaryInterstitialId;
    if (!_canShow(id) || _showingInterstitial) {
      onDone();
      return;
    }

    // Fast path — a matching preloaded ad is ready.
    if (_interstitialAd != null && _loadedInterstitialId == id) {
      final ad = _interstitialAd!;
      _interstitialAd = null;
      _loadedInterstitialId = null;
      _presentInterstitial(ad, onDone);
      return;
    }

    // Slow path — load on demand (user explicitly chose to watch).
    _showingInterstitial = true;
    InterstitialAd.load(
      adUnitId: id,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _presentInterstitial(ad, onDone),
        onAdFailedToLoad: (_) {
          final normal = AdsVariable.fullscreen_preload_normal_adsId;
          if (normal != id && _canShow(normal)) {
            InterstitialAd.load(
              adUnitId: normal,
              request: const AdRequest(),
              adLoadCallback: InterstitialAdLoadCallback(
                onAdLoaded: (ad) => _presentInterstitial(ad, onDone),
                onAdFailedToLoad: (_) => _finishInterstitial(onDone),
              ),
            );
          } else {
            _finishInterstitial(onDone);
          }
        },
      ),
    );
  }

  void _presentInterstitial(InterstitialAd ad, VoidCallback onDone) {
    _showingInterstitial = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _finishInterstitial(onDone);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _finishInterstitial(onDone);
      },
    );
    ad.show();
  }

  void _finishInterstitial(VoidCallback onDone) {
    _showingInterstitial = false;
    onDone();
    preloadInterstitial(); // get the next one ready
  }

  // ── App Open ───────────────────────────────────────────────────────────────

  void showAppOpenIfAvailable() {
    if (!_canShow(AdsVariable.appopen)) return;
    _appOpen.showAdIfAvailable();
  }

  // ── Rewarded ───────────────────────────────────────────────────────────────

  /// Preload a rewarded ad into memory. Safe to call repeatedly.
  void preloadRewarded() {
    if (_preloadingRewarded || _rewardedAd != null) return;
    final id = AdsVariable.rewarded_generate_ad_id;
    if (!_canShow(id)) return;
    _preloadingRewarded = true;
    RewardedAd.load(
      adUnitId: id,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _preloadingRewarded = false;
        },
        onAdFailedToLoad: (_) => _preloadingRewarded = false,
      ),
    );
  }

  /// Shows a rewarded ad. [onReward] fires when the user earns the reward;
  /// [onUnavailable] fires if no ad could be shown. Uses the preloaded ad when
  /// ready, then preloads the next one on dismiss.
  void showRewarded({
    required VoidCallback onReward,
    VoidCallback? onUnavailable,
  }) {
    if (!_canShow(AdsVariable.rewarded_generate_ad_id)) {
      onUnavailable?.call();
      return;
    }
    final ad = _rewardedAd;
    if (ad == null) {
      // Not ready yet — kick off a preload for next time and report unavailable.
      onUnavailable?.call();
      preloadRewarded();
      return;
    }
    _rewardedAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preloadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        onUnavailable?.call();
        preloadRewarded();
      },
    );
    ad.show(onUserEarnedReward: (_, __) => onReward());
  }

  // ── Banner (optional) ────────────────────────────────────────────────────

  /// Builds a guarded BannerAd ready to load — returns null when ads are off.
  /// Caller is responsible for `.load()` and disposing.
  BannerAd? buildBanner({
    required String adUnitId,
    AdSize size = AdSize.banner,
    void Function(Ad)? onLoaded,
    void Function(Ad, LoadAdError)? onFailed,
  }) {
    if (!_canShow(adUnitId)) return null;
    return BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          onFailed?.call(ad, err);
        },
      ),
    );
  }
}
