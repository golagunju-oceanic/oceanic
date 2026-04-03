import 'package:flutter/material.dart';

const kNavyBlue = Color(0xFF2D2D8E);
const kTeal = Color(0xFF3CC8C8);
const kAmber = Color(0xFFF5A623);
const kLightGray = Color(0xFFF5F5F5);
const kMediumGray = Color(0xFFEEEEEE);
const kTextGray = Color(0xFF9E9E9E);

const kLightPrimary = kNavyBlue;
const kLightSecondary = kTeal;
const kLightAccent = kAmber;
const kLightBackground = kLightGray;
const kLightSurface = Colors.white;
const kLightDivider = kMediumGray;
const kLightTextPrimary = Color(0xFF1A1A3D);
const kLightTextSecondary = kTextGray;
const kLightTextOnPrimary = Colors.white;

const kDarkPrimary = Color(0xFF5A5ACD);
const kDarkSecondary = Color(0xFF2EAEAE);
const kDarkAccent = Color(0xFFFFBB45);
const kDarkBackground = Color(0xFF0F0F1E);
const kDarkSurface = Color(0xFF1C1C3A);
const kDarkDivider = Color(0xFF2A2A50);
const kDarkTextPrimary = Color(0xFFF0F0FF);
const kDarkTextSecondary = Color(0xFF7E7EA8);
const kDarkTextOnPrimary = Colors.white;

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kLightPrimary,
  scaffoldBackgroundColor: kLightBackground,
  colorScheme: const ColorScheme.light(
    primary: kLightPrimary,
    secondary: kLightSecondary,
    tertiary: kLightAccent,
    surface: kLightSurface,
    onPrimary: kLightTextOnPrimary,
    onSurface: kLightTextPrimary,
  ),
  cardColor: kLightSurface,
  dividerColor: kLightDivider,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: kLightTextPrimary),
    bodyMedium: TextStyle(color: kLightTextPrimary),
    bodySmall: TextStyle(color: kLightTextSecondary),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kLightPrimary,
    foregroundColor: kLightTextOnPrimary,
    elevation: 0,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kDarkPrimary,
  scaffoldBackgroundColor: kDarkBackground,
  colorScheme: const ColorScheme.dark(
    primary: kDarkPrimary,
    secondary: kDarkSecondary,
    tertiary: kDarkAccent,
    surface: kDarkSurface,
    onPrimary: kDarkTextOnPrimary,
    onSurface: kDarkTextPrimary,
  ),
  cardColor: kDarkSurface,
  dividerColor: kDarkDivider,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: kDarkTextPrimary),
    bodyMedium: TextStyle(color: kDarkTextPrimary),
    bodySmall: TextStyle(color: kDarkTextSecondary),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kDarkSurface,
    foregroundColor: kDarkTextPrimary,
    elevation: 0,
  ),
);
