import 'package:flutter/material.dart';
import 'package:quiet/component.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/common/like_button.dart';
import 'package:quiet/navigation/common/playlist/music_list.dart';
import 'package:quiet/repository.dart';

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

class TrackTile extends StatelessWidget {
  const TrackTile({
    Key? key,
    required this.track,
    required this.index,
  }) : super(key: key);

  final Track track;

  final int index;

  @override
  Widget build(BuildContext context) {
    final configuration = _TrackTableConfiguration.of(context);
    return SizedBox(
        height: 36,
        child: Material(
          color: index.isEven
              ? context.colorScheme.background
              : context.colorScheme.primary.withOpacity(0.04),
          child: InkWell(
            onTap: () => TrackTileContainer.playTrack(context, track),
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
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: configuration.nameWidth,
                    child: Text(
                      track.name,
                      overflow: TextOverflow.ellipsis,
                      style:
                          context.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                  ),
                  SizedBox(
                    width: configuration.artistWidth,
                    child: Text(
                      track.artists.map((e) => e.name).join(', '),
                      style: context.textTheme.caption,
                    ),
                  ),
                  SizedBox(
                    width: configuration.albumWidth,
                    child: Text(
                      track.album?.name ?? '',
                      style: context.textTheme.caption,
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

class _IndexOrPlayIcon extends StatelessWidget {
  const _IndexOrPlayIcon({
    Key? key,
    required this.index,
    required this.track,
  }) : super(key: key);

  final int index;
  final Track track;

  @override
  Widget build(BuildContext context) {
    final isCurrent = TrackTileContainer.getPlaylistId(context) ==
            context.playingTrackList.id &&
        context.playingTrack == track;
    final isPlaying = context.isPlaying;
    if (isCurrent) {
      return isPlaying
          ? const Icon(Icons.volume_up, size: 16)
          : const Icon(Icons.volume_mute, size: 16);
    } else {
      return Text(
        index.toString().padLeft(2, '0'),
        style: context.textTheme.caption,
      );
    }
  }
}
