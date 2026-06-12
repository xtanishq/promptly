import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:promptly/in_app_purchase/purchase_controller.dart';
import 'package:promptly/services/constant.dart';
import 'package:promptly/services/google_ads_material/ads_variable.dart';
import 'package:promptly/screens/common_screen/privacy_policy.dart';
import 'package:promptly/screens/common_screen/terms_screen.dart';

// ── Local subscription-screen controller ─────────────────────────────────────

class _SubController extends GetxController {
  final bool fromFeature;
  final VoidCallback? onSuccess; // ← called after successful purchase
  _SubController(this.fromFeature, {this.onSuccess});

  Rx<Offerings?> offerings = Rx<Offerings?>(null);
  Rx<Package?> selectedPackage = Rx<Package?>(null);
  RxBool isLoading = false.obs;
  RxBool isClose = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchOfferings();
    Future.delayed(const Duration(seconds: 3), () => isClose.value = true);
  }

  Future<void> _fetchOfferings() async {
    try {
      final result = await Purchases.getOfferings();
      offerings.value = result;
      final packages = result.current?.availablePackages ?? [];
      if (packages.isNotEmpty) selectedPackage.value = packages.first;
    } catch (e) {
      debugPrint('[SubScreen] fetchOfferings error: $e');
    }
  }

  Future<void> purchase(BuildContext context) async {
    if (selectedPackage.value == null) return;
    isLoading.value = true;
    final ctrl = Get.find<PurchaseController>();
    await ctrl.buySubscription(
      package: selectedPackage.value!,
      onSuccess: () {
        isLoading.value = false;
        Get.back(); // close subscription screen
        _showSuccessAndNavigate();
      },
      onError: (msg) {
        isLoading.value = false;
        appToast(msg);
      },
    );
    isLoading.value = false;
  }

  Future<void> restore() async {
    isLoading.value = true;
    final ctrl = Get.find<PurchaseController>();
    await ctrl.restorePurchases(
      onSuccess: () {
        isLoading.value = false;
        appToast('Subscription restored!');
        Get.back();
      },
      onError: (msg) {
        isLoading.value = false;
        appToast('No active subscription found.');
      },
    );
  }

  void _showSuccessAndNavigate() {
    appToast('🎉 Subscribed! Credits added to your account.');
    // Small delay so toast is visible before navigating
    Future.delayed(const Duration(milliseconds: 400), () {
      onSuccess?.call();
    });
  }

  /// DEBUG ONLY — simulates a successful purchase without hitting the store.
  Future<void> simulatePurchase() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    final purchaseCtrl = Get.find<PurchaseController>();
    await purchaseCtrl.addCredits(AdsVariable.subscriptionBonus);
    AdsVariable.isPurchase.value = true;
    isLoading.value = false;
    Get.back();
    appToast('🧪 [DEBUG] Subscribed! Credits added.');
    Future.delayed(const Duration(milliseconds: 400), () {
      onSuccess?.call();
    });
  }

  void goBack() {
    if (fromFeature) {
      Get.back();
    } else {
      Get.offAllNamed('/home');
    }
  }
}

// ── The Screen ────────────────────────────────────────────────────────────────

class UpsellScreen extends StatelessWidget {
  final bool item;         // true = came from a feature tap
  final String? videoUrl;  // legacy compat
  final VoidCallback? onSuccess; // called after successful purchase → navigates to destination

