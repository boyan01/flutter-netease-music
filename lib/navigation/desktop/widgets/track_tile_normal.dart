import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';
import '../../common/like_button.dart';
import '../../common/navigation_target.dart';
import '../../common/playlist/music_list.dart';
import 'highlight_clickable_text.dart';

class TrackTableContainer extends StatelessWidget {
  const TrackTableContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

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
    Key? key,
    required this.child,
    required this.width,
  }) : super(key: key);

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
    Key? key,
    required Widget child,
    required this.nameWidth,
    required this.artistWidth,
    required this.albumWidth,
    required this.durationWidth,
  }) : super(key: key, child: child);

  final double nameWidth;
  final double artistWidth;
  final double albumWidth;
  final double durationWidth;

  static _TrackTableConfiguration of(BuildContext context) {
    final _TrackTableConfiguration? result =
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

class TrackTableHeader extends StatelessWidget with PreferredSizeWidget {
  const TrackTableHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: context.textTheme.caption!,
      child: SizedBox.fromSize(
        size: preferredSize,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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

class TrackTile extends ConsumerWidget {
  const TrackTile({
    Key? key,
    required this.track,
    required this.index,
  }) : super(key: key);

  final Track track;

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = _TrackTableConfiguration.of(context);
    return SizedBox(
        height: 36,
        child: Material(
          color: index.isEven
              ? context.colorScheme.background
              : context.colorScheme.primary.withOpacity(0.04),
          child: InkWell(
            onTap: () {
              if (track.type == TrackType.noCopyright) {
                toast(context.strings.trackNoCopyright);
                return;
              }
              TrackTileContainer.playTrack(context, track);
            },
            child: DefaultTextStyle(
              style: const TextStyle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      color: context.textTheme.caption?.color,
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
                              ? context.theme.disabledColor
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: configuration.artistWidth,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: MouseHighlightText(
                        style: context.textTheme.caption,
                        highlightStyle: context.textTheme.caption!.copyWith(
                          color: context.textTheme.bodyMedium!.color,
                        ),
                        children: track.artists
                            .map((artist) => MouseHighlightSpan.highlight(
                                  text: artist.name,
                                  onTap: () {
                                    if (artist.id == 0) {
                                      return;
                                    }
                                    ref
                                        .read(navigatorProvider.notifier)
                                        .navigate(NavigationTargetArtistDetail(
                                            artist.id));
                                  },
                                ))
                            .separated(MouseHighlightSpan.normal(text: '/'))
                            .toList(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: configuration.albumWidth,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: HighlightClickableText(
                        text: track.album?.name ?? '',
                        onTap: () {
                          final albumId = track.album?.id;
                          if (albumId == null) {
                            return;
                          }
                          ref
                              .read(navigatorProvider.notifier)
                              .navigate(NavigationTargetAlbumDetail(albumId));
                        },
                        style: context.textTheme.caption,
                        highlightStyle: context.textTheme.caption?.copyWith(
                          color: context.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: configuration.durationWidth,
                    child: Text(
                      track.duration.timeStamp,
                      style: context.textTheme.caption,
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),
        ));
  }
}

class _IndexOrPlayIcon extends ConsumerWidget {
  const _IndexOrPlayIcon({
    Key? key,
    required this.index,
    required this.track,
  }) : super(key: key);

  final int index;
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingListId = ref.watch(playingListProvider).id;
    final playingTrack = ref.watch(playingTrackProvider);
    final isCurrent =
        TrackTileContainer.getPlaylistId(context) == playingListId &&
            playingTrack == track;
    final isPlaying = ref.watch(isPlayingProvider);
    if (isCurrent) {
      return IconTheme(
        data: IconThemeData(
          color: context.colorScheme.primary,
          size: 16,
        ),
        child: isPlaying
            ? const Icon(Icons.volume_up)
            : const Icon(Icons.volume_mute),
      );
    } else {
      return Text(
        index.toString().padLeft(2, '0'),
        style: context.textTheme.caption,
      );
    }
  }
}
