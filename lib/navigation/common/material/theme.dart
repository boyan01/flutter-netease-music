import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension/providers.dart';
import '../../../providers/player_provider.dart';
import '../../../utils/cache/cached_image.dart';
import '../../../utils/system/system_fonts.dart';

class AppThemeData {
  const AppThemeData({required this.light, required this.dark});

  final ThemeData light;
  final ThemeData dark;
}

const _kDefaultNetEaseRed = Color(0xFFdd4237);

final _defaultTheme = AppThemeData(
  light: _buildTheme(
    ColorScheme.fromSeed(seedColor: _kDefaultNetEaseRed),
  ),
  dark: _buildTheme(
    ColorScheme.fromSeed(
      seedColor: _kDefaultNetEaseRed,
      brightness: Brightness.dark,
    ),
  ),
);

final appThemeProvider = StateProvider<AppThemeData>(
  (ref) {
    ref.listen(playingTrackProvider, (previous, next) async {
      if (next != null) {
        final image = CachedImage(next.imageUrl!);
        ref.controller.state = AppThemeData(
          light: _buildTheme(
            await ColorScheme.fromImageProvider(
              provider: image,
            ),
          ),
          dark: _buildTheme(
            await ColorScheme.fromImageProvider(
              provider: image,
              brightness: Brightness.dark,
            ),
          ),
        );
      }
    }).autoRemove(ref);
    return _defaultTheme;
  },
);

ThemeData _buildTheme(ColorScheme colorScheme) {
  final theme = ThemeData.from(
    colorScheme: colorScheme,
    useMaterial3: true,
  );
  return theme
      .copyWith(
        tooltipTheme: const TooltipThemeData(
          waitDuration: Duration(milliseconds: 1000),
        ),
      )
      .withFallbackFonts()
      .applyCommon();
}

extension QuietAppTheme on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  TextTheme get primaryTextTheme => Theme.of(this).primaryTextTheme;

  AppColorScheme get colorScheme => AppTheme.colorScheme(this);

  ColorScheme get colorScheme2 => Theme.of(this).colorScheme;

  Color dynamicColor({
    required Color light,
    required Color dark,
  }) {
    return colorScheme.brightness == Brightness.light ? light : dark;
  }
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
    );
  }
}

class AppColorScheme with EquatableMixin {
  AppColorScheme({
    required this.brightness,
    required this.background,
    required this.backgroundSecondary,
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
  final Color backgroundSecondary;

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
        backgroundSecondary,
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
      background: theme.colorScheme.background,
      backgroundSecondary: theme.scaffoldBackgroundColor,
      primary: theme.colorScheme.primary,
      textPrimary: theme.textTheme.bodyMedium!.color!,
      textHint: theme.textTheme.bodySmall!.color!,
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
