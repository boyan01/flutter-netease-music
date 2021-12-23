import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/desktop/widgets/navigation_tile.dart';
import 'package:quiet/providers/navigator_provider.dart';
import 'package:quiet/repository.dart';

import '../../../pages/account/account.dart';
import '../../../providers/user_playlists_provider.dart';
import '../../common/navigation_target.dart';

class SliverSidebarUserPlaylist extends ConsumerWidget {
  const SliverSidebarUserPlaylist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider);
    if (userId == null) {
      return const SliverPadding(padding: EdgeInsets.zero);
    }
    return _UserPlaylistLoader(userId: userId);
  }
}

class _UserPlaylistLoader extends ConsumerWidget {
  const _UserPlaylistLoader({Key? key, required this.userId}) : super(key: key);

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(userPlaylistsProvider(userId));
    importExtension();
    return data.when(
      data: (data) => _UserPlaylist(playlists: data, userId: userId),
      loading: () => const SliverPadding(
        padding: EdgeInsets.only(top: 16),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
      error: (e, stacktrace) => SliverPadding(
        padding: const EdgeInsets.only(top: 16),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: Text(context.formattedError(e)),
          ),
        ),
      ),
    );
  }
}

class _UserPlaylist extends StatelessWidget {
  const _UserPlaylist({
    Key? key,
    required this.playlists,
    required this.userId,
  }) : super(key: key);

  final List<PlaylistDetail> playlists;

  final int userId;

  @override
  Widget build(BuildContext context) {
    final created = playlists.where((p) => p.creator.userId == userId).toList();
    final subscribed =
        playlists.where((p) => p.creator.userId != userId).toList();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return NavigationTitle(title: context.strings.createdSongList);
          }
          if (index <= created.length) {
            return _UserPlaylistItem(playlist: created[index - 1]);
          }
          if (index - 1 == created.length) {
            return NavigationTitle(title: context.strings.favoriteSongList);
          }
          return _UserPlaylistItem(
            playlist: subscribed[index - created.length - 2],
          );
        },
        childCount: playlists.length + 2, // +2 for created and subscribed title
      ),
    );
  }
}

class _UserPlaylistItem extends ConsumerWidget {
  const _UserPlaylistItem({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(navigatorProvider.select((value) =>
        value.current is NavigationTargetPlaylist
            ? (value.current as NavigationTargetPlaylist).playlistId
            : null));
    return NavigationTile(
      icon: const Icon(Icons.playlist_play),
      title: Tooltip(
        message: playlist.name,
        child: Text(playlist.name),
      ),
      isSelected: current == playlist.id,
      onTap: () => ref
          .read(navigatorProvider.notifier)
          .navigate(NavigationTarget.playlist(playlistId: playlist.id)),
    );
  }
}
