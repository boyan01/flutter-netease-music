import 'package:flutter/foundation.dart';

extension TargetPlatformExtension on TargetPlatform {
  bool isMobile() =>
      this == TargetPlatform.android || this == TargetPlatform.iOS;

  bool isDesktop() =>
      this == TargetPlatform.macOS ||
      this == TargetPlatform.windows ||
      this == TargetPlatform.linux;

  bool isIos() => this == TargetPlatform.iOS;
}
