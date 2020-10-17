part of 'page_user_detail.dart';

class TabMusic extends StatefulWidget {
  final UserProfile profile;

  const TabMusic(this.profile, {Key key})
      : assert(profile != null),
        super(key: key);

  @override
  _TabMusicState createState() => _TabMusicState();
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
      loadTask: () => neteaseRepository.userPlaylist(widget.profile.userId),
      serialize: (list) => list.map((it) => it.toMap()).toList(),
      deserialize: (list) => (list as List)
          .map((it) => PlaylistDetail.fromMap(it))
          .toList()
          .cast(),
      builder: (context, result) {
        final created =
            result.where((p) => p.creator["userId"] == widget.profile.userId);
        final subscribed =
            result.where((p) => p.creator["userId"] != widget.profile.userId);
        return ListView(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: _Header(title: '歌单(${created.length})')),
                Text('共被收藏${widget.profile.playlistBeSubscribedCount}次',
                    style: Theme.of(context).textTheme.caption),
                SizedBox(width: 16),
              ],
            ),
            ...created.map((playlist) => PlaylistTile(
                  playlist: playlist,
                  enableMore: false,
                  enableHero: false,
                )),
            if (subscribed.isNotEmpty) ...[
              _Header(title: '收藏的歌单(${subscribed.length})'),
              ...subscribed.map((playlist) => PlaylistTile(
                    playlist: playlist,
                    enableMore: false,
                    enableHero: false,
                  )),
            ],
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final String title;

  const _Header({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
