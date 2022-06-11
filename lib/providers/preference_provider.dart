import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferenceProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('init with override'),
);

extension SharedPreferenceProviderExtension on SharedPreferences {
  Size? getWindowSize() {
    final width = getDouble('window_width') ?? 0;
    final height = getDouble('window_height') ?? 0;
    if (width == 0 || height == 0) {
      return null;
    }
    return Size(width, height);
  }

  Future<void> setWindowSize(Size size) async {
    await Future.wait([
      setDouble('window_width', size.width),
      setDouble('window_height', size.height),
    ]);
  }
}
