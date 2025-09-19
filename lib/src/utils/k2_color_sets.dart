// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class K2Colors {
  static const darkBlue = Color(0xff27364e);
  static const lightBlue = Color(0xff6dedf7);
  static const turquoise = Color(0xff149187);
  static const error = Color(0xfff04438);
  static const pending = Color(0xffeebe5d);
  static const secondaryDarkBlue = Color(0xff4ba3de);
  static const navyBlue = Color(0xFF525E71); // #525E71

  static final MaterialColor materialDarkBlue = _createMaterialColor(darkBlue);
  static final MaterialColor materialNavyBlue = _createMaterialColor(navyBlue);
  static final MaterialColor materialLightBlue =
      _createMaterialColor(lightBlue);
  static final MaterialColor materialTurquoise =
      _createMaterialColor(turquoise);
  static final MaterialColor materialError = _createMaterialColor(error);
  static final MaterialColor backgroundGray =
      _createMaterialColor(const Color(0xfff7f7f7));
  static final MaterialColor grey =
      _createMaterialColor(const Color(0xff6e7888));

  static MaterialColor _createMaterialColor(Color color) {
    final List<double> strengths = <double>[.05];
    final Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }
}
