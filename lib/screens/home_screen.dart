import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:get/get.dart';
import 'package:promptly/in_app_purchase/bloc/purchase_bloc.dart';
import 'package:promptly/in_app_purchase/screens/credit_screen.dart';
import 'package:promptly/in_app_purchase/screens/subscription_screen.dart' show UpsellScreen;
import 'package:promptly/in_app_purchase/iap_config.dart';
import 'package:promptly/screens/common_screen/PIX_setting_screen.dart';
import 'package:promptly/services/constant.dart';
import 'package:promptly/services/ShimmerLoader.dart';
import 'package:promptly/services/costom_tab_view.dart';
import 'package:promptly/utils/AppRoutes.dart';
import 'package:promptly/utils/AppTheme.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/HomeController.dart';
import '../data/prompt_model.dart';

class HomeScreen extends GetView<HomeController> {

  // ── Open a prompt ───────────────────────────────────────────────────────────
  /// Browsing is always free — tapping a prompt opens its detail directly.
  /// Monetization is handled at the *action* (Copy / use) inside the detail
  /// screen via [UsageGateService]. PRO / credit badges in the AppBar remain
  /// the upsell entry points.
  void _openPrompt(Prompt prompt) {
    Get.toNamed(AppRoutes.detail, arguments: prompt);
  }

  // ── Open subscription screen directly ───────────────────────────────────────
  void _openSubscriptionScreen() {
    Get.to(
      () => const UpsellScreen(item: false),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 350),
    );
  }

  // ── Open credit screen directly ─────────────────────────────────────────────
  void _openCreditScreen() {
    Get.to(
      () => const CreditScreen(),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        actions: [
          40.horizontalSpace,
          const Text(
            "PROMPTLY",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),

          // ── Credits badge (always visible, tappable to buy more) ──────────
          BlocBuilder<PurchaseBloc, PurchaseState>(builder: (context, state) {
            final credits = state.credits;
            return GestureDetector(
              onTap: _openCreditScreen,
              child: Container(
                margin: EdgeInsets.only(right: 16.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: credits < IapConfig.lowCreditThreshold
                        ? Colors.orange
                        : const Color(0xFFCCFF00),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      color: credits < IapConfig.lowCreditThreshold
                          ? Colors.orange
                          : const Color(0xFFCCFF00),
                      size: 36.sp,
                    ),
                    8.horizontalSpace,
                    Text(
                      '$credits',
                      style: TextStyle(
                        color: credits < IapConfig.lowCreditThreshold
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // ── PRO badge (only shows when NOT subscribed) ────────────────────
          BlocBuilder<PurchaseBloc, PurchaseState>(builder: (context, state) {
            if (state.isSubscribed) return const SizedBox.shrink();
            return GestureDetector(
              onTap: _openSubscriptionScreen,
              child: Container(
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB066FE), Color(0xFF8A2BE2)],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium_rounded,
                        color: const Color(0xFFCCFF00), size: 36.sp),
                    8.horizontalSpace,
                    Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2000.ms, color: Colors.white24),
            );
          }),

          20.horizontalSpace,

          IconButton(
            onPressed: () => Get.to(() => const SettingScreen()),
            icon: const Icon(Icons.settings),
          ),
          15.horizontalSpace,
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) return const ShimmerLoader();
          if (controller.prompts.isEmpty) return _buildNoInternetView();
          return _mainview(theme);
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.surpriseMe,
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.shuffle),
        label: const Text("Surprise Me"),
      ),
    );
  }

  // ── Sub-widgets ─────────────────────────────────────────────────────────────

  Widget _buildNoInternetView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text("Whoops! No Connection", style: TextStyle(fontSize: 18)),
          const Text("Please check your internet and try again."),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.loadRemoteData(),
            child: const Text("RETRY"),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSlider() {
    return SizedBox(
      height: 750.h,
      child: Obx(
        () => PageView.builder(
          controller: PageController(viewportFraction: 1.01),
          itemCount: controller.premiumPrompts.length,
          physics: const PageScrollPhysics(),
          itemBuilder: (context, index) {
            final prompt = controller.premiumPrompts[index];
            return _buildDailyDiscovery(prompt);
          },
        ),
      ),
    );
  }

  Widget _mainview(final theme) {
    return Column(
      children: [
        20.verticalSpace,
        controller.premiumPrompts.isNotEmpty
            ? _buildPremiumSlider()
            : const SizedBox.shrink(),
        50.verticalSpace,
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomTabView(
              itemCount: controller.categories.length,
              selecttabcolor: AppTheme.darkTheme.colorScheme.secondary,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.withOpacity(0.99),
              tabBuilder: (context, index) {
                return Tab(
                  height: 140.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 35.w,
                    ),
                    child: Text(
                      controller.categories[index],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              },
              pageBuilder: (context, index) {
                final category = controller.categories[index];
                final List<Prompt> categorySpecificPrompts = category == 'All'
                    ? controller.prompts
                    : controller.prompts
                          .where((p) => p.category == category)
                          .toList();

                return MasonryGridView.builder(
                  itemCount: categorySpecificPrompts.length,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.h,
                  ),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 12,
                  gridDelegate:
                      const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                  itemBuilder: (context, pIndex) {
                    return _buildPromptCard(
                      categorySpecificPrompts[pIndex],
                      pIndex,
                    );
                  },
                );
              },
              onPositionChange: (index) {
                final category = controller.categories[index];
                controller.onCategorySelected(category);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDailyDiscovery(Prompt prompt) {
    return GestureDetector(
      onTap: () => _openPrompt(prompt),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 50.w),
        height: 650.h,
        width: 1100.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCCFF00), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCCFF00).withOpacity(0.28),
              blurRadius: 4,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFFCCFF00).withOpacity(0.14),
              blurRadius: 4,
              spreadRadius: 3,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: prompt.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                maxHeightDiskCache: 500,
                maxWidthDiskCache: 600,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: const Center(child: CupertinoActivityIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.darkTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "DAILY DISCOVERY",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPromptCard(Prompt prompt, int index) {
    return GestureDetector(
      onTap: () => _openPrompt(prompt),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: prompt.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  CachedNetworkImage(
                    imageUrl: prompt.imageUrl,
                    memCacheHeight: 400,
                    maxWidthDiskCache: 600,
                    filterQuality: FilterQuality.low,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[900]!,
                      highlightColor: Colors.grey[800]!,
                      child: Container(height: 150, color: Colors.black),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 22.w),
                    child: Container(
                      width: 310.w,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: Row(
                        children: [
                          10.horizontalSpace,
                          const Icon(Icons.flash_on, size: 12, color: Colors.red),
                          Text(
                            " ${prompt.genCount} used",
                            style: TextStyle(
                              fontSize: 32.sp,
                              color: Colors.yellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
