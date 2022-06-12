part of 'page_user_detail.dart';

class TabMusic extends StatefulWidget {
  const TabMusic(this.profile, {super.key});

  final User profile;

  @override
  State<TabMusic> createState() => _TabMusicState();
}

class _TabMusicState extends State<TabMusic>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CachedLoader<List<PlaylistDetail>>(
      cacheKey: 'user_playlist_${widget.profile.userId}',
      loadTask: () => neteaseRepository!.userPlaylist(widget.profile.userId),
      serialize: (list) => list.map((it) => it.toJson()).toList(),
      deserialize: (list) => (list as List)
          .cast<Map<String, dynamic>>()
          .map(PlaylistDetail.fromJson)
          .toList()
          .cast(),
      builder: (context, result) {
        final created =
            result.where((p) => p.creator.userId == widget.profile.userId);
        final subscribed =
            result.where((p) => p.creator.userId != widget.profile.userId);
        return ListView(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: _Header(title: '歌单(${created.length})')),
                Text(
                  '共被收藏${widget.profile.playlistBeSubscribedCount}次',
                  style: Theme.of(context).textTheme.caption,
                ),
                const SizedBox(width: 16),
              ],
            ),
            ...created.map(
              (playlist) => PlaylistTile(
                playlist: playlist,
                enableMore: false,
                enableHero: false,
              ),
            ),
            if (subscribed.isNotEmpty) ...[
              _Header(title: '收藏的歌单(${subscribed.length})'),
              ...subscribed.map(
                (playlist) => PlaylistTile(
                  playlist: playlist,
                  enableMore: false,
                  enableHero: false,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
