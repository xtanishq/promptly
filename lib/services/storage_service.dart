import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyUserId = 'user_id';
  static const String keyLastCopyDate = 'last_copy_date';
  static const String keyStreakCount = 'streak_count';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyLangComplete = 'language_complete';

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserId);
  }

  Future<void> setUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserId, id);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyOnboardingComplete, true);
  }
 Future<bool> isLangComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyLangComplete) ?? false;
  }

  Future<void> setLangComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLangComplete, true);
  }

  Future<int> getStreakCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyStreakCount) ?? 0;
  }

  Future<String?> getLastCopyDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLastCopyDate);
  }

  Future<void> updateStreak(int count, String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyStreakCount, count);
    await prefs.setString(keyLastCopyDate, date);
  }
}
