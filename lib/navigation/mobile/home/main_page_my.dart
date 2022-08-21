import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/account_provider.dart';
import '_playlists.dart';
import '_preset_grid.dart';
import '_profile.dart';

///the first page display in page_main
class MainPageMy extends ConsumerStatefulWidget {
  const MainPageMy({super.key});

  @override
  ConsumerState<MainPageMy> createState() => _MainPageMyState();
}

class _MainPageMyState extends ConsumerState<MainPageMy>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late TabController _tabController;

  bool _tabAnimating = false;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: PlayListType.values.length, vsync: this);
    _tabController.addListener(_onUserSelectedTab);
  }

  void _onUserSelectedTab() {
    if (_tabAnimating) {
      return;
    }
    _scrollToPlayList(PlayListType.values[_tabController.index]);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
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
              const PresetGridSection(),
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

  void _scrollToPlayList(PlayListType type) {}

  @override
  bool get wantKeepAlive => true;

  Future<void> _updateCurrentTabSelection(PlayListType type) async {
    if (_tabController.index == type.index) {
      return;
    }
    if (_tabController.indexIsChanging || _tabAnimating) {
      return;
    }
    _tabAnimating = true;
    _tabController.animateTo(type.index);
    await Future.delayed(kTabScrollDuration + const Duration(milliseconds: 100))
        .whenComplete(() {
      _tabAnimating = false;
    });
  }
}