  const UpsellScreen({super.key, required this.item, this.videoUrl, this.onSuccess});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      _SubController(item, onSuccess: onSuccess),
      tag: 'sub_${UniqueKey()}',
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (_) => ctrl.goBack(),
      child: Scaffold(
        backgroundColor: _SubTheme.backgroundDark,
        body: Stack(
          children: [
            // ── Decorative background blobs ──────────────────────────────
            _BgBlob(color: _SubTheme.accentPurple, top: -80, right: -60),
            _BgBlob(color: const Color(0xFF4A1090), bottom: -60, left: -40),

            // ── Main content ─────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  _AppBar(ctrl: ctrl),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 60.w),
                      child: Column(
                        children: [
                          40.verticalSpace,
                          _HeroSection(),
                          48.verticalSpace,
                          _FeatureList(),
                          40.verticalSpace,
                          _PackageSelector(ctrl: ctrl),
                          40.verticalSpace,
                          _SubscribeButton(ctrl: ctrl),
                          28.verticalSpace,
                          _RenewalNote(ctrl: ctrl),
                          24.verticalSpace,
                          _LegalRow(ctrl: ctrl, context: context),
                          // ── Debug-only simulate button ──────────────────
                          if (kDebugMode) _DebugSimulateButton(ctrl: ctrl),
                          32.verticalSpace,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SubTheme {
  static const Color backgroundDark = Color(0xFF121212);
  static const Color accentPurple = Color(0xFF8A2BE2);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceElevated = Color(0xFF2A2A2A);
  static const Color brandYellow = Color(0xFFCCFF00);
  static const Color textMuted = Color(0xFF9E9E9E);
}

class _BgBlob extends StatelessWidget {
  final Color color;
  final double? top, bottom, left, right;
  const _BgBlob({required this.color, this.top, this.bottom, this.left, this.right});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 380.w,
        height: 380.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.35), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final _SubController ctrl;
  const _AppBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
      child: Row(
        children: [
          Obx(() => (ctrl.isClose.value)
              ? GestureDetector(
                  onTap: ctrl.goBack,
                  child: Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                      color: _SubTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Icon(Icons.close_rounded, color: Colors.white70, size: 44.sp),
                  ),
                )
              : const SizedBox.shrink()),
          const Spacer(),
          // Crown badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB066FE), Color(0xFF8A2BE2)],
              ),
              borderRadius: BorderRadius.circular(40.w),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: _SubTheme.brandYellow, size: 36.sp),
                12.horizontalSpace,
                Text('PRO', style: TextStyle(
                  color: Colors.white,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Glowing icon
        Container(
          width: 200.w,
          height: 200.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF8A2BE2), Color(0xFF4A1090)],
            ),
            boxShadow: [
              BoxShadow(
                color: _SubTheme.accentPurple.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Icon(Icons.bolt_rounded, color: _SubTheme.brandYellow, size: 100.sp),
        ).animate().scale(duration: 700.ms, curve: Curves.elasticOut),

        36.verticalSpace,

        Text(
          'Unlock Promptly Pro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 72.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.15, end: 0),

        16.verticalSpace,

        Text(
          'Access unlimited trending AI prompts\nand get 10 credits instantly.',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 44.sp,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ).animate(delay: 150.ms).fadeIn(duration: 600.ms),
      ],
    );
  }
}

class _FeatureList extends StatelessWidget {
  static const _features = [
    (Icons.all_inclusive_rounded,   'Unlimited Prompt Access',      'Browse every category, no restrictions'),
    (Icons.auto_awesome_rounded,    '10 Credits Instantly',         'Credited to your account on subscribe'),
    (Icons.block_rounded,           'Ad-Free Experience',           'Zero interruptions, pure creativity'),
    (Icons.cloud_sync_rounded,      'Priority Support',             'Fast responses from our team'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _features
          .asMap()
          .entries
          .map((e) => _FeatureRow(
                icon: e.value.$1,
                title: e.value.$2,
                sub: e.value.$3,
                delay: e.key * 80,
              ))
          .toList(),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final int delay;
  const _FeatureRow({required this.icon, required this.title, required this.sub, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 28.h),
      child: Row(
        children: [
          Container(
            width: 110.w,
            height: 110.w,
            decoration: BoxDecoration(
              color: _SubTheme.accentPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(28.w),
              border: Border.all(color: _SubTheme.accentPurple.withOpacity(0.3)),
            ),
            child: Icon(icon, color: _SubTheme.accentPurple, size: 56.sp),
          ),
          30.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  color: Colors.white,
                  fontSize: 46.sp,
                  fontWeight: FontWeight.w600,
                )),
                6.verticalSpace,
                Text(sub, style: TextStyle(
                  color: Colors.white54,
                  fontSize: 36.sp,
                )),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: _SubTheme.brandYellow, size: 50.sp),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 200 + delay)).fadeIn(duration: 450.ms).slideX(begin: 0.1, end: 0);
  }
}

class _PackageSelector extends StatelessWidget {
  final _SubController ctrl;
  const _PackageSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.offerings.value == null) {
        return _ShimmerPackage();
      }
      final packages = ctrl.offerings.value!.current?.availablePackages ?? [];
      if (packages.isEmpty) {
        return Center(child: Text('No plans available', style: TextStyle(color: Colors.white54, fontSize: 40.sp)));
      }
      return Column(
        children: packages.map((pkg) => _PackageTile(pkg: pkg, ctrl: ctrl)).toList(),
      );
    });
  }
}

