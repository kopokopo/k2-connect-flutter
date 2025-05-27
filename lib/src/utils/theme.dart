import 'package:flutter/material.dart';
import 'package:k2_connect_flutter/src/utils/k2_color_sets.dart';

class K2Theme {
  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: K2Colors.backgroundGray,
    onPrimary: K2Colors.darkBlue,
    secondary: K2Colors.backgroundGray,
    onSecondary: K2Colors.darkBlue,
    error: K2Colors.backgroundGray,
    onError: K2Colors.error,
    surface: K2Colors.backgroundGray,
    onSurface: K2Colors.darkBlue,
  );

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      fontFamily: 'Poppins',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.primary,
        buttonColor: colorScheme.onPrimary,
        padding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.onPrimary,
        foregroundColor: K2Colors.lightBlue,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        textStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'poppins',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            fontFamily: 'poppins',
          ),
          side: BorderSide(
            color: colorScheme.onPrimary,
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            fontFamily: 'poppins',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: const EdgeInsets.all(16.0),
        ),
      ),
      textTheme: TextTheme(
        // Titles
        displayLarge: TextStyle(
          fontSize: 14.0,
          color: K2Colors.darkBlue,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
        // Money large
        displayMedium: TextStyle(
          fontSize: 16.0,
          color: K2Colors.darkBlue,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        // Money medium size
        displaySmall: TextStyle(
          fontSize: 15.0,
          color: K2Colors.darkBlue,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          fontSize: 24.0,
          color: K2Colors.darkBlue,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          fontSize: 15.0,
          color: K2Colors.darkBlue,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w300,
        ),
        headlineSmall: TextStyle(
          fontSize: 14.0,
          color: K2Colors.darkBlue,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          fontSize: 12.0,
          color: K2Colors.darkBlue,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        titleMedium: TextStyle(
          fontSize: 13.0,
          color: K2Colors.darkBlue,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        titleSmall: TextStyle(
          fontSize: 12.0,
          color: K2Colors.darkBlue,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w300,
        ),
        labelLarge: TextStyle(
          fontSize: 14.0,
          color: K2Colors.darkBlue,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        labelMedium: TextStyle(
          fontSize: 13.0,
          color: K2Colors.darkBlue,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        labelSmall: TextStyle(
          fontSize: 12.0,
          color: K2Colors.darkBlue,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        // Cards body
        bodyLarge: TextStyle(
          fontSize: 13.0,
          color: K2Colors.darkBlue,
          fontFamily: 'Poppins',
        ),
        bodyMedium: TextStyle(
          fontSize: 12.0,
          color: K2Colors.grey,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          fontSize: 10.0,
          color: K2Colors.darkBlue,
          fontFamily: 'Poppins',
        ),
      ).apply(
        bodyColor: K2Colors.darkBlue,
        displayColor: K2Colors.darkBlue,
        fontFamily: 'Poppins',
      ),
    );
  }
}
