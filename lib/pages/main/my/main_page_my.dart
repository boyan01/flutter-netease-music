import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:quiet/component.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import '../playlist_tile.dart';
import '_preset_grid.dart';
import '_profile.dart';

///the first page display in page_main
class MainPageMy extends StatefulWidget {
  @override
  createState() => _MainPlaylistState();
}

class _MainPlaylistState extends State<MainPageMy> with AutomaticKeepAliveClientMixin {
  GlobalKey<LoaderState> _loaderKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userId = UserAccount.of(context).userId;
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        final Logger logger = Logger("_MyPlayListsHeaderState");
        logger.info("on update: ${notification.scrollDelta}");
        return true;
      },
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                UserProfileSection(),
                PresetGridSection(),
                SizedBox(height: 8),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: MyPlayListsHeaderDelegate(),
          ),
          _UserPlayListSection(loaderKey: _loaderKey, userId: userId),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

const double _kPlayListHeaderHeight = 48;

class MyPlayListsHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _MyPlayListsHeader();
  }

  @override
  double get maxExtent => _kPlayListHeaderHeight;

  @override
  double get minExtent => _kPlayListHeaderHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class _MyPlayListsHeader extends StatefulWidget implements PreferredSizeWidget {
  @override
  _MyPlayListsHeaderState createState() => _MyPlayListsHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(_kPlayListHeaderHeight);
}

class _MyPlayListsHeaderState extends State<_MyPlayListsHeader> with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: _controller,
        labelColor: Theme.of(context).textTheme.bodyText1.color,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: [
          Tab(text: context.strings["created_song_list"]),
          Tab(text: context.strings["favorite_song_list"]),
        ],
      ),
    );
  }
}

class _UserPlayListSection extends StatelessWidget {
  const _UserPlayListSection({
    Key key,
    @required GlobalKey<LoaderState> loaderKey,
    @required this.userId,
  })  : _loaderKey = loaderKey,
        super(key: key);

  final GlobalKey<LoaderState> _loaderKey;
  final int userId;

  @override
  Widget build(BuildContext context) {
    if (!UserAccount.of(context).isLogin) {
      return _singleSliver(child: notLogin(context));
    }
    return Loader<List<PlaylistDetail>>(
        key: _loaderKey,
        initialData: neteaseLocalData.getUserPlaylist(userId),
        loadTask: () {
          return neteaseRepository.userPlaylist(userId);
        },
        loadingBuilder: (context) {
          return _singleSliver(child: Container());
        },
        errorBuilder: (context, result) {
          return _singleSliver(child: Loader.buildSimpleFailedWidget(context, result));
        },
        builder: (context, result) {
          final created = result.where((p) => p.creator["userId"] == userId);
          final subscribed = result.where((p) => p.creator["userId"] != userId);
          return SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 10),
              _PlayListsGroupHeader(name: context.strings["created_song_list"], count: created.length),
              ..._playlistWidget(created),
              SizedBox(height: 10),
              _PlayListsGroupHeader(name: context.strings["favorite_song_list"], count: subscribed.length),
              ..._playlistWidget(subscribed),
              SizedBox(height: 10),
            ]),
          );
        });
  }

  static Iterable<Widget> _playlistWidget(Iterable<PlaylistDetail> details) {
    if (details.isEmpty) {
      return const [];
    }
    final list = details.toList(growable: false);
    final List<Widget> widgets = <Widget>[];
    for (int i = 0; i < list.length; i++) {
      widgets.add(_MyPlayListTile(data: list[i], enableBottomRadius: i == list.length - 1));
    }
    return widgets;
  }

  static Widget _singleSliver({@required Widget child}) {
    return SliverList(
      delegate: SliverChildListDelegate([child]),
    );
  }

  Widget notLogin(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Text(context.strings["playlist_login_description"]),
          TextButton(
            child: Text(context.strings["login_right_now"]),
            onPressed: () {
              Navigator.of(context).pushNamed(pageLogin);
            },
          ),
        ],
      ),
    );
  }
}

class _MyPlayListTile extends StatelessWidget {
  final PlaylistDetail data;
  final bool enableBottomRadius;

  const _MyPlayListTile({Key key, @required this.data, this.enableBottomRadius = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        borderRadius: enableBottomRadius ? const BorderRadius.vertical(bottom: Radius.circular(4)) : null,
        color: Theme.of(context).backgroundColor,
        child: Container(
          child: PlaylistTile(playlist: data),
        ),
      ),
    );
  }
}

class _PlayListsGroupHeader extends StatelessWidget {
  final String name;
  final int count;

  const _PlayListsGroupHeader({Key key, @required this.name, this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        color: Theme.of(context).backgroundColor,
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Text("$name($count)"),
              Spacer(),
              Icon(Icons.add),
              Icon(Icons.more_vert),
            ],
          ),
        ),
      ),
    );
  }
}
