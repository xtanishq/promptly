// ── RevenueCat API Keys ───────────────────────────────────────────────────────
const appleApiKey  = 'test_mPwMviDOtToJZhAdnZCFCWClkau'; // iOS (not used on Android)
const googleApiKey = 'goog_CWcJpZyNUwPwNWCLoPqNncCFUJe'; // ✅ Production Play Store key
const amazonApiKey = 'amazon_api_key';

// ── Entitlement key ───────────────────────────────────────────────────────────
// Must match the Identifier in RevenueCat → Product Catalog → Entitlements
const entitlementKey = 'promptlyPro';

// ── Subscription product IDs (RevenueCat / Play Console) ─────────────────────
const planMonthly = 'monthly'; // 20 credits on subscribe
const planYearly  = 'yearly';  // 40 credits on subscribe

// Credits given per subscription plan
const monthlyCredits = 20;
const yearlyCredits  = 40;

// ── Credit pack product IDs ───────────────────────────────────────────────────
// Create these in RevenueCat as "Non-subscription" one-time products
const creditPack300 = 'credit_pack_300'; // ₹300 → 50 credits
const creditPack600 = 'credit_pack_600'; // ₹600 → 100 credits

// Credits given per credit pack
const creditPack300Amount = 50;
const creditPack600Amount = 100;

// ── Credit gate threshold ─────────────────────────────────────────────────────
// If credits fall below this, show credit purchase screen
const lowCreditThreshold = 10;

// ── Cost per action ───────────────────────────────────────────────────────────
const generateImageCost = 5; // Credits deducted per "Generate Now" tap

// Legacy alias
const planWeek = planMonthly;
