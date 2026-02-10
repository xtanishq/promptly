// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:intl/intl.dart' as intl;
//
// import 'app_localizations_en.dart';
// import 'app_localizations_es.dart';
// import 'app_localizations_fr.dart';
// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:intl/intl.dart' as intl;
//
// import 'app_localizations_en.dart';
// import 'app_localizations_es.dart';
// import 'app_localizations_fr.dart';
// abstract class AppLocalizations {
//   AppLocalizations(String locale)
//       : localeName = intl.Intl.canonicalizedLocale(locale.toString());
//
//   final String localeName;
//
//   static AppLocalizations? of(BuildContext context) {
//     return Localizations.of<AppLocalizations>(context, AppLocalizations);
//   }
//
//   static const LocalizationsDelegate<AppLocalizations> delegate =
//   _AppLocalizationsDelegate();
//
//   static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
//   <LocalizationsDelegate<dynamic>>[
//     delegate,
//     GlobalMaterialLocalizations.delegate,
//     GlobalCupertinoLocalizations.delegate,
//     GlobalWidgetsLocalizations.delegate,
//   ];
//
//   /// A list of this localizations delegate's supported locales.
//   static const List<Locale> supportedLocales = <Locale>[
//     Locale('en'),
//     Locale('es'),
//     Locale('fr'),
//   ];
//
//   /// The application title
//   ///
//   /// In en, this message translates to:
//   /// **'Language Switch Demo'**
//   String get appTitle;
//
//   /// Welcome message
//   ///
//   /// In en, this message translates to:
//   /// **'Welcome'**
//   String get welcome;
//
//   /// Language selection prompt
//   ///
//   /// In en, this message translates to:
//   /// **'Select Language'**
//   String get selectLanguage;
//
//   /// Greeting with name parameter
//   ///
//   /// In en, this message translates to:
//   /// **'Hello, {name}!'**
//   String greeting(String name);
//
//   /// Simple question asking how the user is doing
//   ///
//   /// In en, this message translates to:
//   /// **'How are you?'**
//   String get howAreYou;
//
//   /// Item count with plural forms
//   ///
//   /// In en, this message translates to:
//   /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
//   String itemCount(int count);
// }
//
// class _AppLocalizationsDelegate
//     extends LocalizationsDelegate<AppLocalizations> {
//   const _AppLocalizationsDelegate();
//
//   @override
//   Future<AppLocalizations> load(Locale locale) {
//     return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
//   }
//
//   @override
//   bool isSupported(Locale locale) =>
//       <String>['en', 'es', 'fr'].contains(locale.languageCode);
//
//   @override
//   bool shouldReload(_AppLocalizationsDelegate old) => false;
// }
//
// AppLocalizations lookupAppLocalizations(Locale locale) {
//   // Lookup logic when only language code is specified.
//   switch (locale.languageCode) {
//     case 'en':
//       return AppLocalizationsEn();
//     // case 'es':
//     //   return AppLocalizationsEs();
//     // case 'fr':
//     //   return AppLocalizationsFr();
//   }
//
//   throw FlutterError(
//     'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
//         'an issue with the localizations generation tool. Please file an issue '
//         'on GitHub with a reproducible sample app and the gen-l10n configuration '
//         'that was used.',
//   );
// }
