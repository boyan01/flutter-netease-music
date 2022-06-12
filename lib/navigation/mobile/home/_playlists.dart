import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/user_playlists_provider.dart';
import '../../../repository.dart';
import 'playlist_tile.dart';

enum PlayListType { created, favorite }

class PlayListsGroupHeader extends StatelessWidget {
  const PlayListsGroupHeader({Key? key, required this.name, this.count})
      : super(key: key);

  final String name;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        color: Theme.of(context).backgroundColor,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Text('$name($count)'),
              const Spacer(),
              const Icon(Icons.add),
              const Icon(Icons.more_vert),
            ],
          ),
        ),
      ),
    );
  }
}

class MainPlayListTile extends StatelessWidget {
  const MainPlayListTile({
    Key? key,
    required this.data,
    this.enableBottomRadius = false,
  }) : super(key: key);

  final PlaylistDetail data;
  final bool enableBottomRadius;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        borderRadius: enableBottomRadius
            ? const BorderRadius.vertical(bottom: Radius.circular(4))
            : null,
        color: Theme.of(context).backgroundColor,
        child: PlaylistTile(playlist: data),
      ),
    );
  }
}

const double _kPlayListHeaderHeight = 48;

const double _kPlayListDividerHeight = 10;

class MyPlayListsHeaderDelegate extends SliverPersistentHeaderDelegate {
  MyPlayListsHeaderDelegate(this.tabController);

  final TabController? tabController;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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

class _MyPlayListsHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const _MyPlayListsHeader({Key? key, this.controller}) : super(key: key);
  final TabController? controller;

  @override
  Size get preferredSize => const Size.fromHeight(_kPlayListHeaderHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: controller,
        labelColor: Theme.of(context).textTheme.bodyText1!.color,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: [
          Tab(text: context.strings.createdSongList),
          Tab(text: context.strings.favoriteSongList),
        ],
      ),
    );
  }
}

class PlayListTypeNotification extends Notification {
  PlayListTypeNotification({required this.type});

  final PlayListType type;
}

class PlayListSliverKey extends ValueKey {
  const PlayListSliverKey({this.createdPosition, this.favoritePosition})
      : super('_PlayListSliverKey');
  final int? createdPosition;
  final int? favoritePosition;
}

class UserPlayListSection extends ConsumerStatefulWidget {
  const UserPlayListSection({
    Key? key,
    required this.userId,
    this.scrollController,
  }) : super(key: key);

  final int? userId;
  final ScrollController? scrollController;

  @override
  ConsumerState<UserPlayListSection> createState() =>
      _UserPlayListSectionState();
}

class _UserPlayListSectionState extends ConsumerState<UserPlayListSection> {
  final _dividerKey = GlobalKey();

  int _dividerIndex = -1;

  @override
  void initState() {
    super.initState();
    widget.scrollController!.addListener(_onScrolled);
  }

  @override
  void didUpdateWidget(covariant UserPlayListSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.scrollController!.removeListener(_onScrolled);
    widget.scrollController!.addListener(_onScrolled);
  }

  @override
  void dispose() {
    super.dispose();
    widget.scrollController!.removeListener(_onScrolled);
  }

  void _onScrolled() {
    if (_dividerIndex < 0) {
      return;
    }
    final RenderSliverList? global =
        context.findRenderObject() as RenderSliverList?;
    if (global == null) {
      return;
    }
    RenderObject? child = global.firstChild;
    while (
        child != null && global.indexOf(child as RenderBox) != _dividerIndex) {
      child = global.childAfter(child);
    }
    if (child == null) {
      return;
    }
    final offset = global.childMainAxisPosition(child as RenderBox);
    const height = _kPlayListHeaderHeight + _kPlayListDividerHeight / 2;
    PlayListTypeNotification(
            type:
                offset > height ? PlayListType.created : PlayListType.favorite)
        .dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isLoginProvider)) {
      return _singleSliver(child: notLogin(context));
    }
    final playlists = ref.watch(userPlaylistsProvider(widget.userId!));
    return playlists.when(
      data: (result) {
        final created = result.where((p) => p.creator.userId == widget.userId);
        final subscribed =
            result.where((p) => p.creator.userId != widget.userId);
        _dividerIndex = 2 + created.length;
        return SliverList(
          key: PlayListSliverKey(
              createdPosition: 1, favoritePosition: 3 + created.length),
          delegate: SliverChildListDelegate.fixed([
            const SizedBox(height: _kPlayListDividerHeight),
            PlayListsGroupHeader(
                name: context.strings.createdSongList, count: created.length),
            ..._playlistWidget(created.toList()),
            SizedBox(height: _kPlayListDividerHeight, key: _dividerKey),
            PlayListsGroupHeader(
                name: context.strings.favoriteSongList,
                count: subscribed.length),
            ..._playlistWidget(subscribed.toList()),
            const SizedBox(height: _kPlayListDividerHeight),
          ], addAutomaticKeepAlives: false),
        );
      },
      error: (error, stackTrace) =>
          _singleSliver(child: Text(context.formattedError(error))),
      loading: () => _singleSliver(child: Container()),
    );
  }

  Widget notLogin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Text(context.strings.playlistLoginDescription),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(pageLogin);
            },
            child: Text(context.strings.login),
          ),
        ],
      ),
    );
  }

  static Iterable<Widget> _playlistWidget(List<PlaylistDetail> details) {
    return [
      for (var i = 0; i < details.length; i++)
        MainPlayListTile(
          data: details[i],
          enableBottomRadius: i == details.length - 1,
        )
    ];
  }

  static Widget _singleSliver({required Widget child}) {
    return SliverList(
      delegate: SliverChildListDelegate([child]),
    );
  }
}
