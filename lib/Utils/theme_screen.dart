import 'package:flutter/material.dart';

class ThemeScreen {
  static TextStyle get subHeadingStyle {
    return const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  }

  static TextStyle get headingStyle {
    return const TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  }

  static TextStyle calendarStyle({
    required double size,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: Colors.grey,
    );
  }
}
