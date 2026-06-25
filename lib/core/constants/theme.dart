import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oceanic/core/constants/app_colors.dart';

ThemeData lightTheme() => ThemeData(
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(color: kLightTextSecondary),
    prefixIconColor: kLightPrimary,
    contentPadding: EdgeInsets.symmetric(vertical: 16.h),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
  ),
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
  textTheme: Typography.englishLike2018.apply(
    fontSizeFactor: 1.sp,
    bodyColor: kLightTextPrimary,
    displayColor: kLightTextPrimary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kLightPrimary,
    foregroundColor: kLightTextOnPrimary,
    elevation: 0,
  ),
);

ThemeData darkTheme() => ThemeData(
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(color: kDarkTextSecondary),
    prefixIconColor: kDarkPrimary,
    contentPadding: EdgeInsets.symmetric(vertical: 16.h),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
  ),
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
  textTheme: Typography.englishLike2018.apply(
    fontSizeFactor: 1.sp,
    bodyColor: kDarkTextPrimary,
    displayColor: kDarkTextPrimary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kDarkSurface,
    foregroundColor: kDarkTextPrimary,
    elevation: 0,
  ),
);
