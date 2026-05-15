import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  // ── Dark scheme — exact stitch-ui "Midnight Concierge" palette ─────────────
  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFB1CCFF),
    onPrimary: Color(0xFF003063),
    primaryContainer: Color(0xFF82B1FF),
    onPrimaryContainer: Color(0xFF004285),
    secondary: Color(0xFF41E4C0),
    onSecondary: Color(0xFF00382D),
    secondaryContainer: Color(0xFF00C7A5),
    onSecondaryContainer: Color(0xFF004D3F),
    tertiary: Color(0xFFD8C2FF),
    onTertiary: Color(0xFF38265B),
    tertiaryContainer: Color(0xFFBCA6E4),
    onTertiaryContainer: Color(0xFF4C3970),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF111318),
    onSurface: Color(0xFFE2E2E9),
    onSurfaceVariant: Color(0xFFC2C6D2),
    outline: Color(0xFF8C919C),
    outlineVariant: Color(0xFF424751),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE2E2E9),
    onInverseSurface: Color(0xFF2E3035),
    inversePrimary: Color(0xFF295EA6),
    surfaceTint: Color(0xFFA9C7FF),
    surfaceContainerLowest: Color(0xFF0C0E13),
    surfaceContainerLow: Color(0xFF191C20),
    surfaceContainer: Color(0xFF1D2024),
    surfaceContainerHigh: Color(0xFF282A2F),
    surfaceContainerHighest: Color(0xFF33353A),
  );

  // ── Light scheme — stitch-ui "Soft Futurism" palette ───────────────────────
  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF005BBF),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD6E3FF),
    onPrimaryContainer: Color(0xFF001B3D),
    secondary: Color(0xFF006B5C),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF88F7D8),
    onSecondaryContainer: Color(0xFF00201A),
    tertiary: Color(0xFF6833EA),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFEBDCFF),
    onTertiaryContainer: Color(0xFF230F45),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF9F9FF),
    onSurface: Color(0xFF191C23),
    onSurfaceVariant: Color(0xFF44474E),
    outline: Color(0xFF747780),
    outlineVariant: Color(0xFFC3C6CF),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2E3035),
    onInverseSurface: Color(0xFFF0F0F7),
    inversePrimary: Color(0xFFB1CCFF),
    surfaceTint: Color(0xFF005BBF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF4F3FA),
    surfaceContainer: Color(0xFFEEEDF5),
    surfaceContainerHigh: Color(0xFFE8E7EF),
    surfaceContainerHighest: Color(0xFFE2E1E9),
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: _lightScheme,
        textTheme: _textTheme,
        scaffoldBackgroundColor: const Color(0xFFF9F9FF),
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          backgroundColor: const Color(0xFFF9F9FF),
          titleTextStyle: GoogleFonts.beVietnamPro(
            color: const Color(0xFF005BBF),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          iconTheme: const IconThemeData(color: Color(0xFF44474E)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFEEEDF5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          elevation: 0,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: _darkScheme,
        textTheme: _textTheme,
        scaffoldBackgroundColor: const Color(0xFF111318),
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          backgroundColor: const Color(0xFF111318),
          titleTextStyle: GoogleFonts.beVietnamPro(
            color: const Color(0xFFB1CCFF),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          iconTheme: const IconThemeData(color: Color(0xFFC2C6D2)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF1D2024),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1D2024),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          elevation: 0,
        ),
      );

  // High-contrast variant for elderly users
  static ThemeData get lightHighContrast => light.copyWith(
        textTheme: _largeTextTheme,
        colorScheme: _lightScheme.copyWith(
          primary: const Color(0xFF0D47A1),
          onSurface: const Color(0xFF000000),
          surface: const Color(0xFFFFFFFF),
        ),
      );

  static TextTheme get _textTheme => GoogleFonts.beVietnamProTextTheme();

  static TextTheme get _largeTextTheme => GoogleFonts.beVietnamProTextTheme(
        const TextTheme(
          bodyMedium: TextStyle(fontSize: 18),
          bodyLarge: TextStyle(fontSize: 20),
          titleMedium: TextStyle(fontSize: 20),
          titleLarge: TextStyle(fontSize: 24),
          headlineMedium: TextStyle(fontSize: 28),
        ),
      );
}
