part of "page_main.dart";

class _Drawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          _UserInfo(),
          MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Expanded(
                child: ListTileTheme(
                  style: ListTileStyle.drawer,
                  child: ListView(
                    children: <Widget>[
                      _DrawerTile(
                        icon: Icon(Icons.settings),
                        title: Text("设置"),
                        onTap: () {
                          Navigator.pushNamed(context, ROUTE_SETTING);
                        },
                      ),
                      Divider(height: 0, indent: 16),
                      _DrawerTile(
                        icon: Icon(Icons.format_quote),
                        title: Text("Star On GitHub"),
                        onTap: () {
                          launch("https://github.com/boyan01/flutter-netease-music");
                        },
                      ),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}

// The tile item for main draw. auto fit landscape and portrait.
class _DrawerTile extends StatelessWidget {
  final Widget icon;
  final Widget title;

  final VoidCallback onTap;

  final bool selected;

  const _DrawerTile({
    Key key,
    @required this.icon,
    @required this.title,
    @required this.onTap,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (context.isLandscape) {
      final background = selected ? Theme.of(context).primaryColor : Colors.transparent;
      final foreground = selected ? Theme.of(context).primaryIconTheme.color : Theme.of(context).iconTheme.color;
      return Material(
        color: background,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconTheme(
                  data: IconThemeData(size: 36, color: foreground),
                  child: icon,
                ),
                SizedBox(height: 8),
                DefaultTextStyle(style: TextStyle(color: foreground), child: title),
              ],
            ),
          ),
        ),
      );
    } else {
      return ListTile(
        leading: icon,
        title: title,
        onTap: onTap,
        selected: selected,
      );
    }
  }
}
