import 'package:flutter/material.dart';
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
    return LoginStateWidget(Scaffold(
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
              Icon(
                Icons.music_note,
                color: Colors.white,
              ),
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
      body: PageView.builder(
          controller: _pageController, itemCount: 2, itemBuilder: _buildPages),
    ));
  }

  Widget _buildPages(BuildContext context, int index) {
    if (index == 0) {
      return MainPlaylistPage();
    } else if (index == 1) {
      return MainCloudPage();
    }
    throw Error;
  }
}

class MainPlaylistPage extends StatefulWidget {
  @override
  createState() => _MainPlaylistState();
}

class _MainPlaylistState extends State<MainPlaylistPage> {
  ScrollController _controller;

  List<Widget> _buildNavigationList(BuildContext context) {
    var widgets = [
      Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.music_note),
            title: Text("本地音乐"),
          ),
          Divider(height: 1),
        ],
      ),
      Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.schedule),
            title: Text("最近播放"),
          ),
          Divider(height: 1)
        ],
      ),
      Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.file_download),
            title: Text("下载管理"),
          ),
          Divider(height: 1),
        ],
      ),
      Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.library_music),
            title: Text("我的收藏"),
          ),
          Divider(height: 1),
        ],
      )
    ];

    if (LoginState.of(context).user == null) {
      widgets.insert(
          0,
          Column(
            children: <Widget>[
              ListTile(
                title: Text("当前未登录，点击登录!"),
                onTap: () {
                  Navigator.pushNamed(context, "/login").then((_) {
                    LoginState.refresh(context);
                  });
                },
              ),
              Divider(height: 1)
            ],
          ));
    }
    return widgets;
  }

  Widget _buildItem(BuildContext context, int index) {
    var navigationList = _buildNavigationList(context);
    if (index < navigationList.length) {
      return navigationList[index];
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: _controller, itemBuilder: _buildItem, itemCount: 20);
  }
}

class MainCloudPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Placeholder();
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
