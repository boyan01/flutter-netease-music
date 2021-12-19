//网易红调色板
import 'package:flutter/material.dart';

const lightSwatch = MaterialColor(0xFFdd4237, {
  900: Color(0xFFae2a20),
  800: Color(0xFFbe332a),
  700: Color(0xFFcb3931),
  600: Color(0xFFdd4237),
  500: Color(0xFFec4b38),
  400: Color(0xFFe85951),
  300: Color(0xFFdf7674),
  200: Color(0xFFea9c9a),
  100: Color(0xFFfcced2),
  50: Color(0xFFfeebee),
});

ThemeData get quietDarkTheme {
  final theme = ThemeData.from(
    colorScheme: ColorScheme.dark(
      background: Color.alphaBlend(Colors.black87, Colors.white),
      onBackground: Color.alphaBlend(Colors.white54, Colors.black),
      surface: Color.alphaBlend(Colors.black87, Colors.white),
      onSurface: Color.alphaBlend(Colors.white70, Colors.black),
      primary: lightSwatch,
      secondary: lightSwatch[300]!,
      tertiary: lightSwatch[100],
    ),
  );
  return theme.copyWith(
    toggleableActiveColor: lightSwatch,
    tooltipTheme: const TooltipThemeData(
      waitDuration: Duration(milliseconds: 1000),
    ),
  );
}

ThemeData get lightTheme => _buildTheme(lightSwatch);

ThemeData _buildTheme(Color primaryColor) {
  final theme = ThemeData.from(
    colorScheme: const ColorScheme.light(primary: lightSwatch),
  );
  return theme.copyWith(
    toggleableActiveColor: lightSwatch,
    tooltipTheme: const TooltipThemeData(
      waitDuration: Duration(milliseconds: 1000),
    ),
    iconTheme: IconThemeData(
      color: theme.iconTheme.color!.withOpacity(0.7),
      size: 24,
    ),
  );
}

extension QuietAppTheme on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  TextTheme get primaryTextTheme => theme.primaryTextTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  IconThemeData get iconTheme => theme.iconTheme;
}

extension TextStyleExtesntion on TextStyle? {
  TextStyle? get bold => this?.copyWith(fontWeight: FontWeight.bold);
}
