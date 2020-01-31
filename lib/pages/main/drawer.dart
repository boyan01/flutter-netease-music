part of "page_main.dart";

class _Drawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          _AppDrawerHeader(),
          MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Expanded(
                child: ListTileTheme(
                  style: ListTileStyle.drawer,
                  child: ListView(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.settings),
                        title: Text("设置"),
                        onTap: () {
                          Navigator.pushNamed(context, ROUTE_SETTING);
                        },
                      ),
                      Divider(height: 0, indent: 16),
                      ListTile(
                        leading: Icon(Icons.format_quote),
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
