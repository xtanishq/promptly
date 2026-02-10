import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:promptly/services/constant.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../data/prompt_model.dart';
import '../providers/app_state.dart';

class DetailScreen extends GetView<AppController> {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Prompt prompt = Get.arguments;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _handleShare(prompt),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: Hero(
                  tag: prompt.id,
                  child: CachedNetworkImage(
                    imageUrl: prompt.imageUrl!,
                    fit: BoxFit.contain,

                    // ⚡ INSTANT SWAP: Prevents the "loading" blink
                    useOldImageOnUrlChange: true,
                    fadeInCurve: Curves.easeIn,
                    fadeOutDuration: Duration.zero,
                    placeholderFadeInDuration: Duration.zero,

                    // 🛠️ CACHE LOCK: Ensure these match your Home Screen
                    memCacheHeight: 400,
                    // Replace with your standard card height
                    maxWidthDiskCache: 600,

                    // ⏳ ONLY SHOW IF NOT IN CACHE
                    progressIndicatorBuilder: (context, url, progress) {
                      // If it's already in memory, this builder won't even flicker
                      return _loading(progress.progress);
                    },
                    errorWidget: (context, url, error) => _errorWidget(),
                  ),
                  // Image.network(
                  //   prompt.imageUrl,
                  //   fit: BoxFit.contain,
                  //   color: Colors.black.withValues(alpha: 0.4),
                  //   colorBlendMode: BlendMode.darken,
                  // ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        prompt.category.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ).animate().slideY(begin: 0.2, end: 0).fadeIn(),

                    30.verticalSpace,

                    Container(
                      width: double.infinity,
                      height: 750.h,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(
                          (255 * 0.1).round(),
                        ), // Fix withOpacity deprecation
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          prompt.promptText,
                          style: const TextStyle(
                            fontFamily:
                                'Courier', // Monospace hack if font not loaded
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ).animate(delay: 100.ms).slideY(begin: 0.2, end: 0).fadeIn(),

                    // Prompt Text
                    50.verticalSpace,
                    // Copy Button
                    SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleCopy(prompt),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCCFF00),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.copy),
                            label: const Text(
                              "COPY FULL PROMPT",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                        .animate(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0)
                        .fadeIn(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.black12,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }

  Widget _loading(double? progress) {
    return Container(
      color: Colors.black12,
      alignment: Alignment.center,
      child: CupertinoActivityIndicator(
        // value: progress,
        // strokeWidth: 2,
      ),
    );
  }

  Widget _errorWidget() {
    return Container(
      color: Colors.black12,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: Colors.grey,
        size: 40,
      ),
    );
  }

  void _handleShare(Prompt prompt) {
    Share.share(
      "Check out this AI prompt from Promptly:\n\n${prompt.promptText}",
      subject: "AI Prompt - ${prompt.category}",
    );
  }

  void _handleCopy(Prompt prompt) {
    // 1. Copy to Clipboard
    Clipboard.setData(ClipboardData(text: prompt.promptText));

    // 2. Haptic Feedback
    HapticFeedback.mediumImpact();

    // 3. Update Streak / App State
    // Provider.of<AppState>(context, listen: false).recordCopyAction();
    controller.recordCopyAction();
    // 4. Show Success Message
    // appToast("Prompt copied to clipboard");
    Get.snackbar(
      "Success!",
      "Prompt copied ⚡",
      snackPosition: SnackPosition.BOTTOM,
      // Background ko dark grey/black rakhein taaki neon color pop kare
      backgroundColor: const Color(0xFF1E1E1E),
      // Text mein wahi neon yellow/lime color use karein jo icon mein hai
      colorText: const Color(0xFFD4E157),
      icon: const Icon(Icons.bolt, color: Color(0xFFD4E157)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      duration: const Duration(seconds: 2),
      isDismissible: true,
      borderRadius: 12,
      // Subtle border glow effect ke liye
      borderColor: const Color(0xFFD4E157).withOpacity(0.3),
      borderWidth: 1,
      boxShadows: [
        BoxShadow(
          color: const Color(0xFFD4E157).withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
        )
      ],
      forwardAnimationCurve: Curves.easeOutBack,
      snackStyle: SnackStyle.FLOATING,
    );
  }
}
