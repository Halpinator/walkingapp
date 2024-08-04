/*
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300,
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade900,
  )
);
*/
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade100, // Clean light gray for surfaces
    primary: Colors.blueGrey.shade800, // Deep blue-grey for primary elements
    secondary: Colors.cyan.shade600, // Vibrant cyan for secondary elements
    tertiary: Colors.grey.shade300, // Soft gray for tertiary elements
    inversePrimary: Colors.cyan.shade900, // Dark cyan for elements on dark backgrounds
  )
);

/*
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Color(0xFF003366),
    secondary: Color(0xFF4682B4),
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  ),
);
*/