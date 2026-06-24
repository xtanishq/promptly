import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:promptly/in_app_purchase/bloc/purchase_bloc.dart';
import 'package:promptly/in_app_purchase/iap_config.dart';
import 'package:promptly/injection.dart';
import 'package:promptly/utils/auth_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ── Colors ────────────────────────────────────────────────────────────────────
class _C {
  static const bg      = Color(0xFF0E0E0E);
  static const surface = Color(0xFF1A1A1A);
  static const gold    = Color(0xFFFFBF00);
  static const accent  = Color(0xFF00C9A7);
}

void _toast(String msg) =>
    Fluttertoast.showToast(msg: msg, gravity: ToastGravity.BOTTOM);

// ── Controller ────────────────────────────────────────────────────────────────
class _CreditController extends GetxController {
  final VoidCallback? onSuccess;
  _CreditController({this.onSuccess});

  // UI selection — works WITHOUT RevenueCat packages
  // Default: ₹300 pack selected
  RxString selectedPlanId = IapConfig.creditPack300.obs;

  RxBool isLoading = false.obs;

  // Get the credits for currently selected plan
  int get selectedCredits => selectedPlanId.value == IapConfig.creditPack600
      ? IapConfig.creditPack600Amount
      : IapConfig.creditPack300Amount;

  /// Buy the selected credit pack via the PurchaseBloc (RevenueCat under the hood).
  Future<void> buy(BuildContext context) async {
    isLoading.value = true;
    final bloc = getIt<PurchaseBloc>();
    final done = bloc.stream.firstWhere((s) =>
        s.status == PurchaseStatus.success ||
        s.status == PurchaseStatus.error ||
        s.status == PurchaseStatus.cancelled);
    bloc.add(CreditPackPurchaseRequested(selectedPlanId.value, selectedCredits));
    final result = await done;
    isLoading.value = false;
    if (result.status == PurchaseStatus.success) {
      Get.back();
      _toast('💪 $selectedCredits credits added!');
      Future.delayed(const Duration(milliseconds: 400), () => onSuccess?.call());
    } else if (result.status == PurchaseStatus.error) {
      _toast(result.error ?? 'Purchase failed. Please try again.');
    }
    // cancelled → user backed out, do nothing
  }

