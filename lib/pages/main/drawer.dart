import 'package:flutter/material.dart';
import 'package:quiet/component.dart';
import 'package:quiet/material.dart';
import 'package:quiet/model.dart';
import 'package:quiet/pages/account/account.dart';
import 'package:quiet/pages/account/page_user_detail.dart';
import 'package:url_launcher/url_launcher.dart';

class MainNavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserInfo(),
          MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Expanded(
                child: ListTileTheme(
                  style: ListTileStyle.drawer,
                  child: ListView(
                    children: <Widget>[
                      MainNavigationDrawerTile(
                        icon: Icon(Icons.settings),
                        title: Text("设置"),
                        onTap: () {
                          Navigator.pushNamed(context, ROUTE_SETTING);
                        },
                      ),
                      Divider(height: 0, indent: 16),
                      MainNavigationDrawerTile(
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
class MainNavigationDrawerTile extends StatelessWidget {
  final Widget icon;
  final Widget title;

  final VoidCallback onTap;

  final bool selected;

  const MainNavigationDrawerTile({
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

///the header of drawer
class UserInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (UserAccount.of(context).isLogin) {
      return _buildHeader(context);
    } else {
      return _buildHeaderNotLogin(context);
    }
  }

  Widget _buildHeader(BuildContext context) {
    UserProfile profile = UserAccount.of(context).userDetail.profile;
    return UserAccountsDrawerHeader(
      currentAccountPicture: InkResponse(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserDetailPage(userId: UserAccount.of(context).userId)));
        },
        child: CircleAvatar(
          backgroundImage: CachedImage(profile.avatarUrl),
        ),
      ),
      accountName: Text(profile.nickname),
      accountEmail: null,
      otherAccountsPictures: [
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            tooltip: "退出登陆",
            onPressed: () async {
              if (await showConfirmDialog(context, Text('确认退出登录吗？'), positiveLabel: '退出登录')) {
                UserAccount.of(context, rebuildOnChange: false).logout();
              }
            },
          ),
        )
      ],
    );
  }

  Widget _buildHeaderNotLogin(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
      ),
      child: Container(
        constraints: BoxConstraints.expand(),
        child: DefaultTextStyle(
          style: Theme.of(context).primaryTextTheme.caption.copyWith(fontSize: 14),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("登陆网易云音乐"),
                Text("手机电脑多端同步,尽享海量高品质音乐"),
                SizedBox(height: 8),
                FlatButton(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).primaryTextTheme.bodyText2.color.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    onPressed: () {
                      Navigator.pushNamed(context, pageLogin);
                    },
                    textColor: Theme.of(context).primaryTextTheme.bodyText2.color,
                    child: Text("立即登陆"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
