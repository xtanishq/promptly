import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../services/storage_service.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
// Import your storage service here

class AppController extends GetxController {
  final StorageService _storage = StorageService();

  // .obs makes these variables reactive streams
  final _userId = RxnString();
  final _streakCount = 0.obs;
  final _isLoading = true.obs;
  final _isOnboardingComplete = false.obs;

  // Getters
  String? get userId => _userId.value;
  int get streakCount => _streakCount.value;
  bool get isLoading => _isLoading.value;
  bool get isOnboardingComplete => _isOnboardingComplete.value;
  bool get isVisionary => _streakCount.value >= 3;

  @override
  void onInit() {
    super.onInit();
    initializeApp();
  }

  Future<void> initializeApp() async {
    _isLoading.value = true;

    // 1. Check Onboarding
    _isOnboardingComplete.value = await _storage.isOnboardingComplete();

    // 2. User ID logic
    String? id = await _storage.getUserId();
    if (id == null) {
      id = const Uuid().v4();
      await _storage.setUserId(id);
    }
    _userId.value = id;

    // 3. Load & Validate streak
    _streakCount.value = await _storage.getStreakCount();
    await _validateStreak();

    _isLoading.value = false;
  }

  Future<void> completeOnboarding() async {
    await _storage.setOnboardingComplete();
    _isOnboardingComplete.value = true;
  }

  Future<void> _validateStreak() async {
    final lastDateStr = await _storage.getLastCopyDate();
    if (lastDateStr == null) return;

    final lastDate = DateTime.parse(lastDateStr);
    final today = DateTime.now().toOnlyDate(); // Senior Tip: Extension method for clarity
    final last = lastDate.toOnlyDate();

    if (today.difference(last).inDays > 1) {
      _streakCount.value = 0;
      await _storage.updateStreak(0, lastDateStr);
    }
  }
  Future<void> recordCopyAction() async {
    final now = DateTime.now();
    final today = now.toOnlyDate();

    final lastDateStr = await _storage.getLastCopyDate();

    // FIRST EVER COPY
    if (lastDateStr == null) {
      _streakCount.value = 1;
      await _storage.updateStreak(1, now.toIso8601String());
      return;
    }

    final last = DateTime.parse(lastDateStr).toOnlyDate();
    final diff = today.difference(last).inDays;

    // SAME DAY → do nothing
    if (diff == 0) {
      return;
    }

    // NEXT DAY → increment
    if (diff == 1) {
      _streakCount.value += 1;
    }
    // GAP → reset to 1
    else {
      _streakCount.value = 1;
    }

    await _storage.updateStreak(_streakCount.value, now.toIso8601String());
  }


// Future<void> recordCopyAction() async {
  //   final now = DateTime.now();
  //   final lastDateStr = await _storage.getLastCopyDate();
  //
  //   if (lastDateStr == null) {
  //     _streakCount.value = 1;
  //   } else {
  //     final last = DateTime.parse(lastDateStr).toOnlyDate();
  //     final today = now.toOnlyDate();
  //
  //     if (today.isAfter(last)) {
  //       int diff = today.difference(last).inDays;
  //       _streakCount.value = (diff == 1) ? _streakCount.value + 1 : 1;
  //     }
  //   }
  //   await _storage.updateStreak(_streakCount.value, now.toIso8601String());
  // }
}

// Senior Tip: Use extension to keep logic clean
extension DateUtils on DateTime {
  DateTime toOnlyDate() => DateTime(year, month, day);
}