class _PackageTile extends StatelessWidget {
  final Package pkg;
  final _SubController ctrl;
  const _PackageTile({required this.pkg, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = ctrl.selectedPackage.value?.identifier == pkg.identifier;
      final isMonthly = pkg.packageType == PackageType.monthly;
      return GestureDetector(
        onTap: () => ctrl.selectedPackage.value = pkg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.only(bottom: 28.h),
          padding: EdgeInsets.all(44.w),
          decoration: BoxDecoration(
            color: isSelected ? _SubTheme.accentPurple.withOpacity(0.12) : _SubTheme.surface,
            borderRadius: BorderRadius.circular(36.w),
            border: Border.all(
              color: isSelected ? _SubTheme.accentPurple : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: _SubTheme.accentPurple.withOpacity(0.25), blurRadius: 20, spreadRadius: 2)]
                : [],
          ),
          child: Row(
            children: [
              // Left: radio circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? const LinearGradient(colors: [Color(0xFFB066FE), Color(0xFF8A2BE2)])
                      : null,
                  border: isSelected ? null : Border.all(color: Colors.white30, width: 2),
                ),
                child: isSelected
                    ? Icon(Icons.check_rounded, color: Colors.white, size: 36.sp)
                    : null,
              ),
              30.horizontalSpace,

              // Middle: plan name + billing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isMonthly ? 'Monthly Plan' : 'Yearly Plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isSelected) ...[
                          14.horizontalSpace,
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: _SubTheme.brandYellow,
                              borderRadius: BorderRadius.circular(20.w),
                            ),
                            child: Text('SELECTED', style: TextStyle(
                              color: Colors.black,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            )),
                          ),
                        ],
                      ],
                    ),
                    10.verticalSpace,
                    Text(
                      '${AdsVariable.subscriptionBonus} credits included · ${isMonthly ? 'Renews monthly' : 'Renews yearly'}',
                      style: TextStyle(color: Colors.white54, fontSize: 36.sp),
                    ),
                  ],
                ),
              ),

              // Right: price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    pkg.storeProduct.priceString,
                    style: TextStyle(
                      color: isSelected ? _SubTheme.brandYellow : Colors.white,
                      fontSize: 52.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    isMonthly ? '/ month' : '/ year',
                    style: TextStyle(color: Colors.white38, fontSize: 32.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ShimmerPackage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(2, (i) => Container(
        margin: EdgeInsets.only(bottom: 28.h),
        height: 180.h,
        decoration: BoxDecoration(
          color: _SubTheme.surface,
          borderRadius: BorderRadius.circular(36.w),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(color: Colors.white10, duration: 1200.ms)),
    );
  }
}

class _SubscribeButton extends StatelessWidget {
  final _SubController ctrl;
  const _SubscribeButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = ctrl.isLoading.value;
      return GestureDetector(
        onTap: loading ? null : () => ctrl.purchase(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 180.h,
          decoration: BoxDecoration(
            gradient: loading
                ? const LinearGradient(colors: [Color(0xFF5A1DB0), Color(0xFF4A0D90)])
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB066FE), Color(0xFF8A2BE2), Color(0xFF621FB3)],
                  ),
            borderRadius: BorderRadius.circular(40.w),
            boxShadow: [
              BoxShadow(
                color: _SubTheme.accentPurple.withOpacity(loading ? 0.2 : 0.45),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 60.w,
                    height: 60.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, color: _SubTheme.brandYellow, size: 56.sp),
                      16.horizontalSpace,
                      Text(
                        'Subscribe Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 60.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

class _RenewalNote extends StatelessWidget {
  final _SubController ctrl;
  const _RenewalNote({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pkg = ctrl.selectedPackage.value;
      if (pkg == null) return const SizedBox.shrink();
      final isMonthly = pkg.packageType == PackageType.monthly;
      return Text(
        isMonthly
            ? 'Subscription renews automatically monthly at ${pkg.storeProduct.priceString}. Cancel anytime.'
            : 'Subscription renews automatically yearly at ${pkg.storeProduct.priceString}. Cancel anytime.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white38, fontSize: 33.sp, height: 1.5),
      );
    });
  }
}

class _LegalRow extends StatelessWidget {
  final _SubController ctrl;
  final BuildContext context;
  const _LegalRow({required this.ctrl, required this.context});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        _legalBtn('Privacy Policy', () => Get.to(() => const PrivacyPolicy())),
        Text('·', style: TextStyle(color: Colors.white24, fontSize: 36.sp)),
        _legalBtn('Terms of Use', () => Get.to(() => const TermsOfUse())),
        Text('·', style: TextStyle(color: Colors.white24, fontSize: 36.sp)),
        _legalBtn('Restore', ctrl.restore),
        if (Platform.isAndroid) ...[
          Text('·', style: TextStyle(color: Colors.white24, fontSize: 36.sp)),
          _legalBtn('Manage Sub', () async {
            const url = 'https://play.google.com/store/account/subscriptions';
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            }
          }),
        ],
      ],
    );
  }

  Widget _legalBtn(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 16.w)),
      child: Text(
        label,
        style: TextStyle(color: Colors.white38, fontSize: 34.sp),
      ),
    );
  }
}

// ── Debug-only simulate button ────────────────────────────────────────────────
// Sirf debug mode mein dikhta hai (flutter run). Production build mein NAHI dikhta.

class _DebugSimulateButton extends StatelessWidget {
  final _SubController ctrl;
  const _DebugSimulateButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: GestureDetector(
        onTap: ctrl.simulatePurchase,
        child: Container(
          width: double.infinity,
          height: 140.h,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(28.w),
            border: Border.all(
              color: Colors.orange.withOpacity(0.5),
              width: 1.5,
              // dashed effect via strokeAlign
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bug_report_rounded, color: Colors.orange, size: 40.sp),
              14.horizontalSpace,
              Text(
                '🧪 [DEBUG] Simulate Purchase',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 38.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
