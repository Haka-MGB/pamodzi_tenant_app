import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PamodziColors {
  // Light mode
  static const bg = Color(0xFFF5F3EF);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF0EDE6);
  static const border = Color(0xFFE5DFD3);
  static const border2 = Color(0xFFD1C9B8);
  static const text = Color(0xFF1E2A2A);
  static const text2 = Color(0xFF5A6B5E);
  static const muted = Color(0xFF8F9A8E);

  // Brand colors
  static const green = Color(0xFF2D6A4F);
  static const greenDark = Color(0xFF1F4D38);
  static const greenGl = Color(0x1A2D6A4F);
  static const greenGl2 = Color(0x0F2D6A4F);
  static const amber = Color(0xFFC9881A);
  static const amberGl = Color(0x1FD9A13B);
  static const red = Color(0xFFC35D3A);
  static const redGl = Color(0x1AC35D3A);
  static const blue = Color(0xFF3A7DC3);
  static const blueGl = Color(0x1A3A7DC3);

  // Dark mode
  static const bgDark = Color(0xFF111816);
  static const surfaceDark = Color(0xFF1B2421);
  static const surface2Dark = Color(0xFF222E2A);
  static const borderDark = Color(0xFF263330);
  static const border2Dark = Color(0xFF344540);
  static const textDark = Color(0xFFEEF0EA);
  static const text2Dark = Color(0xFFB8C8B4);
  static const mutedDark = Color(0xFF7A9080);
  static const greenDark2 = Color(0xFF3E9970);
  static const greenDarkD = Color(0xFF2D6A4F);
  static const amberDark = Color(0xFFD9A13B);
  static const redDark = Color(0xFFD97A56);
  static const blueDark = Color(0xFF5A9ED9);

  // Rent hero gradient
  static const heroGrad1 = Color(0xFF1A3D2B);
  static const heroGrad2 = Color(0xFF0F2D1E);
  static const heroGrad3 = Color(0xFF1A2830);
}

class PamodziTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: PamodziColors.bg,
      colorScheme: const ColorScheme.light(
        primary: PamodziColors.green,
        secondary: PamodziColors.amber,
        surface: PamodziColors.surface,
        onPrimary: Colors.white,
        onSurface: PamodziColors.text,
      ),
      textTheme: _textTheme(PamodziColors.text),
      appBarTheme: const AppBarTheme(
        backgroundColor: PamodziColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PamodziColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: PamodziColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: PamodziColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: PamodziColors.green, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PamodziColors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PamodziColors.surface,
        selectedItemColor: PamodziColors.green,
        unselectedItemColor: PamodziColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: PamodziColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: PamodziColors.greenDark2,
        secondary: PamodziColors.amberDark,
        surface: PamodziColors.surfaceDark,
        onPrimary: Colors.white,
        onSurface: PamodziColors.textDark,
      ),
      textTheme: _textTheme(PamodziColors.textDark),
      appBarTheme: const AppBarTheme(
        backgroundColor: PamodziColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PamodziColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: PamodziColors.borderDark, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: PamodziColors.borderDark, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: PamodziColors.greenDark2, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PamodziColors.greenDark2,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PamodziColors.surfaceDark,
        selectedItemColor: PamodziColors.greenDark2,
        unselectedItemColor: PamodziColors.mutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static TextTheme _textTheme(Color base) {
    return GoogleFonts.interTextTheme(TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w800, color: base),
      displayMedium: TextStyle(fontWeight: FontWeight.w800, color: base),
      headlineLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.03, color: base),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: base),
      headlineSmall: TextStyle(fontWeight: FontWeight.w700, color: base),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, color: base),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, color: base),
      bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: base),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: base),
      labelSmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.06, color: base),
    ));
  }
}
