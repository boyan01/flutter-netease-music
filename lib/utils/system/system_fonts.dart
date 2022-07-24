import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

bool _fallbackFontsLoaded = false;

String? loadedFallbackFonts;

// TODO(BIN): remove this when https://github.com/flutter/flutter/issues/90951 has been fixed.
Future<void> loadFallbackFonts() async {
  if (!Platform.isLinux) {
    return;
  }

  // Skip load fallback fonts if current system language is en.
  // See more: https://github.com/flutter/flutter/issues/90951
  if (window.locale.languageCode == 'en') {
    return;
  }
  if (_fallbackFontsLoaded) {
    return;
  }
  _fallbackFontsLoaded = true;

  // On some Linux systems(Ubuntu 20.04）, flutter can not render CJK fonts correctly when
  // current system language is not en.
  // https://github.com/flutter/flutter/issues/90951
  // We load the DroidSansFallbackFull font from the system and use it as a fallback.
  try {
    final matchedResult = Process.runSync('fc-match', ['-f', '%{family}']);
    if (matchedResult.exitCode != 0) {
      debugPrint(
          'failed to get best match font family. error: ${matchedResult.stderr}');
      return;
    }
    final result = Process.runSync('fc-list',
        ['-f', '%{family}:%{file}\n', matchedResult.stdout as String]);
    final lines = const LineSplitter().convert(result.stdout as String);
    String? fontFamily;
    final fontPaths = <String>[];
    assert(lines.isNotEmpty);
    for (final line in lines) {
      // font config "family:file"
      final fontConfig = line.split(':');
      assert(fontConfig.length == 2,
          'font config do not match required format. $fontConfig');
      if (fontFamily == null) {
        fontFamily = fontConfig.first;
        fontPaths.add(fontConfig[1]);
      } else if (fontFamily == fontConfig.first) {
        fontPaths.add(fontConfig[1]);
      } else {
        debugPrint(
          'font family not match. expect $fontFamily, but ${fontConfig.first}. line: $line',
        );
      }
    }
    if (fontPaths.isEmpty || fontFamily == null) {
      debugPrint('failed to retriver font config: $lines');
      return;
    }
    loadedFallbackFonts = fontFamily;
    for (final path in fontPaths) {
      debugPrint('load fallback fonts: $fontFamily $path');
      try {
        final file = File(path.trim());
        final bytes = file.readAsBytesSync();
        await loadFontFromList(bytes, fontFamily: fontFamily);
      } catch (e, stacktrace) {
        debugPrint('failed to load font $path, $e $stacktrace');
      }
    }
  } catch (error, stacktrace) {
    debugPrint('failed to load system fonts, error: $error, $stacktrace');
  }
}

extension ApplyFontsExtension on ThemeData {
  ThemeData withFallbackFonts() {
    if (loadedFallbackFonts == null) {
      if (Platform.isWindows) {
        return copyWith(
          textTheme: textTheme.applyFonts(null, ['Microsoft Yahei UI']),
          primaryTextTheme:
              primaryTextTheme.applyFonts(null, ['Microsoft Yahei UI']),
        );
      }
      return this;
    }
    return copyWith(
      textTheme: textTheme.applyFonts(loadedFallbackFonts, null),
      primaryTextTheme: primaryTextTheme.applyFonts(loadedFallbackFonts, null),
    );
  }
}

extension _TextTheme on TextTheme {
  TextTheme applyFonts(String? fontFamily, List<String>? fontFamilyFallback) =>
      copyWith(
        displayLarge: displayLarge?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        displayMedium: displayMedium?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        displaySmall: displaySmall?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        headlineLarge: headlineLarge?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        headlineMedium: headlineMedium?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        headlineSmall: headlineSmall?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        titleLarge: titleLarge?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        titleMedium: titleMedium?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        titleSmall: titleSmall?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        bodyLarge: bodyLarge?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        bodyMedium: bodyMedium?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        bodySmall: bodySmall?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        labelLarge: labelLarge?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        labelMedium: labelMedium?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        labelSmall: labelSmall?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
      );
}
