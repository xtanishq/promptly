
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';

  static final List<Locale> supportedLocales = [
    const Locale('en', ''),
    const Locale('es', ''),
    const Locale('fr', ''),
    const Locale('hi', ''), // Hindi
    const Locale('pt', ''), // Portuguese
    const Locale('ar', ''), // Arabic
    const Locale('ja', ''), // Japanese
    const Locale('de', ''), // German
  ];

  static final Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'hi': 'हिन्दी',
    'pt': 'Português',
    'ar': 'العربية',
    'ja': '日本語',
    'de': 'Deutsch',
  };

  Future<Locale> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);

    if (languageCode != null) {
      return Locale(languageCode);
    }

    return supportedLocales.first;
  }

  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }

  Future<void> clearLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageKey);
  }
}

/// GetX controller to replace Provider's LocaleProvider.
/// Usage: register controller with `Get.put(LocaleController())` before runApp.
class LocaleController extends GetxController {
  final LanguageService _languageService = LanguageService();

  /// Reactive locale used by the app
  final Rx<Locale> locale = Rx<Locale>(LanguageService.supportedLocales.first);

  Locale get value => locale.value;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final saved = await _languageService.getSavedLocale();
    locale.value = saved;
    // Keep GetX internal locale in sync
    Get.updateLocale(saved);
    // No need to call update(), listeners will react via Obx
  }

  Future<void> setLocale(Locale newLocale) async {
    // guard against unsupported locales (match by languageCode)
    final supported = LanguageService.supportedLocales
        .any((l) => l.languageCode == newLocale.languageCode);
    if (!supported) return;

    locale.value = newLocale;
    await _languageService.saveLocale(newLocale);
    Get.updateLocale(newLocale);
  }

  Future<void> clearLocale() async {
    final defaultLocale = LanguageService.supportedLocales.first;
    locale.value = defaultLocale;
    await _languageService.clearLocale();
    Get.updateLocale(defaultLocale);
  }

  /// convenience toggle example
  void toggleEnglishSpanish() {
    final next =
    locale.value.languageCode == 'en' ? const Locale('es') : const Locale('en');
    setLocale(next);
  }
}
