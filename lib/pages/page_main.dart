import 'package:flutter/material.dart';
import 'package:quiet/pages/page_main_cloud.dart';
import 'package:quiet/pages/page_main_playlist.dart';
import 'package:quiet/part/part.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
    _tabController.addListener(() {
      _pageController.animateToPage(_tabController.index,
          duration: const Duration(milliseconds: 300), curve: Curves.linear);
    });
    _pageController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _tabController.index = _pageController.page.toInt();
        _tabController.offset = _pageController.page;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Quiet(
      child: LoginStateWidget(Scaffold(
        drawer: Drawer(
          child: ListView(
            children: <Widget>[MyDrawerHeader()],
          ),
        ),
        appBar: AppBar(
          title: Container(
            height: kToolbarHeight,
            width: 128,
            child: TabBar(
              controller: _tabController,
              tabs: <Widget>[
                Icon(Icons.music_note, color: Colors.white),
                Icon(Icons.cloud, color: Colors.white)
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
        body: BoxWithBottomPlayerController(PageView(
          controller: _pageController,
          children: <Widget>[MainPlaylistPage(), MainCloudPage()],
        )),
      )),
    );
  }
}

class MyDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      var state = LoginState.of(context);
      if (state.isLogin) {
        Map<String, Object> profile = state.user["profile"];
        return _createHeader(
            context, Image.network(profile["avatarUrl"]), profile["nickname"]);
      } else {
        return _createHeader(
            context,
            Container(
              color: Colors.grey,
            ),
            "未登录");
      }
    });
  }

  Widget _createHeader(BuildContext context, Widget avatar, String username) {
    return DrawerHeader(
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Column(
          children: <Widget>[
            Spacer(),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    height: 48,
                    width: 48,
                    child: ClipOval(
                      child: avatar,
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [Text(username)],
              ),
            )
          ],
        ));
  }
}
