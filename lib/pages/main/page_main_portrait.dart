part of "page_main.dart";

class _PortraitMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<_PortraitMainPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProxyAnimation transitionAnimation =
      ProxyAnimation(kAlwaysDismissedAnimation);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MainNavigationDrawer(),
      appBar: AppBar(
        toolbarTextStyle: context.textTheme.bodyText2,
        iconTheme: Theme.of(context).iconTheme,
        leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            }),
        title: SizedBox(
          height: kToolbarHeight,
          width: 128,
          child: TabBar(
            labelColor: Theme.of(context).textTheme.bodyText1!.color,
            unselectedLabelColor: Theme.of(context).textTheme.caption!.color,
            controller: _tabController,
            indicatorColor: Colors.transparent,
            labelStyle: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                Theme.of(context).textTheme.caption!.copyWith(fontSize: 14),
            tabs: <Widget>[
              _PageTab(text: context.strings.my),
              _PageTab(text: context.strings.discover),
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
              Navigator.push(context, SearchPageRoute(transitionAnimation));
            },
            icon: const Icon(Icons.search),
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
  const _PageTab({Key? key, required this.text}) : super(key: key);
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(text!),
      ),
    );
  }
}
