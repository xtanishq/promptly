import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/constant.dart';
import '../../services/firebase_configuration/firebase_event.dart';


class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  late WebViewController controller;
  Uri? policyUri;

  @override
  void initState() {
    policyUri = Uri.tryParse(privacyPolicyUrl);
    controller = WebViewController();
    if (policyUri != null && privacyPolicyUrl.isNotEmpty) {
      controller.loadRequest(policyUri!);
    }
    FirebaseAnalyticsService.logEvent(eventName: "Promptly_PRIVACY_SCREEN");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 75.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: policyUri == null || privacyPolicyUrl.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Privacy policy is currently unavailable.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : WebViewWidget(controller: controller),
      ),
    );
  }
}
