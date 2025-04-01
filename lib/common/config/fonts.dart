import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// TODO: 5-Update App Fonts
/// Google fonts constant setting: https://fonts.google.com/
TextTheme kTextTheme(theme, String? language) {
  switch (language) {
    // case 'en':
    //   return GoogleFonts.ralewayTextTheme(theme);
    // case 'ar':
    //   return GoogleFonts.ralewayTextTheme(theme);
    // default:
    //   return GoogleFonts.ralewayTextTheme(theme);
    case 'en':
      return GoogleFonts.poppinsTextTheme(theme);
    case 'ar':
      return GoogleFonts.poppinsTextTheme(theme);
    default:
      return GoogleFonts.poppinsTextTheme(theme);
  }
}

TextTheme kHeadlineTheme(theme, [language = 'en']) {
  switch (language) {
    // case 'en':
    //   return GoogleFonts.ralewayTextTheme(theme);
    // case 'ar':
    //   return GoogleFonts.ralewayTextTheme(theme);
    // default:
    //   return GoogleFonts.ralewayTextTheme(theme);
    case 'en':
      return GoogleFonts.poppinsTextTheme(theme);
    case 'ar':
      return GoogleFonts.poppinsTextTheme(theme);
    default:
      return GoogleFonts.poppinsTextTheme(theme);
  }
}
