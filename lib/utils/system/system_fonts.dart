import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';

const _kDroidSansFallback = 'DroidSansFallbackFull';

String? getFallbackFontFamily() =>
    Platform.isLinux && _droidSansLoaded ? _kDroidSansFallback : null;

bool _droidSansLoaded = false;

Future<void> loadFallbackFonts() async {
  if (!Platform.isLinux) {
    return;
  }
  if (_droidSansLoaded) {
    return;
  }
  _droidSansLoaded = true;

  // On some Linux systems, flutter can not render CJK fonts correctly.
  // https://github.com/flutter/flutter/issues/90951
  // We load the DroidSansFallbackFull font from the system and use it as a fallback.
  final file =
      File('/usr/share/fonts/truetype/droid/DroidSansFallbackFull.ttf');
  if (!file.existsSync()) {
    debugPrint('failed to load DroidSansFallbackFull.ttf');
    return;
  }
  try {
    final bytes = await file.readAsBytes();
    await loadFontFromList(bytes, fontFamily: _kDroidSansFallback);
  } catch (e, stacktrace) {
    debugPrint('failed to load DroidSansFallbackFull.ttf, $e $stacktrace');
  }
}
