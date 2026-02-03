import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PraxisTheme {
  static const Color creamVellum = Color(0xFFFDFBF7);
  static const Color charcoalInk = Color(0xFF18181B);
  static const Color burnishedGold = Color(0xFFC5A059);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: creamVellum,
      primaryColor: charcoalInk,
      colorScheme: ColorScheme.fromSeed(
        seedColor: charcoalInk,
        primary: charcoalInk,
        secondary: burnishedGold,
        surface: creamVellum,
        onSurface: charcoalInk,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(color: charcoalInk),
        displayMedium: GoogleFonts.playfairDisplay(color: charcoalInk),
        displaySmall: GoogleFonts.playfairDisplay(color: charcoalInk),
        headlineLarge: GoogleFonts.playfairDisplay(color: charcoalInk),
        headlineMedium: GoogleFonts.playfairDisplay(color: charcoalInk),
        headlineSmall: GoogleFonts.playfairDisplay(color: charcoalInk),
        titleLarge: GoogleFonts.inter(color: charcoalInk),
        titleMedium: GoogleFonts.inter(color: charcoalInk),
        titleSmall: GoogleFonts.inter(color: charcoalInk),
        bodyLarge: GoogleFonts.inter(color: charcoalInk),
        bodyMedium: GoogleFonts.inter(color: charcoalInk),
        bodySmall: GoogleFonts.inter(color: charcoalInk),
      ),
    );
  }
}
