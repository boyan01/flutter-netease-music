import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component/global/orientation.dart';
import 'package:quiet/pages/account/page_user_detail.dart';
import 'package:quiet/pages/main/main_cloud.dart';
import 'package:quiet/pages/main/main_playlist.dart';
import 'package:quiet/pages/search/page_search.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:url_launcher/url_launcher.dart';

part 'drawer.dart';
part 'page_main_landscape.dart';
part 'page_main_portrait.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return context.isLandscape ? _LandscapeMainPage() : _PortraitMainPage();
  }
}

extension LandscapeMainContext on BuildContext {
  /// Obtain the primary navigator for landscape mode.
  NavigatorState get landscapePrimaryNavigator =>
      findAncestorStateOfType<_LandscapeMainPageState>()._landscapeNavigatorKey.currentState;

  /// Obtain the secondary navigator for landscape mode.
  NavigatorState get landscapeSecondaryNavigator =>
      findAncestorStateOfType<_LandscapeMainPageState>()._landscapeSecondaryNavigatorKey.currentState;
}
