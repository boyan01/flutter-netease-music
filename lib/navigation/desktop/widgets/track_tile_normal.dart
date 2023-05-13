import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/playlist_detail_provider.dart';
import '../../../providers/user_playlists_provider.dart';
import '../../../repository.dart';
import '../../common/like_button.dart';
import '../../common/navigation_target.dart';
import '../../common/player/animated_playing_indicator.dart';
import '../../common/playlist/track_list_container.dart';
import 'context_menu.dart';
import 'highlight_clickable_text.dart';

class TrackTableContainer extends StatelessWidget {
  const TrackTableContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => _TrackTableContainer(
        width: constraints.maxWidth - 110,
        child: child,
      ),
    );
  }
}

class _TrackTableContainer extends StatefulWidget {
  const _TrackTableContainer({
    super.key,
    required this.child,
    required this.width,
  });

  final Widget child;

  final double width;

  @override
  State<_TrackTableContainer> createState() => _TrackTableContainerState();

  static _TrackTableContainerState of(BuildContext context) {
    final state = context.findAncestorStateOfType<_TrackTableContainerState>();
    assert(state != null, '_TrackTableContainerState not found');
    return state!;
  }
}

class _TrackTableContainerState extends State<_TrackTableContainer> {
  double nameWidth = 0;
  double artistWidth = 0;
  double albumWidth = 0;
  double durationWidth = 0;

  static const _nameMinWidth = 80.0;
  static const _artistMinWidth = 80.0;
  static const _albumMinWidth = 80.0;
  static const _durationMinWidth = 40.0;

  @override
  void initState() {
    super.initState();
    nameWidth = widget.width * .30;
    artistWidth = widget.width * .30;
    albumWidth = widget.width * .30;
    durationWidth = widget.width * .10;
  }

  @override
  void didUpdateWidget(covariant _TrackTableContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.width != widget.width) {
      final totalWidth = nameWidth + artistWidth + albumWidth + durationWidth;
      nameWidth = widget.width * nameWidth / totalWidth;
      artistWidth = widget.width * artistWidth / totalWidth;
      albumWidth = widget.width * albumWidth / totalWidth;
      durationWidth = widget.width * durationWidth / totalWidth;
    }
  }

  void offsetNameArtist(double? delta) {
    if (delta == null) {
      return;
    }
    setState(() {
      nameWidth += delta;
      artistWidth -= delta;
      if (nameWidth < _nameMinWidth) {
        artistWidth = artistWidth + nameWidth - _nameMinWidth;
        nameWidth = _nameMinWidth;
      } else if (artistWidth < _artistMinWidth) {
        nameWidth = nameWidth + artistWidth - _artistMinWidth;
        artistWidth = _artistMinWidth;
      }
    });
  }

  void offsetArtistAlbum(double? delta) {
    if (delta == null) {
      return;
    }
    setState(() {
      artistWidth += delta;
      albumWidth -= delta;
      if (artistWidth < _artistMinWidth) {
        albumWidth = albumWidth + artistWidth - _artistMinWidth;
        artistWidth = _artistMinWidth;
      } else if (albumWidth < _albumMinWidth) {
        artistWidth = artistWidth + albumWidth - _albumMinWidth;
        albumWidth = _albumMinWidth;
      }
    });
  }

  void offsetAlbumDuration(double? delta) {
    if (delta == null) {
      return;
    }
    setState(() {
      albumWidth += delta;
      durationWidth -= delta;
      if (albumWidth < _albumMinWidth) {
        durationWidth = durationWidth + albumWidth - _albumMinWidth;
        albumWidth = _albumMinWidth;
      } else if (durationWidth < _durationMinWidth) {
        albumWidth = albumWidth + durationWidth - _durationMinWidth;
        durationWidth = _durationMinWidth;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _TrackTableConfiguration(
      nameWidth: nameWidth,
      artistWidth: artistWidth,
      albumWidth: albumWidth,
      durationWidth: durationWidth,
      child: widget.child,
    );
  }
}

class _TrackTableConfiguration extends InheritedWidget {
  const _TrackTableConfiguration({
    super.key,
    required super.child,
    required this.nameWidth,
    required this.artistWidth,
    required this.albumWidth,
    required this.durationWidth,
  });

  final double nameWidth;
  final double artistWidth;
  final double albumWidth;
  final double durationWidth;

  static _TrackTableConfiguration of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<_TrackTableConfiguration>();
    assert(result != null, 'No _TrackTableConfiguration found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_TrackTableConfiguration old) {
    return nameWidth != old.nameWidth ||
        artistWidth != old.artistWidth ||
        albumWidth != old.albumWidth ||
        durationWidth != old.durationWidth;
  }
}

class TrackTableHeader extends StatelessWidget implements PreferredSizeWidget {
  const TrackTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: context.textTheme.bodySmall!,
      child: SizedBox.fromSize(
        size: preferredSize,
        child: Row(
          children: [
            const SizedBox(width: 80),
            SizedBox(
              width: _TrackTableConfiguration.of(context).nameWidth - 2,
              child: Text(context.strings.musicName),
            ),
            SizedBox(
              width: 4,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      _TrackTableContainer.of(context)
                          .offsetNameArtist(details.primaryDelta),
                ),
              ),
            ),
            SizedBox(
              width: _TrackTableConfiguration.of(context).artistWidth - 4,
              child: Text(context.strings.artists),
            ),
            SizedBox(
              width: 4,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      _TrackTableContainer.of(context)
                          .offsetArtistAlbum(details.primaryDelta),
                ),
              ),
            ),
            SizedBox(
              width: _TrackTableConfiguration.of(context).albumWidth - 4,
              child: Text(context.strings.album),
            ),
            SizedBox(
              width: 4,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      _TrackTableContainer.of(context)
                          .offsetAlbumDuration(details.primaryDelta),
                ),
              ),
            ),
            SizedBox(
              width: _TrackTableConfiguration.of(context).durationWidth - 2,
              child: Text(context.strings.duration),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);
}

