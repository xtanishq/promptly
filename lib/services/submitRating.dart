import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import 'checkConnectivity.dart';
import 'constant.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:url_launcher/url_launcher.dart';

import 'dialog.dart';

class SubmitRating {
  Future<void> submitRating(BuildContext context) async {
    final inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }

  Future<void> submitRatingSetting(BuildContext context) async {
    if (Platform.isAndroid) {
      ConnectivityService.checkConnectivity().then((value) async {
        if (value) {
          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          String appId = packageInfo.packageName;
          // print("Application ID: $appId");
          final playStoreUrl =
              "https://play.google.com/store/apps/details?id=$appId";
          launchUrl(Uri.parse(playStoreUrl));
        } else {
          DialogService.showCheckConnectivity(context);
        }
      });
    } else {
      InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        try {
          inAppReview.requestReview();
        } catch (e) {
          if (kDebugMode) {
            print('Error requesting in-app review: $e');
          }
        }
      } else {
        inAppReview.openStoreListing(appStoreId: '');
      }
    }
  }

  Future<void> shareContent(BuildContext context) async {
    const String text = 'Check out this awesome app!';
    const String subject = 'Awesome App';
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String packageName = packageInfo.packageName;
    final String appStoreUrl = 'https://apps.apple.com/app/$packageName';
    final String playStoreUrl =
        'https://play.google.com/store/apps/details?id=$packageName';
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      Share.share('$text\n\n$appStoreUrl', subject: subject);
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      Share.share('$text\n\n$playStoreUrl', subject: subject);
    } else {
      throw PlatformException(
        code: 'PLATFORM_NOT_SUPPORTED',
        message: 'Sharing is not supported on this platform.',
      );
    }
  }
}
