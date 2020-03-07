import 'package:flutter/material.dart';
import 'package:quiet/pages/main/page_main.dart';

extension OrientationContext on BuildContext {
  NavigatorState get primaryNavigator => isLandscape ? landscapePrimaryNavigator : Navigator.of(this);

  NavigatorState get secondaryNavigator => isLandscape ? landscapeSecondaryNavigator : Navigator.of(this);

  ///
  /// check current application orientation is landscape.
  ///
  bool get isLandscape => MediaQuery.of(this).isLandscape;

  bool get isPortrait => !isLandscape;
}

extension _MediaData on MediaQueryData {
  bool get isLandscape => orientation == Orientation.landscape;
}
