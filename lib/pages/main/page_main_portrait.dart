part of "page_main.dart";

class _PortraitMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<_PortraitMainPage> with SingleTickerProviderStateMixin {
  TabController _tabController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProxyAnimation transitionAnimation = ProxyAnimation(kAlwaysDismissedAnimation);

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
    return Scaffold(
      key: _scaffoldKey,
      drawer: _Drawer(),
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            }),
        title: Container(
          height: kToolbarHeight,
          width: 128,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            labelStyle: Theme.of(context).primaryTextTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: Theme.of(context).primaryTextTheme.caption.copyWith(fontSize: 14),
            tabs: <Widget>[
              _PageTab(text: context.strings.main_page_tab_title_my),
              _PageTab(text: context.strings.main_page_tab_title_discover),
            ],
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleSpacing: 0,
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(context, NeteaseSearchPageRoute(transitionAnimation));
            },
            icon: Icon(Icons.search),
          )
        ],
      ),
      body: BoxWithBottomPlayerController(TabBarView(
        controller: _tabController,
        children: <Widget>[MainPlaylistPage(), MainCloudPage()],
      )),
    );
  }
}

class _PageTab extends StatelessWidget {
  final String text;

  const _PageTab({Key key, @required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(text),
      ),
    );
  }
}

///the header of drawer
class _UserInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (UserAccount.of(context).isLogin) {
      return _buildHeader(context);
    } else {
      return _buildHeaderNotLogin(context);
    }
  }

  Widget _buildHeader(BuildContext context) {
    Map profile = UserAccount.of(context).user["profile"];
    return UserAccountsDrawerHeader(
      currentAccountPicture: InkResponse(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserDetailPage(userId: UserAccount.of(context).userId)));
        },
        child: CircleAvatar(
          backgroundImage: CachedImage(profile["avatarUrl"]),
        ),
      ),
      accountName: Text(profile["nickname"]),
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
