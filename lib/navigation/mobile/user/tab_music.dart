part of 'page_user_detail.dart';

class TabMusic extends ConsumerStatefulWidget {
  const TabMusic(this.profile, {super.key});

  final User profile;

  @override
  ConsumerState createState() => _TabMusicState();
}

class _TabMusicState extends ConsumerState<TabMusic>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final playlists = ref.watch(userPlaylistsProvider(widget.profile.userId));
    return playlists.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(context.formattedError(e))),
      data: (result) {
        final created =
            result.where((p) => p.creatorUserId == widget.profile.userId);
        final subscribed =
            result.where((p) => p.creatorUserId != widget.profile.userId);
        return ListView(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: _Header(title: '歌单(${created.length})')),
                Text(
                  '共被收藏${widget.profile.playlistBeSubscribedCount}次',
                  style: Theme.of(context).textTheme.bodySmall,
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
