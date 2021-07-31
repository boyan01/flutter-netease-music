part of "page_main.dart";

class _LandscapeMainPage extends StatefulWidget {
  @override
  _LandscapeMainPageState createState() => _LandscapeMainPageState();
}

const _navigationSearch = pageSearch;

const _navigationMyPlaylist = "playlist";

const _navigationCloud = "cloud";

const _navigationFmPlayer = "fm";

const _navigationSettings = "settings";

class _LandscapeMainPageState extends State<_LandscapeMainPage>
    with NavigatorObserver {
  static const double kDrawerWidth = 120.0;

  final GlobalKey<NavigatorState> _landscapeNavigatorKey =
      GlobalKey(debugLabel: "landscape_main_navigator");

  final GlobalKey<NavigatorState> _landscapeSecondaryNavigatorKey = GlobalKey(
    debugLabel: "landscape_secondary_navigator",
  );

  String? _currentSubRouteName;

  @override
  void didPush(Route route, Route? previousRoute) {
    _onPageSelected(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _onPageSelected(previousRoute!);
  }

  void _onPageSelected(Route route) {
    final name = route.settings.name;
    debugPrint("on landscape show : $name");
    WidgetsBinding.instance!.scheduleFrameCallback((timeStamp) {
      setState(() {
        _currentSubRouteName = name;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Expanded(
            child: DisableBottomController(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    constraints:
                        const BoxConstraints.tightFor(width: kDrawerWidth),
                    decoration: BoxDecoration(
                        border: BorderDirectional(
                            end: BorderSide(
                                color: Theme.of(context).dividerColor))),
                    child: _LandscapeDrawer(
                        selectedRouteName: _currentSubRouteName),
                  ),
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                          border: BorderDirectional(
                              end: BorderSide(
                                  color: Theme.of(context).dividerColor))),
                      child: Navigator(
                        key: _landscapeNavigatorKey,
                        initialRoute: _navigationMyPlaylist,
                        observers: [this],
                        onGenerateRoute: _onGeneratePrimaryRoute,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Navigator(
                      key: _landscapeSecondaryNavigatorKey,
                      onGenerateRoute: _onGenerateSecondaryRoute,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _BottomPlayerBar(
            paddingPageBottom: MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom,
          ),
        ],
      ),
    );
  }

  Route<dynamic> _onGeneratePrimaryRoute(RouteSettings settings) {
    Widget? widget;
    switch (settings.name) {
      case _navigationMyPlaylist:
        widget = Scaffold(
          body: MainPageMy(),
          primary: false,
          resizeToAvoidBottomInset: false,
        );
        break;
      case _navigationCloud:
        widget = Scaffold(
          body: MainPageDiscover(),
          primary: false,
          resizeToAvoidBottomInset: false,
        );
        break;
      case _navigationSearch:
        return NeteaseSearchPageRoute(null);
      case _navigationFmPlayer:
        toast("页面未完成");
        widget = Container();
        break;
      case _navigationSettings:
        widget = SettingPage();
        break;
    }
    assert(widget != null, "can not generate route for $settings");
    return MaterialPageRoute(settings: settings, builder: (context) => widget!);
  }

  Route<dynamic>? _onGenerateSecondaryRoute(RouteSettings settings) {
    if (settings.name == Navigator.defaultRouteName) {
      return MaterialPageRoute(
          settings: settings, builder: (context) => _SecondaryPlaceholder());
    }
    final builder = routes[settings.name!];
    if (builder != null) {
      return MaterialPageRoute(settings: settings, builder: builder);
    }
    return routeFactory(settings);
  }
}

class _LandscapeDrawer extends ConsumerWidget {
  const _LandscapeDrawer({Key? key, required this.selectedRouteName})
      : super(key: key);

  // Current selected page name in Main Drawer.
  final String? selectedRouteName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      elevation: 0,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MainNavigationDrawerTile(
                selected: _navigationSearch == selectedRouteName,
                icon: const Icon(Icons.search),
                title: const Text("搜索"),
                onTap: () {
                  context.primaryNavigator!.pushNamed(_navigationSearch);
                }),
            MainNavigationDrawerTile(
                selected: _navigationMyPlaylist == selectedRouteName,
                icon: const Icon(Icons.music_note),
                title: const Text("我的音乐"),
                onTap: () {
                  context.primaryNavigator!.pushNamed(_navigationMyPlaylist);
                }),
            MainNavigationDrawerTile(
                selected: _navigationCloud == selectedRouteName,
                icon: const Icon(Icons.cloud),
                title: const Text("发现音乐"),
                onTap: () {
                  context.primaryNavigator!.pushNamed(_navigationCloud);
                }),
            MainNavigationDrawerTile(
                selected: _navigationFmPlayer == selectedRouteName,
                icon: const Icon(Icons.radio),
                title: const Text("私人FM"),
                onTap: () {
                  context.primaryNavigator!.pushNamed(_navigationFmPlayer);
                }),
            const Spacer(),
            MainNavigationDrawerTile(
              icon: const Icon(Icons.settings),
              title: Container(),
              onTap: () {
                context.primaryNavigator!.pushNamed(_navigationSettings);
              },
            ),
            MainNavigationDrawerTile(
                icon: const Icon(Icons.account_circle),
                title: const Text("我的"),
                onTap: () {
                  if (!ref.read(userProvider).isLogin) {
                    context.rootNavigator.pushNamed(pageLogin);
                    return;
                  }
                  context.primaryNavigator!.push(
                    MaterialPageRoute(
                      builder: (context) => UserDetailPage(
                        userId: ref.read(userProvider).userId,
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

// Default page for secondary navigator
class _SecondaryPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text("仿网易云音乐"),
            InkWell(
              onTap: () {
                launch("https://github.com/boyan01/flutter-netease-music");
              },
              child: Text("https://github.com/boyan01/flutter-netease-music",
                  style: TextStyle(color: Theme.of(context).accentColor)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom player bar for landscape
class _BottomPlayerBar extends StatelessWidget {
  const _BottomPlayerBar({Key? key, this.paddingPageBottom}) : super(key: key);

  final double? paddingPageBottom;

  @override
  Widget build(BuildContext context) {
    final current = context.listenPlayerValue.current;
    if (current == null) {
      return SizedBox(height: paddingPageBottom);
    }
    return BottomControllerBar(
      bottomPadding: paddingPageBottom!,
    );
  }
}
