import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../utils/system/system_fonts.dart';

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
      onPrimary: const Color(0xFFDDDDDD),
    ),
  );
  return theme
      .copyWith(
        toggleableActiveColor: lightSwatch,
        tooltipTheme: const TooltipThemeData(
          waitDuration: Duration(milliseconds: 1000),
        ),
      )
      .withFallbackFonts()
      .applyCommon();
}

ThemeData get lightTheme => _buildTheme(lightSwatch);

ThemeData _buildTheme(Color primaryColor) {
  final theme = ThemeData.from(
    colorScheme: const ColorScheme.light(primary: lightSwatch),
  );
  return theme
      .copyWith(
        toggleableActiveColor: lightSwatch,
        tooltipTheme: const TooltipThemeData(
          waitDuration: Duration(milliseconds: 1000),
        ),
        iconTheme: IconThemeData(
          color: theme.iconTheme.color!.withOpacity(0.7),
          size: 24,
        ),
      )
      .withFallbackFonts()
      .applyCommon();
}

extension QuietAppTheme on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  TextTheme get primaryTextTheme => Theme.of(this).primaryTextTheme;

  AppColorScheme get colorScheme => AppTheme.colorScheme(this);
}

extension TextStyleExtesntion on TextStyle? {
  TextStyle? get bold => this?.copyWith(fontWeight: FontWeight.bold);
}

extension _ThemeExt on ThemeData {
  ThemeData applyCommon() {
    return copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        },
      ),
      useMaterial3: false,
    );
  }
}

class AppColorScheme with EquatableMixin {
  AppColorScheme({
    required this.brightness,
    required this.background,
    required this.primary,
    required this.textPrimary,
    required this.textHint,
    required this.textDisabled,
    required this.onPrimary,
    required this.surface,
    required this.highlight,
    required this.divider,
  });

  final Brightness brightness;

  final Color background;
  final Color primary;

  final Color textPrimary;
  final Color textHint;
  final Color textDisabled;

  final Color onPrimary;

  final Color surface;
  final Color highlight;
  final Color divider;

  Color surfaceWithElevation(double elevation) => brightness == Brightness.light
      ? surface
      : ElevationOverlay.colorWithOverlay(surface, textPrimary, elevation);

  @override
  List<Object> get props => [
        brightness,
        background,
        primary,
        textPrimary,
        textHint,
        textDisabled,
        onPrimary,
        surface,
        highlight,
        divider,
      ];
}

class AppTheme extends StatelessWidget {
  const AppTheme({super.key, required this.child});

  final Widget child;

  static AppColorScheme colorScheme(BuildContext context) =>
      _AppThemeData.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = AppColorScheme(
      brightness: theme.brightness,
      background: theme.backgroundColor,
      primary: theme.colorScheme.primary,
      textPrimary: theme.textTheme.bodyMedium!.color!,
      textHint: theme.textTheme.caption!.color!,
      textDisabled: theme.disabledColor,
      onPrimary: theme.colorScheme.onPrimary,
      surface: theme.colorScheme.surface,
      highlight: theme.highlightColor,
      divider: theme.dividerColor,
    );

    return _AppThemeData(
      colorScheme: colorScheme,
      child: child,
    );
  }
}

class _AppThemeData extends InheritedWidget {
  const _AppThemeData({
    super.key,
    required super.child,
    required this.colorScheme,
  });

  final AppColorScheme colorScheme;

  static _AppThemeData of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<_AppThemeData>();
    assert(result != null, 'No _AppTheme found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_AppThemeData old) {
    return colorScheme != old.colorScheme;
  }
}
