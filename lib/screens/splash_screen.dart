import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:promptly/services/constant.dart';
import 'package:promptly/services/google_ads_material/ads_service.dart';

import '../providers/app_state.dart';
import '../utils/auth_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppController controllere = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final sw = Stopwatch()..start();

    // ─── Run auth + ad bootstrap in parallel ─────────────────────────────────
    // AdsBootstrap gathers GDPR consent and initializes MobileAds (no-op for
    // subscribers / when ads are disabled). Time-boxed so a misbehaving consent
    // SDK can never trap the user on the splash.
    final adsFuture = AdsService.instance.init().timeout(
      const Duration(seconds: 8),
      onTimeout: () {},
    );
    await AuthRepository().authenticateUser();
    await adsFuture;

    // Minimum 2-second vibe delay (net of however long the above took)
    final elapsed = sw.elapsedMilliseconds;
    if (elapsed < 2000) {
      await Future.delayed(Duration(milliseconds: 2000 - elapsed));
    }

    // Remove native splash right before we navigate
    FlutterNativeSplash.remove();

    if (mounted) {
      if (controllere.isOnboardingComplete) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    }
  }

  // Ads are globally disabled — this method intentionally removed.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(),
            const Icon(Icons.bolt_rounded, size: 100, color: pressColor)
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  duration: 1000.ms,
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.1, 1.1),
                )
                .tint(
                  color: Colors.white.withValues(alpha: 0.5),
                  duration: 1000.ms,
                )
                .then()
                .tint(
                  color: Theme.of(context).colorScheme.primary,
                  duration: 1000.ms,
                ),

            const SizedBox(height: 20),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Promptly',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    fontFamily: 'PlusJakarta',
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Trending AI Prompts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.2,
                    fontFamily: 'PlusJakarta',
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),

            const Spacer(),

            LinearProgressIndicator(
              minHeight: 20.h,
              backgroundColor: Colors.transparent,
              color: context.theme.primaryColorLight,
            ),
            45.verticalSpace,
          ],
        ),
      ),
    );
  }
}
