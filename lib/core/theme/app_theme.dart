import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
  }

  // Optional: Add dark theme support
  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true);
  }
}
