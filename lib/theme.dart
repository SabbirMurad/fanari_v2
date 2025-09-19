import 'package:fanari_v2/constants/colors.dart';
import 'package:flutter/material.dart';

final light = ThemeData(
  fontFamily: 'Archivo',
  hintColor: const Color.fromRGBO(228, 228, 228, 1),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromRGBO(255, 255, 255, 1),
    primary: AppColors.primary,
    surface: const Color(0xFFF8FAFC),
    secondary: const Color(0xFFD9EAFD),
    tertiary: const Color(0xFF171717),
    primaryContainer: const Color.fromRGBO(212, 212, 221, 1),
    secondaryContainer: const Color.fromRGBO(255, 255, 255, 1),
    shadow: const Color.fromRGBO(154, 121, 245, 0.3),
  ),
  shadowColor: const Color.fromRGBO(154, 121, 245, .3),
  datePickerTheme: const DatePickerThemeData(
    backgroundColor: Color.fromRGBO(255, 255, 255, .15),
  ),
  useMaterial3: true,
);

final dark = ThemeData(
  fontFamily: 'Archivo',
  hintColor: const Color.fromRGBO(228, 228, 228, 1),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromRGBO(255, 255, 255, 1),
    primary: AppColors.primary,
    surface: const Color(0xFF171717), // #171717
    secondary: const Color(0xFF25292E), // #212121
    tertiary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFF25292E),
    secondaryContainer: const Color.fromRGBO(255, 255, 255, 1),
    shadow: const Color.fromARGB(75, 27, 27, 29),
  ),
  shadowColor: const Color.fromRGBO(0, 0, 0, .3),
  datePickerTheme: const DatePickerThemeData(
    backgroundColor: AppColors.secondary,
    dividerColor: AppColors.text,
    dayStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
    dayForegroundColor: WidgetStatePropertyAll(
      Color.fromARGB(255, 255, 255, 255),
    ),
    yearForegroundColor: WidgetStatePropertyAll(
      Color.fromARGB(255, 255, 255, 255),
    ),
    headerForegroundColor: Color.fromARGB(255, 255, 255, 255),
    rangePickerBackgroundColor: Colors.red,
    rangePickerHeaderBackgroundColor: Colors.green,
    rangePickerHeaderForegroundColor: Colors.amber,
    dayOverlayColor: WidgetStatePropertyAll(Color.fromARGB(174, 255, 78, 78)),
    yearOverlayColor: WidgetStatePropertyAll(AppColors.primary),
    headerBackgroundColor: AppColors.secondary,
    weekdayStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
    yearStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
    rangePickerHeaderHeadlineStyle: TextStyle(color: AppColors.text),
    rangeSelectionOverlayColor: WidgetStatePropertyAll(
      Color.fromARGB(255, 255, 78, 78),
    ),
    headerHeadlineStyle: TextStyle(
      color: AppColors.text,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    headerHelpStyle: TextStyle(color: AppColors.text),
  ),
  useMaterial3: true,
);

// #202329
// #131313
// #0A3D34
// #9A79F5
// #2E343D
// #25292E
// #525252
// #2E343D
// #212121
// #171717
// #3F3F3F
// #0F0F0F
// #1E1E1E
// #2E3133
// Color(0xFFFF4E4E)
// Color(0xFF3F3F3F)

// Color.fromRGBO(24, 24, 24, 1)
// Color.fromARGB(255, 255, 78, 78)
