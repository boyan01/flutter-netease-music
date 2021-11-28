import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/part/part.dart';

import '_playlists.dart';
import '_preset_grid.dart';
import '_profile.dart';

///the first page display in page_main
class MainPageMy extends ConsumerStatefulWidget {
  @override
  _MainPageMyState createState() => _MainPageMyState();
}

class _MainPageMyState extends ConsumerState<MainPageMy>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  TabController? _tabController;

  bool _scrollerAnimating = false;
  bool _tabAnimating = false;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: PlayListType.values.length, vsync: this);
    _tabController!.addListener(_onUserSelectedTab);
  }

  void _onUserSelectedTab() {
    debugPrint("_onUserSelectedTab :"
        " ${_tabController!.index} ${_tabController!.indexIsChanging}");
    if (_scrollerAnimating || _tabAnimating) {
      return;
    }
    _scrollToPlayList(PlayListType.values[_tabController!.index]);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userId = ref.watch(userProvider)?.userId;
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              const UserProfileSection(),
              PresetGridSection(),
              const SizedBox(height: 8),
            ],
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: MyPlayListsHeaderDelegate(_tabController),
        ),
        NotificationListener<PlayListTypeNotification>(
          onNotification: (notification) {
            _updateCurrentTabSelection(notification.type);
            return true;
          },
          child: UserPlayListSection(
            userId: userId,
            scrollController: _scrollController,
          ),
        ),
      ],
    );
  }

  void _computeScroller(
    void Function(
      PlayListSliverKey sliverKey,
      List<Element> children,
      int start,
      int end,
    )
        callback,
  ) {
    SliverMultiBoxAdaptorElement? playListSliver;
    void playListSliverFinder(Element element) {
      if (element.widget.key is PlayListSliverKey) {
        playListSliver = element as SliverMultiBoxAdaptorElement?;
      } else if (playListSliver == null) {
        element.visitChildElements(playListSliverFinder);
      }
    }

    // to find PlayListSliver.
    context.visitChildElements(playListSliverFinder);

    if (playListSliver == null) {
      return;
    }

    final PlayListSliverKey? sliverKey =
        playListSliver!.widget.key as PlayListSliverKey?;
    assert(playListSliver != null, "can not find sliver");
    debugPrint("sliverKey : created position:"
        " ${sliverKey!.createdPosition} ${sliverKey.favoritePosition}");

    final List<Element> children = [];
    playListSliver!.visitChildElements((element) {
      children.add(element);
    });
    if (children.isEmpty) {
      return;
    }
    final start = _index(children.first)!;
    final end = _index(children.last)!;
    if (end <= start) {
      return;
    }
    debugPrint("position start - end -> $start - $end");
    callback(sliverKey, children, start, end);
  }

  void _scrollToPlayList(PlayListType type) {
    _scrollerAnimating = true;

    _computeScroller((sliverKey, children, start, end) {
      final target = type == PlayListType.created
          ? sliverKey.createdPosition!
          : sliverKey.favoritePosition!;
      final position = _scrollController.position;
      if (target >= start && target <= end) {
        final Element toShow = children[target - start];
        position
            .ensureVisible(toShow.renderObject!,
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear)
            .whenComplete(() {
          _scrollerAnimating = false;
        });
      } else if (target < start) {
        position
            .ensureVisible(
          children.first.renderObject!,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        )
            .then((_) {
          WidgetsBinding.instance!.scheduleFrameCallback((timeStamp) {
            _scrollToPlayList(type);
          });
        });
      } else if (target > end) {
        position
            .ensureVisible(
          children.last.renderObject!,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        )
            .then((_) {
          WidgetsBinding.instance!.scheduleFrameCallback((timeStamp) {
            _scrollToPlayList(type);
          });
        });
      }
    });
  }

  static int? _index(Element element) {
    int? index;
    void _findIndex(Element e) {
      if (e.widget is IndexedSemantics) {
        index = (e.widget as IndexedSemantics).index;
      } else {
        e.visitChildElements(_findIndex);
      }
    }

    element.visitChildElements(_findIndex);
    assert(index != null, "can not get index for element $element");
    return index;
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _updateCurrentTabSelection(PlayListType type) async {
    if (_tabController!.index == type.index) {
      return;
    }
    if (_tabController!.indexIsChanging ||
        _scrollerAnimating ||
        _tabAnimating) {
      return;
    }
    _tabAnimating = true;
    _tabController!.animateTo(type.index);
    Future.delayed(kTabScrollDuration + const Duration(milliseconds: 100))
        .whenComplete(() {
      _tabAnimating = false;
    });
  }
}
