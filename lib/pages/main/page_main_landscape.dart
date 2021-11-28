part of "page_main.dart";

class _LandscapeMainPage extends StatefulWidget {
  @override
  _LandscapeMainPageState createState() => _LandscapeMainPageState();
}

class _LandscapeMainPageState extends State<_LandscapeMainPage>
    with NavigatorObserver {
  static const double kDrawerWidth = 96.0;

  final GlobalKey<NavigatorState> _landscapeNavigatorKey =
      GlobalKey(debugLabel: "landscape_main_navigator");

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
      body: SafeArea(
        bottom: false,
        child: Column(
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
                    Expanded(
                      child: Navigator(
                        key: _landscapeNavigatorKey,
                        initialRoute: pageMainMyMusic,
                        observers: [this],
                        onGenerateRoute: onLandscapeBuildPrimaryRoute,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _BottomPlayerBar(),
          ],
        ),
      ),
    );
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
                selected: pageSearch == selectedRouteName,
                icon: const Icon(Icons.search),
                title: Text(context.strings.search),
                onTap: () {
                  context.push(pageSearch);
                }),
            MainNavigationDrawerTile(
                selected: pageMainMyMusic == selectedRouteName,
                icon: const Icon(Icons.music_note),
                title: Text(context.strings.myMusic),
                onTap: () {
                  context.push(pageMainMyMusic);
                }),
            MainNavigationDrawerTile(
                selected: pageMainCloud == selectedRouteName,
                icon: const Icon(Icons.cloud),
                title: Text(context.strings.discover),
                onTap: () {
                  context.push(pageMainCloud);
                }),
            MainNavigationDrawerTile(
                selected: pageFmPlaying == selectedRouteName,
                icon: const Icon(Icons.radio),
                title: Text(context.strings.personalFM),
                onTap: () {
                  context.push(pageFmPlaying);
                }),
            const Spacer(),
            MainNavigationDrawerTile(
              icon: const Icon(Icons.settings),
              title: Container(),
              onTap: () {
                context.push(pageSetting);
              },
            ),
            MainNavigationDrawerTile(
                icon: const Icon(Icons.account_circle),
                title: Text(context.strings.my),
                onTap: () {
                  if (!ref.read(isLoginProvider)) {
                    context.push(pageLogin);
                    return;
                  }
                  context.push(pageProfileMy);
                }),
          ],
        ),
      ),
    );
  }
}

/// Bottom player bar for landscape
class _BottomPlayerBar extends StatelessWidget {
  const _BottomPlayerBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final current = context.watchPlayerValue.current;
    final paddingPageBottom = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;
    if (current == null) {
      return SizedBox(height: paddingPageBottom);
    }
    return BottomControllerBar(
      bottomPadding: paddingPageBottom,
    );
  }
}
