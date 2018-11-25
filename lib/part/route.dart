import 'package:flutter/material.dart';
import 'package:quiet/pages/page_login.dart';
import 'package:quiet/pages/page_main.dart';

export 'package:quiet/pages/page_login.dart';
export 'package:quiet/pages/page_main.dart';
export 'package:quiet/pages/page_playlist_detail.dart';

const ROUTE_MAIN = "/";

const ROUTE_LOGIN = "/login";

const ROUTE_PLAYLIST_DETAIL = "/playlist/detail";

///app routers
final Map<String, WidgetBuilder> routes = {
  ROUTE_MAIN: (context) => MainPage(),
  ROUTE_LOGIN: (context) => LoginPage(),
};
