import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promptly/services/google_ads_material/ads_variable.dart';

/// Manages daily free-use quota for the ads-only release.
/// After the free quota is exhausted, an interstitial ad is shown and the
/// action still continues.
///
/// Usage:
/// ```dart
/// UsageGateService.checkAndProceed(
///   context: context,
///   onAllowed: () => _doTheAction(),
/// );
/// ```
class UsageGateService {
  // SharedPrefs keys
  static const _kUsageCount = 'gate_usage_count';
  static const _kUsageDate  = 'gate_usage_date'; // stored as "yyyy-MM-dd"
  static bool _isShowingGateAd = false;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Call this before any gated action (Copy / Generate).
  /// - If user is subscribed   → calls [onAllowed] immediately.
  /// - If master switch off    → calls [onAllowed] immediately.
  /// - If free uses remain     → decrements counter, calls [onAllowed].
  /// - If quota exhausted      → shows an interstitial, then continues.
  static Future<void> checkAndProceed({
    required BuildContext context,
    required VoidCallback onAllowed,
  }) async {
    // 1. Subscribed users bypass everything
    if (AdsVariable.isPurchase.value) {
      onAllowed();
      return;
    }

    // 2. Master kill-switch (remote config can disable gate entirely)
    if (!AdsVariable.ads_enabled) {
      // If ads are disabled remotely, keep the feature usable.
      final remaining = await _getRemainingUses();
      if (remaining > 0) {
        await _decrementUsage();
      }
      onAllowed();
      return;
    }

    final remaining = await _getRemainingUses();

    if (remaining > 0) {
      await _decrementUsage();
      onAllowed();
      return;
    }

    await _showGateInterstitialThenContinue(onAllowed);
  }

  /// Returns how many free uses the user has left today.
  static Future<int> getRemainingUses() async => _getRemainingUses();

  /// For testing / debug: resets today's usage count to zero.
  static Future<void> resetUsageForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kUsageCount, 0);
    await prefs.setString(_kUsageDate, _today());
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<int> _getRemainingUses() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_kUsageDate) ?? '';

    // New day → reset counter
    if (savedDate != _today()) {
      await prefs.setInt(_kUsageCount, 0);
      await prefs.setString(_kUsageDate, _today());
    }

    final usedToday = prefs.getInt(_kUsageCount) ?? 0;
    final limit = AdsVariable.free_uses_limit;
    return (limit - usedToday).clamp(0, limit);
  }

  static Future<void> _decrementUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_kUsageCount) ?? 0;
    await prefs.setInt(_kUsageCount, used + 1);
  }

  static Future<void> _showGateInterstitialThenContinue(
    VoidCallback onAllowed,
  ) async {
    if (_isShowingGateAd) return;

    final adUnitId = AdsVariable.gate_interstitial_ad_id;
    if (adUnitId.isEmpty || adUnitId == '11') {
      onAllowed();
      return;
    }

    _isShowingGateAd = true;

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isShowingGateAd = false;
              onAllowed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isShowingGateAd = false;
              onAllowed();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          _isShowingGateAd = false;
          onAllowed();
        },
      ),
    );
  }
}