  /// DEBUG only — simulate credit purchase without store
  Future<void> simulateBuy() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 700));
    await AuthRepository().addCredits(selectedCredits);
    isLoading.value = false;
    Get.back();
    _toast('🧪 [DEBUG] $selectedCredits credits added!');
    Future.delayed(const Duration(milliseconds: 400), () => onSuccess?.call());
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class CreditScreen extends StatelessWidget {
  final VoidCallback? onSuccess;
  const CreditScreen({super.key, this.onSuccess});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      _CreditController(onSuccess: onSuccess),
      tag: 'credit_${UniqueKey()}',
    );

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 60.w),
                child: Column(
                  children: [
                    40.verticalSpace,
                    _buildHero(),
                    48.verticalSpace,
                    _buildWhatYouGet(),
                    40.verticalSpace,
                    _buildPackages(ctrl),
                    40.verticalSpace,
                    _buildBuyButton(ctrl),
                    24.verticalSpace,
                    _buildLegal(ctrl),
                    if (kDebugMode) _buildDebugButton(ctrl),
                    32.verticalSpace,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: _C.surface,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
              ),
              child: Icon(Icons.close_rounded, color: Colors.white70, size: 44.sp),
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFFFBF00), Color(0xFFFF8C00)]),
              borderRadius: BorderRadius.circular(40.w),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, color: Colors.white, size: 36.sp),
                12.horizontalSpace,
                Text('CREDITS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero ───────────────────────────────────────────────────────────────────
  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 200.w,
          height: 200.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
                colors: [Color(0xFFFFBF00), Color(0xFFFF6F00)]),
            boxShadow: [
              BoxShadow(
                  color: _C.gold.withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 8)
            ],
          ),
          child: Icon(Icons.bolt_rounded, color: Colors.white, size: 100.sp),
        ).animate().scale(duration: 700.ms, curve: Curves.elasticOut),
        36.verticalSpace,
        Text('Buy More Credits',
            style: TextStyle(
                color: Colors.white,
                fontSize: 68.sp,
                fontWeight: FontWeight.w800),
            textAlign: TextAlign.center)
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.15, end: 0),
        16.verticalSpace,
        Text('Each credit pack gives you extra\ngenerations & prompt unlocks.',
            style:
                TextStyle(color: Colors.white60, fontSize: 42.sp, height: 1.5),
            textAlign: TextAlign.center)
            .animate(delay: 150.ms)
            .fadeIn(duration: 600.ms),
      ],
    );
  }

  // ── What you get ───────────────────────────────────────────────────────────
  Widget _buildWhatYouGet() {
    final items = [
      (Icons.auto_awesome_rounded, '1 Credit = 1 AI Generation',
          'Each image or prompt uses 1–5 credits'),
      (Icons.bolt_rounded, 'Instant credit top-up',
          'Credits are added the moment you pay'),
      (Icons.all_inclusive_rounded, 'Credits never expire',
          'Use them whenever you want'),
    ];
    return Column(
      children: items.asMap().entries.map((e) {
        return Padding(
          padding: EdgeInsets.only(bottom: 28.h),
          child: Row(
            children: [
              Container(
                width: 110.w,
                height: 110.w,
                decoration: BoxDecoration(
                  color: _C.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(28.w),
                  border:
                      Border.all(color: _C.gold.withOpacity(0.3)),
                ),
                child: Icon(e.value.$1, color: _C.gold, size: 56.sp),
              ),
              30.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.value.$2,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 44.sp,
                            fontWeight: FontWeight.w600)),
                    6.verticalSpace,
                    Text(e.value.$3,
                        style: TextStyle(
                            color: Colors.white54, fontSize: 34.sp)),
                  ],
                ),
              ),
              Icon(Icons.check_circle_rounded,
                  color: _C.accent, size: 50.sp),
            ],
          ),
        )
            .animate(
                delay: Duration(milliseconds: 200 + e.key * 80))
            .fadeIn(duration: 450.ms)
            .slideX(begin: 0.1, end: 0);
      }).toList(),
    );
  }

  // ── Package tiles ──────────────────────────────────────────────────────────
  Widget _buildPackages(_CreditController ctrl) {
    return Column(
      children: [
        _CreditPackTile(
          ctrl: ctrl,
          label: '₹300 Pack',
          credits: IapConfig.creditPack300Amount,
          planId: IapConfig.creditPack300,
          priceLabel: '₹300',
          badge: null,
        ),
        24.verticalSpace,
        _CreditPackTile(
          ctrl: ctrl,
          label: '₹600 Pack',
          credits: IapConfig.creditPack600Amount,
          planId: IapConfig.creditPack600,
          priceLabel: '₹600',
          badge: 'BEST VALUE',
        ),
      ],
    );
  }

  // ── Buy button ─────────────────────────────────────────────────────────────
  Widget _buildBuyButton(_CreditController ctrl) {
    return Obx(() {
      final loading = ctrl.isLoading.value;
      return GestureDetector(
        onTap: loading ? null : () => ctrl.buy(Get.context!),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 180.h,
          decoration: BoxDecoration(
            gradient: loading
                ? const LinearGradient(
                    colors: [Color(0xFF8A6800), Color(0xFF6A5000)])
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFBF00), Color(0xFFFF8C00)],
                  ),
            borderRadius: BorderRadius.circular(40.w),
            boxShadow: [
              BoxShadow(
                color: _C.gold.withOpacity(loading ? 0.15 : 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 56.w,
                    height: 56.w,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded,
                          color: Colors.white, size: 56.sp),
                      16.horizontalSpace,
                      Text('Buy Credits Now',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 58.sp,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
          ),
        ),
      );
    }).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  // ── Legal row ──────────────────────────────────────────────────────────────
  Widget _buildLegal(_CreditController ctrl) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w)),
          child: Text('Restore',
              style: TextStyle(color: Colors.white38, fontSize: 34.sp)),
        ),
        if (Platform.isAndroid) ...[
          Text('·',
              style: TextStyle(color: Colors.white24, fontSize: 36.sp)),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w)),
            child: Text('Manage',
                style: TextStyle(color: Colors.white38, fontSize: 34.sp)),
          ),
        ],
      ],
    );
  }

  // ── Debug button ───────────────────────────────────────────────────────────
  Widget _buildDebugButton(_CreditController ctrl) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: GestureDetector(
        onTap: ctrl.simulateBuy,
        child: Container(
          width: double.infinity,
          height: 140.h,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(28.w),
            border: Border.all(
                color: Colors.orange.withOpacity(0.5), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bug_report_rounded,
                  color: Colors.orange, size: 40.sp),
              14.horizontalSpace,
              Text('🧪 [DEBUG] Simulate Credit Buy',
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Individual pack tile ──────────────────────────────────────────────────────
class _CreditPackTile extends StatelessWidget {
  final _CreditController ctrl;
  final String label;
  final int credits;
  final String planId;    // creditPack300 or creditPack600
  final String priceLabel;
  final String? badge;

  const _CreditPackTile({
    required this.ctrl,
    required this.label,
    required this.credits,
    required this.planId,
    required this.priceLabel,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = ctrl.selectedPlanId.value == planId;

      return GestureDetector(
        // ← Always works, no null check needed
        onTap: () => ctrl.selectedPlanId.value = planId,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.all(44.w),
          decoration: BoxDecoration(
            color: isSelected ? _C.gold.withOpacity(0.1) : _C.surface,
            borderRadius: BorderRadius.circular(36.w),
            border: Border.all(
              color: isSelected ? _C.gold : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: _C.gold.withOpacity(0.2), blurRadius: 20)]
                : [],
          ),
          child: Row(
            children: [
              // Radio circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFFFBF00), Color(0xFFFF8C00)])
                      : null,
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.white30, width: 2),
                ),
                child: isSelected
                    ? Icon(Icons.check_rounded,
                        color: Colors.white, size: 36.sp)
                    : null,
              ),
              30.horizontalSpace,

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(label,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48.sp,
                              fontWeight: FontWeight.w700,
                            )),
                        if (badge != null) ...[
                          12.horizontalSpace,
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: _C.gold,
                              borderRadius: BorderRadius.circular(20.w),
                            ),
                            child: Text(badge!,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w800,
                                )),
                          ),
                        ],
                      ],
                    ),
                    10.verticalSpace,
                    Text('$credits credits included',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 36.sp)),
                  ],
                ),
              ),

              // Price (real from RevenueCat if available, else hardcoded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    priceLabel,
                    style: TextStyle(
                      color: isSelected ? _C.gold : Colors.white,
                      fontSize: 50.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text('one-time',
                      style:
                          TextStyle(color: Colors.white38, fontSize: 30.sp)),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
