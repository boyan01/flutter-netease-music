import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart' hide ExpansionPanel, ExpansionPanelList;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../media/tracks/track_list.dart';
import '../../../media/tracks/tracks_player.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/repository_provider.dart';
import '../../../providers/user_playlists_provider.dart';
import '../../../repository.dart';
import '../../common/buttons.dart';
import '../../common/navigation_target.dart';
import '../widgets/expansion_panel.dart';
import '../widgets/navigation_tile.dart';

class SliverSidebarUserPlaylist extends ConsumerWidget {
  const SliverSidebarUserPlaylist({super.key});

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
  const _UserPlaylistLoader({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(userPlaylistsProvider(userId));
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

class _UserPlaylist extends HookWidget {
  const _UserPlaylist({
    super.key,
    required this.playlists,
    required this.userId,
  });

  final List<PlaylistDetail> playlists;

  final int userId;

  @override
  Widget build(BuildContext context) {
    final created = playlists.where((p) => p.creator.userId == userId).toList();
    final subscribed =
        playlists.where((p) => p.creator.userId != userId).toList();

    final createdExpanded = useState(true);
    final subscribedExpanded = useState(true);

    final backgroundColor = context.colorScheme.surfaceWithElevation(1);

    return SliverToBoxAdapter(
      child: ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.zero,
        dividerColor: backgroundColor,
        elevation: 0,
        children: [
          ExpansionPanel(
            backgroundColor: backgroundColor,
            headerBuilder: (context, isExpanded) => _PlaylistsHeader(
              title: context.strings.createdSongList,
              expanded: isExpanded,
              onTap: () => createdExpanded.value = !isExpanded,
            ),
            body: Column(
              children: [
                for (final playlist in created)
                  _UserPlaylistItem(playlist: playlist),
              ],
            ),
            isExpanded: createdExpanded.value,
          ),
          ExpansionPanel(
            headerBuilder: (context, isExpanded) => _PlaylistsHeader(
              title: context.strings.favoriteSongList,
              expanded: isExpanded,
              onTap: () => subscribedExpanded.value = !isExpanded,
            ),
            backgroundColor: backgroundColor,
            body: Column(
              children: [
                for (final playlist in subscribed)
                  _UserPlaylistItem(playlist: playlist),
              ],
            ),
            isExpanded: subscribedExpanded.value,
          ),
        ],
      ),
    );
  }
}

class _PlaylistsHeader extends StatelessWidget {
  const _PlaylistsHeader({
    super.key,
    required this.title,
    required this.onTap,
    required this.expanded,
  });

  final String title;
  final VoidCallback onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Flexible(
              child: Text(title, style: context.textTheme.bodySmall),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: expanded ? 0 : -0.25,
              child: Icon(
                FluentIcons.chevron_down_16_regular,
                color: context.colorScheme.textPrimary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _UserPlaylistItem extends ConsumerWidget {
  const _UserPlaylistItem({
    super.key,
    required this.playlist,
  });

  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(
      navigatorProvider.select(
        (value) => value.current is NavigationTargetPlaylist
            ? (value.current as NavigationTargetPlaylist).playlistId
            : null,
      ),
    );
    return NavigationTile(
      icon: const Icon(FluentIcons.music_note_1_24_regular),
      title: Tooltip(
        message: playlist.name,
        child: Text(
          playlist.isFavorite
              ? context.strings.myFavoriteMusics
              : playlist.name,
        ),
      ),
      isSelected: current == playlist.id,
      trailing: !playlist.isFavorite
          ? null
          : AppIconButton(
              icon: FluentIcons.heart_pulse_20_regular,
              size: 20,
              tooltip: context.strings.intelligenceRecommended,
              onPressed: () async {
                final player = ref.read(playerProvider);
                if (player.repeatMode == RepeatMode.heart) {
                  ref
                      .read(navigatorProvider.notifier)
                      .navigate(NavigationTargetPlaying());
                  return;
                }
                try {
                  final list = await ref
                      .read(neteaseRepositoryProvider)
                      .playModeIntelligenceList(id: 1, playlistId: playlist.id);
                  if (list.isEmpty) {
                    e('playlist intelligence list is null');
                    return;
                  }
                  player.setRepeatMode(RepeatMode.heart);
                  player.setTrackList(
                    TrackList.playlist(
                      id: 'playlist_${playlist.id}',
                      tracks: list,
                      rawPlaylistId: playlist.id,
                      isUserFavoriteList: true,
                    ),
                  );
                  await player.playFromMediaId(list.first.id);
                } catch (error, stacktrace) {
                  e('error: $error, stacktrace: $stacktrace');
                  toast(context.formattedError(error));
                }
              },
            ),
      onTap: () => ref
          .read(navigatorProvider.notifier)
          .navigate(NavigationTarget.playlist(playlistId: playlist.id)),
    );
  }
}
