import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> get constantPreference async => await SharedPreferences.getInstance();

class InitializationHelper {
  Future<FormError?> initialize() async {
    final completer = Completer<FormError?>();

    final params = ConsentRequestParameters(
      consentDebugSettings: kDebugMode
          ? ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea,
            )
          : null,
    );
    ConsentInformation.instance.requestConsentInfoUpdate(params, () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        await _loadConsentForm();
      } else {
        SharedPreferences prefs = await constantPreference;
        prefs.setInt("keyvalue",0);
        await _initialize();
      }
      completer.complete();
    }, (error) {
      completer.complete(error);
    });

    return completer.future;
  }

  Future<FormError?> _loadConsentForm() async {
    final completer = Completer<FormError?>();

    ConsentForm.loadConsentForm((consentForm) async {
      final status = await ConsentInformation.instance.getConsentStatus();
      if (status == ConsentStatus.required) {
        SharedPreferences prefs = await constantPreference;
        prefs.setInt("keyvalue",1);
        consentForm.show((formError) async {
          if (formError != null) {
            completer.complete(formError);
            return;
          }
          await _initialize();
          completer.complete();
        });
      } else {
        // The user has chosen an option,
        // it's time to initialize the ads component.
        SharedPreferences prefs = await constantPreference;
        prefs.setInt("keyvalue",0);
        await _initialize();
        completer.complete();
      }
    }, (FormError? error) {
      completer.complete(error);
    });

    return completer.future;
  }

  Future<void> _initialize() async {
    await MobileAds.instance.initialize();

    /**
     * Here you can place any other initialization of any
     * other component that depends on consent management,
     * for example the initialization of Google Analytics
     * or Google Crashlytics would go here.
     */
  }

  Future<bool> changePrivacyPreferences() async {
    final completer = Completer<bool>();
    ConsentInformation.instance
        .requestConsentInfoUpdate(ConsentRequestParameters(), () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        ConsentForm.loadConsentForm((consentForm) {
          consentForm.show((formError) async {
            await _initialize();
            completer.complete(true);
          });
        }, (formError) {
          completer.complete(false);
        });
      } else {
        completer.complete(false);
      }
    }, (error) {
      completer.complete(false);
    });

    return completer.future;
  }
}

Future<bool> isUnderGdpr() async {
  SharedPreferences prefs = await constantPreference;
  int isGdpr = prefs.getInt("keyvalue") ?? 0;
  return isGdpr == 1;
}
