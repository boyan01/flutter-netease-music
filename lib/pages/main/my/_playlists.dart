import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logging/logging.dart';
import 'package:quiet/component.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import '../playlist_tile.dart';

enum PlayListType { created, favorite }

class PlayListsGroupHeader extends StatelessWidget {
  final String name;
  final int count;

  const PlayListsGroupHeader({Key key, @required this.name, this.count}) : super(key: key);

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

class MainPlayListTile extends StatelessWidget {
  final PlaylistDetail data;
  final bool enableBottomRadius;

  const MainPlayListTile({
    Key key,
    @required this.data,
    this.enableBottomRadius = false,
  }) : super(key: key);

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

const double _kPlayListHeaderHeight = 48;

const double _kPlayListDividerHeight = 10;

class MyPlayListsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  MyPlayListsHeaderDelegate(this.tabController);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _MyPlayListsHeader(controller: tabController);
  }

  @override
  double get maxExtent => _kPlayListHeaderHeight;

  @override
  double get minExtent => _kPlayListHeaderHeight;

  @override
  bool shouldRebuild(covariant MyPlayListsHeaderDelegate oldDelegate) {
    return oldDelegate.tabController != tabController;
  }
}

class _MyPlayListsHeader extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;

  const _MyPlayListsHeader({Key key, this.controller}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(_kPlayListHeaderHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: controller,
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

class PlayListTypeNotification extends Notification {
  final PlayListType type;

  PlayListTypeNotification({@required this.type});
}

class PlayListSliverKey extends ValueKey {
  final int createdPosition;
  final int favoritePosition;

  const PlayListSliverKey({this.createdPosition, this.favoritePosition}) : super("_PlayListSliverKey");
}

class UserPlayListSection extends StatefulWidget {
  const UserPlayListSection({
    Key key,
    @required this.userId,
    this.scrollController,
  }) : super(key: key);

  final int userId;
  final ScrollController scrollController;

  @override
  _UserPlayListSectionState createState() => _UserPlayListSectionState();
}

class _UserPlayListSectionState extends State<UserPlayListSection> {
  final logger = Logger("_UserPlayListSectionState");

  final _dividerKey = GlobalKey();

  int _dividerIndex = -1;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScrolled);
  }

  @override
  void didUpdateWidget(covariant UserPlayListSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.scrollController.removeListener(_onScrolled);
    widget.scrollController.addListener(_onScrolled);
  }

  @override
  void dispose() {
    super.dispose();
    widget.scrollController.removeListener(_onScrolled);
  }

  void _onScrolled() {
    if (_dividerIndex < 0) {
      return;
    }
    final RenderSliverList global = context.findRenderObject();
    RenderObject child = global.firstChild;
    while (child != null && global.indexOf(child) != _dividerIndex) {
      child = global.childAfter(child);
    }
    if (child == null) {
      return;
    }
    final offset = global.childMainAxisPosition(child);
    const height = _kPlayListHeaderHeight + _kPlayListDividerHeight / 2;
    PlayListTypeNotification(type: offset > height ? PlayListType.created : PlayListType.favorite).dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!UserAccount.of(context).isLogin) {
      return _singleSliver(child: notLogin(context));
    }
    return Loader<List<PlaylistDetail>>(
        initialData: neteaseLocalData.getUserPlaylist(widget.userId),
        loadTask: () {
          return neteaseRepository.userPlaylist(widget.userId);
        },
        loadingBuilder: (context) {
          return _singleSliver(child: Container());
        },
        errorBuilder: (context, result) {
          return _singleSliver(child: Loader.buildSimpleFailedWidget(context, result));
        },
        builder: (context, result) {
          final created = result.where((p) => p.creator["userId"] == widget.userId);
          final subscribed = result.where((p) => p.creator["userId"] != widget.userId);
          _dividerIndex = 2 + created.length;
          return SliverList(
            key: PlayListSliverKey(createdPosition: 1, favoritePosition: 3 + created.length),
            delegate: SliverChildListDelegate.fixed([
              SizedBox(height: _kPlayListDividerHeight),
              PlayListsGroupHeader(name: context.strings["created_song_list"], count: created.length),
              ..._playlistWidget(created),
              SizedBox(height: _kPlayListDividerHeight, key: _dividerKey),
              PlayListsGroupHeader(name: context.strings["favorite_song_list"], count: subscribed.length),
              ..._playlistWidget(subscribed),
              SizedBox(height: _kPlayListDividerHeight),
            ], addAutomaticKeepAlives: false),
          );
        });
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

  static Iterable<Widget> _playlistWidget(Iterable<PlaylistDetail> details) {
    if (details.isEmpty) {
      return const [];
    }
    final list = details.toList(growable: false);
    final List<Widget> widgets = <Widget>[];
    for (int i = 0; i < list.length; i++) {
      widgets.add(MainPlayListTile(data: list[i], enableBottomRadius: i == list.length - 1));
    }
    return widgets;
  }

  static Widget _singleSliver({@required Widget child}) {
    return SliverList(
      delegate: SliverChildListDelegate([child]),
    );
  }
}
