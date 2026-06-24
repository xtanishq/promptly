import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:promptly/in_app_purchase/screens/subscription_screen.dart' show UpsellScreen;
import 'package:promptly/services/google_ads_material/ads_service.dart';
import 'package:promptly/services/google_ads_material/ads_variable.dart';

/// The free-tier usage gate for non-subscribers. Browsing is always free —
/// this runs only on an *action* (Copy / use a prompt). Credits are NOT used
/// here (they're spent only by the backend-metered Generate feature).
///
/// Order of precedence:
///   1. Subscriber (`isPurchase`)  → allow, unlimited.
///   2. Ads disabled (remote)      → allow (kept usable).
///   3. Daily free uses remaining  → consume one, allow.
///   4. Out of free uses           → choice sheet: Watch a short ad / Go Premium.
///      Dismissing the sheet cancels the action — it never hard-crashes.
class UsageGateService {
  // SharedPrefs keys
  static const _kUsageCount = 'gate_usage_count';
  static const _kUsageDate  = 'gate_usage_date'; // stored as "yyyy-MM-dd"

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Call this before any gated action (Copy / use a prompt).
  static Future<void> checkAndProceed({
    required BuildContext context,
    required VoidCallback onAllowed,
  }) async {
    // 1. Subscribers bypass everything (read via the AdsVariable bridge).
    if (AdsVariable.isPurchase.value) {
      onAllowed();
      return;
    }

    // 2. Master kill-switch — if ads are disabled remotely, keep the app usable.
    if (!AdsVariable.ads_enabled) {
      final remaining = await _getRemainingUses();
      if (remaining > 0) await _decrementUsage();
      onAllowed();
      return;
    }

    // 3. Spend a daily free use if available.
    final remaining = await _getRemainingUses();
    if (remaining > 0) {
      await _decrementUsage();
      onAllowed();
      return;
    }

    // 4. Out of free uses → let the user choose how to continue.
    _showChoiceSheet(onAllowed);
  }

  /// Returns how many free uses the user has left today.
  static Future<int> getRemainingUses() async => _getRemainingUses();

  /// For testing / debug: resets today's usage count to zero.
  static Future<void> resetUsageForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kUsageCount, 0);
    await prefs.setString(_kUsageDate, _today());
  }

  // ── Choice sheet ───────────────────────────────────────────────────────────

  static void _showChoiceSheet(VoidCallback onAllowed) {
    Get.bottomSheet(
      _GateSheet(
        onWatchAd: () {
          Get.back();
          AdsService.instance.showInterstitial(onDone: onAllowed);
        },
        onGoPremium: () {
          Get.back();
          Get.to(
            () => UpsellScreen(item: true, onSuccess: onAllowed),
            transition: Transition.downToUp,
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
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
}

// ── Sheet UI ───────────────────────────────────────────────────────────────

class _GateSheet extends StatelessWidget {
  final VoidCallback onWatchAd;
  final VoidCallback onGoPremium;

  const _GateSheet({required this.onWatchAd, required this.onGoPremium});

  static const _accent = Color(0xFFCCFF00);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "You're out of free uses today",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Pick how you want to continue',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 22),

          _OptionTile(
            icon: Icons.play_circle_fill_rounded,
            iconColor: _accent,
            title: 'Watch a short ad',
            subtitle: 'Continue for free',
            onTap: onWatchAd,
          ),
          const SizedBox(height: 12),

          _OptionTile(
            icon: Icons.workspace_premium_rounded,
            iconColor: _accent,
            title: 'Go Premium',
            subtitle: 'Unlimited uses, zero ads',
            highlighted: true,
            onTap: onGoPremium,
          ),

          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Maybe later',
              style: TextStyle(color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool highlighted;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: highlighted
              ? const LinearGradient(
                  colors: [Color(0xFFB066FE), Color(0xFF8A2BE2)],
                )
              : null,
          color: highlighted ? null : const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlighted ? Colors.transparent : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
