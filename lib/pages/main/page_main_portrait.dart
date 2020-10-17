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
      drawer: MainNavigationDrawer(),
      appBar: AppBar(
        textTheme: Theme.of(context).textTheme,
        iconTheme: Theme.of(context).iconTheme,
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            }),
        title: Container(
          height: kToolbarHeight,
          width: 128,
          child: TabBar(
            labelColor: Theme.of(context).textTheme.bodyText1.color,
            unselectedLabelColor: Theme.of(context).textTheme.caption.color,
            controller: _tabController,
            indicatorColor: Colors.transparent,
            labelStyle: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: Theme.of(context).textTheme.caption.copyWith(fontSize: 14),
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
        children: <Widget>[MainPageMy(), MainPageDiscover()],
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
