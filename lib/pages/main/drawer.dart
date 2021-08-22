import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/component.dart';
import 'package:quiet/material.dart';
import 'package:quiet/model.dart';
import 'package:quiet/pages/account/account.dart';
import 'package:quiet/pages/account/page_user_detail.dart';
import 'package:url_launcher/url_launcher.dart';

class MainNavigationDrawer extends StatelessWidget {
  const MainNavigationDrawer({Key? key}) : super(key: key);

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
                        icon: const Icon(Icons.settings),
                        title: const Text("设置"),
                        onTap: () {
                          Navigator.pushNamed(context, pageSetting);
                        },
                      ),
                      const Divider(height: 0, indent: 16),
                      MainNavigationDrawerTile(
                        icon: const Icon(Icons.format_quote),
                        title: const Text("Star On GitHub"),
                        onTap: () {
                          launch(
                              "https://github.com/boyan01/flutter-netease-music");
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
  const MainNavigationDrawerTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.selected = false,
  }) : super(key: key);

  final Widget icon;
  final Widget title;

  final VoidCallback onTap;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (context.isLandscape) {
      final background =
          selected ? Theme.of(context).primaryColor : Colors.transparent;
      final foreground = selected
          ? Theme.of(context).primaryIconTheme.color
          : Theme.of(context).iconTheme.color;
      return Material(
        color: background,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconTheme(
                  data: IconThemeData(size: 32, color: foreground),
                  child: icon,
                ),
                const SizedBox(height: 8),
                DefaultTextStyle(
                  style: context.textTheme.caption!.copyWith(color: foreground),
                  child: title,
                ),
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
class UserInfo extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(userProvider).isLogin) {
      return _buildHeader(context, ref);
    } else {
      return _buildHeaderNotLogin(context);
    }
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final UserProfile profile = ref.watch(userProvider).userDetail!.profile;
    return UserAccountsDrawerHeader(
      currentAccountPicture: InkResponse(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailPage(
                userId: ref.read(userProvider).userId,
              ),
            ),
          );
        },
        child: CircleAvatar(
          backgroundImage: CachedImage(profile.avatarUrl!),
        ),
      ),
      accountName: Text(profile.nickname!),
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
              if (await showConfirmDialog(context, const Text('确认退出登录吗？'),
                  positiveLabel: '退出登录')) {
                ref.read(userProvider.notifier).logout();
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
        constraints: const BoxConstraints.expand(),
        child: DefaultTextStyle(
          style: Theme.of(context)
              .primaryTextTheme
              .caption!
              .copyWith(fontSize: 14),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text("登陆网易云音乐"),
                const Text("手机电脑多端同步,尽享海量高品质音乐"),
                const SizedBox(height: 8),
                FlatButton(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .bodyText2!
                                .color!
                                .withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    onPressed: () {
                      Navigator.pushNamed(context, pageLogin);
                    },
                    textColor:
                        Theme.of(context).primaryTextTheme.bodyText2!.color,
                    child: const Text("立即登陆"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
