import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:promptly/screens/common_screen/PIX_setting_screen.dart';
import 'package:promptly/services/constant.dart';
import 'package:promptly/utils/AppTheme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/HomeController.dart';
import '../data/prompt_data.dart';
import '../data/prompt_model.dart';
import '../providers/app_state.dart';
import '../services/ShimmerLoader.dart';
import '../services/costom_tab_view.dart';
import '../utils/AppRoutes.dart';
import 'detail_screen.dart';

class HomeScreen extends GetView<HomeController> {
  AppController controllere = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        // backgroundColor:Colors.white,
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
          Spacer(),
          _buildStreakBadge(controllere),

          IconButton(
            onPressed: () {
              Get.to(() => SettingScreen());
            },
            icon: Icon(Icons.settings),
          ),
          35.horizontalSpace,
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // return _mainview(theme);
          if (controller.isLoading.value) return const ShimmerLoader();

          // If even after fallback, there is no data (or you want to force internet)
          if (controller.prompts.isEmpty) {
            return _buildNoInternetView();
          }

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
          // अगले कार्ड की झलक के लिए
          itemCount: controller.premiumPrompts.length,

          //
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
        controller.dailyDiscovery != null
            ? _buildPremiumSlider()
            : const SizedBox.shrink(),
        // 50.verticalSpace,
        // SizedBox(
        //   height: 140.h,
        //   // The only Obx you need. It watches both 'categories' list
        //   // and 'selectedCategory' value.
        //   child: Obx(() {
        //     // Senior Tip: Access the value at the very top of Obx to
        //     // explicitly tell GetX to track this variable for the entire block.
        //     final selectedCat = controller.selectedCategory.value;
        //
        //     return ListView.builder(
        //       scrollDirection: Axis.horizontal,
        //       padding: const EdgeInsets.symmetric(horizontal: 16),
        //       itemCount: controller.categories.length,
        //       itemBuilder: (context, index) {
        //         final category = controller.categories[index];
        //         final isSelected = category == selectedCat;
        //
        //         return GestureDetector(
        //           onTap: () {
        //             // Logic should stay in the controller
        //             controller.onCategorySelected(category);
        //           },
        //           child: AnimatedContainer(
        //             duration: const Duration(milliseconds: 250),
        //             curve: Curves.easeInOut,
        //             // Added curve for smoother feel
        //             margin: const EdgeInsets.only(right: 12),
        //             padding: const EdgeInsets.symmetric(
        //               horizontal: 16,
        //               vertical: 8,
        //             ),
        //             alignment: Alignment.center,
        //             decoration: BoxDecoration(
        //               // Use the locally stored isSelected
        //               color: isSelected
        //                   ? Theme.of(context).colorScheme.primary
        //                   : Colors.white.withValues(alpha: 0.1),
        //               borderRadius: BorderRadius.circular(20),
        //               border: Border.all(
        //                 color: isSelected ? Colors.transparent : Colors.white24,
        //               ),
        //             ),
        //             child: Text(
        //               category,
        //               style: TextStyle(
        //                 color: isSelected ? Colors.white : Colors.white70,
        //                 fontWeight: isSelected
        //                     ? FontWeight.bold
        //                     : FontWeight.normal,
        //                 fontSize: 13,
        //               ),
        //             ),
        //           ),
        //         );
        //       },
        //     );
        //   }),
        // ),
        50.verticalSpace,
        // Inside your build method or where you display the content
        Expanded(
          child: Obx(() {
            // 1. Safety check for loading state
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return
              CustomTabView(
              itemCount: controller.categories.length,
              selecttabcolor: AppTheme.darkTheme.colorScheme.secondary,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.withOpacity(0.99),
              // 2. Build the Tab Headers
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
              // 3. Build the Pages (The Grids)
              pageBuilder: (context, index) {
                final category = controller.categories[index];

                // Filter prompts for this specific tab's category
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
                    // Using your existing _buildPromptCard method
                    return _buildPromptCard(
                      categorySpecificPrompts[pIndex],
                      pIndex,
                    );
                  },
                );
              },

              // 4. Sync the Swipe/Click back to GetX controller
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

  Widget _buildStreakBadge(AppController state) {
    return GestureDetector(
      onTap: () => _showStreakDetails(state), // The action trigger
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: state.streakCount > 0
              ? const Color(0xFFCCFF00).withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: state.streakCount > 0
                ? const Color(0xFFCCFF00).withValues(alpha: 0.5)
                : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              size: 16,
              color: state.streakCount > 0
                  ? const Color(0xFFCCFF00)
                  : Colors.grey,
            ),
            const SizedBox(width: 4),
            Obx(
              () => Text(
                "${state.streakCount}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JetBrainsMono', // Technical vibe
                  color: state.streakCount > 0
                      ? const Color(0xFFCCFF00)
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStreakDetails(AppController state) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E), // Surface color
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. The Big Visual Reward
            const Icon(
                  Icons.local_fire_department,
                  size: 80,
                  color: Color(0xFFCCFF00),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .shimmer(color: Colors.white),

            const SizedBox(height: 16),

            Text(
              "${state.streakCount} Day Streak!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "You're on fire! Copy a prompt every day to keep the streak alive.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 32),

            // 2. The Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCCFF00),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "KEEP IT UP",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildDailyDiscovery(Prompt prompt) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.detail, arguments: prompt),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 50.w),
        height: 650.h,
        width: 1100.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFCCFF00), // clean neon edge
            width: 1.2,
          ),
          boxShadow: [
            // Inner soft aura
            BoxShadow(
              color: const Color(0xFFCCFF00).withOpacity(0.28),
              blurRadius: 4,
              spreadRadius: 0,
            ),

            // Outer diffused glow
            BoxShadow(
              color: const Color(0xFFCCFF00).withOpacity(0.14),
              blurRadius: 4,
              spreadRadius: 3,
            ),
          ],
        ),

        // Use ClipRRect to ensure the image and placeholder obey the border radius
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 2. The Cached Image Widget
              CachedNetworkImage(
                imageUrl: prompt.imageUrl,
                fit: BoxFit.cover,
                // Changed from contain to cover to fill the 650.h height better
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

              // 3. The Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),

              // 4. The Text Content
              Positioned(
                bottom: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                  ],
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
      onTap: () => Get.toNamed(AppRoutes.detail, arguments: prompt),
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
                    // ADD THESE TWO LINES for instant loading from memory
                    memCacheHeight: 400,
                    maxWidthDiskCache: 600,
                    // useOldImageOnUrlChange: true,
                    filterQuality: FilterQuality.low,
                    fadeInDuration: Duration.zero,
                    // 🔥 REMOVE FLASH
                    fadeOutDuration: Duration.zero,

                    // Faster rendering
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
                          const Icon(
                            Icons.flash_on,
                            size: 12,
                            color: Colors.red,
                          ),
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
