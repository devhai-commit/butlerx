import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static const Color _primarySeed = Color(0xFF1A73E8);
  static const Color _secondaryColor = Color(0xFF00BFA5);
  static const Color _errorColor = Color(0xFFD32F2F);

  static ThemeData get light => FlexThemeData.light(
        colors: const FlexSchemeColor(
          primary: _primarySeed,
          primaryContainer: Color(0xFFD2E3FC),
          secondary: _secondaryColor,
          secondaryContainer: Color(0xFFB2DFDB),
          tertiary: Color(0xFF7C4DFF),
          tertiaryContainer: Color(0xFFEDE7F6),
          error: _errorColor,
          errorContainer: Color(0xFFFFCDD2),
        ),
        textTheme: _textTheme,
        appBarElevation: 0,
        subThemesData: const FlexSubThemesData(
          defaultRadius: 12.0,
          inputDecoratorRadius: 12.0,
          cardRadius: 16.0,
          dialogRadius: 20.0,
          bottomSheetRadius: 20.0,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
      );

  static ThemeData get dark => FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: Color(0xFF82B1FF),
          primaryContainer: Color(0xFF1565C0),
          secondary: Color(0xFF64FFDA),
          secondaryContainer: Color(0xFF00695C),
          tertiary: Color(0xFFB39DDB),
          tertiaryContainer: Color(0xFF4527A0),
          error: Color(0xFFEF9A9A),
          errorContainer: Color(0xFFB71C1C),
        ),
        textTheme: _textTheme,
        appBarElevation: 0,
        subThemesData: const FlexSubThemesData(
          defaultRadius: 12.0,
          inputDecoratorRadius: 12.0,
          cardRadius: 16.0,
          dialogRadius: 20.0,
          bottomSheetRadius: 20.0,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
      );

  // High-contrast theme for elderly users
  static ThemeData get lightHighContrast => light.copyWith(
        textTheme: _largeTextTheme,
        extensions: const [],
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
