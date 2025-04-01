import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'config/fonts.dart';
import 'constants/colors.dart';

const kProductTitleStyleLarge = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

const kTextField = InputDecoration(
  hintText: 'Enter your value',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(3.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(3.0)),
  ),
);

IconThemeData _customIconTheme(IconThemeData original) {
  return original.copyWith(color: kGrey900);
}

ThemeData buildLightTheme(String? language) {
  final base = ThemeData.light().copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
      },
    ),
    colorScheme: const ColorScheme(
      primary: kTeal100,
      secondary: kGrey600,
      surface: kSurfaceWhite,
      error: kErrorRed,
      onPrimary: kDarkBG,
      onSecondary: kGrey900,
      onSurface: kGrey900,
      onError: kSurfaceWhite,
      brightness: Brightness.light,
    ),
    cardColor: Colors.white,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: kLightAccent,
      selectionColor: kTeal100,
    ),
    primaryColor: kLightPrimary,
    scaffoldBackgroundColor: kLightBG,
    appBarTheme: const AppBarTheme(
        elevation: 0,
        iconTheme: IconThemeData(color: kDarkAccent),
        backgroundColor: kTeal100
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.black,
      unselectedLabelColor: Colors.black,
      labelStyle: TextStyle(fontSize: 13),
      unselectedLabelStyle: TextStyle(fontSize: 13),
    ),
  );

  return base.copyWith(
    textTheme: _buildTextTheme(base.textTheme, language),
  );
}

TextTheme _buildTextTheme(TextTheme base, String? language) {
  var textTheme = kTextTheme(base, language);
  return textTheme.copyWith(
    titleLarge: textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w500,
      color: Colors.red,
    ),
    titleMedium: textTheme.titleMedium?.copyWith(
      fontSize: 18.0,
    ),
    bodySmall: textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14.0,
    ),
    bodyMedium: textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 16.0,
    ),
  ).apply(
    displayColor: kGrey900,
    bodyColor: kGrey900,
  );
}

const ColorScheme kColorScheme = ColorScheme(
  primary: kTeal100,
  secondary: kTeal50,
  surface: kSurfaceWhite,
  background: Colors.white,
  error: kErrorRed,
  onPrimary: kDarkBG,
  onSecondary: kGrey900,
  onSurface: kGrey900,
  onBackground: kGrey900,
  onError: kSurfaceWhite,
  brightness: Brightness.light,
);

ThemeData buildDarkTheme(String? language) {
  final base = ThemeData.dark().copyWith(
    colorScheme: kColorScheme.copyWith(
      brightness: Brightness.dark,
      background: kDarkBG,
      surface: kDarkBG,
      primary: kTeal100, // Use the same primary color as in the light theme
    ),
    scaffoldBackgroundColor: kDarkBG,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      iconTheme: IconThemeData(color: kDarkAccent),
      backgroundColor: kTeal100,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white,
      labelStyle: TextStyle(fontSize: 13),
      unselectedLabelStyle: TextStyle(fontSize: 13),
    ),
  );

  return base.copyWith(
    textTheme: _buildTextTheme(base.textTheme, language).apply(
      displayColor: kLightBG,
      bodyColor: kLightBG,
    ),
  );
}


const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: kTeal400, width: 2.0),
  ),
);

const kSendButtonTextStyle = TextStyle(
  color: kTeal400,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);
