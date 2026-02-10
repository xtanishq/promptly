import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:promptly/utils/AppTheme.dart';

const appName = 'Promptly: Trending AI Prompts';
const rateID = '';
const fontFamily = 'Regular';
const privacyPolicyUrl = 'https://stonekrossofficial.github.io/promptly-privacy-policy/';
const termsOfUseUrl = '';


// 1. Map to your new AppTheme colors
const Color textColor = Colors.white;
const Color appBackgroundColor = Color(0xFF1A1A1A); // Matches AppTheme._background
const Color dialogBgColor = Color(0xFF1E1E1E);      // Matches AppTheme._surface
const Color dialogButtonTextColor = Colors.white;

// 2. Primary Action Colors (Electric Purple)
const int _appColorValue = 0xFF8A2BE2;
const MaterialColor appColor = MaterialColor(
  _appColorValue,
  <int, Color>{
    50:  Color(0xFFF1E6FC),
    100: Color(0xFFDCC3F7),
    200: Color(0xFFC59DF2),
    300: Color(0xFFAE77ED),
    400: Color(0xFF9C5CE8),
    500: Color(_appColorValue), // Base Purple
    600: Color(0xFF8227DE),
    700: Color(0xFF7722D9),
    800: Color(0xFF6D1DD5),
    900: Color(0xFF5B13CE),
  },
);

// 3. Secondary/Accent Colors (Neon Yellow)
const Color secondaryColor = Color(0xFFCCFF00);
const Color pressColor = secondaryColor; // Use Yellow for interactions
const Color unPressColor = appColor;      // Use Purple for default state

// 4. Activity Indicator
const iosIndicator = Center(
    child: CupertinoActivityIndicator(radius: 15, color: appColor));

// 5. Toast Refactor (Senior Tip: Use the Surface color for consistency)
appToast(String msg) =>
    Fluttertoast.showToast(
        msg: msg,
        backgroundColor: Colors.black,
        textColor: AppTheme.darkTheme.colorScheme.primary,
        toastLength: Toast.LENGTH_LONG);

// 6. Gradients Refactored
// Using variations of Purple for the default state
const unPressGradiant = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFB066FE), // Lighter purple
    Color(0xFF8A2BE2), // Brand purple
    Color(0xFF621FB3), // Darker purple
  ],
);

// Using Yellow/Neon tones for the Pressed/Active state
const pressGradiant = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFE5FF80), // Tinted yellow
    Color(0xFFCCFF00), // Brand yellow
    Color(0xFFAACC00), // Shaded yellow
  ],
);