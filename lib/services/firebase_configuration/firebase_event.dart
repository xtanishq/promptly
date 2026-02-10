import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: _analytics);
  /// Logs a custom event
  static Future<void> logEvent({
    required String eventName,
  }) async {
    try {
      await _analytics.logEvent(
        name: "Action_Figure_$eventName",
      );
    } catch (e) {
      print("Error logging event: $e");
    }
  }
}
// FirebaseAnalyticsService.logEvent(eventName: "SPLASH_SCREEN");