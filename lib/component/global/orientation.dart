import 'package:flutter/material.dart';

extension OrientationContext on BuildContext {
  NavigatorState get rootNavigator => Navigator.of(this, rootNavigator: true);

  // TODO remove this.
  NavigatorState? get secondaryNavigator => Navigator.of(this);

  ///
  /// check current application orientation is landscape.
  ///
  bool get isLandscape => MediaQuery.of(this).isLandscape;

  bool get isPortrait => !isLandscape;
}

extension _MediaData on MediaQueryData {
  bool get isLandscape => orientation == Orientation.landscape;
}
