// color_helper.dart

import 'package:flutter/material.dart';

class ColorHelper {
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  static Color hexToColor(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
  }

  static Color defaultColor = const Color.fromARGB(153, 240, 229, 229);
}