class TrackTile extends HookConsumerWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.index,
  });

  final Track track;

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = _TrackTableConfiguration.of(context);
    final highlighting = useState(false);
    final isMounted = useIsMounted();

    Future<void> showContextMenu(Offset globalPosition) async {
      highlighting.value = true;
      final controller = TrackTileContainer.controller(context);
      final entry = showOverlayAtPosition(
        globalPosition: globalPosition,
        builder: (context) => _TrackItemMenus(
          track: track,
          playTrack: () => controller.play(track),
          deleteTrack:
              controller.canDelete ? () => controller.delete(track) : null,
        ),
      );
      await entry.dismissed;
      if (!isMounted()) {
        return;
      }
      highlighting.value = false;
    }

    final isMouseTracking = useRef(false);

    return SizedBox(
      height: 36,
      child: Material(
        color: index.isEven
            ? context.colorScheme.background
            : context.colorScheme.primary.withOpacity(0.04),
        child: ColoredBox(
          color: highlighting.value
              ? context.colorScheme.highlight
              : Colors.transparent,
          child: GestureDetector(
            onSecondaryTapUp: (details) =>
                showContextMenu(details.globalPosition),
            onLongPressDown: (details) {
              isMouseTracking.value = details.kind == PointerDeviceKind.mouse;
            },
            onLongPressUp: () {
              isMouseTracking.value = false;
            },
            onLongPressStart: (details) {
              if (isMouseTracking.value) {
                return;
              }
              showContextMenu(details.globalPosition);
            },
            child: InkWell(
              onTap: () {
                if (track.type == TrackType.noCopyright) {
                  toast(context.strings.trackNoCopyright);
                  return;
                }
                TrackTileContainer.controller(context).play(track);
              },
              child: DefaultTextStyle(
                style: const TextStyle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: _IndexOrPlayIcon(index: index, track: track),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 20,
                      child: LikeButton(
                        music: track,
                        iconSize: 16,
                        padding: const EdgeInsets.all(2),
                        likedColor: context.colorScheme.primary,
                        color: context.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: configuration.nameWidth,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          track.name,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: track.type == TrackType.noCopyright
                                ? context.colorScheme.textDisabled
                                : null,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: configuration.artistWidth,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: HighlightArtistText(
                          artists: track.artists,
                          onTap: (artist) {
                            if (artist.id == 0) {
                              return;
                            }
                            ref.read(navigatorProvider.notifier).navigate(
                                  NavigationTargetArtistDetail(
                                    artist.id,
                                  ),
                                );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: configuration.albumWidth,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: HighlightClickableText(
                          text: track.album?.name ?? '',
                          enable: track.album != null &&
                              track.album!.id != 0 &&
                              track.album!.name.isNotEmpty,
                          onTap: () {
                            final albumId = track.album?.id;
                            if (albumId == null) {
                              return;
                            }
                            ref
                                .read(navigatorProvider.notifier)
                                .navigate(NavigationTargetAlbumDetail(albumId));
                          },
                          style: context.textTheme.bodySmall,
                          highlightStyle: context.textTheme.bodySmall?.copyWith(
                            color: context.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: configuration.durationWidth,
                      child: Text(
                        track.duration.timeStamp,
                        style: context.textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IndexOrPlayIcon extends ConsumerWidget {
  const _IndexOrPlayIcon({
    super.key,
    required this.index,
    required this.track,
  });

  final int index;
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingListId = ref.watch(playingListProvider).id;
    final playingTrack = ref.watch(playingTrackProvider);
    final isCurrent =
        TrackTileContainer.controller(context).playlistId == playingListId &&
            playingTrack?.id == track.id;
    final isPlaying = ref.watch(isPlayingProvider);
    if (isCurrent) {
      return AnimatedPlayingIndicator(playing: isPlaying);
    } else {
      return Text(
        index.toString().padLeft(2, '0'),
        style: context.textTheme.bodySmall,
      );
    }
  }
}

class _TrackItemMenus extends ConsumerWidget {
  const _TrackItemMenus({
    super.key,
    required this.track,
    required this.playTrack,
    required this.deleteTrack,
  });

  final Track track;
  final VoidCallback playTrack;
  final Future<void> Function()? deleteTrack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider);
    return ContextMenuLayout(
      children: [
        ContextMenuItem(
          title: Text(context.strings.play),
          icon: const Icon(FluentIcons.play_circle_24_regular),
          enable: track.type != TrackType.noCopyright,
          onTap: playTrack,
        ),
        ContextMenuItem(
          title: Text(context.strings.playInNext),
          icon: const Icon(FluentIcons.arrow_forward_24_regular),
          enable: track.type != TrackType.noCopyright,
          onTap: () {
            ref.read(playerProvider).insertToNext(track);
          },
        ),
        if (userId != null)
          ContextMenuItem(
            title: Text(context.strings.addToPlaylist),
            icon: const Icon(FluentIcons.album_add_24_regular),
            subMenuBuilder: (context) => _AddToPlaylistSubMenu(track: track),
          ),
        if (deleteTrack != null)
          ContextMenuItem(
            title: Text(context.strings.delete),
            icon: const Icon(FluentIcons.delete_24_regular),
            onTap: deleteTrack,
          ),
      ],
    );
  }
}

class _AddToPlaylistSubMenu extends ConsumerWidget {
  const _AddToPlaylistSubMenu({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.read(userIdProvider);
    assert(userId != null, 'userId is null');
    final data = ref.watch(
      userPlaylistsProvider(userId!).select(
        (value) => value.whenData(
          (value) => value.where((element) => element.creator.userId == userId),
        ),
      ),
    );
    return data.when(
      data: (data) => ContextMenuLayout(
        children: [
          for (final playlist in data)
            ContextMenuItem(
              title: Text(playlist.name),
              icon: const Icon(FluentIcons.music_note_1_24_regular),
              onTap: () async {
                try {
                  final controller =
                      ref.read(playlistDetailProvider(playlist.id).notifier);
                  await controller.addTrack([track]);
                  toast(context.strings.addedToPlaylistSuccess);
                } catch (error, stacktrace) {
                  toast(context.formattedError(error));
                  debugPrint('add to playlist failed: $error\n$stacktrace');
                }
              },
            ),
        ],
      ),
      error: (error, stacktrace) => ContextMenuLayout(
        children: [
          Text(context.formattedError(error)),
        ],
      ),
      loading: () => ContextMenuLayout(
        children: [
          ContextMenuItem(
            title: Text(context.strings.loading),
            icon: const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
