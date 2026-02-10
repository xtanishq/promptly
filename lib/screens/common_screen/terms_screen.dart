import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/constant.dart';
import '../../services/firebase_configuration/firebase_event.dart';


class TermsOfUse extends StatefulWidget {
  const TermsOfUse({Key? key}) : super(key: key);

  @override
  State<TermsOfUse> createState() => _TermsOfUseState();
}

class _TermsOfUseState extends State<TermsOfUse> {
  late WebViewController controller;

  @override
  void initState() {
    controller = WebViewController()
      ..loadRequest(
        Uri.parse(termsOfUseUrl),
      );
    FirebaseAnalyticsService.logEvent(eventName: "I2D_TERMS_OF_USE_SCREEN");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Terms Of Use',
          style: TextStyle(
            color: Colors.white,
            fontSize: 75.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
