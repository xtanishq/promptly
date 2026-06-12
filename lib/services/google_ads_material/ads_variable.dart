import 'package:get/get.dart';

class AdsVariable {

  static String mishy_ai_token = 'Bearer msy_IyALVvUxdCKbVSVueJAUfwcYyzYiOnfXU9Jp';

  static String showsubmitrating = '1';

  static int inAppFlag = 1;
  static String in_app_screen_ad_continue_ads_online = '1';

  static int creditAppFlag = 0;
  static String credit_screen_ad_continue_ads_online = '1';

  static int homeFlag = 0;
  static String home_screen_ad_continue_ads_online = '1';

  // static String fullscreen_on_in_splash_screen = '0';

  // Google Test Ad Unit IDs — BLOCKED (all ads disabled for now)
  static String fullscreen_preload_high_adsId = '11';
  static String fullscreen_preload_normal_adsId = '11';
  static String fullscreen_splash_adsId_high = '11';
  static String fullscreen_splash_adsId_normal = '11';
  static String fullscreen_in_app_adsId = '11';
  static String fullscreen_credit_adsId = '11';
  static String fullscreen_home = '11';
  static String rewarded_generate_ad_id = '11';

  static String native_intro_big = "11";
  static String native_home_small = '11';

  static String appopen = '11';

  // ── Monetization Gate ────────────────────────────────────────────────────
  /// Reactive subscription status — true when RevenueCat confirms active entitlement.
  /// When true, all usage-gating and ads are bypassed.
  static RxBool isPurchase = false.obs;
  // static RxBool isPurchase = false.obs;

  /// Reactive credit balance — updated after subscribe / buy-credits.
  static RxInt credits = 0.obs;

  /// Credits given to user immediately after subscribing.
  static int subscriptionBonus = 10;

  /// Credits awarded for each plan tier via weekly sub. Override via Remote Config.
  static int weekCredit = 10;
  static int yearCredit = 100;
  static int big_plan_credit   = 200;
  static int small_plan_credit = 50;

  /// Max free uses per day before gating kicks in.
  static int free_uses_limit = 2;

  /// Master kill-switch for ads. Remote Config can still disable ads at runtime.
  static bool ads_enabled = true;

  /// The interstitial ad ID shown at the usage gate.
  static String gate_interstitial_ad_id = 'ca-app-pub-3940256099942544/1033173712';
  // ─────────────────────────────────────────────────────────────────────────

  // Credit packs for the credit upsell screen
  static String firstCreditIdentifier = '';
  static String showOffText = '0';
  static String showIamTesterButton = '0';
  static String show_close_delay = '0';
  static String without_subscription = '0';
  static String purchaseScreenIndex = '0';
  static String show_week_price = '0';
  static Map<String, int> creditPlans = {};

  static String facebookId = "11";
  static String facebookToken = "11";
  static String nativeBGColor = "222222";
}
