import 'package:flutter/material.dart';
import 'package:quiet/pages/page_main_cloud.dart';
import 'package:quiet/pages/page_main_playlist.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Quiet(
      child: LoginStateWidget(Scaffold(
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              MyDrawerHeader(),
              MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Expanded(
                    child: ListView(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.settings,
                              color: Theme.of(context).iconTheme.color),
                          title: Text(
                            "设置",
                          ),
                          onTap: () {
                            //TODO to setting
                          },
                        ),
                        Divider(
                          height: 0.5,
                          indent: 64,
                        )
                      ],
                    ),
                  ))
            ],
          ),
        ),
        appBar: AppBar(
          title: Container(
            height: kToolbarHeight,
            width: 128,
            child: TabBar(
              controller: _tabController,
              tabs: <Widget>[
                Tab(child: Icon(Icons.music_note, color: Colors.white)),
                Tab(child: Icon(Icons.cloud, color: Colors.white)),
              ],
            ),
          ),
          titleSpacing: 0,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: () => {},
              icon: Icon(Icons.search),
            )
          ],
        ),
        body: BoxWithBottomPlayerController(TabBarView(
          controller: _tabController,
          children: <Widget>[MainPlaylistPage(), MainCloudPage()],
        )),
      )),
    );
  }
}

class MyDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget name;
    ImageProvider avatar;
    List<Widget> otherAccountsPictures;
    if (LoginState.of(context).isLogin) {
      Map profile = LoginState.of(context).user["profile"];
      name = Text(profile["nickname"]);
      avatar = NeteaseImage(profile["avatarUrl"]);
      otherAccountsPictures = [
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            tooltip: "退出登陆",
            onPressed: () {
              neteaseRepository.logout();
            },
          ),
        )
      ];
    } else {
      name = const Text("未登录");
    }

    void _onAvatarClick() {
      if (!LoginState.of(context).isLogin) {
        Navigator.of(context).pushNamed(ROUTE_LOGIN);
      } else {
        debugPrint("work in process...");
      }
    }

    return UserAccountsDrawerHeader(
      currentAccountPicture: InkResponse(
        onTap: _onAvatarClick,
        child: CircleAvatar(
          backgroundImage: avatar,
        ),
      ),
      accountName: name,
      accountEmail: null,
      otherAccountsPictures: otherAccountsPictures,
    );
  }
}
