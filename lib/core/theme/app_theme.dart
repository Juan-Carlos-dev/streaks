import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  // Colors
  static const Color primaryBlue = Color(0xFF0099FF);
  static const Color secondaryBlue = Color(0xFF00E5FF);
  static const Color backgroundBlack = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF1C1C1E);
  static const Color errorColor = Color(0xFFCF6679);
  static const Color onBackground = Colors.white;

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundBlack,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: secondaryBlue,
      surface: surfaceColor,
      background: backgroundBlack,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: onBackground,
      onBackground: onBackground,
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundBlack,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: onBackground,
      ),
      iconTheme: const IconThemeData(color: onBackground),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: onBackground,
        textStyle: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.all(20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
      hintStyle: const TextStyle(color: Colors.grey),
    ),

    // Typography
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: onBackground),
      displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: onBackground),
      titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: onBackground),
      bodyLarge: GoogleFonts.outfit(fontSize: 16, color: onBackground),
      bodyMedium: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[400]),
      labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: onBackground),
    ),
  );
}
