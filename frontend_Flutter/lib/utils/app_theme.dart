import 'package:flutter/material.dart';

class AppTheme {
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1E3C72),  // Deep Ocean Blue
      Color(0xFF2A5298),  // Royal Blue
      Color(0xFF185ADB),  // Bright Blue
    ],
    stops: [0.0, 0.5, 1.0],
  );
}