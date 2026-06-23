/// ╔══════════════════════════════════════════════════════════════════════════╗
/// ║  IAP CONFIG — the ONLY file you edit to reuse this template in a new app.  ║
/// ║  Fill in your RevenueCat keys, entitlement id, and product ids. Nothing    ║
/// ║  else in the in_app_purchase/ module references raw strings.               ║
/// ╚══════════════════════════════════════════════════════════════════════════╝
class IapConfig {
  // ── RevenueCat API keys (per app) ──────────────────────────────────────────
  static const String androidApiKey = 'goog_CWcJpZyNUwPwNWCLoPqNncCFUJe'; // Play Store
  static const String appleApiKey   = 'test_mPwMviDOtToJZhAdnZCFCWClkau'; // TODO(prod): real iOS key
  static const String amazonApiKey  = 'amazon_api_key';

  // ── Entitlement (must match RevenueCat → Entitlements identifier) ───────────
  static const String entitlementKey = 'promptlyPro';

  // ── Subscription product ids (RevenueCat / Play Console / App Store) ────────
  static const String planMonthly = 'monthly';
  static const String planYearly  = 'yearly';

  // Credits granted on each subscription tier.
  static const int monthlyCredits = 20;
  static const int yearlyCredits  = 40;

  // ── One-time credit-pack product ids ───────────────────────────────────────
  static const String creditPack300 = 'credit_pack_300';
  static const String creditPack600 = 'credit_pack_600';

  static const int creditPack300Amount = 50;
  static const int creditPack600Amount = 100;

  // ── Economy tuning ─────────────────────────────────────────────────────────
  /// Credits deducted per gated action (Copy / use a prompt).
  static const int creditCostPerUse = 1;

  /// Credits deducted by the heavier "Generate" feature.
  static const int generateImageCost = 5;

  /// Below this balance, the credit-purchase screen is suggested.
  static const int lowCreditThreshold = 10;
}
