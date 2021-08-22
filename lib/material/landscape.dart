import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:quiet/component.dart';
import 'package:url_launcher/url_launcher.dart';

/// 根据横竖屏来显示不同的部件
class LandscapeWidgetSwitcher extends StatelessWidget {
  const LandscapeWidgetSwitcher({Key? key, this.landscape, this.portrait})
      : super(key: key);

  final WidgetBuilder? landscape;
  final WidgetBuilder? portrait;

  @override
  Widget build(BuildContext context) {
    if (context.isLandscape) {
      return landscape == null ? const SizedBox() : landscape!(context);
    } else {
      return portrait == null ? const SizedBox() : portrait!(context);
    }
  }
}

class LandscapeSecondaryKey extends LabeledGlobalKey<NavigatorState> {
  LandscapeSecondaryKey() : super('');
}

class LandscapePrimaryRoutePage extends HookWidget {
  const LandscapePrimaryRoutePage({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final secondaryKey = useMemoized(() => LandscapeSecondaryKey());
    return Provider.value(
      value: secondaryKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                border: BorderDirectional(
                  end: BorderSide(color: context.theme.dividerColor),
                ),
              ),
              child: child,
            ),
          ),
          Flexible(
            child: Navigator(
              key: secondaryKey,
              onGenerateRoute: _onGenerateSecondaryRoute,
            ),
          ),
        ],
      ),
    );
  }
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

// Default page for secondary navigator
class _SecondaryPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("仿网易云音乐"),
            InkWell(
              onTap: () {
                launch("https://github.com/boyan01/flutter-netease-music");
              },
              child: Text(
                "https://github.com/boyan01/flutter-netease-music",
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
